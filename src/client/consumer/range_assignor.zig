const std = @import("std");
const Assignor = @import("assignor.zig").Assignor;
const TopicPartition = @import("../metadata/topic_partition.zig").TopicPartition;
const memberSubscribesToTopic = @import("assignor.zig").memberSubscribesToTopic;
const sortMembers = @import("assignor.zig").sortMembers;

/// Range partition assignment strategy.
///
/// For each topic:
/// 1. Sort consumers lexicographically by member_id
/// 2. Divide partitions into ranges and assign to consumers
/// 3. First consumer gets extra partitions if not evenly divisible
///
/// Example:
/// - Topic with 10 partitions, 3 consumers:
///   - C0: partitions 0-3 (4 partitions)
///   - C1: partitions 4-6 (3 partitions)
///   - C2: partitions 7-9 (3 partitions)
///
/// This matches librdkafka's range assignor behavior.
/// Note: Using short name "range" for compatibility with Redpanda
pub const range_assignor = Assignor{
    .name = "range",
    .assign_fn = &rangeAssign,
};

pub fn rangeAssign(
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

    // For each topic, assign partitions in ranges
    for (topics) |topic| {
        // Find members subscribing to this topic
        var subscribing_indices = std.array_list.Managed(usize).init(allocator);
        defer subscribing_indices.deinit();

        for (sorted_members, 0..) |member, idx| {
            if (memberSubscribesToTopic(member, topic.name)) {
                try subscribing_indices.append(idx);
            }
        }

        if (subscribing_indices.items.len == 0) continue;

        // Calculate partitions per member
        const total_partitions = topic.partition_count;
        const member_count: i32 = @intCast(subscribing_indices.items.len);
        const partitions_per_member = @divFloor(total_partitions, member_count);
        const remainder = @mod(total_partitions, member_count);

        // Assign ranges
        var start: i32 = 0;
        for (subscribing_indices.items, 0..) |member_idx, i| {
            const extra: i32 = if (i < remainder) 1 else 0;
            const count = partitions_per_member + extra;

            if (count == 0) continue;

            // Allocate partition array for this member's topic
            const old_partitions = assignments[member_idx].partitions;
            const new_size = old_partitions.len + @as(usize, @intCast(count));
            var new_partitions = try allocator.alloc(TopicPartition, new_size);

            // Copy existing partitions
            @memcpy(new_partitions[0..old_partitions.len], old_partitions);

            // Add new partitions for this topic
            var offset: usize = 0;
            while (offset < count) : (offset += 1) {
                const partition = start + @as(i32, @intCast(offset));
                new_partitions[old_partitions.len + offset] = .{
                    .topic = topic.name,
                    .partition = partition,
                };
            }

            // Free old partition array and update
            if (old_partitions.len > 0) {
                allocator.free(old_partitions);
            }
            assignments[member_idx].partitions = new_partitions;

            start += count;
        }
    }

    return assignments;
}

// ============================================================================
// Tests
// ============================================================================

test "range assignment - single topic, even split" {
    const allocator = std.testing.allocator;

    const members = [_]Assignor.Member{
        .{ .member_id = "C0", .subscribed_topics = &[_][]const u8{"orders"} },
        .{ .member_id = "C1", .subscribed_topics = &[_][]const u8{"orders"} },
    };

    const topics = [_]Assignor.Topic{
        .{ .name = "orders", .partition_count = 4 },
    };

    const assignments = try rangeAssign(&members, &topics, allocator);
    defer {
        for (assignments) |*a| {
            allocator.free(a.partitions);
        }
        allocator.free(assignments);
    }

    try std.testing.expectEqual(@as(usize, 2), assignments.len);

    // C0: partitions 0-1 (2 partitions)
    try std.testing.expectEqualStrings("C0", assignments[0].member_id);
    try std.testing.expectEqual(@as(usize, 2), assignments[0].partitions.len);
    try std.testing.expectEqual(@as(i32, 0), assignments[0].partitions[0].partition);
    try std.testing.expectEqual(@as(i32, 1), assignments[0].partitions[1].partition);

    // C1: partitions 2-3 (2 partitions)
    try std.testing.expectEqualStrings("C1", assignments[1].member_id);
    try std.testing.expectEqual(@as(usize, 2), assignments[1].partitions.len);
    try std.testing.expectEqual(@as(i32, 2), assignments[1].partitions[0].partition);
    try std.testing.expectEqual(@as(i32, 3), assignments[1].partitions[1].partition);
}

