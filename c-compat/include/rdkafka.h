#ifndef _RDKAFKA_H_
#define _RDKAFKA_H_

#include <stddef.h>
#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

/**
 * Zig Kafka C Compatibility Library
 * Drop-in replacement for librdkafka v2.13.0
 *
 * This is a minimal but functional subset of the librdkafka API
 * implemented in Zig for compatibility with existing C/C++ applications.
 */

//
// Opaque types
//

typedef struct rd_kafka_s rd_kafka_t;
typedef struct rd_kafka_topic_s rd_kafka_topic_t;
typedef struct rd_kafka_conf_s rd_kafka_conf_t;
typedef struct rd_kafka_topic_conf_s rd_kafka_topic_conf_t;
typedef struct rd_kafka_headers_s rd_kafka_headers_t;
typedef struct rd_kafka_queue_s rd_kafka_queue_t;

//
// Enums
//

typedef enum {
    RD_KAFKA_PRODUCER = 0,
    RD_KAFKA_CONSUMER = 1,
} rd_kafka_type_t;

typedef enum {
    RD_KAFKA_CONF_UNKNOWN = -2,
    RD_KAFKA_CONF_INVALID = -1,
    RD_KAFKA_CONF_OK = 0,
} rd_kafka_conf_res_t;

typedef enum {
    // Internal errors
    RD_KAFKA_RESP_ERR__BEGIN = -200,
    RD_KAFKA_RESP_ERR__BAD_MSG = -199,
    RD_KAFKA_RESP_ERR__BAD_COMPRESSION = -198,
    RD_KAFKA_RESP_ERR__DESTROY = -197,
    RD_KAFKA_RESP_ERR__FAIL = -196,
    RD_KAFKA_RESP_ERR__TRANSPORT = -195,
    RD_KAFKA_RESP_ERR__CRIT_SYS_RESOURCE = -194,
    RD_KAFKA_RESP_ERR__RESOLVE = -193,
    RD_KAFKA_RESP_ERR__MSG_TIMED_OUT = -192,
    RD_KAFKA_RESP_ERR__PARTITION_EOF = -191,
    RD_KAFKA_RESP_ERR__UNKNOWN_PARTITION = -190,
    RD_KAFKA_RESP_ERR__FS = -189,
    RD_KAFKA_RESP_ERR__UNKNOWN_TOPIC = -188,
    RD_KAFKA_RESP_ERR__ALL_BROKERS_DOWN = -187,
    RD_KAFKA_RESP_ERR__INVALID_ARG = -186,
    RD_KAFKA_RESP_ERR__TIMED_OUT = -185,
    RD_KAFKA_RESP_ERR__QUEUE_FULL = -184,
    RD_KAFKA_RESP_ERR__ISR_INSUFF = -183,
    RD_KAFKA_RESP_ERR__NODE_UPDATE = -182,
    RD_KAFKA_RESP_ERR__SSL = -181,
    RD_KAFKA_RESP_ERR__WAIT_COORD = -180,
    RD_KAFKA_RESP_ERR__UNKNOWN_GROUP = -179,
    RD_KAFKA_RESP_ERR__IN_PROGRESS = -178,
    RD_KAFKA_RESP_ERR__PREV_IN_PROGRESS = -177,
    RD_KAFKA_RESP_ERR__EXISTING_SUBSCRIPTION = -176,
    RD_KAFKA_RESP_ERR__ASSIGN_PARTITIONS = -175,
    RD_KAFKA_RESP_ERR__REVOKE_PARTITIONS = -174,
    RD_KAFKA_RESP_ERR__CONFLICT = -173,
    RD_KAFKA_RESP_ERR__STATE = -172,
    RD_KAFKA_RESP_ERR__UNKNOWN_PROTOCOL = -171,
    RD_KAFKA_RESP_ERR__NOT_IMPLEMENTED = -170,
    RD_KAFKA_RESP_ERR__AUTHENTICATION = -169,
    RD_KAFKA_RESP_ERR__NO_OFFSET = -168,
    RD_KAFKA_RESP_ERR__OUTDATED = -167,
    RD_KAFKA_RESP_ERR__TIMED_OUT_QUEUE = -166,
    RD_KAFKA_RESP_ERR__UNSUPPORTED_FEATURE = -165,
    RD_KAFKA_RESP_ERR__WAIT_CACHE = -164,
    RD_KAFKA_RESP_ERR__INTR = -163,
    RD_KAFKA_RESP_ERR__KEY_SERIALIZATION = -162,
    RD_KAFKA_RESP_ERR__VALUE_SERIALIZATION = -161,
    RD_KAFKA_RESP_ERR__KEY_DESERIALIZATION = -160,
    RD_KAFKA_RESP_ERR__VALUE_DESERIALIZATION = -159,
    RD_KAFKA_RESP_ERR__PARTIAL = -158,
    RD_KAFKA_RESP_ERR__READ_ONLY = -157,
    RD_KAFKA_RESP_ERR__NOENT = -156,
    RD_KAFKA_RESP_ERR__UNDERFLOW = -155,
    RD_KAFKA_RESP_ERR__INVALID_TYPE = -154,
    RD_KAFKA_RESP_ERR__RETRY = -153,
    RD_KAFKA_RESP_ERR__PURGE_QUEUE = -152,
    RD_KAFKA_RESP_ERR__PURGE_INFLIGHT = -151,
    RD_KAFKA_RESP_ERR__FATAL = -150,
    RD_KAFKA_RESP_ERR__INCONSISTENT = -149,
    RD_KAFKA_RESP_ERR__GAPLESS_GUARANTEE = -148,
    RD_KAFKA_RESP_ERR__MAX_POLL_EXCEEDED = -147,
    RD_KAFKA_RESP_ERR__UNKNOWN_BROKER = -146,
    RD_KAFKA_RESP_ERR__NOT_CONFIGURED = -145,
    RD_KAFKA_RESP_ERR__FENCED = -144,
    RD_KAFKA_RESP_ERR__APPLICATION = -143,
    RD_KAFKA_RESP_ERR__ASSIGNMENT_LOST = -142,
    RD_KAFKA_RESP_ERR__NOOP = -141,
    RD_KAFKA_RESP_ERR__AUTO_OFFSET_RESET = -140,
    RD_KAFKA_RESP_ERR__LOG_TRUNCATION = -139,
    RD_KAFKA_RESP_ERR__END = -100,

    // Kafka broker errors
    RD_KAFKA_RESP_ERR_NO_ERROR = 0,
    RD_KAFKA_RESP_ERR_OFFSET_OUT_OF_RANGE = 1,
    RD_KAFKA_RESP_ERR_CORRUPT_MESSAGE = 2,
    RD_KAFKA_RESP_ERR_UNKNOWN_TOPIC_OR_PARTITION = 3,
    RD_KAFKA_RESP_ERR_INVALID_FETCH_SIZE = 4,
    RD_KAFKA_RESP_ERR_LEADER_NOT_AVAILABLE = 5,
    RD_KAFKA_RESP_ERR_NOT_LEADER_FOR_PARTITION = 6,
    RD_KAFKA_RESP_ERR_REQUEST_TIMED_OUT = 7,
    RD_KAFKA_RESP_ERR_BROKER_NOT_AVAILABLE = 8,
    RD_KAFKA_RESP_ERR_REPLICA_NOT_AVAILABLE = 9,
    RD_KAFKA_RESP_ERR_MESSAGE_TOO_LARGE = 10,
    RD_KAFKA_RESP_ERR_STALE_CONTROLLER_EPOCH = 11,
    RD_KAFKA_RESP_ERR_OFFSET_METADATA_TOO_LARGE = 12,
    RD_KAFKA_RESP_ERR_NETWORK_EXCEPTION = 13,
    RD_KAFKA_RESP_ERR_COORDINATOR_LOAD_IN_PROGRESS = 14,
    RD_KAFKA_RESP_ERR_COORDINATOR_NOT_AVAILABLE = 15,
    RD_KAFKA_RESP_ERR_NOT_COORDINATOR = 16,
    RD_KAFKA_RESP_ERR_INVALID_TOPIC_EXCEPTION = 17,
    RD_KAFKA_RESP_ERR_RECORD_LIST_TOO_LARGE = 18,
    RD_KAFKA_RESP_ERR_NOT_ENOUGH_REPLICAS = 19,
    RD_KAFKA_RESP_ERR_NOT_ENOUGH_REPLICAS_AFTER_APPEND = 20,
    RD_KAFKA_RESP_ERR_INVALID_REQUIRED_ACKS = 21,
    RD_KAFKA_RESP_ERR_ILLEGAL_GENERATION = 22,
    RD_KAFKA_RESP_ERR_INCONSISTENT_GROUP_PROTOCOL = 23,
    RD_KAFKA_RESP_ERR_INVALID_GROUP_ID = 24,
    RD_KAFKA_RESP_ERR_UNKNOWN_MEMBER_ID = 25,
    RD_KAFKA_RESP_ERR_INVALID_SESSION_TIMEOUT = 26,
    RD_KAFKA_RESP_ERR_REBALANCE_IN_PROGRESS = 27,
    RD_KAFKA_RESP_ERR_INVALID_COMMIT_OFFSET_SIZE = 28,
    RD_KAFKA_RESP_ERR_TOPIC_AUTHORIZATION_FAILED = 29,
    RD_KAFKA_RESP_ERR_GROUP_AUTHORIZATION_FAILED = 30,
    RD_KAFKA_RESP_ERR_CLUSTER_AUTHORIZATION_FAILED = 31,
} rd_kafka_resp_err_t;

