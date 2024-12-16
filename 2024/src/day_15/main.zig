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
    return 10092;
}

pub fn part_2_expected() u32 {
    return 9021;
}

const Coordinate = struct {
    x: i64,
    y: i64,

    fn plus(self: Coordinate, other: Coordinate) Coordinate {
        return .{.x = self.x + other.x, .y = self.y + other.y};
    }

    fn add(self: *Coordinate, other: Coordinate) void {
        self.x += other.x;
        self.y += other.y;
    }
};

var width: u32 = 0;
var height: u32 = 0;

var walls = std.AutoHashMap(Coordinate, void).init(std.heap.page_allocator);
var boxes = std.AutoHashMap(Coordinate, void).init(std.heap.page_allocator);
var boxes_pair = std.AutoHashMap(Coordinate, void).init(std.heap.page_allocator);

fn move_boxes(x: i64, y: i64, direction: u2) void {

    const is_box = boxes.contains(.{.x = x, .y = y});
    if(!is_box) return;

    var box_x: i64 = x;
    var box_y: i64 = y;

    var count: i64 = 0;
    while(boxes.contains(.{.x = box_x, .y = box_y})) : (count += 1) {
        if(direction == 0) {
            box_y -= 1;
        } else if(direction == 1) {
            box_y += 1;
        } else if(direction == 2) {
            box_x -= 1;
        } else if(direction == 3) {
            box_x += 1;
        }
    }

    _ = boxes.remove(.{.x = x, .y = y});
    boxes.put(.{.x = box_x, .y = box_y}, {}) catch unreachable;
}

fn can_move(x: i64, y: i64, direction: u2) bool {

    var box_x: i64 = 0;
    var box_y: i64 = 0;
    if(direction == 0) {
        box_x = x;
        box_y = y - 1;
    } else if(direction == 1) {
        box_x = x;
        box_y = y + 1;
    } else if(direction == 2) {
        box_x = x - 1;
        box_y = y;
    } else if(direction == 3) {
        box_x = x + 1;
        box_y = y;
    }

    const is_wall = walls.contains(.{.x = box_x, .y = box_y});
    if(is_wall) return false;

    const is_box = boxes.contains(.{.x = box_x, .y = box_y});
    if(!is_box) return true;

    return can_move(box_x, box_y, direction);
}

fn can_move_2(x: i64, y: i64, direction: u2) bool {

    var box_x: i64 = 0;
    var box_y: i64 = 0;
    if(direction == 0) {
        box_x = x;
        box_y = y - 1;

        const is_wall = walls.contains(.{.x = box_x, .y = box_y});
        if(is_wall) return false;

        if(boxes.contains(.{.x = box_x, .y = box_y})) {
            return can_move_2(box_x, box_y, direction) and can_move_2(box_x + 1, box_y, direction);
        }
        if (boxes_pair.contains(.{.x = box_x, .y = box_y})) {
            return can_move_2(box_x - 1, box_y, direction) and can_move_2(box_x, box_y, direction);
        }

    } else if(direction == 1) {
        box_x = x;
        box_y = y + 1;

        const is_wall = walls.contains(.{.x = box_x, .y = box_y});
        if(is_wall) return false;

        if(boxes.contains(.{.x = box_x, .y = box_y})) {
            return can_move_2(box_x, box_y, direction) and can_move_2(box_x + 1, box_y, direction);
        }
        if (boxes_pair.contains(.{.x = box_x, .y = box_y})) {
            return can_move_2(box_x - 1, box_y, direction) and can_move_2(box_x, box_y, direction);
        }
    } else if(direction == 2) {
        box_x = x - 1;
        box_y = y;

        const is_wall = walls.contains(.{.x = box_x, .y = box_y});
        if(is_wall) return false;

        if (boxes_pair.contains(.{.x = box_x, .y = box_y})) {
            return can_move_2(box_x - 1, box_y, direction);
        }
    } else if(direction == 3) {
        box_x = x + 1;
        box_y = y;

        const is_wall = walls.contains(.{.x = box_x, .y = box_y});
        if(is_wall) return false;

        if (boxes.contains(.{.x = box_x, .y = box_y})) {
            return can_move_2(box_x + 1, box_y, direction);
        }
    }

    return true;
}

fn move_box(x: i64, y: i64, direction: u2) void {
    var new_boxes = std.AutoHashMap(Coordinate, void).init(std.heap.page_allocator);
    var new_pairs = std.AutoHashMap(Coordinate, void).init(std.heap.page_allocator);

    move_boxes_2(&new_boxes, &new_pairs, x, y, direction);

    var box_it = new_boxes.keyIterator();
    while(box_it.next()) |box| {
        // std.debug.print("Box: x: {}, y: {}\n", .{box.x, box.y});
        boxes.put(box.*, {}) catch unreachable;
    }

    var pair_it = new_pairs.keyIterator();
    while (pair_it.next()) |pair| {
        // std.debug.print("Pair: x: {}, y: {}\n", .{pair.x, pair.y});
        boxes_pair.put(pair.*, {}) catch unreachable;
    }
}


