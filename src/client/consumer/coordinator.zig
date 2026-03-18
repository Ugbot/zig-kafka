const std = @import("std");
const SubscriptionState = @import("subscription.zig").SubscriptionState;
const BrokerPool = @import("../../wire/broker_pool.zig").BrokerPool;
const MetadataCache = @import("../metadata/cache.zig").MetadataCache;
const Assignor = @import("assignor.zig").Assignor;
const TopicPartition = @import("../metadata/topic_partition.zig").TopicPartition;
const request_mod = @import("../../wire/request.zig");
const types = @import("kafka_generated").types;
const ConsumerMetrics = @import("../metrics.zig").ConsumerMetrics;

const FindCoordinatorRequest = @import("kafka_generated").find_coordinator_request.FindCoordinatorRequest;
const FindCoordinatorResponse = @import("kafka_generated").find_coordinator_response.FindCoordinatorResponse;
const JoinGroupRequest = @import("kafka_generated").join_group_request.JoinGroupRequest;
const JoinGroupRequestProtocol = @import("kafka_generated").join_group_request.JoinGroupRequestProtocol;
const JoinGroupResponse = @import("kafka_generated").join_group_response.JoinGroupResponse;
const SyncGroupRequest = @import("kafka_generated").sync_group_request.SyncGroupRequest;
const SyncGroupRequestAssignment = @import("kafka_generated").sync_group_request.SyncGroupRequestAssignment;
const SyncGroupResponse = @import("kafka_generated").sync_group_response.SyncGroupResponse;
const HeartbeatRequest = @import("kafka_generated").heartbeat_request.HeartbeatRequest;
const HeartbeatResponse = @import("kafka_generated").heartbeat_response.HeartbeatResponse;
const LeaveGroupRequest = @import("kafka_generated").leave_group_request.LeaveGroupRequest;

