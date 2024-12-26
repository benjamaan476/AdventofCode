const std = @import("std");

pub const Coordinate = struct {
    x: i64,
    y: i64,
};

pub fn split_data(comptime data: []const u8) std.mem.SplitIterator(u8, .scalar) {
    const trimmed_data = std.mem.trim(u8, data, " \t\n");
    return std.mem.splitScalar(u8, trimmed_data, '\n');
}
