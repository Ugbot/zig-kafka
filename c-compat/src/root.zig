const std = @import("std");
const kafka = @import("kafka");
const registry = @import("handle_registry.zig");
const types = @import("types.zig");
const error_mod = @import("error.zig");

// Re-export error types
pub const rd_kafka_resp_err_t = error_mod.rd_kafka_resp_err_t;
pub const rd_kafka_err2str = error_mod.rd_kafka_err2str;
pub const rd_kafka_err2name = error_mod.rd_kafka_err2name;
pub const rd_kafka_last_error = error_mod.rd_kafka_last_error;

// Re-export types
pub const rd_kafka_type_t = types.rd_kafka_type_t;
pub const rd_kafka_conf_res_t = types.rd_kafka_conf_res_t;
pub const rd_kafka_message_t = types.rd_kafka_message_t;
pub const rd_kafka_topic_partition_t = types.rd_kafka_topic_partition_t;
pub const rd_kafka_topic_partition_list_t = types.rd_kafka_topic_partition_list_t;
pub const rd_kafka_timestamp_type_t = types.rd_kafka_timestamp_type_t;

// Opaque types (for C API)
pub const rd_kafka_t = opaque {};
pub const rd_kafka_topic_t = opaque {};
pub const rd_kafka_conf_t = opaque {};
pub const rd_kafka_topic_conf_t = opaque {};
pub const rd_kafka_headers_t = opaque {};
pub const rd_kafka_queue_t = opaque {};

// Unassigned partition sentinel (matches librdkafka)
const RD_KAFKA_PARTITION_UA: i32 = -1;

// Global state
var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const allocator = gpa.allocator();
var global_registry: registry.HandleRegistry = undefined;
var registry_initialized = false;

fn ensureRegistryInit() void {
    if (!registry_initialized) {
        global_registry = registry.HandleRegistry.init(allocator);
        registry_initialized = true;
    }
}

// ============================================================================
// Configuration API
// ============================================================================

export fn rd_kafka_conf_new() callconv(.C) ?*rd_kafka_conf_t {
    ensureRegistryInit();

    const config = allocator.create(registry.HandleRegistry.ConfigHandle) catch return null;
    config.* = .{
        .bootstrap_servers = null,
        .client_id = null,
        .settings = std.StringHashMap([]const u8).init(allocator),
    };

    const id = global_registry.register(.{ .config = config }) catch return null;
    return @ptrFromInt(id);
}

export fn rd_kafka_conf_destroy(conf: ?*rd_kafka_conf_t) callconv(.C) void {
    if (conf) |c| {
        const id = @intFromPtr(c);
        if (global_registry.remove(id)) |handle| {
            if (handle == .config) {
                handle.config.settings.deinit();
                allocator.destroy(handle.config);
            }
        }
    }
}

export fn rd_kafka_conf_set(
    conf: ?*rd_kafka_conf_t,
    name: [*:0]const u8,
    value: [*:0]const u8,
    errstr: [*]u8,
    errstr_size: usize,
) callconv(.C) types.rd_kafka_conf_res_t {
    const id = @intFromPtr(conf orelse return .RD_KAFKA_CONF_INVALID);
    const handle = global_registry.get(id, .config) orelse return .RD_KAFKA_CONF_INVALID;

    const name_str = std.mem.span(name);
    const value_str = std.mem.span(value);

    // Known configuration parameters
    if (std.mem.eql(u8, name_str, "bootstrap.servers")) {
        handle.config.bootstrap_servers = allocator.dupe(u8, value_str) catch {
            copyErrorString(errstr, errstr_size, "Memory allocation failed");
            return .RD_KAFKA_CONF_INVALID;
        };
        return .RD_KAFKA_CONF_OK;
    } else if (std.mem.eql(u8, name_str, "client.id")) {
        handle.config.client_id = allocator.dupe(u8, value_str) catch {
            copyErrorString(errstr, errstr_size, "Memory allocation failed");
            return .RD_KAFKA_CONF_INVALID;
        };
        return .RD_KAFKA_CONF_OK;
    }

    // Store all other configs for later use
    handle.config.settings.put(
        allocator.dupe(u8, name_str) catch return .RD_KAFKA_CONF_INVALID,
        allocator.dupe(u8, value_str) catch return .RD_KAFKA_CONF_INVALID,
    ) catch return .RD_KAFKA_CONF_INVALID;

    return .RD_KAFKA_CONF_OK;
}

