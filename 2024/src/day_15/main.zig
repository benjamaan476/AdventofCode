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
    const is_wall = walls.contains(.{.x = x, .y = y});
    if(is_wall) return;

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

    const is_box = (boxes.contains(.{.x = box_x, .y = box_y}) and boxes_pair.contains(.{.x = box_x + 1, .y = box_y})) or (boxes_pair.contains(.{.x = box_x, .y = box_y}) and boxes.contains(.{.x = box_x - 1, .y = box_y}));
    if(!is_box) return true;
    
    return can_move_2(box_x, box_y, direction);
}

fn move_boxes_2(x: i64, y: i64, direction: u2) void {
    const is_wall = walls.contains(.{.x = x, .y = y});
    if(is_wall) return;

    const is_box = boxes.contains(.{.x = x, .y = y}) and boxes_pair.contains(.{.x = x + 1, .y = y});
    const is_pair = boxes_pair.contains(.{.x = x, .y = y}) and boxes.contains(.{.x = x - 1, .y = y});

    var box_x: i64 = x;
    var box_y: i64 = y;

    if(is_box) {
        while(boxes.contains(.{.x = box_x, .y = box_y}) or boxes_pair.contains(.{.x = box_x, .y = box_y})) {
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
        _ = boxes_pair.remove(.{.x = x + 1, .y = y});

        boxes.put(.{.x = box_x, .y = box_y}, {}) catch unreachable;
        boxes_pair.put(.{.x = box_x + 1, .y = box_y}, {}) catch unreachable;
    } else if (is_pair) {
        while(boxes_pair.contains(.{.x = box_x, .y = box_y}) or boxes.contains(.{.x = box_x, .y = box_y})) {
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
        _ = boxes.remove(.{.x = x - 1, .y = y});
        _ = boxes_pair.remove(.{.x = x, .y = y});

        boxes.put(.{.x = box_x - 1, .y = box_y}, {}) catch unreachable;
        boxes_pair.put(.{.x = box_x, .y = box_y}, {}) catch unreachable;
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
    std.debug.print("Robot: x: {}, y: {}\n", .{bot.x, bot.y});
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
            _ = move_boxes_2(bot.x, bot.y, instruction);
        }
    std.debug.print("Robot: x: {}, y: {}\n", .{bot.x, bot.y});
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
