
const std = @import("std");
const aoc = @import("../aoc.zig");
const test_data = @embedFile("test_data.txt");
const real_data = @embedFile("data.txt");

pub fn day(part: u8, comptime is_test: bool) !u64 {
    const data = comptime if(is_test) test_data else real_data;

    if(part == 1) {
        return part_1(data);
    }
    else if (part == 2) {
        return part_2(data);
    } else unreachable;
}

pub fn part_1_expected() u32 {
    return 37327623;
}

pub fn part_2_expected() u32 {
    return 0;
}

fn mix(secret: u64, value: u64) u64 {
    return secret ^ value;
}

fn prune(secret: u64) u64 {
    return @mod(secret, 16777216);
}

fn hash(secret: u64) u64 {
    var result = secret * 64;
    var new_secret = prune(mix(secret, result));

    result = new_secret / 32;
    new_secret = prune(mix(new_secret, result));

    result = new_secret * 2048;
    new_secret = prune(mix(new_secret, result));

    return new_secret;
}

fn part_1(comptime input_data: [] const u8) !u64 {
    var total : u64 = 0;
    total = 0;
    var data = comptime aoc.split_data(input_data);

    while(data.next()) |line| {
        var val = try std.fmt.parseInt(u64, line, 10);

        for(0..2000) |_| {
            val = hash(val);
        }

        total += val;
    }

    return total;
}

fn part_2(comptime input_data: []const u8) !u64 {
    var total : u64 = 0;
    total = 0;
    var data = comptime aoc.split_data(input_data);

    while(data.next()) |line| {
        _ = line;
    }

    return total;
}