export fn rd_kafka_conf_dup(conf: ?*const rd_kafka_conf_t) callconv(.C) ?*rd_kafka_conf_t {
    ensureRegistryInit();

    const id = @intFromPtr(conf orelse return null);
    const handle = global_registry.get(id, .config) orelse return null;

    const new_config = allocator.create(registry.HandleRegistry.ConfigHandle) catch return null;
    new_config.* = .{
        .bootstrap_servers = if (handle.config.bootstrap_servers) |bs|
            allocator.dupe(u8, bs) catch return null
        else
            null,
        .client_id = if (handle.config.client_id) |ci|
            allocator.dupe(u8, ci) catch return null
        else
            null,
        .settings = std.StringHashMap([]const u8).init(allocator),
    };

    // Copy settings manually
    var it = handle.config.settings.iterator();
    while (it.next()) |entry| {
        const key_copy = allocator.dupe(u8, entry.key_ptr.*) catch {
            new_config.settings.deinit();
            allocator.destroy(new_config);
            return null;
        };
        const val_copy = allocator.dupe(u8, entry.value_ptr.*) catch {
            allocator.free(key_copy);
            new_config.settings.deinit();
            allocator.destroy(new_config);
            return null;
        };
        new_config.settings.put(key_copy, val_copy) catch {
            allocator.free(key_copy);
            allocator.free(val_copy);
            new_config.settings.deinit();
            allocator.destroy(new_config);
            return null;
        };
    }

    const new_id = global_registry.register(.{ .config = new_config }) catch {
        new_config.settings.deinit();
        allocator.destroy(new_config);
        return null;
    };

    return @ptrFromInt(new_id);
}

// ============================================================================
// Client Lifecycle
// ============================================================================

