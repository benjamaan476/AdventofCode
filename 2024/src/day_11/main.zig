const std = @import("std");
const test_data = @embedFile("test_data.txt");
const real_data = @embedFile("data.txt");

fn split_data(comptime data: []const u8) std.mem.SplitIterator(u8, .scalar) {
    const trimmed_data = std.mem.trim(u8, data, " \t\n");
    return std.mem.splitScalar(u8, trimmed_data, '\n');
}

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
    return 55312;
}

pub fn part_2_expected() u32 {
    return 0;
}

fn digit_count(val: u64) u64 {
    return std.math.log10(val) + 1;
}

fn split_digit(val: u64) [2]u64 {
    var digits: [2]u64 = undefined;

    const count = digit_count(val);
    digits[0] = val / std.math.pow(u64, 10, count / 2);
    digits[1] = val % std.math.pow(u64, 10, count / 2);
    return digits;
}

fn part_1(comptime input_data: [] const u8) !u64 {
    var total : u64 = 0;
    var data = comptime split_data(input_data);

    var stones = std.ArrayList(u64).init(std.heap.page_allocator);

    var j: u32 = 0;
    while(data.next()) |line| : (j += 1) {
        var it = std.mem.tokenizeScalar(u8, line, ' ');
        while(it.next()) |token| {
            const stone = try std.fmt.parseInt(u32, token, 10);
            try stones.append(stone);
        }
    }

    for(0..25) |i| {
        _ = i;
    var stones_next = std.ArrayList(u64).init(std.heap.page_allocator);
    defer stones_next.deinit();
    std.debug.print("{}\n", .{stones.items.len});
        // std.debug.print("Stones: {any}\n", .{stones.items});
    for(stones.items) |stone| {
        if(stone == 0) {
            try stones_next.append(1);
        } else if (digit_count(stone) % 2 == 0) {
            const split = split_digit(stone);
            try stones_next.append(split[0]);
            try stones_next.append(split[1]);
        } else {
            try stones_next.append(stone * 2024);
        }
    }
    
    stones.clearAndFree();
    stones = try stones_next.clone();
    }
     
    total = stones.items.len;
    return total;
}

fn blink(stone: u64, blinks_remaining: u32) u64 {
    if(blinks_remaining == 0) {
        return 1;
    }
    const new_count = blinks_remaining - 1;

    if(stone == 0) {
        return blink(1, new_count);
    }
    else if (digit_count(stone) % 2 == 0) {
        const split = split_digit(stone);
        return blink(split[0], new_count) + blink(split[1], new_count);
    } else return blink(stone * 2024, new_count);
}

fn part_2(comptime input_data: []const u8) !u64 {
    var total : u64 = 0;
    var data = comptime split_data(input_data);

    var stones = std.ArrayList(u64).init(std.heap.page_allocator);

    var j: u32 = 0;
    while(data.next()) |line| : (j += 1) {
        var it = std.mem.tokenizeScalar(u8, line, ' ');
        while(it.next()) |token| {
            const stone = try std.fmt.parseInt(u32, token, 10);
            try stones.append(stone);
        }
    }

    for(stones.items) |stone| {

        std.debug.print("Blink\n", .{});
        total += blink(stone, 75);
        std.debug.print("Total: {}\n", .{total});
    }
     
    return total;
}
