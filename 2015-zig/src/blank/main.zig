const std = @import("std");

const data = @embedFile("data.txt");

pub fn main() !void {
    var count: u64 = 0;
    _ = &count;
    var lines = std.mem.tokenizeScalar(u8, data, '\n');
    while (lines.next()) |l| {
        const line = std.mem.trimEnd(u8, l, "\r");
        _ = line;
    }

    std.debug.print("Count: {}\n", .{count});
}
