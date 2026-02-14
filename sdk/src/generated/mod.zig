//! Generated Kafka Protocol Messages
//! Auto-generated module index

// Core Protocol Messages
pub const ApiVersionsRequest = @import("api_versions_request.zig");
pub const ApiVersionsResponse = @import("api_versions_response.zig");
pub const MetadataRequest = @import("metadata_request.zig");
pub const MetadataResponse = @import("metadata_response.zig");
pub const ProduceRequest = @import("produce_request.zig");
pub const ProduceResponse = @import("produce_response.zig");
pub const FetchRequest = @import("fetch_request.zig");
pub const FetchResponse = @import("fetch_response.zig");

// Offset Management
pub const ListOffsetsRequest = @import("list_offsets_request.zig");
pub const ListOffsetsResponse = @import("list_offsets_response.zig");
pub const OffsetCommitRequest = @import("offset_commit_request.zig");
pub const OffsetCommitResponse = @import("offset_commit_response.zig");
pub const OffsetFetchRequest = @import("offset_fetch_request.zig");
pub const OffsetFetchResponse = @import("offset_fetch_response.zig");

// Group Management
pub const FindCoordinatorRequest = @import("find_coordinator_request.zig");
pub const FindCoordinatorResponse = @import("find_coordinator_response.zig");
pub const JoinGroupRequest = @import("join_group_request.zig");
pub const JoinGroupResponse = @import("join_group_response.zig");
pub const HeartbeatRequest = @import("heartbeat_request.zig");
pub const HeartbeatResponse = @import("heartbeat_response.zig");
pub const LeaveGroupRequest = @import("leave_group_request.zig");
pub const LeaveGroupResponse = @import("leave_group_response.zig");
pub const SyncGroupRequest = @import("sync_group_request.zig");
pub const SyncGroupResponse = @import("sync_group_response.zig");
pub const ListGroupsRequest = @import("list_groups_request.zig");
pub const ListGroupsResponse = @import("list_groups_response.zig");
pub const DescribeGroupsRequest = @import("describe_groups_request.zig");
pub const DescribeGroupsResponse = @import("describe_groups_response.zig");

// Topic Management
pub const CreateTopicsRequest = @import("create_topics_request.zig");
pub const CreateTopicsResponse = @import("create_topics_response.zig");
pub const DeleteTopicsRequest = @import("delete_topics_request.zig");
pub const DeleteTopicsResponse = @import("delete_topics_response.zig");

// Configuration Management
pub const DescribeConfigsRequest = @import("describe_configs_request.zig");
pub const DescribeConfigsResponse = @import("describe_configs_response.zig");
pub const AlterConfigsRequest = @import("alter_configs_request.zig");
pub const AlterConfigsResponse = @import("alter_configs_response.zig");

// Re-export types for convenience
pub const types = @import("../protocol/types.zig");