typedef enum {
    RD_KAFKA_TIMESTAMP_NOT_AVAILABLE = 0,
    RD_KAFKA_TIMESTAMP_CREATE_TIME = 1,
    RD_KAFKA_TIMESTAMP_LOG_APPEND_TIME = 2,
} rd_kafka_timestamp_type_t;

//
// Structures
//

typedef struct rd_kafka_message_s {
    rd_kafka_resp_err_t err;
    rd_kafka_topic_t *rkt;
    int32_t partition;
    void *payload;
    size_t len;
    void *key;
    size_t key_len;
    int64_t offset;
    void *_private;
} rd_kafka_message_t;

typedef struct rd_kafka_topic_partition_s {
    const char *topic;
    int32_t partition;
    int64_t offset;
    void *metadata;
    size_t metadata_size;
    void *opaque;
    rd_kafka_resp_err_t err;
    void *_private;
} rd_kafka_topic_partition_t;

typedef struct rd_kafka_topic_partition_list_s {
    int cnt;
    int size;
    rd_kafka_topic_partition_t *elems;
} rd_kafka_topic_partition_list_t;

//
// Constants
//

#define RD_KAFKA_MSG_F_FREE    0x1
#define RD_KAFKA_MSG_F_COPY    0x2
#define RD_KAFKA_MSG_F_BLOCK   0x4
#define RD_KAFKA_MSG_F_PARTITION 0x8

