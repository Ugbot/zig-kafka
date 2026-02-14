const std = @import("std");
const testing = std.testing;
const kafka = @import("zig-kafka");

test "protocol types compile" {
    // Ensure all protocol types are accessible
    _ = kafka.protocol.types;
    _ = kafka.protocol.frame;
    _ = kafka.protocol.compression;
    _ = kafka.protocol.record_batch;
}

test "generated messages compile" {
    // Ensure core message types compile
    _ = kafka.messages.ProduceRequest;
    _ = kafka.messages.ProduceResponse;
    _ = kafka.messages.FetchRequest;
    _ = kafka.messages.FetchResponse;
    _ = kafka.messages.MetadataRequest;
    _ = kafka.messages.MetadataResponse;
}

test "wire protocol types compile" {
    // Ensure wire protocol types are accessible
    _ = kafka.wire.BrokerPool;
    _ = kafka.wire.Connection;
}

// More comprehensive tests will be added as we refactor