export fn rd_kafka_new(
    type_: types.rd_kafka_type_t,
    conf: ?*rd_kafka_conf_t,
    errstr: [*]u8,
    errstr_size: usize,
) callconv(.C) ?*rd_kafka_t {
    ensureRegistryInit();

    const config_id = @intFromPtr(conf orelse {
        copyErrorString(errstr, errstr_size, "Configuration required");
        return null;
    });

    const config_handle = global_registry.get(config_id, .config) orelse {
        copyErrorString(errstr, errstr_size, "Invalid configuration");
        return null;
    };

    // Parse bootstrap servers into BrokerAddress array
    const bootstrap = config_handle.config.bootstrap_servers orelse "localhost:9092";
    const broker_addresses = parseBrokerAddresses(bootstrap) catch {
        copyErrorString(errstr, errstr_size, "Failed to parse bootstrap.servers");
        return null;
    };

    // Build client name (null-terminated for C)
    const name_z = allocator.dupeZ(u8, config_handle.config.client_id orelse "zig-kafka-c-compat") catch {
        copyErrorString(errstr, errstr_size, "Memory allocation failed");
        return null;
    };

    // Create KafkaClient
    const client = allocator.create(kafka.KafkaClient) catch {
        copyErrorString(errstr, errstr_size, "Memory allocation failed");
        return null;
    };

    client.* = kafka.KafkaClient.init(.{
        .bootstrap_servers = broker_addresses,
        .client_id = config_handle.config.client_id orelse "zig-kafka-c-compat",
    }, allocator) catch |err| {
        copyErrorString(errstr, errstr_size, @errorName(err));
        allocator.destroy(client);
        return null;
    };

    const client_handle = allocator.create(registry.HandleRegistry.ClientHandle) catch {
        copyErrorString(errstr, errstr_size, "Memory allocation failed");
        client.close();
        allocator.destroy(client);
        return null;
    };

    client_handle.* = .{
        .client = client,
        .type = if (type_ == .RD_KAFKA_PRODUCER) .producer else .consumer,
        .name_z = name_z,
        .broker_addresses = broker_addresses,
    };

    // Create producer or consumer based on type
    if (type_ == .RD_KAFKA_PRODUCER) {
        const producer_config = buildProducerConfig(config_handle.config);
        const producer = client.createProducer(producer_config) catch |err| {
            copyErrorString(errstr, errstr_size, @errorName(err));
            allocator.destroy(client_handle);
            client.close();
            allocator.destroy(client);
            return null;
        };
        client_handle.producer = allocator.create(kafka.Producer) catch {
            copyErrorString(errstr, errstr_size, "Memory allocation failed");
            allocator.destroy(client_handle);
            client.close();
            allocator.destroy(client);
            return null;
        };
        client_handle.producer.?.* = producer;
    } else {
        const consumer_config = buildConsumerConfig(config_handle.config);
        const consumer = client.createConsumer(consumer_config) catch |err| {
            copyErrorString(errstr, errstr_size, @errorName(err));
            allocator.destroy(client_handle);
            client.close();
            allocator.destroy(client);
            return null;
        };
        client_handle.consumer = allocator.create(kafka.Consumer) catch {
            copyErrorString(errstr, errstr_size, "Memory allocation failed");
            allocator.destroy(client_handle);
            client.close();
            allocator.destroy(client);
            return null;
        };
        client_handle.consumer.?.* = consumer;
    }

    const id = global_registry.register(.{ .client = client_handle }) catch {
        if (client_handle.producer) |p| {
            p.close();
            allocator.destroy(p);
        }
        if (client_handle.consumer) |c_| {
            c_.deinit();
            allocator.destroy(c_);
        }
        allocator.destroy(client_handle);
        client.close();
        allocator.destroy(client);
        return null;
    };

    return @ptrFromInt(id);
}

export fn rd_kafka_destroy(rk: ?*rd_kafka_t) callconv(.C) void {
    if (rk) |r| {
        const id = @intFromPtr(r);
        if (global_registry.remove(id)) |handle| {
            if (handle == .client) {
                if (handle.client.producer) |p| {
                    p.close();
                    allocator.destroy(p);
                }
                if (handle.client.consumer) |c| {
                    c.deinit();
                    allocator.destroy(c);
                }
                handle.client.client.close();
                allocator.destroy(handle.client.client);
                allocator.destroy(handle.client);
            }
        }
    }
}

export fn rd_kafka_name(rk: ?*const rd_kafka_t) callconv(.C) [*:0]const u8 {
    const id = @intFromPtr(rk orelse return "unknown");
    const handle = global_registry.get(id, .client) orelse return "unknown";
    return handle.client.name_z.ptr;
}

export fn rd_kafka_type(rk: ?*const rd_kafka_t) callconv(.C) types.rd_kafka_type_t {
    const id = @intFromPtr(rk orelse return .RD_KAFKA_PRODUCER);
    const handle = global_registry.get(id, .client) orelse return .RD_KAFKA_PRODUCER;
    return if (handle.client.type == .producer) .RD_KAFKA_PRODUCER else .RD_KAFKA_CONSUMER;
}

// ============================================================================
// Topic API
// ============================================================================

