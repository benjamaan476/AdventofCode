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
    return 7036;
}

pub fn part_2_expected() u32 {
    return 45;
}

var walls = std.AutoHashMap(aoc.Coordinate, void).init(std.heap.page_allocator);

const Direction = enum {
    Up,
    Down,
    Left,
    Right,

    fn turn_right(self: Direction) Direction {
        return switch(self) {
            .Up => Direction.Right,
            .Down => Direction.Left,
            .Left => Direction.Up,
            .Right => Direction.Down,
        };
    }

    fn turn_left(self: Direction) Direction {
        return switch(self) {
            .Up => Direction.Left,
            .Down => Direction.Right,
            .Left => Direction.Down,
            .Right => Direction.Up,
        };
    }
};

const Bump = error { Wall, Visited };

fn step(start: aoc.Coordinate, dir: Direction) Bump!aoc.Coordinate {
    switch(dir) {
        .Up =>
            if(walls.contains(.{.x = start.x, .y = start.y - 1})) {
                return error.Wall;
            } else return .{.x = start.x, .y = start.y - 1},
                .Down => 
                    if(walls.contains(.{.x = start.x, .y = start.y + 1})) {
                        return error.Wall;
                    } else return .{.x = start.x, .y = start.y + 1},
                        .Left => 
                            if(walls.contains(.{.x = start.x - 1, .y = start.y})) {
                                return error.Wall;
                            } else return .{.x = start.x - 1, .y = start.y},
                                .Right => 
                                    if(walls.contains(.{.x = start.x + 1, .y = start.y})) {
                                        return error.Wall;
                                    } else return .{.x = start.x + 1, .y = start.y},
    }
}

fn can_turn_right(start: aoc.Coordinate, dir: Direction) bool {
    switch(dir) {
        .Up => return !walls.contains(.{.x = start.x + 1, .y = start.y}),
        .Down => return !walls.contains(.{.x = start.x - 1, .y = start.y}),
        .Left => return !walls.contains(.{.x = start.x, .y = start.y - 1}),
        .Right => return !walls.contains(.{.x = start.x, .y = start.y + 1}),
    }
}

fn can_turn_left(start: aoc.Coordinate, dir: Direction) bool {
    switch(dir) {
        .Up => return !walls.contains(.{.x = start.x - 1, .y = start.y}),
        .Down => return !walls.contains(.{.x = start.x + 1, .y = start.y}),
        .Left => return !walls.contains(.{.x = start.x, .y = start.y + 1}),
        .Right => return !walls.contains(.{.x = start.x, .y = start.y - 1}),
    }
}

fn can_go_straight(start: aoc.Coordinate, dir: Direction) bool {
    switch(dir) {
        .Up => return !walls.contains(.{.x = start.x, .y = start.y - 1}),
        .Down => return !walls.contains(.{.x = start.x, .y = start.y + 1}),
        .Left => return !walls.contains(.{.x = start.x - 1, .y = start.y}),
        .Right => return !walls.contains(.{.x = start.x + 1, .y = start.y}),
    }
}

const Move = struct {
    pos: aoc.Coordinate,
    dir: Direction,
    cost: i32,
};

var min_distance = std.AutoHashMap(aoc.Coordinate, [4]i32).init(std.heap.page_allocator);

fn less_than(context: void, a: Move, b: Move) std.math.Order {
    _ = context;
    return std.math.order(a.cost, b.cost);
}

var queue = std.PriorityQueue(Move, void, less_than).init(std.heap.page_allocator, {});

fn part_1(comptime input_data: [] const u8) !u64 {
    var total : u64 = 0;
    total = 0;
    var data = comptime aoc.split_data(input_data);

    var start: aoc.Coordinate = .{.x = 0, .y = 0};
    var end: aoc.Coordinate = .{.x = 0, .y = 0};
    var dir: Direction = Direction.Right;

    var yy: i32 = 0;
    while(data.next()) |line| : (yy += 1) {
        for(line, 0..) |c, x| {
            const xx: i32 = @intCast(x);
            if(c == '#') {
                try walls.put(.{.x = xx, .y = yy}, {});
            } else if (c == 'S') {
                start = .{.x = xx, .y = yy};
            } else if (c == 'E') {
                end = .{.x = xx, .y = yy};
            }
        }
    }

    for(0..@intCast(yy)) |y| {
        for(0..@intCast(yy)) |x| {
            var i: [4]i32 = undefined;
            @memset(&i, std.math.maxInt(i32));
            try min_distance.put(.{.x = @intCast(x), .y = @intCast(y)}, i);
        }
    }

    try queue.add(.{.pos = start, .dir = dir, .cost = 0});

    var pos = start;
    var cost: i32 = 0;
    while(queue.peek()) |move| {
        _ = queue.remove();

        pos = move.pos;
        dir = move.dir;
        cost = move.cost;

        if(pos.x == end.x and pos.y == end.y) {
            break;
        }

        if(cost >= min_distance.get(pos).?[@intFromEnum(dir)]) {
            continue;
        }

        var in: [4]i32 = min_distance.get(pos).?;
        in[@intFromEnum(dir)] = cost;
        try min_distance.put(pos, in);

        if(can_turn_right(pos, dir)) {
            const new_dir = dir.turn_right();
            try queue.add(.{.pos = pos, .dir = new_dir, .cost = cost + 1000});
        }
        if(can_turn_left(pos, dir)) {
            const new_dir = dir.turn_left();
            try queue.add(.{.pos = pos, .dir = new_dir, .cost = cost + 1000});
        }

        if(can_go_straight(pos, dir)) {
            const next = step(pos, dir) catch unreachable;
            try queue.add(.{.pos = next, .dir = dir, .cost = cost + 1});
        }
    }

    total = @intCast(cost);
    return total;
}

