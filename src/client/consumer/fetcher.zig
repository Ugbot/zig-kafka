const std = @import("std");
const SubscriptionState = @import("subscription.zig").SubscriptionState;
const BrokerPool = @import("../../wire/broker_pool.zig").BrokerPool;
const MetadataCache = @import("../metadata/cache.zig").MetadataCache;
const AutoOffsetReset = @import("../config.zig").AutoOffsetReset;
const request_mod = @import("../../wire/request.zig");
const types = @import("kafka_generated").types;
const message_format = @import("message_format.zig");
const RecordPool = @import("record_pool.zig").RecordPool;
const ConsumerMetrics = @import("../metrics.zig").ConsumerMetrics;

const FetchRequest = @import("kafka_generated").fetch_request.FetchRequest;
const FetchTopic = @import("kafka_generated").fetch_request.FetchTopic;
const FetchPartition = @import("kafka_generated").fetch_request.FetchPartition;
const FetchResponse = @import("kafka_generated").fetch_response.FetchResponse;

/// Builds FetchRequests, sends them to broker leaders, and parses responses to extract records.
/// Uses round-robin iteration for fair partition fetching.
pub const Fetcher = struct {
    const Self = @This();
    const MAX_RECORDS = 4096;

    broker_pool: *BrokerPool,
    metadata_cache: *MetadataCache,
    subscription: *SubscriptionState,
    allocator: std.mem.Allocator,

    // Metrics reference
    metrics: *ConsumerMetrics,

    // Configuration
    fetch_min_bytes: i32,
    fetch_max_wait_ms: i32,
    max_partition_fetch_bytes: i32,
    max_poll_records: u32,
    auto_offset_reset: AutoOffsetReset,

    // Round-robin state
    next_partition_idx: usize = 0,

    // Fetched records buffer
    records: [MAX_RECORDS]ConsumerRecord = undefined,
    record_count: usize = 0,

    // Pre-allocated pool for record keys/values (zero-allocation principle)
    record_pool: RecordPool,

    // Track how many records from pool are currently in use
    pool_records_in_use: u32 = 0,

    // Metadata refresh flag (set when fetch errors require metadata update)
    needs_metadata_refresh: std.atomic.Value(bool) = std.atomic.Value(bool).init(false),

    // Metadata refresh flag (set when errors indicate stale metadata)
    metadata_refresh_needed: std.atomic.Value(bool) = std.atomic.Value(bool).init(false),

    pub const ConsumerRecord = struct {
        topic: [249]u8 = undefined,
        topic_len: u8 = 0,
        partition: i32 = 0,
        offset: i64 = 0,
        timestamp: i64 = 0,
        key: ?[]const u8 = null,
        value: []const u8 = &[_]u8{},
        // Note: headers not yet implemented
    };

    pub fn init(
        broker_pool: *BrokerPool,
        metadata_cache: *MetadataCache,
        subscription: *SubscriptionState,
        fetch_min_bytes: i32,
        fetch_max_wait_ms: i32,
        max_partition_fetch_bytes: i32,
        max_poll_records: u32,
        auto_offset_reset: AutoOffsetReset,
        metrics: *ConsumerMetrics,
        allocator: std.mem.Allocator,
    ) !Self {
        return .{
            .broker_pool = broker_pool,
            .metadata_cache = metadata_cache,
            .subscription = subscription,
            .metrics = metrics,
            .fetch_min_bytes = fetch_min_bytes,
            .fetch_max_wait_ms = fetch_max_wait_ms,
            .max_partition_fetch_bytes = max_partition_fetch_bytes,
            .max_poll_records = max_poll_records,
            .auto_offset_reset = auto_offset_reset,
            .allocator = allocator,
            .record_pool = try RecordPool.init(allocator),
        };
    }

    pub fn deinit(self: *Self) void {
        self.record_pool.deinit();
    }


    /// Check if all assigned partitions have non-zero topic UUIDs.
    /// Required for Fetch API v13+ which uses UUIDs instead of names.
    /// Follows librdkafka pattern: cap at v12 if ANY partition lacks UUID.
    fn canUseTopicIds(self: *Self) bool {
        var active_count: usize = 0;
        for (self.subscription.assigned_partitions[0..self.subscription.assigned_count]) |*part| {
            if (!part.active) continue;
            active_count += 1;

            const topic_name = part.topic[0..part.topic_len];
            const topic_info = self.metadata_cache.getTopic(topic_name) orelse return false;

            // Check if topic_id is all zeros (not available)
            const is_zero = std.mem.allEqual(u8, &topic_info.topic_id, 0);
            if (is_zero) return false;
        }

        // If no active partitions, can't use topic IDs (return false to be safe)
        if (active_count == 0) return false;

        return true;
    }

    /// Build and send FetchRequest for assigned partitions, parse response.
    /// Returns slice of fetched records (valid until next fetch() call).
    pub fn fetch(self: *Self, timeout_ms: i64) ![]ConsumerRecord {
        std.debug.print("[FETCH] Starting fetch, timeout={d}ms, assigned_count={d}\n", .{ timeout_ms, self.subscription.assigned_count });
        const start_ms = std.time.milliTimestamp();

        // Release previous batch's records back to pool
        if (self.pool_records_in_use > 0) {
            self.record_pool.releaseAll(self.pool_records_in_use);
            self.pool_records_in_use = 0;
        }

        self.record_count = 0;

        // Group assigned partitions by leader broker
        var broker_partitions = std.AutoHashMap(i32, std.array_list.Managed(PartitionToFetch)).init(self.allocator);
        defer {
            var it = broker_partitions.iterator();
            while (it.next()) |entry| {
                entry.value_ptr.deinit();
            }
            broker_partitions.deinit();
        }

        // Iterate partitions starting from next_partition_idx (round-robin)
        var count: usize = 0;
        const total = self.subscription.assigned_count;
        while (count < total) : (count += 1) {
            const idx = (self.next_partition_idx + count) % total;
            const part = &self.subscription.assigned_partitions[idx];

            if (!part.active) continue;
            if (self.subscription.isPaused(part.topic[0..part.topic_len], part.partition)) continue;
            if (part.fetch_offset < 0) continue; // No fetch position set yet

            const topic_name = part.topic[0..part.topic_len];

            // Get leader for this partition
            const leader_id = self.metadata_cache.getLeader(topic_name, part.partition);
            if (leader_id < 0) continue; // No leader known

            // Add to broker's partition list
            const gop = try broker_partitions.getOrPut(leader_id);
            if (!gop.found_existing) {
                gop.value_ptr.* = std.array_list.Managed(PartitionToFetch).init(self.allocator);
            }

            try gop.value_ptr.append(.{
                .topic = topic_name,
                .partition = part.partition,
                .fetch_offset = part.fetch_offset,
                .leader_epoch = part.fetch_epoch,
            });
        }

        // Update round-robin index for next call
        self.next_partition_idx = (self.next_partition_idx + total) % @max(total, 1);

        // Send FetchRequest to each broker
        std.debug.print("[FETCH] Grouped into {d} broker(s)\n", .{broker_partitions.count()});
        var broker_it = broker_partitions.iterator();
        while (broker_it.next()) |entry| {
            // Check if timeout exceeded
            const elapsed_ms = std.time.milliTimestamp() - start_ms;
            if (elapsed_ms >= timeout_ms) break;

            const broker_id = entry.key_ptr.*;
            const partitions = entry.value_ptr.items;
            std.debug.print("[FETCH] Fetching from broker {d} for {d} partition(s)\n", .{ broker_id, partitions.len });

            try self.fetchFromBroker(broker_id, partitions);

            // Stop if we've reached max_poll_records
            if (self.record_count >= self.max_poll_records) break;
        }

        return self.records[0..self.record_count];
    }

    /// Fetch from a single broker for the given partitions.
    fn fetchFromBroker(
        self: *Self,
        broker_id: i32,
        partitions: []const PartitionToFetch,
    ) !void {
        const start_ms = std.time.milliTimestamp();
        const conn = try self.broker_pool.getConnection(broker_id);

        // Use negotiated version for Fetch API (key=1)
        // Support up to v16 (latest as of Kafka 3.8)
        const api_versions = @import("../../wire/api_versions.zig");
        var negotiated_version = api_versions.selectVersion(conn, 1, 0, 16) orelse {
            std.debug.print("[FETCH] Broker doesn't support Fetch API\n", .{});
            return error.UnsupportedApiVersion;
        };

        // Fallback to v12 if topic IDs not available (v13+ requires UUIDs)
        // This follows librdkafka's pattern: cap at v12 when any partition lacks topic UUID
        if (negotiated_version > 12 and !self.canUseTopicIds()) {
            std.debug.print("[FETCH] Topic IDs not available, capping at v12 (negotiated was v{d})\n", .{negotiated_version});
            negotiated_version = 12;
        }


        // Build FetchRequest
        var req = FetchRequest.default();
        req.max_wait_ms = self.fetch_max_wait_ms;
        req.min_bytes = self.fetch_min_bytes;

        // Group partitions by topic
        var topic_map = std.StringHashMap(std.array_list.Managed(FetchPartition)).init(self.allocator);
        defer {
            var it = topic_map.iterator();
            while (it.next()) |entry| {
                entry.value_ptr.deinit();
            }
            topic_map.deinit();
        }

        for (partitions) |part| {
            std.debug.print("[FETCH] Adding partition: topic={s} partition={d} offset={d}\n", .{ part.topic, part.partition, part.fetch_offset });

            const gop = try topic_map.getOrPut(part.topic);
            if (!gop.found_existing) {
                gop.value_ptr.* = std.array_list.Managed(FetchPartition).init(self.allocator);
            }

            try gop.value_ptr.append(.{
                .partition = part.partition,
                .fetch_offset = part.fetch_offset,
                .partition_max_bytes = self.max_partition_fetch_bytes,
            });
        }

        // Build topics array
        var topics_list = std.array_list.Managed(FetchTopic).init(self.allocator);
        defer topics_list.deinit();

        var it = topic_map.iterator();
        while (it.next()) |entry| {
            const topic_partitions = try entry.value_ptr.toOwnedSlice();
            const topic_name = entry.key_ptr.*;

            if (negotiated_version > 12) {
                // v13+: Use topic UUIDs
                const topic_info = self.metadata_cache.getTopic(topic_name) orelse {
                    std.debug.print("[FETCH] Warning: No metadata for topic {s}, skipping\n", .{topic_name});
                    self.allocator.free(topic_partitions);
                    continue;
                };
                try topics_list.append(.{
                    .topic_id = topic_info.topic_id,
                    .partitions = topic_partitions,
                });
            } else {
                // v0-12: Use topic names
                try topics_list.append(.{
                    .topic = topic_name,
                    .partitions = topic_partitions,
                });
            }
        }

        req.topics = try topics_list.toOwnedSlice();
        defer {
            for (req.topics.?) |topic| {
                self.allocator.free(topic.partitions.?);
            }
            self.allocator.free(req.topics.?);
        }

        std.debug.print("[FETCH] FetchRequest: max_wait={d}ms, min_bytes={d}, topics.len={d}\n", .{
            req.max_wait_ms,
            req.min_bytes,
            req.topics.?.len,
        });
        if (req.topics) |topics| {
            for (topics) |topic| {
                std.debug.print("[FETCH]   Topic: {s}, partitions.len={d}\n", .{ topic.topic, topic.partitions.?.len });
                if (topic.partitions) |parts| {
                    for (parts) |p| {
                        std.debug.print("[FETCH]     Partition {d}: offset={d}, max_bytes={d}\n", .{
                            p.partition,
                            p.fetch_offset,
                            p.partition_max_bytes,
                        });
                    }
                }
            }
        }

        // Send request
        const resp_size = conn.sendRequest(1, negotiated_version, req) catch |err| {
            self.metrics.recordFetchError();
            return err;
        };

        // Parse response
        self.parseFetchResponseWithVersion(conn.recv_buf[0..resp_size], negotiated_version) catch |err| {
            self.metrics.recordFetchError();
            return err;
        };

        // Record successful fetch
        const latency_ms: u64 = @intCast(std.time.milliTimestamp() - start_ms);
        self.metrics.recordFetchRequest(latency_ms);
    }

    /// Parse FetchResponse and extract records.
    fn parseFetchResponseWithVersion(self: *Self, data: []const u8, version: i16) !void {
        std.debug.print("[PARSE] Response size={d}, version={d}\n", .{ data.len, version });

        // Use arena allocator for response decoding (zero-leak principle)
        // All allocated strings (topic names, etc.) freed when arena is freed
        var arena = std.heap.ArenaAllocator.init(self.allocator);
        defer arena.deinit();
        const arena_allocator = arena.allocator();

        // Dump all bytes in hex for debugging
        std.debug.print("[PARSE] All {d} bytes:\n", .{data.len});
        var i: usize = 0;
        while (i < data.len) : (i += 16) {
            const end = @min(i + 16, data.len);
            std.debug.print("  [{d:4}]: ", .{i});
            for (data[i..end]) |byte| {
                std.debug.print("{x:0>2} ", .{byte});
            }
            std.debug.print("\n", .{});
        }

        // Skip 4-byte size prefix + response header
        const resp_header_ver = request_mod.responseHeaderVersion(1, version);
        var stream = std.io.fixedBufferStream(data[4..]);
        const reader = stream.reader();

        std.debug.print("[PARSE] After skipping size prefix, bytes available={d}\n", .{ data.len - 4 });

        // Skip response header
        const corr_id = try types.decodeInt32(reader);
        std.debug.print("[PARSE] Correlation ID={d}, response header version={d}\n", .{ corr_id, resp_header_ver });

        if (resp_header_ver >= 1) {
            const tag_count = try types.decodeUnsignedVarInt(reader);
            std.debug.print("[PARSE] Tagged fields count={d}\n", .{tag_count});
        }

        std.debug.print("[PARSE] About to decode FetchResponse body, stream pos={d}\n", .{stream.pos});

        // Decode using arena allocator - all memory freed at end of function
        const resp = try FetchResponse.decode(reader, version, arena_allocator);

        std.debug.print("[PARSE] FetchResponse decoded: throttle={d}ms, error={d}, session_id={d}\n", .{
            resp.throttle_time_ms,
            resp.error_code,
            resp.session_id,
        });

        if (resp.responses) |topics| {
            std.debug.print("[PARSE] Response has {d} topic(s)\n", .{topics.len});
            std.debug.print("[PARSE] Response has {d} topics\n", .{topics.len});
            for (topics) |topic_resp| {
                // Resolve topic name (v13+ uses UUIDs, v0-12 uses names)
                const topic_name = if (version > 12) blk: {
                    // v13+: Look up topic name by UUID
                    const topic_info = self.metadata_cache.getTopicByUuid(topic_resp.topic_id) orelse {
                        std.log.warn("Unknown topic UUID in fetch response, skipping", .{});
                        continue;
                    };
                    break :blk topic_info.name();
                } else topic_resp.topic;

                std.debug.print("[PARSE] Topic: {s}\n", .{topic_name});

                if (topic_resp.partitions) |partitions| {
                    std.debug.print("[PARSE]   {d} partition(s)\n", .{partitions.len});
                    for (partitions) |partition| {
                        std.debug.print("[PARSE]   Partition {d}: error={d}, hwm={d}, records={any}\n", .{
                            partition.partition_index,
                            partition.error_code,
                            partition.high_watermark,
                            partition.records != null,
                        });
                        // Handle errors
                        if (partition.error_code != 0) {
                            try self.handleFetchError(
                                topic_name,
                                partition.partition_index,
                                partition.error_code,
                            );
                            continue;
                        }

                        // Update high water mark
                        if (partition.high_watermark >= 0) {
                            self.subscription.updateHighWaterMark(
                                topic_name,
                                partition.partition_index,
                                partition.high_watermark,
                            ) catch {};
                        }

                        // Parse records if present
                        if (partition.records) |records_bytes| {
                            if (records_bytes.len == 0) continue;

                            // Parse RecordBatch using existing message_format.zig
                            const messages = message_format.parseRecordBatch(
                                self.allocator,
                                records_bytes,
                            ) catch |err| {
                                std.log.warn("Failed to parse RecordBatch for {s}-{d}: {any}", .{
                                    topic_name,
                                    partition.partition_index,
                                    err,
                                });
                                continue;
                            };
                            defer self.allocator.free(messages); // Free the array container

                            // Convert TickStreamMessage to ConsumerRecord using record pool
                            for (messages) |msg| {
                                // Stop if max_poll_records reached
                                if (self.record_count >= self.max_poll_records) {
                                    return;
                                }

                                // Allocate slot in record pool
                                const pool_idx = self.record_pool.alloc() catch {
                                    std.log.warn("Record pool exhausted, stopping fetch", .{});
                                    return;
                                };
                                self.pool_records_in_use += 1;

                                // Copy key and value into pool buffers
                                const pool_key = if (msg.key) |k| blk: {
                                    break :blk self.record_pool.setKey(pool_idx, k) catch {
                                        std.log.warn("Key too large for pool, truncating", .{});
                                        break :blk try self.record_pool.setKey(pool_idx, k[0..@min(k.len, RecordPool.MAX_KEY_SIZE)]);
                                    };
                                } else
                                    try self.record_pool.setKey(pool_idx, null);

                                const pool_value = self.record_pool.setValue(pool_idx, msg.value) catch {
                                    std.log.warn("Value too large for pool: {} bytes, max={}", .{ msg.value.len, RecordPool.MAX_VALUE_SIZE });
                                    return error.ValueTooLarge;
                                };

                                // Build ConsumerRecord pointing to pool buffers
                                var record = &self.records[self.record_count];
                                const topic_len = @min(topic_name.len, 249);
                                @memcpy(record.topic[0..topic_len], topic_name[0..topic_len]);
                                record.topic_len = @intCast(topic_len);

                                record.partition = partition.partition_index;
                                record.offset = msg.offset;
                                record.timestamp = msg.timestamp;
                                record.key = if (msg.key != null) pool_key else null;
                                record.value = pool_value;

                                self.record_count += 1;

                                // Update fetch offset for next fetch (offset + 1)
                                self.subscription.updateFetchPosition(
                                    topic_name,
                                    partition.partition_index,
                                    msg.offset + 1,
                                ) catch {};
                            }
                        }

                        // Stop if max_poll_records reached
                        if (self.record_count >= self.max_poll_records) return;
                    }
                }
            }
        } else {
            std.debug.print("[PARSE] Response.responses is NULL (fetch session in use, no changes)\n", .{});
        }
    }

    /// Handle Fetch errors by logging and potentially seeking.
    fn handleFetchError(self: *Self, topic: []const u8, partition: i32, error_code: i16) !void {
        switch (error_code) {
            1 => { // OFFSET_OUT_OF_RANGE
                std.debug.print("[FETCH] OFFSET_OUT_OF_RANGE for {s}-{d}, auto-reset={s}\n", .{ topic, partition, @tagName(self.auto_offset_reset) });
                switch (self.auto_offset_reset) {
                    .earliest => {
                        const offset = try self.getEarliestOffset(topic, partition);
                        try self.seekPartition(topic, partition, offset);
                        std.debug.print("[FETCH] Auto-seeked to earliest offset {d}\n", .{offset});
                        self.metrics.recordAutoSeek(.earliest);
                    },
                    .latest => {
                        const offset = try self.getLatestOffset(topic, partition);
                        try self.seekPartition(topic, partition, offset);
                        std.debug.print("[FETCH] Auto-seeked to latest offset {d}\n", .{offset});
                        self.metrics.recordAutoSeek(.latest);
                    },
                    .none => {
                        std.debug.print("[FETCH] auto.offset.reset=none, cannot recover\n", .{});
                        return error.OffsetOutOfRange;
                    },
                }
            },
            6 => { // NOT_LEADER_OR_FOLLOWER
                std.debug.print("[FETCH] NOT_LEADER_OR_FOLLOWER for {s}-{d}, marking metadata stale\n", .{ topic, partition });
                self.needs_metadata_refresh.store(true, .release);
                self.invalidateTopicCache(topic);
            },
            13 => { // UNKNOWN_LEADER_EPOCH
                std.debug.print("[FETCH] UNKNOWN_LEADER_EPOCH for {s}-{d}, marking metadata stale\n", .{ topic, partition });
                self.needs_metadata_refresh.store(true, .release);
                self.invalidateTopicCache(topic);
            },
            3 => { // UNKNOWN_TOPIC_OR_PARTITION
                std.debug.print("[FETCH] UNKNOWN_TOPIC_OR_PARTITION for {s}-{d}, marking metadata stale\n", .{ topic, partition });
                self.needs_metadata_refresh.store(true, .release);
                self.invalidateTopicCache(topic);
            },
            78 => { // OFFSET_NOT_AVAILABLE
                std.log.debug("OFFSET_NOT_AVAILABLE for {s}-{d}, will retry", .{ topic, partition });
                // Transient error, next fetch will work
            },
            else => {
                std.log.warn("Fetch error {d} for {s}-{d}", .{ error_code, topic, partition });
            },
        }
    }

    /// Get the earliest available offset for a partition using ListOffsets API.
    pub fn getEarliestOffset(self: *Self, topic: []const u8, partition: i32) !i64 {
        return try self.listOffsets(topic, partition, -2); // -2 = earliest
    }

    /// Get the latest available offset for a partition using ListOffsets API.
    pub fn getLatestOffset(self: *Self, topic: []const u8, partition: i32) !i64 {
        return try self.listOffsets(topic, partition, -1); // -1 = latest
    }

    /// Call ListOffsets API to get offset for a timestamp.
    /// Special timestamps: -2 = earliest, -1 = latest
    pub fn listOffsets(self: *Self, topic: []const u8, partition: i32, timestamp: i64) !i64 {
        // Get leader broker for this partition
        const topic_info = self.metadata_cache.getTopic(topic) orelse return error.TopicNotFound;

        var leader_id: ?i32 = null;
        for (topic_info.partitions) |part| {
            if (part.id == partition) {
                leader_id = part.leader_id;
                break;
            }
        }

        if (leader_id == null) return error.PartitionNotFound;

        const conn = try self.broker_pool.getConnection(leader_id.?);

        // Use ListOffsets API (key=2)
        const ListOffsetsRequest = @import("kafka_generated").list_offsets_request.ListOffsetsRequest;
        const ListOffsetsTopic = @import("kafka_generated").list_offsets_request.ListOffsetsTopic;
        const ListOffsetsPartition = @import("kafka_generated").list_offsets_request.ListOffsetsPartition;
        const ListOffsetsResponse = @import("kafka_generated").list_offsets_response.ListOffsetsResponse;

        // Negotiate API version (v0-v8)
        const api_versions = @import("../../wire/api_versions.zig");
        const negotiated_version = api_versions.selectVersion(conn, 2, 0, 8) orelse {
            return error.UnsupportedApiVersion;
        };

        // Use arena for request allocation
        var arena = std.heap.ArenaAllocator.init(self.allocator);
        defer arena.deinit();

        var partitions_array = try arena.allocator().alloc(ListOffsetsPartition, 1);
        partitions_array[0] = .{
            .partition_index = partition,
            .timestamp = timestamp,
        };

        var topics_array = try arena.allocator().alloc(ListOffsetsTopic, 1);
        topics_array[0] = .{
            .name = topic,
            .partitions = partitions_array,
        };

        var req = ListOffsetsRequest.default();
        req.replica_id = -1; // Consumer
        req.isolation_level = 0; // READ_UNCOMMITTED
        req.topics = topics_array;

        const resp_size = try conn.sendRequest(2, negotiated_version, req);

        const resp_header_ver = request_mod.responseHeaderVersion(2, negotiated_version);
        var stream = std.io.fixedBufferStream(conn.recv_buf[4..resp_size]);
        const reader = stream.reader();

        _ = try types.decodeInt32(reader);
        if (resp_header_ver >= 1) {
            _ = try types.decodeUnsignedVarInt(reader);
        }

        const resp = try ListOffsetsResponse.decode(reader, negotiated_version, arena.allocator());

        // Extract offset from response
        if (resp.topics) |topics| {
            if (topics.len > 0) {
                if (topics[0].partitions) |partitions| {
                    if (partitions.len > 0) {
                        const part_resp = partitions[0];
                        if (part_resp.error_code != 0) {
                            std.debug.print("[FETCH] ListOffsets error: {d}\n", .{part_resp.error_code});
                            return error.ListOffsetsFailed;
                        }
                        return part_resp.offset;
                    }
                }
            }
        }

        return error.NoOffsetReturned;
    }

    /// Seek a partition to a specific offset.
    fn seekPartition(self: *Self, topic: []const u8, partition: i32, offset: i64) !void {
        for (self.subscription.assigned_partitions[0..self.subscription.assigned_count]) |*part| {
            if (!part.active) continue;
            const part_topic = part.topic[0..part.topic_len];
            if (std.mem.eql(u8, part_topic, topic) and part.partition == partition) {
                part.fetch_offset = offset;
                std.debug.print("[FETCH] Seeked {s}-{d} to offset {d}\n", .{ topic, partition, offset });
                return;
            }
        }
        return error.PartitionNotAssigned;
    }

    /// Invalidate cached metadata for a topic to force refresh on next fetch.
    fn invalidateTopicCache(self: *Self, topic: []const u8) void {
        // Mark the topic as needing fresh metadata
        // The metadata cache will be refreshed by the consumer
        _ = self;
        _ = topic;
        // Note: We set the needs_metadata_refresh flag, which the consumer checks
    }

    /// Check if metadata refresh is needed and clear the flag.
    pub fn checkAndClearMetadataRefresh(self: *Self) bool {
        return self.needs_metadata_refresh.swap(false, .acq_rel);
    }

    const PartitionToFetch = struct {
        topic: []const u8,
        partition: i32,
        fetch_offset: i64,
        leader_epoch: i32,
    };
};

