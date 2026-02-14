//! Re-export index for generated Kafka protocol types.
//!
//! This file lives within src/codecs/kafka/ so that all relative imports
//! stay within the module's directory tree (Zig 0.14 requirement).
//! Used by the kafka_client module via named import "kafka_generated".

// Wire type primitives
pub const types = @import("protocol/types.zig");

// Record batch format
pub const record_batch = @import("protocol/record_batch.zig");

// Request/Response Headers
pub const request_header = @import("generated/request_header.zig");
pub const response_header = @import("generated/response_header.zig");

// API Versions
pub const api_versions_request = @import("generated/api_versions_request.zig");
pub const api_versions_response = @import("generated/api_versions_response.zig");

// Metadata
pub const metadata_request = @import("generated/metadata_request.zig");
pub const metadata_response = @import("generated/metadata_response.zig");

// Produce
pub const produce_request = @import("generated/produce_request.zig");
pub const produce_response = @import("generated/produce_response.zig");

// Fetch
pub const fetch_request = @import("generated/fetch_request.zig");
pub const fetch_response = @import("generated/fetch_response.zig");

// Consumer Group
pub const find_coordinator_request = @import("generated/find_coordinator_request.zig");
pub const find_coordinator_response = @import("generated/find_coordinator_response.zig");
pub const join_group_request = @import("generated/join_group_request.zig");
pub const join_group_response = @import("generated/join_group_response.zig");
pub const sync_group_request = @import("generated/sync_group_request.zig");
pub const sync_group_response = @import("generated/sync_group_response.zig");
pub const heartbeat_request = @import("generated/heartbeat_request.zig");
pub const heartbeat_response = @import("generated/heartbeat_response.zig");
pub const leave_group_request = @import("generated/leave_group_request.zig");
pub const leave_group_response = @import("generated/leave_group_response.zig");

// Offsets
pub const offset_commit_request = @import("generated/offset_commit_request.zig");
pub const offset_commit_response = @import("generated/offset_commit_response.zig");
pub const offset_fetch_request = @import("generated/offset_fetch_request.zig");
pub const offset_fetch_response = @import("generated/offset_fetch_response.zig");
pub const list_offsets_request = @import("generated/list_offsets_request.zig");
pub const list_offsets_response = @import("generated/list_offsets_response.zig");

// Idempotent Producer
pub const init_producer_id_request = @import("generated/init_producer_id_request.zig");
pub const init_producer_id_response = @import("generated/init_producer_id_response.zig");

// Transactions
pub const add_partitions_to_txn_request = @import("generated/add_partitions_to_txn_request.zig");
pub const add_partitions_to_txn_response = @import("generated/add_partitions_to_txn_response.zig");
pub const end_txn_request = @import("generated/end_txn_request.zig");
pub const end_txn_response = @import("generated/end_txn_response.zig");

// Admin
pub const create_topics_request = @import("generated/create_topics_request.zig");
pub const create_topics_response = @import("generated/create_topics_response.zig");
pub const delete_topics_request = @import("generated/delete_topics_request.zig");
pub const delete_topics_response = @import("generated/delete_topics_response.zig");
pub const list_groups_request = @import("generated/list_groups_request.zig");
pub const list_groups_response = @import("generated/list_groups_response.zig");
pub const delete_groups_request = @import("generated/delete_groups_request.zig");
pub const delete_groups_response = @import("generated/delete_groups_response.zig");