fn move_boxes_2(new_boxes: *std.AutoHashMap(Coordinate, void), new_pairs: *std.AutoHashMap(Coordinate, void), x: i64, y: i64, direction: u2) void {
    const is_wall = walls.contains(.{.x = x, .y = y});
    if(is_wall) return;

    const is_box = boxes.contains(.{.x = x, .y = y});
    const is_pair = boxes_pair.contains(.{.x = x, .y = y});
    if(!is_box and !is_pair) return;

    var box: Coordinate = .{.x = x, .y = y};
    var pos: Coordinate = undefined;
    if(direction == 0) {
        pos = .{.x = 0, .y = -1};
        if(is_box) {
            _ = boxes.remove(box);
            _ = boxes_pair.remove(box.plus(.{.x = 1, .y = 0}));

            box.add(pos);

            new_boxes.put(box, {}) catch unreachable;
            new_pairs.put(box.plus(.{.x = 1, .y = 0}), {}) catch unreachable;

            move_boxes_2(new_boxes, new_pairs, box.x, box.y, direction);
            move_boxes_2(new_boxes, new_pairs, box.x + 1, box.y, direction);
            return;
        }
        if(is_pair) {
            _ = boxes_pair.remove(box);
            _ = boxes.remove(box.plus(.{.x = -1, .y = 0}));

            box.add(pos);

            new_pairs.put(box, {}) catch unreachable;
            new_boxes.put(box.plus(.{.x = -1, .y = 0}), {}) catch unreachable;

            move_boxes_2(new_boxes, new_pairs, box.x, box.y, direction);
            move_boxes_2(new_boxes, new_pairs, box.x - 1, box.y, direction);
            return;
        }
    } else if(direction == 1) {
        pos = .{.x = 0, .y = 1};
        if(is_box) {
            _ = boxes.remove(box);
            _ = boxes_pair.remove(box.plus(.{.x = 1, .y = 0}));

            box.add(pos);

            new_boxes.put(box, {}) catch unreachable;
            new_pairs.put(box.plus(.{.x = 1, .y = 0}), {}) catch unreachable;

            move_boxes_2(new_boxes, new_pairs, box.x, box.y, direction);
            move_boxes_2(new_boxes, new_pairs, box.x + 1, box.y, direction);
            return;
        }
        if(is_pair) {
            _ = boxes_pair.remove(box);
            _ = boxes.remove(box.plus(.{.x = -1, .y = 0}));

            box.add(pos);

            new_pairs.put(box, {}) catch unreachable;
            new_boxes.put(box.plus(.{.x = -1, .y = 0}), {}) catch unreachable;

            move_boxes_2(new_boxes, new_pairs, box.x, box.y, direction);
            move_boxes_2(new_boxes, new_pairs, box.x - 1, box.y, direction);
            return;
        }
    } else if(direction == 2) {
        pos = .{.x = -1, .y = 0};
        if(is_box) {
            _ = boxes.remove(box);
            new_boxes.put(box.plus(pos), {}) catch unreachable;
        }
        if(is_pair) {
            _ = boxes_pair.remove(box);
            new_pairs.put(box.plus(pos), {}) catch unreachable;

        }
        box.add(pos);
        move_boxes_2(new_boxes, new_pairs, box.x, box.y, direction);
        return;
    } else if(direction == 3) {
        pos = .{.x = 1, .y = 0};
        if(is_box) {
            _ = boxes.remove(box);
            new_boxes.put(box.plus(pos), {}) catch unreachable;
        }
        if(is_pair) {
            _ = boxes_pair.remove(box);
            new_pairs.put(box.plus(pos), {}) catch unreachable;

        }
        box.add(pos);
        move_boxes_2(new_boxes, new_pairs, box.x, box.y, direction);
        return;
    }

}

