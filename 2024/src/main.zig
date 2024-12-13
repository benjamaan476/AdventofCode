const std = @import("std");
const day = @import("day_13/main.zig");

pub fn main() !void {

    var args = std.process.args();
    var part: u8 = undefined;
    _ = args.next();
    while(args.next()) |arg| {
        part = try std.fmt.parseInt(u8, arg, 10);
    }
    
    const result = try day.day(part, false);
    std.debug.print("Result: {}\n", .{result});
}

test "part 1" {
    try std.testing.expectEqual(day.part_1_expected(), day.day(1, true));
}

test "part 2" {
    try std.testing.expectEqual(day.part_2_expected(), day.day(2, true));
}
