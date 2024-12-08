const std = @import("std");
const day_6 = @import("day_7/main.zig");

pub fn main() !void {

    var args = std.process.args();
    var part: u8 = undefined;
    _ = args.next();
    while(args.next()) |arg| {
        part = try std.fmt.parseInt(u8, arg, 10);
    }
    
    const result = try day_6.day(part, false);
    std.debug.print("Result: {}\n", .{result});
}

test "part 1" {
    try std.testing.expectEqual(day_6.part_1_expected(), day_6.day(1, true));
}

test "part 2" {
    try std.testing.expectEqual(day_6.part_2_expected(), day_6.day(2, true));
}
