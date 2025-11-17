const std = @import("std");

const data = @embedFile("data.txt");

fn process(line: []const u8) u64 {
    const line_count = line.len;
    var count: u8 = 0;
    var i: u8 = 0;
    while (i < line.len) : (i += 1) {
        switch (line[i]) {
            '"' => count += 2,
            '\\' => {
                //if (line[i + 1] == 'x') {
                // hex escape
                //    i += 3;
                //    count += 5;
                // } else {
                // simple escape
                count += 2;
                // }
            },
            else => count += 1,
        }
    }
    return count + 2 - line_count;
}

pub fn main() !void {
    var count: u64 = 0;

    var lines = std.mem.tokenizeScalar(u8, data, '\n');
    while (lines.next()) |l| {
        const line = std.mem.trimEnd(u8, l, "\r");

        count += process(line);
    }

    std.debug.print("Count: {}\n", .{count});
}
