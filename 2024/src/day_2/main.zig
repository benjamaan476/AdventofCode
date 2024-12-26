const std = @import("std");
const test_data = @embedFile("test_data.txt");
const real_data = @embedFile("data.txt");

fn split_data(comptime data: []const u8) std.mem.TokenIterator(u8, .scalar) {
    const trimmed_data = std.mem.trim(u8, data, " \t\n");
    return std.mem.tokenizeScalar(u8, trimmed_data, '\n');
}

pub fn main() !void {
    const result = try part_2(real_data);
    std.debug.print("{}\n", .{result});
}

fn is_monotomic_up(data: []i32) bool {
    var prev: i32 = 0;
    for(data) |item| {
        if (item < prev) {
            return false;
        }
        prev = item;
    }
    return true;
}

fn is_monotomic_down(data: []i32) bool {
    var prev: i32 = 0xFFFF;
    for(data) |item| {
        if (item > prev) {
            return false;
        }
        prev = item;
    }
    return true;
}

fn is_monotomic(data: []i32) bool {
    return is_monotomic_down(data) or is_monotomic_up(data);
}

fn string_to_ints(data: []const u8) ![]i32 {
    var result = std.ArrayList(i32).init(std.heap.page_allocator);
    var it = std.mem.tokenizeScalar(u8, data, ' ');
    while (it.next()) |item| {
        const value = std.fmt.parseInt(i32, item, 10) catch 0;
        try result.append(value);
    }
    return result.items;
}

fn part_1(comptime input_data: [] const u8) !u32 {

    var total : u32 = 0;
    var data = split_data(input_data);

    while (data.next()) |line| {
        const ints = try string_to_ints(line);
        const good = line: {
            if(is_monotomic(ints)) {
                var it = std.mem.window(i32, ints, 2, 1);
                while(it.next()) |window| {
                    const first = window[0];
                    const second = window[1];
                    // try first_col.append(first);
                    // try second_col.append(second);
                    if(@abs(first - second) < 1 or @abs(first - second) > 3) {
                        // std.debug.print("bad: {d} {d}\n", .{first, second});
                        break :line false;
                    }
                }
                break :line true;
            }
            break :line false;
        };

        if(good) {
            total += 1;
        }
    }
    return total;
}

fn part_2(comptime input_data: []const u8) !u32 {

    var total : u32 = 0;
    var data = split_data(input_data);

    while (data.next()) |line| {
        const ints = try string_to_ints(line);
        const good = line: {
            undamp: {
                if(is_monotomic(ints)) {
                    var it = std.mem.window(i32, ints, 2, 1);
                    while(it.next()) |window| {
                        const first = window[0];
                        const second = window[1];
                        // try first_col.append(first);
                        // try second_col.append(second);
                        if(@abs(first - second) < 1 or @abs(first - second) > 3) {
                            // std.debug.print("/ad: {d} {d}\n", .{first, second});
                            break :undamp;
                        }
                    }
                    break :line true;
                }
            }
                    // else
                    {
                        damp: for(0..ints.len) |item| {
                            var damp_line = std.ArrayList(i32).init(std.heap.page_allocator);
                            defer damp_line.deinit();
                            for (0..ints.len) |i| {
                                if(i == item) {
                                    continue;
                                }
                                else {
                                    try damp_line.append(ints[i]);
                                }
                            }
                            // std.debug.print("damp_line: {any}\n", .{damp_line.items});

                            if(is_monotomic(damp_line.items)) {
                                var it = std.mem.window(i32, damp_line.items, 2, 1);
                                while(it.next()) |window| {
                                    const first = window[0];
                                    const second = window[1];
                                    // try first_col.append(first);
                                    // try second_col.append(second);
                                    if(@abs(first - second) < 1 or @abs(first - second) > 3) {
                                        // std.debug.print("bad: {d} {d}\n", .{first, second});
                                        continue :damp;
                                    }
                                }
                                break :line true;
                            }
                        }
                    }
                    break :line false;
                };

        if(good) {
            total += 1;
        }
    }
    return total;
}


test "part 1" {
    try std.testing.expectEqual(2, part_1(test_data));
}

test "part 2" {
    try std.testing.expectEqual(4, part_2(test_data));
}