/// Group coordinator state machine.
/// Implements coordinator discovery, join/sync protocol, and heartbeat thread.
pub const GroupCoordinator = struct {
    const Self = @This();

    allocator: std.mem.Allocator,
    broker_pool: *BrokerPool,
    metadata_cache: *MetadataCache,
    subscription: *SubscriptionState,
    assignor: *const Assignor,

    // Metrics reference (optional)
    metrics: ?*ConsumerMetrics = null,

    // Configuration
    group_id: []const u8,
    session_timeout_ms: i32,
    heartbeat_interval_ms: i32,
    max_poll_interval_ms: i32,

    // Coordinator state
    coord_state: CoordState = .init,
    coord_broker_id: i32 = -1,

    // Join state
    join_state: JoinState = .init,
    member_id_buf: [256]u8 = undefined,
    member_id_len: u8 = 0,
    generation_id: i32 = -1,
    is_leader: bool = false,

    // Heartbeat thread
    heartbeat_thread: ?std.Thread = null,
    heartbeat_running: std.atomic.Value(bool) = std.atomic.Value(bool).init(false),
    last_heartbeat_ms: std.atomic.Value(i64) = std.atomic.Value(i64).init(0),

    // Rebalance event queue (lock-free SPSC)
    rebalance_events: [16]RebalanceEvent = undefined,
    rebalance_head: std.atomic.Value(u32) = std.atomic.Value(u32).init(0),
    rebalance_tail: std.atomic.Value(u32) = std.atomic.Value(u32).init(0),

    // API versions
    find_coordinator_version: i16 = 4,
    join_group_version: i16 = 7,
    sync_group_version: i16 = 5,
    heartbeat_version: i16 = 4,

    pub const CoordState = enum {
        init,
        query_coord,
        wait_coord,
        wait_broker,
        up,
        term,
    };

    pub const JoinState = enum {
        init,
        wait_join,
        wait_metadata,
        wait_sync,
        steady,
    };

    pub const RebalanceEvent = enum {
        revoke_start,
        revoke_complete,
        assign_start,
        assign_complete,
    };

    /// Set metrics reference (called from consumer).
    pub fn setMetrics(self: *Self, metrics: *ConsumerMetrics) void {
        self.metrics = metrics;
    }

    pub fn init(
        allocator: std.mem.Allocator,
        broker_pool: *BrokerPool,
        metadata_cache: *MetadataCache,
        subscription: *SubscriptionState,
        assignor: *const Assignor,
        group_id: []const u8,
        session_timeout_ms: i32,
        heartbeat_interval_ms: i32,
        max_poll_interval_ms: i32,
    ) Self {
        return .{
            .allocator = allocator,
            .broker_pool = broker_pool,
            .metadata_cache = metadata_cache,
            .subscription = subscription,
            .assignor = assignor,
            .group_id = group_id,
            .session_timeout_ms = session_timeout_ms,
            .heartbeat_interval_ms = heartbeat_interval_ms,
            .max_poll_interval_ms = max_poll_interval_ms,
        };
    }

    pub fn deinit(self: *Self) void {
        self.stop();
    }

    /// Start coordinator discovery and join protocol.
    pub fn start(self: *Self) !void {
        // Find coordinator
        try self.findCoordinator();

        // Join group
        try self.joinGroup();

        // Start heartbeat thread
        self.heartbeat_running.store(true, .release);
        self.heartbeat_thread = try std.Thread.spawn(.{}, heartbeatLoop, .{self});
    }

    /// Stop heartbeat thread and leave group.
    pub fn stop(self: *Self) void {
        self.heartbeat_running.store(false, .release);

        if (self.heartbeat_thread) |t| {
            t.join();
            self.heartbeat_thread = null;
        }

        // Leave group if joined
        if (self.coord_broker_id >= 0 and self.member_id_len > 0) {
            self.leaveGroup() catch {};
        }

        self.coord_state = .term;
        self.join_state = .init;
    }

    /// Poll for rebalance events (non-blocking).
    pub fn pollRebalanceEvent(self: *Self) ?RebalanceEvent {
        const head = self.rebalance_head.load(.acquire);
        const tail = self.rebalance_tail.load(.acquire);

        if (head == tail) return null; // Empty

        const event = self.rebalance_events[head % 16];
        self.rebalance_head.store((head + 1) % 16, .release);

        return event;
    }

    /// Find the group coordinator broker.
    fn findCoordinator(self: *Self) !void {
        self.coord_state = .query_coord;

        // Use arena allocator for response decoding (zero-leak)
        var arena = std.heap.ArenaAllocator.init(self.allocator);
        defer arena.deinit();

        // Use any broker from the pool to find coordinator
        const conn = try self.broker_pool.getAnyBroker();

        // Negotiate API version for FindCoordinator (key=10, v0-v4)
        const api_versions = @import("../../wire/api_versions.zig");
        const negotiated_version = api_versions.selectVersion(conn, 10, 0, 4) orelse {
            std.debug.print("[COORDINATOR] Broker doesn't support FindCoordinator API\n", .{});
            return error.UnsupportedApiVersion;
        };
        std.debug.print("[COORDINATOR] Using FindCoordinator v{d}\n", .{negotiated_version});

        var req = FindCoordinatorRequest.default();
        req.key = self.group_id;
        req.key_type = 0; // 0 = consumer group

        const resp_size = try conn.sendRequest(10, negotiated_version, req);

        // Parse response
        const resp_header_ver = request_mod.responseHeaderVersion(10, negotiated_version);
        var stream = std.io.fixedBufferStream(conn.recv_buf[4..resp_size]);
        const reader = stream.reader();

        _ = try types.decodeInt32(reader); // correlation_id
        if (resp_header_ver >= 1) {
            _ = try types.decodeUnsignedVarInt(reader); // tagged fields
        }

        const resp = try FindCoordinatorResponse.decode(reader, negotiated_version, arena.allocator());

        if (resp.error_code != 0) {
            return error.FindCoordinatorFailed;
        }

        self.coord_broker_id = resp.node_id;
        self.coord_state = .up;
    }

    /// Join the consumer group.
    fn joinGroup(self: *Self) !void {
        if (self.coord_broker_id < 0) return error.CoordinatorNotAvailable;

        self.join_state = .wait_join;

        const conn = try self.broker_pool.getConnection(self.coord_broker_id);

        // Negotiate API version for JoinGroup (key=11, v0-v9)
        // Try v0-v5 first, fall back to v2 if we get UNSUPPORTED_ASSIGNOR
        const api_versions = @import("../../wire/api_versions.zig");
        var negotiated_version = api_versions.selectVersion(conn, 11, 0, 5) orelse {
            std.debug.print("[COORDINATOR] Broker doesn't support JoinGroup API\n", .{});
            return error.UnsupportedApiVersion;
        };

        // Try JoinGroup with negotiated version
        const error_code = self.joinGroupAttempt(conn, negotiated_version) catch |err| {
            return err;
        };

        // If we get UNSUPPORTED_ASSIGNOR with v3+, fall back to v2
        if (error_code == 79 and negotiated_version > 2) {
            std.debug.print("[COORDINATOR] JoinGroup v{d} returned UNSUPPORTED_ASSIGNOR, falling back to v2\n", .{negotiated_version});
            negotiated_version = 2;
            const retry_error = self.joinGroupAttempt(conn, negotiated_version) catch |err| {
                return err;
            };
            if (retry_error != 0) {
                std.debug.print("[COORDINATOR] JoinGroup v2 also failed with error_code={d}\n", .{retry_error});
                return error.JoinGroupFailed;
            }
        } else if (error_code != 0) {
            std.debug.print("[COORDINATOR] JoinGroup error_code={d}\n", .{error_code});
            return error.JoinGroupFailed;
        }

        std.debug.print("[COORDINATOR] JoinGroup succeeded with v{d}\n", .{negotiated_version});
    }

    /// Attempt to join group with a specific API version.
    /// Returns the error_code from the response (0 = success).
    fn joinGroupAttempt(self: *Self, conn: anytype, version: i16) !i16 {
        // Use arena allocator for response decoding (zero-leak)
        var arena = std.heap.ArenaAllocator.init(self.allocator);
        defer arena.deinit();

        var req = JoinGroupRequest.default();
        req.group_id = self.group_id;
        req.session_timeout_ms = self.session_timeout_ms;
        req.rebalance_timeout_ms = self.max_poll_interval_ms;
        req.member_id = if (self.member_id_len > 0) self.member_id_buf[0..self.member_id_len] else "";
        req.protocol_type = "consumer";

        // Build supported protocols with subscription metadata
        // Send both range and roundrobin for broader compatibility
        const protocols = try self.allocator.alloc(JoinGroupRequestProtocol, 2);
        defer self.allocator.free(protocols);

        // Encode ConsumerProtocolSubscription into metadata (same for all protocols)
        const metadata = try self.encodeSubscriptionMetadata();
        defer self.allocator.free(metadata);

        // Protocol 0: range
        protocols[0] = .{
            .name = "range",
            .metadata = metadata,
        };

        // Protocol 1: roundrobin
        protocols[1] = .{
            .name = "roundrobin",
            .metadata = metadata,
        };

        req.protocols = protocols;

        const resp_size = try conn.sendRequest(11, version, req);

        // Parse response
        const resp_header_ver = request_mod.responseHeaderVersion(11, version);
        var stream = std.io.fixedBufferStream(conn.recv_buf[4..resp_size]);
        const reader = stream.reader();

        _ = try types.decodeInt32(reader);
        if (resp_header_ver >= 1) {
            _ = try types.decodeUnsignedVarInt(reader);
        }

        const resp = try JoinGroupResponse.decode(reader, version, arena.allocator());

        // Return error_code for caller to handle
        if (resp.error_code != 0) {
            return resp.error_code;
        }

        // Save member_id and generation_id
        const member_id = resp.member_id;
        if (member_id.len > 255) return error.MemberIdTooLong;

        @memcpy(self.member_id_buf[0..member_id.len], member_id);
        self.member_id_len = @intCast(member_id.len);
        self.generation_id = resp.generation_id;
        self.is_leader = std.mem.eql(u8, resp.leader, member_id);

        // Transition to sync
        try self.syncGroup(resp.members);

        // Success
        return 0;
    }

    /// Synchronize group assignment.
    fn syncGroup(self: *Self, members: ?[]const @TypeOf(@import("kafka_generated").join_group_response.JoinGroupResponse.default().members.?[0])) !void {
        self.join_state = .wait_sync;

        // If we're the leader, compute partition assignments for all members
        var computed_assignments: ?[]SyncGroupRequestAssignment = null;
        defer if (computed_assignments) |assignments| {
            for (assignments) |assignment| {
                self.allocator.free(assignment.assignment);
            }
            self.allocator.free(assignments);
        };

        if (self.is_leader and members != null) {
            computed_assignments = try self.computePartitionAssignments(members.?);
        }

        // Use arena allocator for response decoding (zero-leak)
        var arena = std.heap.ArenaAllocator.init(self.allocator);
        defer arena.deinit();

        const conn = try self.broker_pool.getConnection(self.coord_broker_id);

        // Negotiate API version for SyncGroup (key=14, v0-v5)
        const api_versions = @import("../../wire/api_versions.zig");
        const negotiated_version = api_versions.selectVersion(conn, 14, 0, 5) orelse {
            std.debug.print("[COORDINATOR] Broker doesn't support SyncGroup API\n", .{});
            return error.UnsupportedApiVersion;
        };
        std.debug.print("[COORDINATOR] Using SyncGroup v{d}\n", .{negotiated_version});

        var req = SyncGroupRequest.default();
        req.group_id = self.group_id;
        req.generation_id = self.generation_id;
        req.member_id = self.member_id_buf[0..self.member_id_len];

        // If leader, send computed assignments for all members
        // Otherwise, send empty assignment (follower behavior)
        if (computed_assignments) |assignments| {
            req.assignments = assignments;
        } else {
            req.assignments = &[_]SyncGroupRequestAssignment{};
        }

        const resp_size = try conn.sendRequest(14, negotiated_version, req);

        // Parse response
        const resp_header_ver = request_mod.responseHeaderVersion(14, negotiated_version);
        var stream = std.io.fixedBufferStream(conn.recv_buf[4..resp_size]);
        const reader = stream.reader();

        _ = try types.decodeInt32(reader);
        if (resp_header_ver >= 1) {
            _ = try types.decodeUnsignedVarInt(reader);
        }

        const resp = try SyncGroupResponse.decode(reader, negotiated_version, arena.allocator());

        if (resp.error_code != 0) {
            std.debug.print("[COORDINATOR] SyncGroup failed with error_code={d}\n", .{resp.error_code});
            return error.SyncGroupFailed;
        }

        // Parse assignment from resp.assignment and update subscription
        if (resp.assignment.len > 0) {
            try self.applyPartitionAssignment(resp.assignment);
        } else {
            std.debug.print("[COORDINATOR] Received empty assignment\n", .{});
        }

        self.join_state = .steady;
        self.enqueueRebalanceEvent(.assign_complete);
    }

    /// Leave the consumer group.
    fn leaveGroup(self: *Self) !void {
        if (self.coord_broker_id < 0) return;
        if (self.member_id_len == 0) return;

        const conn = try self.broker_pool.getConnection(self.coord_broker_id);

        var req = LeaveGroupRequest.default();
        req.group_id = self.group_id;
        // Note: LeaveGroupRequest structure varies by version
        // This is simplified; full implementation would encode member_id properly

        _ = conn.sendRequest(13, 4, req) catch {};
    }

    /// Heartbeat loop (runs in background thread).
    fn heartbeatLoop(self: *Self) void {
        while (self.heartbeat_running.load(.acquire)) {
            const now_ms = std.time.milliTimestamp();
            const last_ms = self.last_heartbeat_ms.load(.acquire);

            if (now_ms - last_ms >= self.heartbeat_interval_ms) {
                self.sendHeartbeat() catch |err| {
                    // Ignore errors during shutdown - connection might be closed
                    if (self.heartbeat_running.load(.acquire)) {
                        std.debug.print("[COORDINATOR] Heartbeat error: {any}\n", .{err});
                        if (self.metrics) |m| m.recordHeartbeatFailure();
                    }
                };
                self.last_heartbeat_ms.store(now_ms, .release);
            }

            std.time.sleep(100 * std.time.ns_per_ms); // Sleep 100ms
        }
    }

    /// Send a single heartbeat.
    fn sendHeartbeat(self: *Self) !void {
        // Check if we should still be running
        if (!self.heartbeat_running.load(.acquire)) return;

        if (self.coord_broker_id < 0) return;
        if (self.join_state != .steady) return;

        // Use arena allocator for response decoding (zero-leak)
        var arena = std.heap.ArenaAllocator.init(self.allocator);
        defer arena.deinit();

        const conn = try self.broker_pool.getConnection(self.coord_broker_id);

        // Negotiate API version for Heartbeat (key=12, v0-v4)
        const api_versions = @import("../../wire/api_versions.zig");
        const negotiated_version = api_versions.selectVersion(conn, 12, 0, 4) orelse {
            std.debug.print("[COORDINATOR] Broker doesn't support Heartbeat API\n", .{});
            return error.UnsupportedApiVersion;
        };

        var req = HeartbeatRequest.default();
        req.group_id = self.group_id;
        req.generation_id = self.generation_id;
        req.member_id = self.member_id_buf[0..self.member_id_len];

        const resp_size = try conn.sendRequest(12, negotiated_version, req);

        // Parse response
        const resp_header_ver = request_mod.responseHeaderVersion(12, negotiated_version);
        var stream = std.io.fixedBufferStream(conn.recv_buf[4..resp_size]);
        const reader = stream.reader();

        _ = try types.decodeInt32(reader);
        if (resp_header_ver >= 1) {
            _ = try types.decodeUnsignedVarInt(reader);
        }

        const resp = try HeartbeatResponse.decode(reader, negotiated_version, arena.allocator());

        // Check for rebalance
        if (resp.error_code == 27) { // REBALANCE_IN_PROGRESS
            self.join_state = .init;
            self.enqueueRebalanceEvent(.revoke_start);
            // Trigger rejoin
            self.joinGroup() catch {};
        }
    }

    /// Decode ConsumerProtocolSubscription from JoinGroup member metadata.
    /// Format: version (int16) + topics (array of strings) + user_data (bytes)
    pub fn decodeSubscriptionMetadata(metadata: []const u8, allocator: std.mem.Allocator) ![][]const u8 {
        var stream = std.io.fixedBufferStream(metadata);
        const reader = stream.reader();

        // Read version (int16) - currently only v0 supported
        const version = try types.decodeInt16(reader);
        if (version != 0) {
            std.debug.print("[COORDINATOR] Unsupported ConsumerProtocolSubscription version: {d}\n", .{version});
            return error.UnsupportedVersion;
        }

        // Read topics array (int32 count + strings)
        const topic_count = try types.decodeInt32(reader);
        if (topic_count < 0) return &[_][]const u8{};

        var topics = try allocator.alloc([]const u8, @intCast(topic_count));
        errdefer allocator.free(topics);

        for (0..@intCast(topic_count)) |i| {
            const topic = try types.decodeString(reader, allocator);
            topics[i] = topic orelse "";
        }

        // Skip user_data (bytes)
        _ = try types.decodeBytes(reader, allocator);

        return topics;
    }

    /// Compute partition assignments for all group members (leader only).
    /// Decodes member subscriptions, fetches metadata, calls assignor, and encodes results.
    pub fn computePartitionAssignments(
        self: *Self,
        members: []const @TypeOf(@import("kafka_generated").join_group_response.JoinGroupResponse.default().members.?[0]),
    ) ![]SyncGroupRequestAssignment {
        std.debug.print("[COORDINATOR] Computing partition assignments for {d} members as leader\n", .{members.len});

        var arena = std.heap.ArenaAllocator.init(self.allocator);
        defer arena.deinit();
        const arena_allocator = arena.allocator();

        // Decode member subscriptions
        var assignor_members = try arena_allocator.alloc(Assignor.Member, members.len);
        var unique_topics = std.StringHashMap(void).init(arena_allocator);

        for (members, 0..) |member, i| {
            const topics = try decodeSubscriptionMetadata(member.metadata, arena_allocator);
            assignor_members[i] = .{
                .member_id = member.member_id,
                .subscribed_topics = topics,
            };

            // Track unique topics across all members
            for (topics) |topic| {
                try unique_topics.put(topic, {});
            }
        }

        // Get partition counts from metadata cache
        var assignor_topics = std.array_list.Managed(Assignor.Topic).init(arena_allocator);
        var topic_iter = unique_topics.keyIterator();
        while (topic_iter.next()) |topic_name| {
            const topic_info = self.metadata_cache.getTopic(topic_name.*);
            if (topic_info) |info| {
                try assignor_topics.append(.{
                    .name = topic_name.*,
                    .partition_count = @intCast(info.partitions.len),
                });
            } else {
                std.debug.print("[COORDINATOR] Topic '{s}' not found in metadata cache, skipping\n", .{topic_name.*});
            }
        }

        std.debug.print("[COORDINATOR] Found {d} unique topics across all members\n", .{assignor_topics.items.len});

        // Call assignor to compute assignments
        const assignments = try self.assignor.assign(assignor_members, assignor_topics.items, arena_allocator);
        defer {
            for (assignments) |*assignment| {
                arena_allocator.free(assignment.partitions);
            }
            arena_allocator.free(assignments);
        }

        // Encode assignments for SyncGroup request
        var sync_assignments = try self.allocator.alloc(SyncGroupRequestAssignment, assignments.len);
        errdefer self.allocator.free(sync_assignments);

        for (assignments, 0..) |assignment, i| {
            const encoded = try self.encodeAssignmentMetadata(assignment.partitions);
            sync_assignments[i] = .{
                .member_id = assignment.member_id,
                .assignment = encoded,
            };
        }

        return sync_assignments;
    }

    /// Encode ConsumerProtocolAssignment for SyncGroup response.
    /// Format: version (int16) + assigned_partitions (array) + user_data (bytes)
    pub fn encodeAssignmentMetadata(self: *Self, partitions: []const TopicPartition) ![]u8 {
        var buf = std.array_list.Managed(u8).init(self.allocator);
        errdefer buf.deinit();

        const writer = buf.writer();

        // Version = 0
        try types.encodeInt16(writer, 0);

        // Group partitions by topic
        var topics_map = std.StringHashMap(std.array_list.Managed(i32)).init(self.allocator);
        defer {
            var iter = topics_map.valueIterator();
            while (iter.next()) |list| {
                list.deinit();
            }
            topics_map.deinit();
        }

        for (partitions) |tp| {
            var entry = try topics_map.getOrPut(tp.topic);
            if (!entry.found_existing) {
                entry.value_ptr.* = std.array_list.Managed(i32).init(self.allocator);
            }
            try entry.value_ptr.append(tp.partition);
        }

        // Write assigned_partitions array (int32 count + topic entries)
        try types.encodeInt32(writer, @intCast(topics_map.count()));

        var topic_iter = topics_map.iterator();
        while (topic_iter.next()) |entry| {
            // Topic name
            try types.encodeString(writer, entry.key_ptr.*);
            // Partition array (int32 count + partition IDs)
            try types.encodeInt32(writer, @intCast(entry.value_ptr.items.len));
            for (entry.value_ptr.items) |partition_id| {
                try types.encodeInt32(writer, partition_id);
            }
        }

        // User data (null)
        try types.encodeBytes(writer, null);

        return buf.toOwnedSlice();
    }

    /// Parse partition assignment from SyncGroup response and update subscription.
    /// Format: version (int16) + assigned_partitions (array) + user_data (bytes)
    pub fn applyPartitionAssignment(self: *Self, assignment: []const u8) !void {
        var stream = std.io.fixedBufferStream(assignment);
        const reader = stream.reader();

        // Read version (int16)
        const version = try types.decodeInt16(reader);
        if (version != 0) {
            std.debug.print("[COORDINATOR] Unsupported ConsumerProtocolAssignment version: {d}\n", .{version});
            return error.UnsupportedVersion;
        }

        // Read assigned_partitions array
        const topic_count = try types.decodeInt32(reader);
        if (topic_count < 0) {
            std.debug.print("[COORDINATOR] Received negative topic count in assignment\n", .{});
            return;
        }

        // Clear current assignments
        self.subscription.revokeAll();

        // Collect all partitions first, then assign once
        var partitions = std.array_list.Managed(TopicPartition).init(self.allocator);
        defer partitions.deinit();

        // Parse each topic's partitions
        for (0..@intCast(topic_count)) |_| {
            const topic_name = try types.decodeString(reader, self.allocator) orelse "";
            defer self.allocator.free(topic_name);

            const partition_count = try types.decodeInt32(reader);
            if (partition_count < 0) continue;

            for (0..@intCast(partition_count)) |_| {
                const partition_id = try types.decodeInt32(reader);

                // Collect partition (need to dupe topic_name as it gets freed)
                const topic_duped = try self.allocator.dupe(u8, topic_name);
                try partitions.append(.{ .topic = topic_duped, .partition = partition_id });
            }
        }

        std.debug.print("[COORDINATOR] Applied assignment: {d} partitions\n", .{partitions.items.len});

        // Assign all partitions at once
        try self.subscription.assign(partitions.items);

        // Free duped topic names
        for (partitions.items) |tp| {
            self.allocator.free(tp.topic);
        }

        // Skip user_data
        _ = try types.decodeBytes(reader, self.allocator);
    }

    /// Encode ConsumerProtocolSubscription for JoinGroup metadata.
    /// Format: version (int16) + topics (array of strings) + user_data (bytes)
    /// Uses non-compact encoding (for JoinGroup v0-v5)
    pub fn encodeSubscriptionMetadata(self: *Self) ![]u8 {
        var buf = std.array_list.Managed(u8).init(self.allocator);
        errdefer buf.deinit();

        const writer = buf.writer();

        // Version = 0
        try types.encodeInt16(writer, 0);

        // Topics (non-compact array for v0-v5)
        // Count the subscribed topics
        var topic_count: i32 = 0;
        for (self.subscription.subscribed_topics[0..self.subscription.subscribed_count]) |*topic| {
            if (topic.active) topic_count += 1;
        }

        // Write array length as int32
        try types.encodeInt32(writer, topic_count);

        // Write each topic as non-compact string (int16 length + bytes)
        for (self.subscription.subscribed_topics[0..self.subscription.subscribed_count]) |*topic| {
            if (!topic.active) continue;
            const topic_name = topic.name[0..topic.name_len];
            try types.encodeString(writer, topic_name);
        }

        // User data (empty bytes = null array, encoded as -1)
        try types.encodeBytes(writer, null);

        return buf.toOwnedSlice();
    }

    /// Enqueue a rebalance event.
    fn enqueueRebalanceEvent(self: *Self, event: RebalanceEvent) void {
        const tail = self.rebalance_tail.load(.acquire);
        const next_tail = (tail + 1) % 16;
        const head = self.rebalance_head.load(.acquire);

        if (next_tail == head) return; // Full

        self.rebalance_events[tail] = event;
        self.rebalance_tail.store(next_tail, .release);

        // Record rebalance metrics when revoke_start is enqueued (beginning of rebalance)
        if (event == .revoke_start) {
            if (self.metrics) |m| m.recordRebalance();
        }
    }

    /// Get member_id as a slice.
    pub fn memberId(self: *const Self) []const u8 {
        return self.member_id_buf[0..self.member_id_len];
    }
};