fn part_1(comptime input_data: [] const u8) !u64 {
    var total : u64 = 0;
    total = 0;
    var data = comptime split_data(input_data);

    var instructions = std.ArrayList(u2).init(std.heap.page_allocator);
    var bot: Coordinate = .{.x = 0, .y = 0};
    var yy: u32 = 0;
    while(data.next()) |line| {
        if(std.mem.eql(u8, line, "")) {
            continue;
        } else if(line[0] == '#') {
            for(line, 0..) |c, x| {
                if(c == '#') {
                    try walls.put(.{.x = @intCast(x), .y = @intCast(yy)}, {});
                } else if(c == 'O') {
                    try boxes.put(.{.x = @intCast(x), .y = @intCast(yy)}, {});
                } else if(c == '@') {
                    bot = .{.x = @intCast(x), .y = @intCast(yy)};
                }
            }
            yy += 1;
        }
        else {
            for(line) |c| {
                if(c == '^') {
                    try instructions.append(0);
                } else if(c == 'v') {
                    try instructions.append(1);
                } else if(c == '<') {
                    try instructions.append(2);
                } else if(c == '>') {
                    try instructions.append(3);
                }
            }
        }
    }

    width = @intCast(yy);
    height = @intCast(yy);

    for(instructions.items) |instruction| {
        if(can_move(bot.x, bot.y, instruction)) {
            if(instruction == 0) {
                bot.y -= 1;
            } else if(instruction == 1) {
                bot.y += 1;
            } else if(instruction == 2) {
                bot.x -= 1;
            } else if(instruction == 3) {
                bot.x += 1;
            }
            _ = move_boxes(bot.x, bot.y, instruction);
        }
    }

    for(0..height) |y| {
        for(0..width) |x| {
            if(x == bot.x and y == bot.y) {
                std.debug.print("@", .{});
            } else if(walls.contains(.{.x = @intCast(x), .y = @intCast(y)})) {
                std.debug.print("#", .{});
            } else if(boxes.contains(.{.x = @intCast(x), .y = @intCast(y)})) {
                std.debug.print("O", .{});
            } else {
                std.debug.print(".", .{});
            }
        }
        std.debug.print("\n", .{});
    }

    var box_it = boxes.keyIterator();
    while(box_it.next()) |box| {
        total += @intCast(box.x + 100 * box.y);
    }

    boxes.clearAndFree();
    walls.clearAndFree();
    return total;
}

fn part_2(comptime input_data: []const u8) !u64 {
    var total : u64 = 0;
    total = 0;
    var data = comptime split_data(input_data);

    var instructions = std.ArrayList(u2).init(std.heap.page_allocator);
    var bot: Coordinate = .{.x = 0, .y = 0};
    var yy: u32 = 0;
    while(data.next()) |line| {
        if(std.mem.eql(u8, line, "")) {
            continue;
        } else if(line[0] == '#') {
            var x: u32 = 0;
            for(line) |c| {
                if(c == '#') {
                    try walls.put(.{.x = @intCast(x), .y = @intCast(yy)}, {});
                    try walls.put(.{.x = @intCast(x + 1), .y = @intCast(yy)}, {});
                } else if(c == 'O') {
                    const box: Coordinate = .{.x = @intCast(x), .y = @intCast(yy)};
                    const box_pair: Coordinate = .{.x = @intCast(x + 1), .y = @intCast(yy)};
                    try boxes.put(box, {});
                    try boxes_pair.put(box_pair, {});
                } else if(c == '@') {
                    bot = .{.x = @intCast(x), .y = @intCast(yy)};
                }
                x += 2;
            }
            yy += 1;
        }
        else {
            for(line) |c| {
                if(c == '^') {
                    try instructions.append(0);
                } else if(c == 'v') {
                    try instructions.append(1);
                } else if(c == '<') {
                    try instructions.append(2);
                } else if(c == '>') {
                    try instructions.append(3);
                }
            }
        }
    }

    width = @intCast(2 * yy);
    height = @intCast(yy);

    for(instructions.items) |instruction| {
        if(can_move_2(bot.x, bot.y, instruction)) {
            if(instruction == 0) {
                bot.y -= 1;
            } else if(instruction == 1) {
                bot.y += 1;
            } else if(instruction == 2) {
                bot.x -= 1;
            } else if(instruction == 3) {
                bot.x += 1;
            }
            _ = move_box(bot.x, bot.y, instruction);
            std.debug.print("Bot: x: {}, y: {}\n", .{bot.x, bot.y});
        }
    }

    for(0..height) |y| {
        for(0..width) |x| {
            if(x == bot.x and y == bot.y) {
                std.debug.print("@", .{});
            } else if(walls.contains(.{.x = @intCast(x), .y = @intCast(y)})) {
                std.debug.print("#", .{});
            } else if(boxes.contains(.{.x = @intCast(x), .y = @intCast(y)})) {
                std.debug.print("[", .{});
            } else if(boxes_pair.contains(.{.x = @intCast(x), .y = @intCast(y)})) {
                std.debug.print("]", .{});
            } else {
                std.debug.print(".", .{});
            }
        }
        std.debug.print("\n", .{});
    }

    var box_it = boxes.keyIterator();
    while(box_it.next()) |box| {
        total += @intCast(box.x + 100 * box.y);
    }

    return total;
}