// ============================================================================
// Helper: Subscription state needs updateHighWaterMark
// ============================================================================

// Note: This would be added to subscription.zig:
// pub fn updateHighWaterMark(self: *Self, topic: []const u8, partition: i32, hwm: i64) !void {
//     for (self.assigned_partitions[0..self.assigned_count]) |*part| {
//         if (!part.active) continue;
//         const name = part.topic[0..part.topic_len];
//         if (std.mem.eql(u8, name, topic) and part.partition == partition) {
//             part.high_watermark = hwm;
//             return;
//         }
//     }
//     return error.PartitionNotAssigned;
// }

// ============================================================================
// Tests
// ============================================================================

test "Fetcher init" {
    const allocator = std.testing.allocator;

    var broker_pool = BrokerPool.init(allocator);

    var metadata = MetadataCache{};

    var subscription = @import("subscription.zig").SubscriptionState.init(allocator);
    defer subscription.deinit();

    var fetcher = try Fetcher.init(
        &broker_pool,
        &metadata,
        &subscription,
        1,
        500,
        1024 * 1024,
        500,
        allocator,
    );
    defer fetcher.deinit();

    try std.testing.expectEqual(@as(i32, 1), fetcher.fetch_min_bytes);
    try std.testing.expectEqual(@as(i32, 500), fetcher.fetch_max_wait_ms);
    try std.testing.expectEqual(@as(u32, 500), fetcher.max_poll_records);
}