// ============================================================================
// Tests
// ============================================================================

test "GroupCoordinator init" {
    const allocator = std.testing.allocator;

    var broker_pool = BrokerPool.init(allocator);
    var metadata = MetadataCache{};

    var subscription = SubscriptionState.init(allocator);
    defer subscription.deinit();

    const assignor = &@import("assignor.zig").range_assignor;

    var coordinator = GroupCoordinator.init(
        allocator,
        &broker_pool,
        &metadata,
        &subscription,
        assignor,
        "test-group",
        45000,
        3000,
        300000,
    );
    defer coordinator.deinit();

    try std.testing.expectEqualStrings("test-group", coordinator.group_id);
    try std.testing.expectEqual(@as(i32, 45000), coordinator.session_timeout_ms);
    try std.testing.expectEqual(@as(i32, 3000), coordinator.heartbeat_interval_ms);
    try std.testing.expectEqual(GroupCoordinator.CoordState.init, coordinator.coord_state);
    try std.testing.expectEqual(GroupCoordinator.JoinState.init, coordinator.join_state);
}

test "GroupCoordinator state transitions" {
    const allocator = std.testing.allocator;

    var broker_pool = BrokerPool.init(allocator);
    var metadata = MetadataCache{};

    var subscription = SubscriptionState.init(allocator);
    defer subscription.deinit();

    const assignor = &@import("assignor.zig").range_assignor;

    var coordinator = GroupCoordinator.init(
        allocator,
        &broker_pool,
        &metadata,
        &subscription,
        assignor,
        "test-group",
        45000,
        3000,
        300000,
    );
    defer coordinator.deinit();

    // Verify initial state
    try std.testing.expectEqual(GroupCoordinator.CoordState.init, coordinator.coord_state);
    try std.testing.expectEqual(@as(i32, -1), coordinator.coord_broker_id);
}

test "GroupCoordinator rebalance events" {
    const allocator = std.testing.allocator;

    var broker_pool = BrokerPool.init(allocator);
    var metadata = MetadataCache{};

    var subscription = SubscriptionState.init(allocator);
    defer subscription.deinit();

    const assignor = &@import("assignor.zig").range_assignor;

    var coordinator = GroupCoordinator.init(
        allocator,
        &broker_pool,
        &metadata,
        &subscription,
        assignor,
        "test-group",
        45000,
        3000,
        300000,
    );
    defer coordinator.deinit();

    // No events initially
    try std.testing.expectEqual(@as(?GroupCoordinator.RebalanceEvent, null), coordinator.pollRebalanceEvent());

    // Enqueue event
    coordinator.enqueueRebalanceEvent(.revoke_start);

    // Poll should return it
    const event = coordinator.pollRebalanceEvent();
    try std.testing.expect(event != null);
    try std.testing.expectEqual(GroupCoordinator.RebalanceEvent.revoke_start, event.?);

    // Queue now empty
    try std.testing.expectEqual(@as(?GroupCoordinator.RebalanceEvent, null), coordinator.pollRebalanceEvent());
}