test "range assignment - single topic, uneven split" {
    const allocator = std.testing.allocator;

    const members = [_]Assignor.Member{
        .{ .member_id = "C0", .subscribed_topics = &[_][]const u8{"orders"} },
        .{ .member_id = "C1", .subscribed_topics = &[_][]const u8{"orders"} },
    };

    const topics = [_]Assignor.Topic{
        .{ .name = "orders", .partition_count = 3 },
    };

    const assignments = try rangeAssign(&members, &topics, allocator);
    defer {
        for (assignments) |*a| {
            allocator.free(a.partitions);
        }
        allocator.free(assignments);
    }

    try std.testing.expectEqual(@as(usize, 2), assignments.len);

    // C0: partitions 0-1 (2 partitions - gets extra)
    try std.testing.expectEqualStrings("C0", assignments[0].member_id);
    try std.testing.expectEqual(@as(usize, 2), assignments[0].partitions.len);
    try std.testing.expectEqual(@as(i32, 0), assignments[0].partitions[0].partition);
    try std.testing.expectEqual(@as(i32, 1), assignments[0].partitions[1].partition);

    // C1: partition 2 (1 partition)
    try std.testing.expectEqualStrings("C1", assignments[1].member_id);
    try std.testing.expectEqual(@as(usize, 1), assignments[1].partitions.len);
    try std.testing.expectEqual(@as(i32, 2), assignments[1].partitions[0].partition);
}

test "range assignment - multiple topics" {
    const allocator = std.testing.allocator;

    const members = [_]Assignor.Member{
        .{ .member_id = "C0", .subscribed_topics = &[_][]const u8{ "orders", "events" } },
        .{ .member_id = "C1", .subscribed_topics = &[_][]const u8{ "orders", "events" } },
    };

    const topics = [_]Assignor.Topic{
        .{ .name = "orders", .partition_count = 3 },
        .{ .name = "events", .partition_count = 3 },
    };

    const assignments = try rangeAssign(&members, &topics, allocator);
    defer {
        for (assignments) |*a| {
            allocator.free(a.partitions);
        }
        allocator.free(assignments);
    }

    try std.testing.expectEqual(@as(usize, 2), assignments.len);

    // C0: orders[0-1] + events[0-1] = 4 partitions
    try std.testing.expectEqual(@as(usize, 4), assignments[0].partitions.len);

    // C1: orders[2] + events[2] = 2 partitions
    try std.testing.expectEqual(@as(usize, 2), assignments[1].partitions.len);
}

test "range assignment - different subscriptions" {
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

    const assignments = try rangeAssign(&members, &topics, allocator);
    defer {
        for (assignments) |*a| {
            allocator.free(a.partitions);
        }
        allocator.free(assignments);
    }

    try std.testing.expectEqual(@as(usize, 3), assignments.len);

    // C0: orders[0] (1 partition)
    try std.testing.expectEqual(@as(usize, 1), assignments[0].partitions.len);
    try std.testing.expectEqualStrings("orders", assignments[0].partitions[0].topic);

    // C1: orders[1] + events[0] (2 partitions)
    try std.testing.expectEqual(@as(usize, 2), assignments[1].partitions.len);

    // C2: events[1] (1 partition)
    try std.testing.expectEqual(@as(usize, 1), assignments[2].partitions.len);
    try std.testing.expectEqualStrings("events", assignments[2].partitions[0].topic);
}

test "range assignment - no members" {
    const allocator = std.testing.allocator;

    const members = [_]Assignor.Member{};
    const topics = [_]Assignor.Topic{
        .{ .name = "orders", .partition_count = 3 },
    };

    const assignments = try rangeAssign(&members, &topics, allocator);
    defer allocator.free(assignments);

    try std.testing.expectEqual(@as(usize, 0), assignments.len);
}

test "range assignment - no topics" {
    const allocator = std.testing.allocator;

    const members = [_]Assignor.Member{
        .{ .member_id = "C0", .subscribed_topics = &[_][]const u8{"orders"} },
    };
    const topics = [_]Assignor.Topic{};

    const assignments = try rangeAssign(&members, &topics, allocator);
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

test "range assignment - lexicographic sorting" {
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

    const assignments = try rangeAssign(&members, &topics, allocator);
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

    // C0 gets partition 0 (first in sorted order gets extra)
    try std.testing.expectEqual(@as(usize, 1), assignments[0].partitions.len);
    try std.testing.expectEqual(@as(i32, 0), assignments[0].partitions[0].partition);

    // C1 gets partition 1
    try std.testing.expectEqual(@as(usize, 1), assignments[1].partitions.len);
    try std.testing.expectEqual(@as(i32, 1), assignments[1].partitions[0].partition);

    // C2 gets partition 2
    try std.testing.expectEqual(@as(usize, 1), assignments[2].partitions.len);
    try std.testing.expectEqual(@as(i32, 2), assignments[2].partitions[0].partition);
}