#define RD_KAFKA_OFFSET_BEGINNING  ((int64_t)-2)
#define RD_KAFKA_OFFSET_END        ((int64_t)-1)
#define RD_KAFKA_OFFSET_STORED     ((int64_t)-1000)
#define RD_KAFKA_OFFSET_INVALID    ((int64_t)-1001)

//
// Configuration API
//

rd_kafka_conf_t *rd_kafka_conf_new(void);
void rd_kafka_conf_destroy(rd_kafka_conf_t *conf);
rd_kafka_conf_res_t rd_kafka_conf_set(rd_kafka_conf_t *conf,
                                       const char *name,
                                       const char *value,
                                       char *errstr,
                                       size_t errstr_size);
rd_kafka_conf_t *rd_kafka_conf_dup(const rd_kafka_conf_t *conf);

//
// Client lifecycle
//

rd_kafka_t *rd_kafka_new(rd_kafka_type_t type,
                         rd_kafka_conf_t *conf,
                         char *errstr,
                         size_t errstr_size);
void rd_kafka_destroy(rd_kafka_t *rk);
const char *rd_kafka_name(const rd_kafka_t *rk);
rd_kafka_type_t rd_kafka_type(const rd_kafka_t *rk);

//
// Topic API
//

rd_kafka_topic_t *rd_kafka_topic_new(rd_kafka_t *rk,
                                     const char *topic,
                                     rd_kafka_topic_conf_t *conf);
void rd_kafka_topic_destroy(rd_kafka_topic_t *rkt);
const char *rd_kafka_topic_name(const rd_kafka_topic_t *rkt);

//
// Producer API
//

int rd_kafka_produce(rd_kafka_topic_t *rkt,
                     int32_t partition,
                     int msgflags,
                     void *payload,
                     size_t len,
                     const void *key,
                     size_t keylen,
                     void *msg_opaque);
int rd_kafka_flush(rd_kafka_t *rk, int timeout_ms);
int rd_kafka_poll(rd_kafka_t *rk, int timeout_ms);

//
// Consumer API
//

int rd_kafka_subscribe(rd_kafka_t *rk,
                       const rd_kafka_topic_partition_list_t *topics);
rd_kafka_message_t *rd_kafka_consumer_poll(rd_kafka_t *rk, int timeout_ms);
void rd_kafka_message_destroy(rd_kafka_message_t *rkmessage);
int rd_kafka_consumer_close(rd_kafka_t *rk);
int rd_kafka_assignment(rd_kafka_t *rk,
                        rd_kafka_topic_partition_list_t **partitions);
int rd_kafka_committed(rd_kafka_t *rk,
                       rd_kafka_topic_partition_list_t *partitions,
                       int timeout_ms);
int rd_kafka_commit(rd_kafka_t *rk,
                    rd_kafka_topic_partition_list_t *offsets,
                    int async);

//
// Topic Partition List API
//

rd_kafka_topic_partition_list_t *rd_kafka_topic_partition_list_new(int size);
void rd_kafka_topic_partition_list_destroy(rd_kafka_topic_partition_list_t *rkparlist);
rd_kafka_topic_partition_t *rd_kafka_topic_partition_list_add(
    rd_kafka_topic_partition_list_t *rktparlist,
    const char *topic,
    int32_t partition);

//
// Error handling
//

const char *rd_kafka_err2str(rd_kafka_resp_err_t err);
const char *rd_kafka_err2name(rd_kafka_resp_err_t err);
rd_kafka_resp_err_t rd_kafka_last_error(void);

//
// Version
//

int rd_kafka_version(void);
const char *rd_kafka_version_str(void);

#ifdef __cplusplus
}
#endif

#endif /* _RDKAFKA_H_ */
