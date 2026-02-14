const std = @import("std");
const error_mod = @import("error.zig");
const types = @import("types.zig");

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

// Opaque types (for C API)
pub const rd_kafka_t = opaque {};
pub const rd_kafka_topic_t = opaque {};
pub const rd_kafka_conf_t = opaque {};
pub const rd_kafka_topic_conf_t = opaque {};

//
// Configuration API (simplified - stores config, actual Kafka connection deferred)
//

export fn rd_kafka_conf_new() callconv(.C) ?*rd_kafka_conf_t {
    return @ptrFromInt(1); // Stub - return non-null
}

export fn rd_kafka_conf_destroy(conf: ?*rd_kafka_conf_t) callconv(.C) void {
    _ = conf;
}

export fn rd_kafka_conf_set(
    conf: ?*rd_kafka_conf_t,
    name: [*:0]const u8,
    value: [*:0]const u8,
    errstr: [*]u8,
    errstr_size: usize,
) callconv(.C) types.rd_kafka_conf_res_t {
    _ = conf;
    _ = name;
    _ = value;
    _ = errstr;
    _ = errstr_size;
    return .RD_KAFKA_CONF_OK;
}

export fn rd_kafka_conf_dup(conf: ?*const rd_kafka_conf_t) callconv(.C) ?*rd_kafka_conf_t {
    _ = conf;
    return @ptrFromInt(1); // Stub
}

//
// Client lifecycle (simplified)
//

export fn rd_kafka_new(
    type_: types.rd_kafka_type_t,
    conf: ?*rd_kafka_conf_t,
    errstr: [*]u8,
    errstr_size: usize,
) callconv(.C) ?*rd_kafka_t {
    _ = conf;
    _ = errstr;
    _ = errstr_size;
    // Return a unique handle based on type
    const handle: usize = if (type_ == .RD_KAFKA_PRODUCER) 100 else 200;
    return @ptrFromInt(handle);
}

export fn rd_kafka_destroy(rk: ?*rd_kafka_t) callconv(.C) void {
    _ = rk;
}

export fn rd_kafka_name(rk: ?*const rd_kafka_t) callconv(.C) [*:0]const u8 {
    _ = rk;
    return "zig-kafka";
}

export fn rd_kafka_type(rk: ?*const rd_kafka_t) callconv(.C) types.rd_kafka_type_t {
    const handle = @intFromPtr(rk orelse return .RD_KAFKA_PRODUCER);
    return if (handle >= 200) .RD_KAFKA_CONSUMER else .RD_KAFKA_PRODUCER;
}

//
// Topic API
//

export fn rd_kafka_topic_new(
    rk: ?*rd_kafka_t,
    topic: [*:0]const u8,
    conf: ?*rd_kafka_topic_conf_t,
) callconv(.C) ?*rd_kafka_topic_t {
    _ = rk;
    _ = topic;
    _ = conf;
    return @ptrFromInt(300); // Stub
}

export fn rd_kafka_topic_destroy(rkt: ?*rd_kafka_topic_t) callconv(.C) void {
    _ = rkt;
}

export fn rd_kafka_topic_name(rkt: ?*const rd_kafka_topic_t) callconv(.C) [*:0]const u8 {
    _ = rkt;
    return "unknown-topic";
}

//
// Producer API (stubbed - TODO: integrate with actual Kafka SDK)
//

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
    _ = rkt;
    _ = partition;
    _ = msgflags;
    _ = payload;
    _ = len;
    _ = key;
    _ = keylen;
    _ = msg_opaque;
    // TODO: Implement actual message production
    return 0;
}

export fn rd_kafka_flush(rk: ?*rd_kafka_t, timeout_ms: c_int) callconv(.C) c_int {
    _ = rk;
    _ = timeout_ms;
    // TODO: Implement flush
    return 0;
}

export fn rd_kafka_poll(rk: ?*rd_kafka_t, timeout_ms: c_int) callconv(.C) c_int {
    _ = rk;
    _ = timeout_ms;
    return 0;
}

//
// Consumer API (stubbed - TODO: integrate with actual Kafka SDK)
//

export fn rd_kafka_subscribe(
    rk: ?*rd_kafka_t,
    topics: ?*const types.rd_kafka_topic_partition_list_t,
) callconv(.C) c_int {
    _ = rk;
    _ = topics;
    // TODO: Implement subscription
    return 0;
}

export fn rd_kafka_consumer_poll(
    rk: ?*rd_kafka_t,
    timeout_ms: c_int,
) callconv(.C) ?*types.rd_kafka_message_t {
    _ = rk;
    _ = timeout_ms;
    // TODO: Implement consumer poll
    return null;
}

export fn rd_kafka_message_destroy(rkmessage: ?*types.rd_kafka_message_t) callconv(.C) void {
    _ = rkmessage;
}

export fn rd_kafka_consumer_close(rk: ?*rd_kafka_t) callconv(.C) c_int {
    _ = rk;
    return 0;
}

export fn rd_kafka_assignment(
    rk: ?*rd_kafka_t,
    partitions: ?*?*types.rd_kafka_topic_partition_list_t,
) callconv(.C) c_int {
    _ = rk;
    _ = partitions;
    return -1;
}

export fn rd_kafka_committed(
    rk: ?*rd_kafka_t,
    partitions: ?*types.rd_kafka_topic_partition_list_t,
    timeout_ms: c_int,
) callconv(.C) c_int {
    _ = rk;
    _ = partitions;
    _ = timeout_ms;
    return -1;
}

export fn rd_kafka_commit(
    rk: ?*rd_kafka_t,
    offsets: ?*types.rd_kafka_topic_partition_list_t,
    async_: c_int,
) callconv(.C) c_int {
    _ = rk;
    _ = offsets;
    _ = async_;
    return -1;
}

//
// Topic Partition List API
//

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const allocator = gpa.allocator();

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

//
// Version info
//

export fn rd_kafka_version() callconv(.C) c_int {
    return 0x020d00ff; // 2.13.0
}

export fn rd_kafka_version_str() callconv(.C) [*:0]const u8 {
    return "2.13.0-zig-kafka";
}
