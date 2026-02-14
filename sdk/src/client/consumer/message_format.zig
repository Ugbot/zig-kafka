// RecordBatch parsing for consumer
// Re-exports parseRecordBatch from codec layer

const kafka_codec = @import("kafka_codec");

pub const TickStreamMessage = kafka_codec.TickStreamMessage;
pub const parseRecordBatch = kafka_codec.parseRecordBatch;
