const std = @import("std");

// Client type
pub const rd_kafka_type_t = enum(c_int) {
    RD_KAFKA_PRODUCER = 0,
    RD_KAFKA_CONSUMER = 1,
};

// Configuration result
pub const rd_kafka_conf_res_t = enum(c_int) {
    RD_KAFKA_CONF_UNKNOWN = -2,
    RD_KAFKA_CONF_INVALID = -1,
    RD_KAFKA_CONF_OK = 0,
};

// Message structure (extern for C compatibility)
pub const rd_kafka_message_t = extern struct {
    err: c_int, // rd_kafka_resp_err_t
    rkt: ?*anyopaque, // rd_kafka_topic_t *
    partition: i32,
    payload: ?*anyopaque,
    len: usize,
    key: ?*const anyopaque,
    key_len: usize,
    offset: i64,
    _private: ?*anyopaque,
};

// Topic partition structure
pub const rd_kafka_topic_partition_t = extern struct {
    topic: [*:0]const u8,
    partition: i32,
    offset: i64,
    metadata: ?*anyopaque,
    metadata_size: usize,
    @"opaque": ?*anyopaque,
    err: c_int, // rd_kafka_resp_err_t,
    _private: ?*anyopaque,
};

// Topic partition list
pub const rd_kafka_topic_partition_list_t = extern struct {
    cnt: c_int,
    size: c_int,
    elems: [*]rd_kafka_topic_partition_t,
};

// Timestamp type
pub const rd_kafka_timestamp_type_t = enum(c_int) {
    RD_KAFKA_TIMESTAMP_NOT_AVAILABLE = 0,
    RD_KAFKA_TIMESTAMP_CREATE_TIME = 1,
    RD_KAFKA_TIMESTAMP_LOG_APPEND_TIME = 2,
};

// Message flags
pub const RD_KAFKA_MSG_F_FREE: c_int = 0x1;
pub const RD_KAFKA_MSG_F_COPY: c_int = 0x2;
pub const RD_KAFKA_MSG_F_BLOCK: c_int = 0x4;
pub const RD_KAFKA_MSG_F_PARTITION: c_int = 0x8;

// Special offsets
pub const RD_KAFKA_OFFSET_BEGINNING: i64 = -2;
pub const RD_KAFKA_OFFSET_END: i64 = -1;
pub const RD_KAFKA_OFFSET_STORED: i64 = -1000;
pub const RD_KAFKA_OFFSET_INVALID: i64 = -1001;

// Partition assignment strategy
pub const rd_kafka_rebalance_protocol_t = enum(c_int) {
    RD_KAFKA_REBALANCE_PROTOCOL_NONE = 0,
    RD_KAFKA_REBALANCE_PROTOCOL_EAGER = 1,
    RD_KAFKA_REBALANCE_PROTOCOL_COOPERATIVE = 2,
};

// Event types
pub const rd_kafka_event_type_t = enum(c_int) {
    RD_KAFKA_EVENT_NONE = 0,
    RD_KAFKA_EVENT_DR = 1,
    RD_KAFKA_EVENT_FETCH = 2,
    RD_KAFKA_EVENT_LOG = 3,
    RD_KAFKA_EVENT_ERROR = 4,
    RD_KAFKA_EVENT_REBALANCE = 5,
    RD_KAFKA_EVENT_OFFSET_COMMIT = 6,
    RD_KAFKA_EVENT_STATS = 7,
    RD_KAFKA_EVENT_CREATETOPICS_RESULT = 100,
    RD_KAFKA_EVENT_DELETETOPICS_RESULT = 101,
    RD_KAFKA_EVENT_CREATEPARTITIONS_RESULT = 102,
    RD_KAFKA_EVENT_ALTERCONFIGS_RESULT = 103,
    RD_KAFKA_EVENT_DESCRIBECONFIGS_RESULT = 104,
};

// Admin operation options
pub const rd_kafka_admin_op_t = enum(c_int) {
    RD_KAFKA_ADMIN_OP_ANY = 0,
    RD_KAFKA_ADMIN_OP_CREATETOPICS = 1,
    RD_KAFKA_ADMIN_OP_DELETETOPICS = 2,
    RD_KAFKA_ADMIN_OP_CREATEPARTITIONS = 3,
    RD_KAFKA_ADMIN_OP_ALTERCONFIGS = 4,
    RD_KAFKA_ADMIN_OP_DESCRIBECONFIGS = 5,
    RD_KAFKA_ADMIN_OP_DELETERECORDS = 6,
    RD_KAFKA_ADMIN_OP_DELETEGROUPS = 7,
    RD_KAFKA_ADMIN_OP_DELETECONSUMERGROUPOFFSETS = 8,
    RD_KAFKA_ADMIN_OP_CREATEACLS = 9,
    RD_KAFKA_ADMIN_OP_DESCRIBEACLS = 10,
    RD_KAFKA_ADMIN_OP_DELETEACLS = 11,
};