test "Fetcher with no assigned partitions returns empty" {
    const allocator = std.testing.allocator;

    var broker_pool = BrokerPool.init(allocator);

    var metadata = MetadataCache{};

    var subscription = @import("subscription.zig").SubscriptionState.init(allocator);
    defer subscription.deinit();

    var fetcher = try Fetcher.init(
        &broker_pool,
        &metadata,
        &subscription,
        1,
        500,
        1024 * 1024,
        500,
        allocator,
    );
    defer fetcher.deinit();

    const records = try fetcher.fetch(1000);
    try std.testing.expectEqual(@as(usize, 0), records.len);
}

test "canUseTopicIds returns false when topic has zero UUID" {
    const allocator = std.testing.allocator;
    const tp = @import("../metadata/topic_partition.zig");

    var broker_pool = BrokerPool.init(allocator);
    var metadata = MetadataCache{};
    var subscription = @import("subscription.zig").SubscriptionState.init(allocator);
    defer subscription.deinit();

    // Add topic with zero UUID (default)
    const cache = @import("../metadata/cache.zig");
    var parts = [_]cache.PartitionEntry{
        .{ .id = 0, .leader_id = 1 },
    };
    metadata.updateTopic("test-topic", &parts);

    // Assign partition
    const topic_parts = [_]tp.TopicPartition{
        .{ .topic = "test-topic", .partition = 0 },
    };
    try subscription.assignPartitions(&topic_parts);

    var fetcher = try Fetcher.init(&broker_pool, &metadata, &subscription, 1, 500, 1048576, 500, allocator);
    defer fetcher.deinit();

    // Should return false - topic has zero UUID
    try std.testing.expect(!fetcher.canUseTopicIds());
}

