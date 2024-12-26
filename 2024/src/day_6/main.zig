const std = @import("std");
const test_data = @embedFile("test_data.txt");
const real_data = @embedFile("data.txt");

const part_1_test = 41;
const part_2_test = 6;

fn split_data(comptime data: []const u8) std.mem.SplitIterator(u8, .scalar) {
    const trimmed_data = std.mem.trim(u8, data, " \t\n");
    return std.mem.splitScalar(u8, trimmed_data, '\n');
}

pub fn day(part: u8, comptime is_test: bool) !u32 {
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

var obstacles = std.ArrayList(i32).init(std.heap.page_allocator);

const Direction = enum {
    Up,
    Right,
    Down, Left
};

var guard_location_x: i32 = undefined;
var guard_location_y: i32 = undefined;
var guard_dir: Direction = .Up;
var left_map: bool = false;

var map_size: i32 = undefined;

fn turn() void {
    guard_dir = switch (guard_dir) {
        .Up => .Right,
        .Right => .Down,
        .Down => .Left,
        .Left => .Up,
    };
}

fn move() bool {

    const guard_index = guard_location_y * map_size + guard_location_x;
    return switch (guard_dir) {
        .Up => if(guard_location_y == 0) { 
            left_map = true;
            return false;
        } else if(std.mem.indexOf(i32, obstacles.items, (&(guard_index - map_size))[0..1]) == null) {
            guard_location_y -= 1;
            return false;

        } else { 
            turn();
            return true;
        },
        .Right => if(guard_location_x == map_size - 1) {
            left_map = true;
            return false;
        } else if(std.mem.indexOf(i32, obstacles.items, (&(guard_index + 1))[0..1]) == null) {
            guard_location_x += 1;
            return false;
        } else { turn(); return true; },
        .Down => if(guard_location_y == map_size - 1) {
            left_map = true;
            return false;
        } else if(std.mem.indexOf(i32, obstacles.items, (&(guard_index + map_size))[0..1]) == null) {
            guard_location_y += 1;
            return false;
        } else { turn(); return true; },
        .Left => if(guard_location_x == 0) {
            left_map = true;
            return false;
        } else if(std.mem.indexOf(i32, obstacles.items, (&(guard_index - 1))[0..1]) == null) {
            guard_location_x -= 1;
            return false;
        } else { turn(); return true; },
    };
}

fn visit(map: []u8) void {
    const guard_index = guard_location_y * map_size + guard_location_x;
    map[@intCast(guard_index)] = 'X';
}

fn parse_line(line_num: i32, line: [] const u8) !void {
    for(line, 0..) |item, i| {
        if(item == '#') {
            try obstacles.append(@as(i32, @intCast(line.len)) * line_num + @as(i32, @intCast(i)));
        } else if(item == '^')
        {
            guard_location_x = @intCast(i);
            guard_location_y = line_num;
        }
    }
}

fn part_1(comptime input_data: [] const u8) !u32 {

    var total : u32 = 0;
    var data = comptime split_data(input_data);

var map = std.ArrayList(u8).init(std.heap.page_allocator);
var i: u8 = 0;
    while (data.next()) |line| :(i += 1) {
        try map.appendSlice(line);
        map_size = @intCast(line.len);
        try parse_line(i, line);
    }

    while(!left_map) {
        visit(map.items);
        _ = move();
        }

    for(map.items, 0..) |item, ii| {
        _ = ii;
        if(item == 'X') {
            total += 1;
        }
    }
    return total;
}


fn part_2(comptime input_data: []const u8) !u32 {
    var total : u32 = 0;
    var data = comptime split_data(input_data);

var map = std.ArrayList(u8).init(std.heap.page_allocator);
var i: u8 = 0;
    while (data.next()) |line| :(i += 1) {
        try map.appendSlice(line);
        map_size = @intCast(line.len);
        try parse_line(i, line);
    }

    const guard_start_x = guard_location_x;
    const guard_start_y = guard_location_y;
    for(0..map.items.len) |ii| {
        guard_location_x = guard_start_x;
        guard_location_y = guard_start_y;
        guard_dir = .Up;
        left_map = false;
        if(ii == guard_start_y * map_size + guard_start_x) {
            continue;
        }
        try obstacles.append(@intCast(ii));
        for(0..10000) |iii|
        {
            _ = iii;
            _ = move();
        }

        if(!left_map) {
            total += 1;
        }
         _ = obstacles.pop();
    }

    return total;

}
