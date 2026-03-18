const std = @import("std");
const Assignor = @import("assignor.zig").Assignor;
const TopicPartition = @import("../metadata/topic_partition.zig").TopicPartition;
const memberSubscribesToTopic = @import("assignor.zig").memberSubscribesToTopic;
const sortMembers = @import("assignor.zig").sortMembers;

/// Round-robin partition assignment strategy.
///
/// Algorithm:
/// 1. Sort consumers lexicographically by member_id
/// 2. Flatten all topic-partitions into a single list
/// 3. Assign partitions cyclically to consumers in round-robin fashion
/// 4. Skip consumers that don't subscribe to a partition's topic
///
/// Example:
/// - 2 consumers (C0, C1), 2 topics (T1, T2), 3 partitions each:
///   - All partitions: T1-0, T1-1, T1-2, T2-0, T2-1, T2-2
///   - C0: T1-0, T1-2, T2-1
///   - C1: T1-1, T2-0, T2-2
///
/// This matches librdkafka's round-robin assignor behavior.
pub const roundrobin_assignor = Assignor{
    .name = "org.apache.kafka.clients.consumer.RoundRobinAssignor",
    .assign_fn = &roundRobinAssign,
};

pub fn roundRobinAssign(
    members: []const Assignor.Member,
    topics: []const Assignor.Topic,
    allocator: std.mem.Allocator,
) ![]Assignor.MemberAssignment {
    if (members.len == 0) {
        return try allocator.alloc(Assignor.MemberAssignment, 0);
    }

    // Sort members lexicographically (need mutable copy)
    const sorted_members = try allocator.alloc(Assignor.Member, members.len);
    defer allocator.free(sorted_members);
    @memcpy(sorted_members, members);
    sortMembers(sorted_members);

    // Initialize assignments for each member
    var assignments = try allocator.alloc(Assignor.MemberAssignment, sorted_members.len);
    errdefer allocator.free(assignments);

    for (sorted_members, 0..) |member, i| {
        assignments[i] = .{
            .member_id = member.member_id,
            .partitions = &[_]TopicPartition{},
        };
    }

    // Flatten all partitions across all topics
    var all_partitions = std.array_list.Managed(TopicPartition).init(allocator);
    defer all_partitions.deinit();

    for (topics) |topic| {
        var p: i32 = 0;
        while (p < topic.partition_count) : (p += 1) {
            try all_partitions.append(.{
                .topic = topic.name,
                .partition = p,
            });
        }
    }

    // Round-robin assignment
    var member_idx: usize = 0;
    for (all_partitions.items) |tp| {
        // Find next member subscribing to this topic
        var attempts: usize = 0;
        while (attempts < sorted_members.len) : (attempts += 1) {
            if (memberSubscribesToTopic(sorted_members[member_idx], tp.topic)) {
                // Assign partition to this member
                const old_partitions = assignments[member_idx].partitions;
                const new_size = old_partitions.len + 1;
                var new_partitions = try allocator.alloc(TopicPartition, new_size);

                // Copy existing partitions
                @memcpy(new_partitions[0..old_partitions.len], old_partitions);

                // Add new partition
                new_partitions[old_partitions.len] = tp;

                // Free old array and update
                if (old_partitions.len > 0) {
                    allocator.free(old_partitions);
                }
                assignments[member_idx].partitions = new_partitions;

                // Move to next member
                member_idx = (member_idx + 1) % sorted_members.len;
                break;
            }
            member_idx = (member_idx + 1) % sorted_members.len;
        }
    }

    return assignments;
}

// ============================================================================
// Tests
// ============================================================================

test "roundrobin assignment - single topic, even split" {
    const allocator = std.testing.allocator;

    const members = [_]Assignor.Member{
        .{ .member_id = "C0", .subscribed_topics = &[_][]const u8{"orders"} },
        .{ .member_id = "C1", .subscribed_topics = &[_][]const u8{"orders"} },
    };

    const topics = [_]Assignor.Topic{
        .{ .name = "orders", .partition_count = 4 },
    };

    const assignments = try roundRobinAssign(&members, &topics, allocator);
    defer {
        for (assignments) |*a| {
            allocator.free(a.partitions);
        }
        allocator.free(assignments);
    }

    try std.testing.expectEqual(@as(usize, 2), assignments.len);

    // C0: partitions 0, 2
    try std.testing.expectEqualStrings("C0", assignments[0].member_id);
    try std.testing.expectEqual(@as(usize, 2), assignments[0].partitions.len);
    try std.testing.expectEqual(@as(i32, 0), assignments[0].partitions[0].partition);
    try std.testing.expectEqual(@as(i32, 2), assignments[0].partitions[1].partition);

    // C1: partitions 1, 3
    try std.testing.expectEqualStrings("C1", assignments[1].member_id);
    try std.testing.expectEqual(@as(usize, 2), assignments[1].partitions.len);
    try std.testing.expectEqual(@as(i32, 1), assignments[1].partitions[0].partition);
    try std.testing.expectEqual(@as(i32, 3), assignments[1].partitions[1].partition);
}