test "canUseTopicIds returns true when all topics have non-zero UUIDs" {
    const allocator = std.testing.allocator;
    const tp = @import("../metadata/topic_partition.zig");

    var broker_pool = BrokerPool.init(allocator);
    var metadata = MetadataCache{};
    var subscription = @import("subscription.zig").SubscriptionState.init(allocator);
    defer subscription.deinit();

    // Add topic
    const cache = @import("../metadata/cache.zig");
    var parts = [_]cache.PartitionEntry{
        .{ .id = 0, .leader_id = 1 },
    };
    metadata.updateTopic("test-topic", &parts);

    // Set non-zero UUID
    const test_uuid = [_]u8{ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16 };
    for (&metadata.topics) |*slot| {
        if (slot.*) |*topic| {
            if (std.mem.eql(u8, topic.name(), "test-topic")) {
                topic.topic_id = test_uuid;
                break;
            }
        }
    }

    // Assign partition
    const topic_parts = [_]tp.TopicPartition{
        .{ .topic = "test-topic", .partition = 0 },
    };
    try subscription.assignPartitions(&topic_parts);

    var fetcher = try Fetcher.init(&broker_pool, &metadata, &subscription, 1, 500, 1048576, 500, allocator);
    defer fetcher.deinit();

    // Should return true - topic has non-zero UUID
    try std.testing.expect(fetcher.canUseTopicIds());
}