export fn rd_kafka_topic_new(
    rk: ?*rd_kafka_t,
    topic: [*:0]const u8,
    conf: ?*rd_kafka_topic_conf_t,
) callconv(.C) ?*rd_kafka_topic_t {
    _ = conf;

    const client_id = @intFromPtr(rk orelse return null);
    if (!global_registry.contains(client_id)) return null;

    const topic_str = std.mem.span(topic);
    const topic_handle = allocator.create(registry.HandleRegistry.TopicHandle) catch return null;
    topic_handle.* = .{
        .name = allocator.dupeZ(u8, topic_str) catch {
            allocator.destroy(topic_handle);
            return null;
        },
        .client_id = client_id,
    };

    const id = global_registry.register(.{ .topic = topic_handle }) catch {
        allocator.free(topic_handle.name);
        allocator.destroy(topic_handle);
        return null;
    };

    return @ptrFromInt(id);
}

export fn rd_kafka_topic_destroy(rkt: ?*rd_kafka_topic_t) callconv(.C) void {
    if (rkt) |t| {
        const id = @intFromPtr(t);
        if (global_registry.remove(id)) |handle| {
            if (handle == .topic) {
                allocator.free(handle.topic.name);
                allocator.destroy(handle.topic);
            }
        }
    }
}

export fn rd_kafka_topic_name(rkt: ?*const rd_kafka_topic_t) callconv(.C) [*:0]const u8 {
    const id = @intFromPtr(rkt orelse return "unknown");
    const handle = global_registry.get(id, .topic) orelse return "unknown";
    return handle.topic.name.ptr;
}

// ============================================================================
// Producer API
// ============================================================================

export fn rd_kafka_produce(
    rkt: ?*rd_kafka_topic_t,
    partition: i32,
    msgflags: c_int,
    payload: ?*anyopaque,
    len: usize,
    key: ?*const anyopaque,
    keylen: usize,
    msg_opaque: ?*anyopaque,
) callconv(.C) c_int {
    _ = msgflags;
    _ = msg_opaque;

    const topic_id = @intFromPtr(rkt orelse return -1);
    const topic_handle = global_registry.get(topic_id, .topic) orelse return -1;

    const client_id = topic_handle.topic.client_id;
    const client_handle = global_registry.get(client_id, .client) orelse return -1;

    const producer = client_handle.client.producer orelse return -1;

    const value_slice: []const u8 = if (payload) |p|
        @as([*]const u8, @ptrCast(p))[0..len]
    else
        &[_]u8{};

    const key_slice: ?[]const u8 = if (key) |k|
        @as([*]const u8, @ptrCast(k))[0..keylen]
    else
        null;

    if (partition == RD_KAFKA_PARTITION_UA) {
        producer.produce(topic_handle.topic.name, key_slice, value_slice) catch return -1;
    } else {
        producer.produceToPartition(topic_handle.topic.name, partition, key_slice, value_slice) catch return -1;
    }

    return 0;
}

export fn rd_kafka_flush(rk: ?*rd_kafka_t, timeout_ms: c_int) callconv(.C) c_int {
    const id = @intFromPtr(rk orelse return -1);
    const handle = global_registry.get(id, .client) orelse return -1;

    if (handle.client.producer) |producer| {
        const ms: u32 = if (timeout_ms < 0) 0 else @intCast(timeout_ms);
        producer.flush(ms) catch return -1;
        return 0;
    }

    return -1;
}

export fn rd_kafka_poll(rk: ?*rd_kafka_t, timeout_ms: c_int) callconv(.C) c_int {
    _ = rk;
    _ = timeout_ms;
    // Poll for delivery reports - no-op in minimal implementation
    return 0;
}

// ============================================================================
// Consumer API
// ============================================================================

export fn rd_kafka_subscribe(
    rk: ?*rd_kafka_t,
    topics: ?*const types.rd_kafka_topic_partition_list_t,
) callconv(.C) c_int {
    const id = @intFromPtr(rk orelse return -1);
    const handle = global_registry.get(id, .client) orelse return -1;

    const consumer = handle.client.consumer orelse return -1;
    const topic_list = topics orelse return -1;

    var topic_names = std.ArrayList([]const u8).init(allocator);
    defer topic_names.deinit();

    const cnt: usize = @intCast(topic_list.cnt);
    for (0..cnt) |i| {
        const topic_name = std.mem.span(topic_list.elems[i].topic);
        topic_names.append(topic_name) catch return -1;
    }

    consumer.subscribe(topic_names.items) catch return -1;
    return 0;
}