fn best_path(pos: aoc.Coordinate, dir: Direction, score: i32, target: u64, end: aoc.Coordinate) bool{
    if(score == target and pos.x == end.x and pos.y == end.y) {
        seats.put(pos, {}) catch unreachable;
        return true;
    }

    if(score >= target) {
        return false;
    }

    if(walls.contains(pos)) {
        return false;
    }

    if(score > min_distance.get(pos).?[@intFromEnum(dir)]) {
        return false;
    }

        var in: [4]i32 = min_distance.get(pos).?;
        in[@intFromEnum(dir)] = score;
        min_distance.put(pos, in) catch unreachable;

        var isBestPath = false;
        if(can_go_straight(pos, dir)) {
            const next = step(pos, dir) catch unreachable;
            isBestPath = best_path(next, dir, score + 1, target, end);
        }
        if(best_path(pos, dir.turn_left(), score + 1000, target, end)) {
            isBestPath = true;
        }
        if(best_path(pos, dir.turn_right(), score + 1000, target, end)) {
            isBestPath = true;
        }

        if(isBestPath) {
            seats.put(pos, {}) catch unreachable;
        }

        return isBestPath;

}

var seats = std.AutoHashMap(aoc.Coordinate, void).init(std.heap.page_allocator);
fn part_2(comptime input_data: []const u8) !u64 {
    var total : u64 = 0;
    total = 0;
    var data = comptime aoc.split_data(input_data);

    var start: aoc.Coordinate = .{.x = 0, .y = 0};
    var end: aoc.Coordinate = .{.x = 0, .y = 0};
    var dir: Direction = Direction.Right;

    var yy: i32 = 0;
    while(data.next()) |line| : (yy += 1) {
        for(line, 0..) |c, x| {
            const xx: i32 = @intCast(x);
            if(c == '#') {
                try walls.put(.{.x = xx, .y = yy}, {});
            } else if (c == 'S') {
                start = .{.x = xx, .y = yy};
            } else if (c == 'E') {
                end = .{.x = xx, .y = yy};
            }
        }
    }

    for(0..@intCast(yy)) |y| {
        for(0..@intCast(yy)) |x| {
            var i: [4]i32 = undefined;
            @memset(&i, std.math.maxInt(i32));
            try min_distance.put(.{.x = @intCast(x), .y = @intCast(y)}, i);
        }
    }

    try queue.add(.{.pos = start, .dir = dir, .cost = 0});

    var pos = start;
    var cost: i32 = 0;
    while(queue.peek()) |move| {
        _ = queue.remove();

        pos = move.pos;
        dir = move.dir;
        cost = move.cost;

        if(pos.x == end.x and pos.y == end.y) {
            break;
        }

        if(cost >= min_distance.get(pos).?[@intFromEnum(dir)]) {
            continue;
        }

        var in: [4]i32 = min_distance.get(pos).?;
        in[@intFromEnum(dir)] = cost;
        try min_distance.put(pos, in);

        if(can_turn_right(pos, dir)) {
            const new_dir = dir.turn_right();
            try queue.add(.{.pos = pos, .dir = new_dir, .cost = cost + 1000});
        }
        if(can_turn_left(pos, dir)) {
            const new_dir = dir.turn_left();
            try queue.add(.{.pos = pos, .dir = new_dir, .cost = cost + 1000});
        }

        if(can_go_straight(pos, dir)) {
            const next = step(pos, dir) catch unreachable;
            try queue.add(.{.pos = next, .dir = dir, .cost = cost + 1});
        }
    }
    const score: u64 = @intCast(cost);
    std.debug.print("score: {d}\n", .{score});

    _ = best_path(start, Direction.Right, 0, score, end);

    for(0..@intCast(yy)) |y| {
        for(0..@intCast(yy)) |x| {
            if(seats.contains(.{.x = @intCast(x), .y = @intCast(y)})) {
                std.debug.print("O", .{});
            } else if (walls.contains(.{.x = @intCast(x), .y = @intCast(y)})) {
                std.debug.print("#", .{});
            } else {
                std.debug.print(" ", .{});
            }
        }
        std.debug.print("\n", .{});
    }

    total = seats.count();
    return total;
}