test "canUseTopicIds returns false when any topic lacks UUID" {
    const allocator = std.testing.allocator;
    const tp = @import("../metadata/topic_partition.zig");

    var broker_pool = BrokerPool.init(allocator);
    var metadata = MetadataCache{};
    var subscription = @import("subscription.zig").SubscriptionState.init(allocator);
    defer subscription.deinit();

    // Add two topics
    const cache = @import("../metadata/cache.zig");
    var parts = [_]cache.PartitionEntry{
        .{ .id = 0, .leader_id = 1 },
    };
    metadata.updateTopic("topic-with-uuid", &parts);
    metadata.updateTopic("topic-without-uuid", &parts);

    // Set UUID for first topic only
    const test_uuid = [_]u8{ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16 };
    for (&metadata.topics) |*slot| {
        if (slot.*) |*topic| {
            if (std.mem.eql(u8, topic.name(), "topic-with-uuid")) {
                topic.topic_id = test_uuid;
                break;
            }
        }
    }

    // Assign both partitions
    const topic_parts = [_]tp.TopicPartition{
        .{ .topic = "topic-with-uuid", .partition = 0 },
        .{ .topic = "topic-without-uuid", .partition = 0 },
    };
    try subscription.assignPartitions(&topic_parts);

    var fetcher = try Fetcher.init(&broker_pool, &metadata, &subscription, 1, 500, 1048576, 500, allocator);
    defer fetcher.deinit();

    // Should return false - one topic lacks UUID
    try std.testing.expect(!fetcher.canUseTopicIds());
}
