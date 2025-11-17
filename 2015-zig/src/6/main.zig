const std = @import("std");

const data = @embedFile("6.txt");

pub fn main() !void {
    var grid: [1000]u1000 = undefined;

    for (&grid) |*g| {
        g.* = 0;
    }
    var lines = std.mem.tokenizeScalar(u8, data, '\n');
    while (lines.next()) |l| {
        const line = std.mem.trimEnd(u8, l, "\r");
        var tokens = std.mem.tokenizeScalar(u8, line, ' ');
        const first = tokens.next().?;
        const on = if (std.mem.eql(u8, first, "turn"))
            std.mem.eql(u8, tokens.next().?, "on")
        else
            null;

        var from = std.mem.tokenizeAny(u8, tokens.next().?, ",");
        const from_x = try std.fmt.parseInt(u10, from.next().?, 10);
        const from_y = try std.fmt.parseInt(u10, from.next().?, 10);

        _ = tokens.next();

        var to = std.mem.tokenizeAny(u8, tokens.next().?, ",");
        const to_x = try std.fmt.parseInt(u10, to.next().?, 10);
        const to_y = try std.fmt.parseInt(u10, to.next().?, 10);

        for (from_y..to_y + 1) |y| {
            for (from_x..to_x + 1) |x| {
                const pos: u1000 = @as(u1000, 1) << @intCast(x);
                if (on == null) {
                    grid[y] ^= pos;
                } else if (on.?) {
                    grid[y] |= pos;
                } else {
                    grid[y] &= ~pos;
                }
            }
        }
    }

    var file = try std.fs.cwd().createFile("out.txt", .{});
    defer file.close();
    var writer = file.writerStreaming(&.{});
    var count: u64 = 0;
    for (&grid) |g| {
        try (&writer.interface).print("{b}\n", .{g});
        count += @popCount(g);
    }

    std.debug.print("Num lights: {}\n", .{count});
}