test "roundrobin assignment - single topic, uneven split" {
    const allocator = std.testing.allocator;

    const members = [_]Assignor.Member{
        .{ .member_id = "C0", .subscribed_topics = &[_][]const u8{"orders"} },
        .{ .member_id = "C1", .subscribed_topics = &[_][]const u8{"orders"} },
    };

    const topics = [_]Assignor.Topic{
        .{ .name = "orders", .partition_count = 3 },
    };

    const assignments = try roundRobinAssign(&members, &topics, allocator);
    defer {
        for (assignments) |*a| {
            allocator.free(a.partitions);
        }
        allocator.free(assignments);
    }

    try std.testing.expectEqual(@as(usize, 2), assignments.len);

    // C0: partitions 0, 2
    try std.testing.expectEqualStrings("C0", assignments[0].member_id);
    try std.testing.expectEqual(@as(usize, 2), assignments[0].partitions.len);
    try std.testing.expectEqual(@as(i32, 0), assignments[0].partitions[0].partition);
    try std.testing.expectEqual(@as(i32, 2), assignments[0].partitions[1].partition);

    // C1: partition 1
    try std.testing.expectEqualStrings("C1", assignments[1].member_id);
    try std.testing.expectEqual(@as(usize, 1), assignments[1].partitions.len);
    try std.testing.expectEqual(@as(i32, 1), assignments[1].partitions[0].partition);
}

test "roundrobin assignment - multiple topics" {
    const allocator = std.testing.allocator;

    const members = [_]Assignor.Member{
        .{ .member_id = "C0", .subscribed_topics = &[_][]const u8{ "orders", "events" } },
        .{ .member_id = "C1", .subscribed_topics = &[_][]const u8{ "orders", "events" } },
    };

    const topics = [_]Assignor.Topic{
        .{ .name = "orders", .partition_count = 3 },
        .{ .name = "events", .partition_count = 3 },
    };

    const assignments = try roundRobinAssign(&members, &topics, allocator);
    defer {
        for (assignments) |*a| {
            allocator.free(a.partitions);
        }
        allocator.free(assignments);
    }

    try std.testing.expectEqual(@as(usize, 2), assignments.len);

    // C0: orders[0], orders[2], events[1]
    try std.testing.expectEqual(@as(usize, 3), assignments[0].partitions.len);

    // C1: orders[1], events[0], events[2]
    try std.testing.expectEqual(@as(usize, 3), assignments[1].partitions.len);
}

test "roundrobin assignment - different subscriptions" {
    const allocator = std.testing.allocator;

    const members = [_]Assignor.Member{
        .{ .member_id = "C0", .subscribed_topics = &[_][]const u8{"orders"} },
        .{ .member_id = "C1", .subscribed_topics = &[_][]const u8{ "orders", "events" } },
        .{ .member_id = "C2", .subscribed_topics = &[_][]const u8{"events"} },
    };

    const topics = [_]Assignor.Topic{
        .{ .name = "orders", .partition_count = 2 },
        .{ .name = "events", .partition_count = 2 },
    };

    const assignments = try roundRobinAssign(&members, &topics, allocator);
    defer {
        for (assignments) |*a| {
            allocator.free(a.partitions);
        }
        allocator.free(assignments);
    }

    try std.testing.expectEqual(@as(usize, 3), assignments.len);

    // Verify all partitions are assigned
    var total_assigned: usize = 0;
    for (assignments) |a| {
        total_assigned += a.partitions.len;
    }
    try std.testing.expectEqual(@as(usize, 4), total_assigned);
}

