const std = @import("std");
const test_data = @embedFile("test_data.txt");
const real_data = @embedFile("data.txt");

const part_1_test = 36;
const part_2_test = 81;

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

var map_width: u32 = undefined;
var map_height: u32 = undefined;
var map: std.ArrayList(u32) = std.ArrayList(u32).init(std.heap.page_allocator);

const Coord = struct {
    x: usize,
    y: usize,
};

const Trailhead = struct {
    x: usize,
    y: usize,
    // score: std.AutoHashMap(Coord, void) = std.AutoHashMap(Coord, void).init(std.heap.page_allocator),
    score: u32 = 0,

    fn check_neighbours(x: usize, y:usize, val: u32) ![]Coord {
        var neighbours = std.ArrayList(Coord).init(std.heap.page_allocator);
        if(y > 0) {
            if(map.items[map_width * (y - 1) + x] == val + 1) {
                try neighbours.append(Coord{ .x = x, .y = y - 1 });
            }
        }
        if(x > 0) {
            if(map.items[map_width * y + x - 1] == val + 1) {
                try neighbours.append(Coord{ .x = x - 1, .y = y });
            }
        }
        if(x < map_width - 1) {
            if(map.items[map_width * y + x + 1] == val + 1) {
                try neighbours.append(Coord{ .x = x + 1, .y = y });
            }
        }
        if(y < map_height - 1) {
            if(map.items[map_width * (y + 1) + x] == val + 1) {
                try neighbours.append(Coord{ .x = x, .y = y + 1 });
            }
        }
        return neighbours.toOwnedSlice();
    }
    fn walk(self: *Trailhead, x: usize, y: usize, val: u32) !void {
        if(val == 9) {
            // std.debug.print("Peak found at {d} {d}\n", .{x, y});
            // try self.score.put(Coord{ .x = x, .y = y }, void{});
            self.score += 1;
            return;
        }

        const neighbours = try check_neighbours(x, y, val);
        for(neighbours) |n| {
            try walk(self, n.x, n.y, val + 1);
        }
    }
};

var trailheads = std.ArrayList(Trailhead).init(std.heap.page_allocator);


fn part_1(comptime input_data: [] const u8) !u128 {
    var total : u128 = 0;
    var data = comptime split_data(input_data);

    var j: u32 = 0;
    while(data.next()) |line| : (j += 1) {
        total = 0;
        for(line, 0..) |c, i| {
            try map.append(c - '0');
            if(c == '0') {
                const th = Trailhead{ .x = i, .y = j };
                try trailheads.append(th);
            }
        }
    }
     
    map_width = @intCast(j);
    map_height = @intCast(j);
    
    var i: u32 = 0;
    while(i < trailheads.items.len) : (i += 1) {
        var th = &trailheads.items[i];
        // std.debug.print("Trailhead: {d} {d}\n", .{th.x, th.y});
        try th.walk(th.x, th.y, 0);
        total += th.score;
    }

    return total;
}

fn part_2(comptime input_data: []const u8) !u128 {
    var total : u128 = 0;
    var data = comptime split_data(input_data);

    while(data.next()) |line| {
        total = 0;
        _ = line;
    }

    return total;
}
