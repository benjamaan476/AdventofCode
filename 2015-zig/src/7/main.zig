const std = @import("std");

const data = @embedFile("data.txt");

const instruction = struct {
    to: []const u8,
};

pub fn main() !void {
    var lines = std.mem.tokenizeScalar(u8, data, '\n');
    while (lines.next()) |l| {
        const line = std.mem.trimEnd(u8, l, "\r");
        _ = line;
    }

    const count: u64 = 0;

    std.debug.print("Num lights: {}\n", .{count});
}