export fn rd_kafka_consumer_poll(
    rk: ?*rd_kafka_t,
    timeout_ms: c_int,
) callconv(.C) ?*types.rd_kafka_message_t {
    const id = @intFromPtr(rk orelse return null);
    const handle = global_registry.get(id, .client) orelse return null;

    const consumer = handle.client.consumer orelse return null;

    const records = consumer.poll(@as(i64, @intCast(timeout_ms))) catch return null;
    if (records.len == 0) return null;

    // Allocate message and copy data so it survives past next poll()
    const msg = allocator.create(types.rd_kafka_message_t) catch return null;
    const record = records[0];

    const value_copy = allocator.alloc(u8, record.value.len) catch {
        allocator.destroy(msg);
        return null;
    };
    @memcpy(value_copy, record.value);

    var key_copy: ?[*]const u8 = null;
    var key_copy_len: usize = 0;
    if (record.key) |k| {
        const kc = allocator.alloc(u8, k.len) catch {
            allocator.free(value_copy);
            allocator.destroy(msg);
            return null;
        };
        @memcpy(kc, k);
        key_copy = kc.ptr;
        key_copy_len = k.len;
    }

    msg.* = .{
        .err = 0,
        .rkt = null,
        .partition = record.partition,
        .payload = @ptrCast(value_copy.ptr),
        .len = value_copy.len,
        .key = key_copy,
        .key_len = key_copy_len,
        .offset = record.offset,
        ._private = null,
    };

    return msg;
}

export fn rd_kafka_message_destroy(rkmessage: ?*types.rd_kafka_message_t) callconv(.C) void {
    if (rkmessage) |msg| {
        // Free copied payload
        if (msg.payload) |p| {
            const slice = @as([*]u8, @ptrCast(p))[0..msg.len];
            allocator.free(slice);
        }
        // Free copied key
        if (msg.key) |k| {
            const slice = @as([*]u8, @ptrCast(@constCast(k)))[0..msg.key_len];
            allocator.free(slice);
        }
        allocator.destroy(msg);
    }
}

export fn rd_kafka_consumer_close(rk: ?*rd_kafka_t) callconv(.C) c_int {
    const id = @intFromPtr(rk orelse return -1);
    const handle = global_registry.get(id, .client) orelse return -1;

    if (handle.client.consumer) |consumer| {
        consumer.close() catch return -1;
        return 0;
    }

    return -1;
}

export fn rd_kafka_assignment(
    rk: ?*rd_kafka_t,
    partitions: ?*?*types.rd_kafka_topic_partition_list_t,
) callconv(.C) c_int {
    const id = @intFromPtr(rk orelse return -1);
    const handle = global_registry.get(id, .client) orelse return -1;
    const consumer = handle.client.consumer orelse return -1;
    const out = partitions orelse return -1;

    const sub = consumer.subscription;

    // Count active assignments
    var count: c_int = 0;
    for (sub.assigned_partitions[0..sub.assigned_count]) |part| {
        if (part.active) count += 1;
    }

    const list = rd_kafka_topic_partition_list_new(if (count > 0) count else 1);
    if (list == null) return -1;

    for (sub.assigned_partitions[0..sub.assigned_count]) |part| {
        if (!part.active) continue;
        const topic_name = allocator.dupeZ(u8, part.topic[0..part.topic_len]) catch continue;
        _ = rd_kafka_topic_partition_list_add(list, topic_name.ptr, part.partition);
    }

    out.* = list;
    return 0;
}

