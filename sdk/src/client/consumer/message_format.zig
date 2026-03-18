// RecordBatch parsing for consumer
// Re-exports parseRecordBatch from protocol layer

const protocol_message_format = @import("../../protocol/message_format.zig");

pub const TickStreamMessage = protocol_message_format.TickStreamMessage;
pub const parseRecordBatch = protocol_message_format.parseRecordBatch;
