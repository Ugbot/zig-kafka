const std = @import("std");
const kafka = @import("kafka");

pub const HandleType = enum {
    client,
    topic,
    message,
    config,
    topic_partition_list,
    headers,
    queue,
    error_obj,
};

pub const HandleRegistry = struct {
    mutex: std.Thread.Mutex,
    handles: std.AutoHashMap(usize, Handle),
    next_id: std.atomic.Value(usize),
    allocator: std.mem.Allocator,

    const Handle = union(HandleType) {
        client: *ClientHandle,
        topic: *TopicHandle,
        message: *MessageHandle,
        config: *ConfigHandle,
        topic_partition_list: *TopicPartitionList,
        headers: *Headers,
        queue: *Queue,
        error_obj: *ErrorObject,
    };

    pub const ClientHandle = struct {
        client: *kafka.KafkaClient,
        type: ClientType,
        producer: ?*kafka.Producer = null,
        consumer: ?*kafka.Consumer = null,
        name_z: [:0]const u8 = "zig-kafka",
        broker_addresses: ?[]const kafka.BrokerAddress = null,
    };

    pub const ClientType = enum {
        producer,
        consumer,
    };

    pub const TopicHandle = struct {
        name: [:0]const u8,
        client_id: usize,
    };

    pub const MessageHandle = struct {
        topic: []const u8,
        partition: i32,
        offset: i64,
        key: ?[]const u8,
        value: []const u8,
        timestamp: i64,
        error_code: i32,
    };

    pub const ConfigHandle = struct {
        bootstrap_servers: ?[]const u8 = null,
        client_id: ?[]const u8 = null,
        settings: std.StringHashMap([]const u8),
    };

    pub const TopicPartitionList = struct {
        partitions: std.ArrayList(TopicPartition),

        pub const TopicPartition = struct {
            topic: []const u8,
            partition: i32,
            offset: i64,
            metadata: ?[]const u8 = null,
            error_code: i32 = 0,
        };
    };

    pub const Headers = struct {
        headers: std.ArrayList(Header),

        pub const Header = struct {
            key: []const u8,
            value: []const u8,
        };
    };

    pub const Queue = struct {
        messages: std.ArrayList(usize), // message handle IDs
    };

    pub const ErrorObject = struct {
        code: i32,
        message: []const u8,
    };

    pub fn init(allocator: std.mem.Allocator) HandleRegistry {
        return .{
            .mutex = .{},
            .handles = std.AutoHashMap(usize, Handle).init(allocator),
            .next_id = std.atomic.Value(usize).init(1),
            .allocator = allocator,
        };
    }

    pub fn deinit(self: *HandleRegistry) void {
        self.handles.deinit();
    }

    pub fn register(self: *HandleRegistry, handle: Handle) !usize {
        const id = self.next_id.fetchAdd(1, .monotonic);

        self.mutex.lock();
        defer self.mutex.unlock();

        try self.handles.put(id, handle);
        return id;
    }

    pub fn get(self: *HandleRegistry, id: usize, comptime T: HandleType) ?*Handle {
        self.mutex.lock();
        defer self.mutex.unlock();

        if (self.handles.getPtr(id)) |h| {
            if (std.meta.activeTag(h.*) == T) return h;
        }
        return null;
    }

    pub fn remove(self: *HandleRegistry, id: usize) ?Handle {
        self.mutex.lock();
        defer self.mutex.unlock();

        if (self.handles.fetchRemove(id)) |kv| {
            return kv.value;
        }
        return null;
    }

    pub fn contains(self: *HandleRegistry, id: usize) bool {
        self.mutex.lock();
        defer self.mutex.unlock();

        return self.handles.contains(id);
    }
};
