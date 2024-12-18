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
    return 22;
}

pub fn part_2_expected() u32 {
    return 0;
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

var min_distance = std.AutoHashMap(aoc.Coordinate, i32).init(std.heap.page_allocator);

fn less_than(context: void, a: Move, b: Move) std.math.Order {
    _ = context;
    return std.math.order(a.cost, b.cost);
}

var queue = std.PriorityQueue(Move, void, less_than).init(std.heap.page_allocator, {});

fn part_1(comptime input_data: [] const u8) !u64 {
    var total : u64 = 0;
    total = 0;
    var data = comptime aoc.split_data(input_data);

    const yy: i64 = 9;
    // const yy: i64 = 73;
    const start: aoc.Coordinate = .{.x = 1, .y = 1};
    const end: aoc.Coordinate = .{.x = yy - 2, .y = yy - 2};
    var dir: Direction = Direction.Right;

    var bytes = std.ArrayList(aoc.Coordinate).init(std.heap.page_allocator);
    while(data.next()) |line| {
        var line_it = std.mem.tokenizeScalar(u8, line, ',');
        const x = try std.fmt.parseInt(i64, line_it.next().?, 10);
        const y = try std.fmt.parseInt(i64, line_it.next().?, 10);

        bytes.append(.{.x = x + 1, .y = y + 1}) catch unreachable;
    }

    for(0..@intCast(yy)) |y| {
        for(0..@intCast(yy)) |x| {
            if(x == 0 or x == yy - 1 or y == 0 or y == yy - 1) {
                walls.put(.{.x = @intCast(x), .y = @intCast(y)}, {}) catch unreachable;
            }
            try min_distance.put(.{.x = @intCast(x), .y = @intCast(y)}, std.math.maxInt(i32));
        }
    }

    var xx: usize = 0;
    while(xx < 12) : (xx += 1) {
        const byte = bytes.items[xx];
        walls.put(byte, {}) catch unreachable;
    }

    try queue.add(.{.pos = start, .dir = dir, .cost = 0});

    var pos = start;
    var cost: i32 = 0;
    while(queue.peek()) |move| {
        _ = queue.remove();

        pos = move.pos;
        dir = move.dir;
        cost = move.cost;


        if(cost >= min_distance.get(pos).?) {
            continue;
        }

        try min_distance.put(pos, cost);

        if(pos.x == end.x and pos.y == end.y) {
            break;
        }

        if(can_turn_right(pos, dir)) {
            const new_dir = dir.turn_right();
            const next = step(pos, new_dir) catch unreachable;
            try queue.add(.{.pos = next, .dir = new_dir, .cost = cost + 1});
        }
        if(can_turn_left(pos, dir)) {
            const new_dir = dir.turn_left();
            const next = step(pos, new_dir) catch unreachable;
            try queue.add(.{.pos = next, .dir = new_dir, .cost = cost + 1});
        }

        if(can_go_straight(pos, dir)) {
            const next = step(pos, dir) catch unreachable;
            try queue.add(.{.pos = next, .dir = dir, .cost = cost + 1});
        }
    }

    std.debug.print("\n", .{});
    for(0..@intCast(yy)) |y| {
        for(0..@intCast(yy)) |x| {
            if(seats.contains(.{.x = @intCast(x), .y = @intCast(y)})) {
                std.debug.print("O", .{});
            } else if (walls.contains(.{.x = @intCast(x), .y = @intCast(y)})) {
                std.debug.print("#", .{});
            } else {
                std.debug.print(".", .{});
            }
        }
        std.debug.print("\n", .{});
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

    if(score > min_distance.get(pos).?) {
        return false;
    }

    min_distance.put(pos, score) catch unreachable;

    var isBestPath = false;
    if(can_go_straight(pos, dir)) {
        const next = step(pos, dir) catch unreachable;
        isBestPath = best_path(next, dir, score + 1, target, end);
    }
    if(can_turn_left(pos, dir) and best_path(step(pos, dir.turn_left()) catch unreachable, dir.turn_left(), score + 1, target, end)) {
        isBestPath = true;
    }
    if(can_turn_right(pos, dir) and best_path(step(pos, dir.turn_right()) catch unreachable, dir.turn_right(), score + 1, target, end)) {
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

    // const yy: i64 = 9;
    const yy: i64 = 73;
    const start: aoc.Coordinate = .{.x = 1, .y = 1};
    const end: aoc.Coordinate = .{.x = yy - 2, .y = yy - 2};
    var dir: Direction = Direction.Right;

    var bytes = std.ArrayList(aoc.Coordinate).init(std.heap.page_allocator);
    while(data.next()) |line| {
        var line_it = std.mem.tokenizeScalar(u8, line, ',');
        const x = try std.fmt.parseInt(i64, line_it.next().?, 10);
        const y = try std.fmt.parseInt(i64, line_it.next().?, 10);

        bytes.append(.{.x = x + 1, .y = y + 1}) catch unreachable;
    }

    for(0..@intCast(yy)) |y| {
        for(0..@intCast(yy)) |x| {
            if(x == 0 or x == yy - 1 or y == 0 or y == yy - 1) {
                walls.put(.{.x = @intCast(x), .y = @intCast(y)}, {}) catch unreachable;
            }
            try min_distance.put(.{.x = @intCast(x), .y = @intCast(y)}, std.math.maxInt(i32));
        }
    }

    var xx: usize = 0;
    // const count = 12;
    const count = 1024;
    while(xx < count) : (xx += 1) {
        const byte = bytes.items[xx];
        walls.put(byte, {}) catch unreachable;
    }

    for(count..bytes.items.len) |xxx| {

        const byte = bytes.items[xxx];
        walls.put(byte, {}) catch unreachable;

        for(0..@intCast(yy)) |y| {
            for(0..@intCast(yy)) |x| {
                try min_distance.put(.{.x = @intCast(x), .y = @intCast(y)}, std.math.maxInt(i32));
            }
        }

        var queue_2 = std.PriorityQueue(Move, void, less_than).init(std.heap.page_allocator, {});
        try queue_2.add(.{.pos = start, .dir = Direction.Right, .cost = 0});

        var pos = start;
        var cost: i32 = 0;
        var found_end = false;
        while(queue_2.peek()) |move| {
            _ = queue_2.remove();

            pos = move.pos;
            dir = move.dir;
            cost = move.cost;


            if(pos.x == end.x and pos.y == end.y) {
                found_end = true;
                break;
            }

            if(cost >= min_distance.get(pos).?) {
                continue;
            }

            try min_distance.put(pos, cost);


            if(can_turn_right(pos, dir)) {
                const new_dir = dir.turn_right();
                const next = step(pos, new_dir) catch unreachable;
                try queue_2.add(.{.pos = next, .dir = new_dir, .cost = cost + 1});
            }
            if(can_turn_left(pos, dir)) {
                const new_dir = dir.turn_left();
                const next = step(pos, new_dir) catch unreachable;
                try queue_2.add(.{.pos = next, .dir = new_dir, .cost = cost + 1});
            }

            if(can_go_straight(pos, dir)) {
                const next = step(pos, dir) catch unreachable;
                try queue_2.add(.{.pos = next, .dir = dir, .cost = cost + 1});
            }
        }

        if(!found_end) {
            std.debug.print("No path found\n", .{});
            std.debug.print("{}, {}\n", .{byte.x - 1, byte.y - 1});
            break;
        }

    }
    std.debug.print("\n", .{});
    for(0..@intCast(yy)) |y| {
        for(0..@intCast(yy)) |x| {
            if(seats.contains(.{.x = @intCast(x), .y = @intCast(y)})) {
                std.debug.print("O", .{});
            } else if (walls.contains(.{.x = @intCast(x), .y = @intCast(y)})) {
                std.debug.print("#", .{});
            } else {
                std.debug.print(".", .{});
            }
        }
        std.debug.print("\n", .{});
    }

    // total = @intCast(cost);
    return total;
}
