const std = @import("std");
const TopicPartition = @import("../metadata/topic_partition.zig").TopicPartition;

/// Partition assignment strategy interface.
/// Defines how partitions are distributed across consumers in a group.
pub const Assignor = struct {
    name: []const u8,
    assign_fn: *const fn (
        members: []const Member,
        topics: []const Topic,
        allocator: std.mem.Allocator,
    ) anyerror![]MemberAssignment,

    /// Information about a consumer group member.
    pub const Member = struct {
        member_id: []const u8,
        subscribed_topics: []const []const u8,
    };

    /// Information about a topic's partitions.
    pub const Topic = struct {
        name: []const u8,
        partition_count: i32,
    };

    /// Assignment result for a single member.
    pub const MemberAssignment = struct {
        member_id: []const u8,
        partitions: []TopicPartition,

        pub fn deinit(self: *MemberAssignment, allocator: std.mem.Allocator) void {
            allocator.free(self.partitions);
        }
    };

    /// Perform assignment.
    pub fn assign(
        self: *const Assignor,
        members: []const Member,
        topics: []const Topic,
        allocator: std.mem.Allocator,
    ) ![]MemberAssignment {
        return self.assign_fn(members, topics, allocator);
    }
};

/// Free all assignments returned by an assignor.
pub fn freeAssignments(assignments: []Assignor.MemberAssignment, allocator: std.mem.Allocator) void {
    for (assignments) |*assignment| {
        allocator.free(assignment.partitions);
    }
    allocator.free(assignments);
}

// ============================================================================
// Pre-defined assignors
// ============================================================================

/// Range partition assignment strategy.
/// Imported from range_assignor.zig.
pub const range_assignor = @import("range_assignor.zig").range_assignor;

/// Round-robin partition assignment strategy.
/// Imported from roundrobin_assignor.zig.
pub const roundrobin_assignor = @import("roundrobin_assignor.zig").roundrobin_assignor;

// ============================================================================
// Helper Functions
// ============================================================================

/// Check if a member subscribes to a topic.
pub fn memberSubscribesToTopic(member: Assignor.Member, topic: []const u8) bool {
    for (member.subscribed_topics) |sub_topic| {
        if (std.mem.eql(u8, sub_topic, topic)) return true;
    }
    return false;
}

/// Sort members lexicographically by member_id.
pub fn sortMembers(members: []Assignor.Member) void {
    std.mem.sort(Assignor.Member, members, {}, memberLessThan);
}

fn memberLessThan(_: void, a: Assignor.Member, b: Assignor.Member) bool {
    return std.mem.order(u8, a.member_id, b.member_id) == .lt;
}

// ============================================================================
// Tests
// ============================================================================

test "memberSubscribesToTopic" {
    const member = Assignor.Member{
        .member_id = "consumer-1",
        .subscribed_topics = &[_][]const u8{ "orders", "events" },
    };

    try std.testing.expect(memberSubscribesToTopic(member, "orders"));
    try std.testing.expect(memberSubscribesToTopic(member, "events"));
    try std.testing.expect(!memberSubscribesToTopic(member, "metrics"));
}

test "sortMembers lexicographically" {
    const allocator = std.testing.allocator;

    var members = try allocator.alloc(Assignor.Member, 3);
    defer allocator.free(members);

    members[0] = .{ .member_id = "consumer-3", .subscribed_topics = &.{} };
    members[1] = .{ .member_id = "consumer-1", .subscribed_topics = &.{} };
    members[2] = .{ .member_id = "consumer-2", .subscribed_topics = &.{} };

    sortMembers(members);

    try std.testing.expectEqualStrings("consumer-1", members[0].member_id);
    try std.testing.expectEqualStrings("consumer-2", members[1].member_id);
    try std.testing.expectEqualStrings("consumer-3", members[2].member_id);
}