export fn rd_kafka_committed(
    rk: ?*rd_kafka_t,
    partitions_arg: ?*types.rd_kafka_topic_partition_list_t,
    timeout_ms: c_int,
) callconv(.C) c_int {
    _ = rk;
    _ = partitions_arg;
    _ = timeout_ms;
    // Not yet implemented - would require OffsetFetch API
    return @intFromEnum(error_mod.rd_kafka_resp_err_t._NOT_IMPLEMENTED);
}

export fn rd_kafka_commit(
    rk: ?*rd_kafka_t,
    offsets: ?*types.rd_kafka_topic_partition_list_t,
    async_: c_int,
) callconv(.C) c_int {
    _ = offsets;

    const id = @intFromPtr(rk orelse return -1);
    const handle = global_registry.get(id, .client) orelse return -1;
    const consumer = handle.client.consumer orelse return -1;

    if (async_ != 0) {
        // Async commit - best effort
        consumer.commitSync() catch {};
        return 0;
    }

    consumer.commitSync() catch return -1;
    return 0;
}

// ============================================================================
// Topic Partition List API
// ============================================================================

export fn rd_kafka_topic_partition_list_new(size: c_int) callconv(.C) ?*types.rd_kafka_topic_partition_list_t {
    const list = allocator.create(types.rd_kafka_topic_partition_list_t) catch return null;
    const elems = allocator.alloc(types.rd_kafka_topic_partition_t, @intCast(size)) catch {
        allocator.destroy(list);
        return null;
    };

    list.* = .{
        .cnt = 0,
        .size = size,
        .elems = elems.ptr,
    };

    return list;
}

export fn rd_kafka_topic_partition_list_destroy(rkparlist: ?*types.rd_kafka_topic_partition_list_t) callconv(.C) void {
    if (rkparlist) |list| {
        const elems = list.elems[0..@intCast(list.size)];
        allocator.free(elems);
        allocator.destroy(list);
    }
}

export fn rd_kafka_topic_partition_list_add(
    rktparlist: ?*types.rd_kafka_topic_partition_list_t,
    topic: [*:0]const u8,
    partition: i32,
) callconv(.C) ?*types.rd_kafka_topic_partition_t {
    const list = rktparlist orelse return null;
    if (list.cnt >= list.size) return null;

    const topic_str = std.mem.span(topic);
    const topic_copy = allocator.dupeZ(u8, topic_str) catch return null;

    const idx: usize = @intCast(list.cnt);
    list.elems[idx] = .{
        .topic = topic_copy.ptr,
        .partition = partition,
        .offset = types.RD_KAFKA_OFFSET_INVALID,
        .metadata = null,
        .metadata_size = 0,
        .@"opaque" = null,
        .err = 0,
        ._private = null,
    };

    list.cnt += 1;
    return &list.elems[idx];
}

// ============================================================================
// Version Info
// ============================================================================

export fn rd_kafka_version() callconv(.C) c_int {
    return 0x020d00ff; // 2.13.0
}

export fn rd_kafka_version_str() callconv(.C) [*:0]const u8 {
    return "2.13.0-zig-kafka";
}

// ============================================================================
// Helper Functions
// ============================================================================

fn copyErrorString(dest: [*]u8, size: usize, src: []const u8) void {
    if (size == 0) return;
    const copy_len = @min(src.len, size - 1);
    @memcpy(dest[0..copy_len], src[0..copy_len]);
    dest[copy_len] = 0;
}

fn parseBrokerAddresses(servers_str: []const u8) ![]const kafka.BrokerAddress {
    var addresses = std.ArrayList(kafka.BrokerAddress).init(allocator);
    errdefer addresses.deinit();

    var it = std.mem.splitScalar(u8, servers_str, ',');
    while (it.next()) |server_raw| {
        const server = std.mem.trim(u8, server_raw, " \t");
        if (server.len == 0) continue;

        if (std.mem.lastIndexOfScalar(u8, server, ':')) |colon_idx| {
            const host = try allocator.dupe(u8, server[0..colon_idx]);
            const port = std.fmt.parseInt(u16, server[colon_idx + 1 ..], 10) catch 9092;
            try addresses.append(.{ .host = host, .port = port });
        } else {
            const host = try allocator.dupe(u8, server);
            try addresses.append(.{ .host = host, .port = 9092 });
        }
    }

    return addresses.toOwnedSlice();
}

