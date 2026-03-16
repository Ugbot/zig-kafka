const std = @import("std");

// Re-export generated protocol types (used internally by wire/client layers)
pub const generated = @import("kafka_generated");

// Protocol layer (wire types and encoding)
pub const protocol = struct {
    pub const types = generated.types;
    pub const frame = @import("protocol/frame.zig");
    pub const compression = @import("protocol/compression.zig");
    pub const record_batch = generated.record_batch;
    pub const message_format = @import("protocol/message_format.zig");
};

// Generated protocol messages - convenient re-exports for external users
pub const messages = struct {
    // Produce/Fetch (core message APIs)
    pub const ProduceRequest = generated.produce_request.ProduceRequest;
    pub const ProduceResponse = generated.produce_response.ProduceResponse;
    pub const FetchRequest = generated.fetch_request.FetchRequest;
    pub const FetchResponse = generated.fetch_response.FetchResponse;

    // Metadata
    pub const MetadataRequest = generated.metadata_request.MetadataRequest;
    pub const MetadataResponse = generated.metadata_response.MetadataResponse;
    pub const ApiVersionsRequest = generated.api_versions_request.ApiVersionsRequest;
    pub const ApiVersionsResponse = generated.api_versions_response.ApiVersionsResponse;

    // Consumer groups
    pub const FindCoordinatorRequest = generated.find_coordinator_request.FindCoordinatorRequest;
    pub const FindCoordinatorResponse = generated.find_coordinator_response.FindCoordinatorResponse;
    pub const JoinGroupRequest = generated.join_group_request.JoinGroupRequest;
    pub const JoinGroupResponse = generated.join_group_response.JoinGroupResponse;
    pub const SyncGroupRequest = generated.sync_group_request.SyncGroupRequest;
    pub const SyncGroupResponse = generated.sync_group_response.SyncGroupResponse;
    pub const HeartbeatRequest = generated.heartbeat_request.HeartbeatRequest;
    pub const HeartbeatResponse = generated.heartbeat_response.HeartbeatResponse;
    pub const LeaveGroupRequest = generated.leave_group_request.LeaveGroupRequest;
    pub const LeaveGroupResponse = generated.leave_group_response.LeaveGroupResponse;

    // Offsets
    pub const OffsetFetchRequest = generated.offset_fetch_request.OffsetFetchRequest;
    pub const OffsetFetchResponse = generated.offset_fetch_response.OffsetFetchResponse;
    pub const OffsetCommitRequest = generated.offset_commit_request.OffsetCommitRequest;
    pub const OffsetCommitResponse = generated.offset_commit_response.OffsetCommitResponse;
    pub const ListOffsetsRequest = generated.list_offsets_request.ListOffsetsRequest;
    pub const ListOffsetsResponse = generated.list_offsets_response.ListOffsetsResponse;

    // Transactions
    pub const InitProducerIdRequest = generated.init_producer_id_request.InitProducerIdRequest;
    pub const InitProducerIdResponse = generated.init_producer_id_response.InitProducerIdResponse;
    pub const AddPartitionsToTxnRequest = generated.add_partitions_to_txn_request.AddPartitionsToTxnRequest;
    pub const AddPartitionsToTxnResponse = generated.add_partitions_to_txn_response.AddPartitionsToTxnResponse;
    pub const EndTxnRequest = generated.end_txn_request.EndTxnRequest;
    pub const EndTxnResponse = generated.end_txn_response.EndTxnResponse;

    // Admin
    pub const CreateTopicsRequest = generated.create_topics_request.CreateTopicsRequest;
    pub const CreateTopicsResponse = generated.create_topics_response.CreateTopicsResponse;
    pub const DeleteTopicsRequest = generated.delete_topics_request.DeleteTopicsRequest;
    pub const DeleteTopicsResponse = generated.delete_topics_response.DeleteTopicsResponse;
    pub const DescribeConfigsRequest = generated.describe_configs_request.DescribeConfigsRequest;
    pub const DescribeConfigsResponse = generated.describe_configs_response.DescribeConfigsResponse;
};

// Wire protocol layer
pub const wire = struct {
    pub const BrokerPool = @import("wire/broker_pool.zig").BrokerPool;
    pub const Connection = @import("wire/connection.zig").Connection;
    pub const request = @import("wire/request.zig");
    pub const response = @import("wire/response.zig");
    pub const api_versions = @import("wire/api_versions.zig");
};

// Client SDK (high-level API)
pub const client = struct {
    pub const KafkaClient = @import("client/client.zig").KafkaClient;
    pub const KafkaProducer = @import("client/producer/producer.zig").KafkaProducer;
    pub const KafkaConsumer = @import("client/consumer/consumer.zig").KafkaConsumer;
    pub const KafkaAdmin = @import("client/admin/admin.zig").KafkaAdmin;
};

// Re-export config types for c-compat and external users
pub const ClientConfig = @import("client/config.zig").ClientConfig;
pub const ProducerConfig = @import("client/config.zig").ProducerConfig;
pub const ConsumerConfig = @import("client/config.zig").ConsumerConfig;
pub const BrokerAddress = @import("client/config.zig").BrokerAddress;

// Re-export commonly used types for convenience
pub const KafkaClient = client.KafkaClient;
pub const Producer = client.KafkaProducer;
pub const Consumer = client.KafkaConsumer;
pub const Admin = client.KafkaAdmin;
pub const RecordBatch = protocol.record_batch.RecordBatch;

test {
    // Import all modules to ensure they compile
    std.testing.refAllDecls(@This());
}