test "roundrobin assignment - no members" {
    const allocator = std.testing.allocator;

    const members = [_]Assignor.Member{};
    const topics = [_]Assignor.Topic{
        .{ .name = "orders", .partition_count = 3 },
    };

    const assignments = try roundRobinAssign(&members, &topics, allocator);
    defer allocator.free(assignments);

    try std.testing.expectEqual(@as(usize, 0), assignments.len);
}

test "roundrobin assignment - no topics" {
    const allocator = std.testing.allocator;

    const members = [_]Assignor.Member{
        .{ .member_id = "C0", .subscribed_topics = &[_][]const u8{"orders"} },
    };
    const topics = [_]Assignor.Topic{};

    const assignments = try roundRobinAssign(&members, &topics, allocator);
    defer {
        for (assignments) |*a| {
            allocator.free(a.partitions);
        }
        allocator.free(assignments);
    }

    // Member gets empty assignment
    try std.testing.expectEqual(@as(usize, 1), assignments.len);
    try std.testing.expectEqual(@as(usize, 0), assignments[0].partitions.len);
}

test "roundrobin assignment - cyclic distribution" {
    const allocator = std.testing.allocator;

    const members = [_]Assignor.Member{
        .{ .member_id = "C0", .subscribed_topics = &[_][]const u8{"orders"} },
        .{ .member_id = "C1", .subscribed_topics = &[_][]const u8{"orders"} },
        .{ .member_id = "C2", .subscribed_topics = &[_][]const u8{"orders"} },
    };

    const topics = [_]Assignor.Topic{
        .{ .name = "orders", .partition_count = 7 },
    };

    const assignments = try roundRobinAssign(&members, &topics, allocator);
    defer {
        for (assignments) |*a| {
            allocator.free(a.partitions);
        }
        allocator.free(assignments);
    }

    // C0: partitions 0, 3, 6 (3 partitions)
    try std.testing.expectEqual(@as(usize, 3), assignments[0].partitions.len);
    try std.testing.expectEqual(@as(i32, 0), assignments[0].partitions[0].partition);
    try std.testing.expectEqual(@as(i32, 3), assignments[0].partitions[1].partition);
    try std.testing.expectEqual(@as(i32, 6), assignments[0].partitions[2].partition);

    // C1: partitions 1, 4 (2 partitions)
    try std.testing.expectEqual(@as(usize, 2), assignments[1].partitions.len);
    try std.testing.expectEqual(@as(i32, 1), assignments[1].partitions[0].partition);
    try std.testing.expectEqual(@as(i32, 4), assignments[1].partitions[1].partition);

    // C2: partitions 2, 5 (2 partitions)
    try std.testing.expectEqual(@as(usize, 2), assignments[2].partitions.len);
    try std.testing.expectEqual(@as(i32, 2), assignments[2].partitions[0].partition);
    try std.testing.expectEqual(@as(i32, 5), assignments[2].partitions[1].partition);
}

test "roundrobin assignment - lexicographic sorting" {
    const allocator = std.testing.allocator;

    // Members provided out of order
    const members = [_]Assignor.Member{
        .{ .member_id = "C2", .subscribed_topics = &[_][]const u8{"orders"} },
        .{ .member_id = "C0", .subscribed_topics = &[_][]const u8{"orders"} },
        .{ .member_id = "C1", .subscribed_topics = &[_][]const u8{"orders"} },
    };

    const topics = [_]Assignor.Topic{
        .{ .name = "orders", .partition_count = 3 },
    };

    const assignments = try roundRobinAssign(&members, &topics, allocator);
    defer {
        for (assignments) |*a| {
            allocator.free(a.partitions);
        }
        allocator.free(assignments);
    }

    // Should be sorted: C0, C1, C2
    try std.testing.expectEqualStrings("C0", assignments[0].member_id);
    try std.testing.expectEqualStrings("C1", assignments[1].member_id);
    try std.testing.expectEqualStrings("C2", assignments[2].member_id);

    // C0 gets partition 0
    try std.testing.expectEqual(@as(usize, 1), assignments[0].partitions.len);
    try std.testing.expectEqual(@as(i32, 0), assignments[0].partitions[0].partition);

    // C1 gets partition 1
    try std.testing.expectEqual(@as(usize, 1), assignments[1].partitions.len);
    try std.testing.expectEqual(@as(i32, 1), assignments[1].partitions[0].partition);

    // C2 gets partition 2
    try std.testing.expectEqual(@as(usize, 1), assignments[2].partitions.len);
    try std.testing.expectEqual(@as(i32, 2), assignments[2].partitions[0].partition);
}
