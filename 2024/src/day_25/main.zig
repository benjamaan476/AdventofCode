
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
    return 3;
}

pub fn part_2_expected() u32 {
    return 0;
}

const Lock = std.ArrayList(u8);
const Key = std.ArrayList(u8);

fn part_1(comptime input_data: [] const u8) !u64 {
    var total : u64 = 0;
    total = 0;
    var data = comptime aoc.split_data(input_data);

    var lock_or_key = std.ArrayList(u8).init(std.heap.page_allocator);

    for(0..5) |_| {
        try lock_or_key.append(0);
    }

    var is_key: bool = std.mem.eql(u8, data.peek().?, "#####");
    
    var keys = std.ArrayList(Key).init(std.heap.page_allocator);
    var locks = std.ArrayList(Lock).init(std.heap.page_allocator);

    while(data.next()) |line| {
        if(std.mem.eql(u8, line, "")) {
            std.debug.print("New key\n", .{});
            if(is_key) {
                try keys.append(try lock_or_key.clone());
            } else {
                try locks.append(try lock_or_key.clone());
            }
            lock_or_key.clearAndFree();
            for(0..5) |_| {
                try lock_or_key.append(0);
             }
            is_key = std.mem.eql(u8, data.peek().?, "#####");
        }

        for(line, 0..) |c, i| {
            if(c == '#') {
                lock_or_key.items[i] += 1;
            }
        }
    }
    if(is_key) {
                try keys.append(try lock_or_key.clone());
            } else {
                try locks.append(try lock_or_key.clone());
            }

            for(locks.items) |lock| {
                keys: for(keys.items) |key| {
                    for(lock.items, key.items) |l,k| {
                        if(l + k > 7) {
                            continue :keys;
                        }
                    }
                    total += 1;
                }
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
