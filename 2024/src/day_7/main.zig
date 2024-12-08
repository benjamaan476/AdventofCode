const std = @import("std");
const test_data = @embedFile("test_data.txt");
const real_data = @embedFile("data.txt");

const part_1_test = 3749;
const part_2_test = 11387;

fn split_data(comptime data: []const u8) std.mem.SplitIterator(u8, .scalar) {
    const trimmed_data = std.mem.trim(u8, data, " \t\n");
    return std.mem.splitScalar(u8, trimmed_data, '\n');
}

pub fn day(part: u8, comptime is_test: bool) !u128 {
    const data = comptime if(is_test) test_data else real_data;

    if(part == 1) {
        return part_1(data);
    }
    else if (part == 2) {
        return part_2(data);
    } else unreachable;
}

pub fn part_1_expected() u32 {
    return part_1_test;
}

pub fn part_2_expected() u32 {
    return part_2_test;
}

fn operator(first: u128, second:u128, bit_count: u128, op_position: u6, size: u7, testt: bool) u128 {
    if((bit_count >> size - 1) == 1 and testt) {
        const digit_count = std.math.log10(second) + 1;
        return second + first * std.math.pow(u128, 10, digit_count);
    }
    else if((bit_count & (@as(u128, 1) << op_position)) == 0) {
        return first + second;
    } else {
        return first * second;
    }
}


fn solve(target: u128, numbers: []const u8) !bool {
    for(0..std.math.pow(usize, 2, numbers.len - 1)) |i| {
        const bit_count: u128 = @intCast(i);
        var total: u128 = 0;
        var it = std.mem.tokenizeScalar(u8, numbers, ' ');
        var ii: usize = 0;
        while(it.next()) |number| : (ii += 1) {
            const num = try std.fmt.parseInt(u128, number, 10);
            total = operator(total, num, bit_count, @intCast(ii), @intCast(number.len), false);
            if(total > target) {
                break;
            }
        }
        if(total == target) {
            return true;
        }
    }

    return false;
}

fn to_base_3(num: u128) u128 {
    if(num == 0) {
        return 0;
    }
    var t: u128 = 1;
    var n = num;
    var result: u128 = 0;
    var pow: u8 = 1;
    while(n >= t * 3) {
        t = t * 3;
        pow += 1;
    }

    while(t > 0) {
        result += std.math.pow(u128, 10, pow - 1) * (n / t);
        pow -= 1;
        n -= t * (n / t);
        t /= 3;
    }
     return result;
}

fn to_slice(numbers: []const u8) ![]u128 {
    var res = std.ArrayList(u128).init(std.heap.page_allocator);
    var it = std.mem.tokenizeScalar(u8, numbers, ' ');
    while(it.next()) |number| {
        const num = try std.fmt.parseInt(u128, number, 10);
        try res.append(num);
    }
     return res.items;
}

fn operator_2(first: u128, second:u128, bit_count: u128, op_position: u6) u128 {
    const pow_10 = std.math.pow(u128, 10, op_position);
    const op = (bit_count / pow_10) % 10;
    if(op == 0) {
        const digit_count = std.math.log10(second) + 1;
        // std.debug.print("{} || {}\n", .{first, second});
        return second + first * std.math.pow(u128, 10, digit_count);
    }
    else if(op == 1) {
        // std.debug.print("{} + {}\n", .{first, second});
        return first + second;
    } else {
        // std.debug.print("{} * {}\n", .{first, second});
        return first * second;
    }
}

fn solve_2(target: u128, numbers: []const u8) !bool {
    const nums = try to_slice(numbers);
        // std.debug.print("{any}\n", .{nums});
    for(0..@intCast(std.math.pow(u128, 3, nums.len ))) |i| {
        const bit_count: u128 = to_base_3(@intCast(i));
        // std.debug.print("\r{} -> {}", .{i, bit_count});
        var total: u128 = nums[0];
        for(nums, 0..) |num, ii| {
            if(ii == 0) {
                continue;
            }
            total = operator_2(total, num, bit_count, @intCast(ii));
            if(total > target) {
                break;
            }
        }
        if(total == target) {
        // std.debug.print("YES {any}\n", .{nums});
            return true;
        }
    }
    return false;
}

fn part_1(comptime input_data: [] const u8) !u128 {
    var total : u128 = 0;
    var data = comptime split_data(input_data);

    while(data.next()) |line| {
        var equation = std.mem.splitScalar(u8, line, ':');
        const target = try std.fmt.parseInt(u128, equation.next().?, 10);
        const numbers = equation.rest();
        if(try solve(target, numbers)) {
            total += target;
        }
    }
    return total;
}


fn part_2(comptime input_data: []const u8) !u128 {
    var total : u128 = 0;
    var data = comptime split_data(input_data);

    std.debug.print("{}\n", .{to_base_3(729)});
    while(data.next()) |line| {
        var equation = std.mem.splitScalar(u8, line, ':');
        const target = try std.fmt.parseInt(u128, equation.next().?, 10);
        const numbers = equation.rest();
        if(try solve_2(target, numbers)) {
            total += target;
        }
    }
    return total;
}