fn buildProducerConfig(config_handle: *registry.HandleRegistry.ConfigHandle) kafka.ProducerConfig {
    var cfg = kafka.ProducerConfig{};

    if (config_handle.settings.get("acks")) |v| {
        if (std.mem.eql(u8, v, "all") or std.mem.eql(u8, v, "-1")) {
            cfg.acks = -1;
        } else {
            cfg.acks = std.fmt.parseInt(i16, v, 10) catch -1;
        }
    }
    if (config_handle.settings.get("linger.ms")) |v| {
        cfg.linger_ms = std.fmt.parseInt(u32, v, 10) catch 5;
    }
    if (config_handle.settings.get("batch.size")) |v| {
        cfg.batch_size = std.fmt.parseInt(u32, v, 10) catch 16_384;
    }
    if (config_handle.settings.get("compression.type")) |v| {
        if (std.mem.eql(u8, v, "gzip")) {
            cfg.compression_type = .gzip;
        } else if (std.mem.eql(u8, v, "snappy")) {
            cfg.compression_type = .snappy;
        } else if (std.mem.eql(u8, v, "lz4")) {
            cfg.compression_type = .lz4;
        } else if (std.mem.eql(u8, v, "zstd")) {
            cfg.compression_type = .zstd;
        }
    }
    if (config_handle.settings.get("enable.idempotence")) |v| {
        cfg.enable_idempotence = std.mem.eql(u8, v, "true");
    }
    if (config_handle.settings.get("request.timeout.ms")) |v| {
        cfg.request_timeout_ms = std.fmt.parseInt(u32, v, 10) catch 30_000;
    }

    return cfg;
}

fn buildConsumerConfig(config_handle: *registry.HandleRegistry.ConfigHandle) kafka.ConsumerConfig {
    var cfg = kafka.ConsumerConfig{};

    if (config_handle.settings.get("group.id")) |v| {
        cfg.group_id = v;
    }
    if (config_handle.settings.get("auto.offset.reset")) |v| {
        if (std.mem.eql(u8, v, "earliest")) {
            cfg.auto_offset_reset = .earliest;
        } else if (std.mem.eql(u8, v, "latest")) {
            cfg.auto_offset_reset = .latest;
        } else {
            cfg.auto_offset_reset = .none;
        }
    }
    if (config_handle.settings.get("enable.auto.commit")) |v| {
        cfg.enable_auto_commit = std.mem.eql(u8, v, "true");
    }
    if (config_handle.settings.get("session.timeout.ms")) |v| {
        cfg.session_timeout_ms = std.fmt.parseInt(u32, v, 10) catch 45_000;
    }
    if (config_handle.settings.get("heartbeat.interval.ms")) |v| {
        cfg.heartbeat_interval_ms = std.fmt.parseInt(u32, v, 10) catch 3_000;
    }
    if (config_handle.settings.get("max.poll.records")) |v| {
        cfg.max_poll_records = std.fmt.parseInt(u32, v, 10) catch 500;
    }
    if (config_handle.settings.get("max.poll.interval.ms")) |v| {
        cfg.max_poll_interval_ms = std.fmt.parseInt(u32, v, 10) catch 300_000;
    }
    if (config_handle.settings.get("fetch.min.bytes")) |v| {
        cfg.fetch_min_bytes = std.fmt.parseInt(u32, v, 10) catch 1;
    }
    if (config_handle.settings.get("fetch.max.wait.ms")) |v| {
        cfg.fetch_max_wait_ms = std.fmt.parseInt(u32, v, 10) catch 500;
    }

    return cfg;
}
