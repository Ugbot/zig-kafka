/**
 * Basic test of zig-kafka C compatibility layer
 *
 * This demonstrates the C API is working correctly.
 */

#include <stdio.h>
#include <string.h>
#include "rdkafka.h"

int main(void) {
    printf("Zig Kafka C Compatibility Test\n");
    printf("================================\n\n");

    // Test version
    printf("Library version: %s (0x%08x)\n\n",
           rd_kafka_version_str(),
           rd_kafka_version());

    // Test error strings
    printf("Testing error strings:\n");
    printf("  NO_ERROR: %s\n", rd_kafka_err2str(RD_KAFKA_RESP_ERR_NO_ERROR));
    printf("  LEADER_NOT_AVAILABLE: %s\n",
           rd_kafka_err2str(RD_KAFKA_RESP_ERR_LEADER_NOT_AVAILABLE));
    printf("  _MSG_TIMED_OUT: %s\n",
           rd_kafka_err2str(RD_KAFKA_RESP_ERR__MSG_TIMED_OUT));
    printf("\n");

    // Test configuration
    printf("Testing configuration:\n");
    rd_kafka_conf_t *conf = rd_kafka_conf_new();
    if (!conf) {
        fprintf(stderr, "Failed to create configuration\n");
        return 1;
    }
    printf("  Created configuration\n");

    char errstr[512];
    rd_kafka_conf_res_t res;

    res = rd_kafka_conf_set(conf, "bootstrap.servers", "localhost:9092",
                            errstr, sizeof(errstr));
    if (res != RD_KAFKA_CONF_OK) {
        fprintf(stderr, "  Failed to set bootstrap.servers: %s\n", errstr);
        rd_kafka_conf_destroy(conf);
        return 1;
    }
    printf("  Set bootstrap.servers = localhost:9092\n");

    res = rd_kafka_conf_set(conf, "client.id", "c-api-test",
                            errstr, sizeof(errstr));
    if (res != RD_KAFKA_CONF_OK) {
        fprintf(stderr, "  Failed to set client.id: %s\n", errstr);
        rd_kafka_conf_destroy(conf);
        return 1;
    }
    printf("  Set client.id = c-api-test\n");

    // Test producer creation
    printf("\nTesting producer creation:\n");
    rd_kafka_t *producer = rd_kafka_new(RD_KAFKA_PRODUCER, conf,
                                        errstr, sizeof(errstr));
    if (!producer) {
        fprintf(stderr, "  Failed to create producer: %s\n", errstr);
        return 1;
    }
    printf("  Created producer: %s\n", rd_kafka_name(producer));
    printf("  Type: %s\n",
           rd_kafka_type(producer) == RD_KAFKA_PRODUCER ? "PRODUCER" : "CONSUMER");

    // Note: conf is now owned by producer, don't destroy it

    // Test topic creation
    printf("\nTesting topic creation:\n");
    rd_kafka_topic_t *topic = rd_kafka_topic_new(producer, "test-topic", NULL);
    if (!topic) {
        fprintf(stderr, "  Failed to create topic\n");
        rd_kafka_destroy(producer);
        return 1;
    }
    printf("  Created topic: %s\n", rd_kafka_topic_name(topic));

    // Test topic partition list
    printf("\nTesting topic partition list:\n");
    rd_kafka_topic_partition_list_t *topics = rd_kafka_topic_partition_list_new(2);
    if (!topics) {
        fprintf(stderr, "  Failed to create topic partition list\n");
        rd_kafka_topic_destroy(topic);
        rd_kafka_destroy(producer);
        return 1;
    }
    printf("  Created topic partition list\n");

    rd_kafka_topic_partition_t *tp1 = rd_kafka_topic_partition_list_add(
        topics, "topic1", 0);
    if (!tp1) {
        fprintf(stderr, "  Failed to add partition to list\n");
        rd_kafka_topic_partition_list_destroy(topics);
        rd_kafka_topic_destroy(topic);
        rd_kafka_destroy(producer);
        return 1;
    }
    printf("  Added partition: topic=%s, partition=%d\n", tp1->topic, tp1->partition);

    rd_kafka_topic_partition_t *tp2 = rd_kafka_topic_partition_list_add(
        topics, "topic2", 1);
    if (!tp2) {
        fprintf(stderr, "  Failed to add partition to list\n");
        rd_kafka_topic_partition_list_destroy(topics);
        rd_kafka_topic_destroy(topic);
        rd_kafka_destroy(producer);
        return 1;
    }
    printf("  Added partition: topic=%s, partition=%d\n", tp2->topic, tp2->partition);
    printf("  Total partitions: %d\n", topics->cnt);

    // Cleanup
    printf("\nCleaning up:\n");
    rd_kafka_topic_partition_list_destroy(topics);
    printf("  Destroyed topic partition list\n");
    rd_kafka_topic_destroy(topic);
    printf("  Destroyed topic\n");
    rd_kafka_destroy(producer);
    printf("  Destroyed producer\n");

    printf("\nAll tests passed!\n");
    return 0;
}
