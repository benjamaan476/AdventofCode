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
    return 12;
}

pub fn part_2_expected() u32 {
    return 0;
}

const Coordinate = struct {
    x: i64,
    y: i64,
};

const Robot = struct {
    pos: Coordinate,
    vel: Coordinate,

    fn print(self: *Robot) void {
        std.debug.print("Robot: x: {}, y: {}, dx: {}, dy: {}\n", .{self.pos.x, self.pos.y, self.vel.x, self.vel.y});
    }

    fn jump(self: *Robot, n: i64) void {
        self.pos.x += self.vel.x * n;
        self.pos.y += self.vel.y * n;
    }

    fn warp(self: *Robot, width: i64, height: i64) void {
        self.pos.x = @mod(self.pos.x, width);
        self.pos.y = @mod(self.pos.y, height);
    }
};

fn part_1(comptime input_data: [] const u8) !u64 {
    var total : u64 = 0;
    total = 0;
    var data = comptime split_data(input_data);

    var robots = std.ArrayList(Robot).init(std.heap.page_allocator);
    while(data.next()) |line| {
        var it = std.mem.tokenizeScalar(u8, line, ' ');
        const pos = it.next().?;
        const vel = it.next().?;
        var pos_it = std.mem.tokenizeScalar(u8, pos[2..], ',');
        const x = try std.fmt.parseInt(i64, pos_it.next().?, 10);
        const y = try std.fmt.parseInt(i64, pos_it.next().?, 10);
        var vel_it = std.mem.tokenizeScalar(u8, vel[2..], ',');
        const dx = try std.fmt.parseInt(i64, vel_it.next().?, 10);
        const dy = try std.fmt.parseInt(i64, vel_it.next().?, 10);
        try robots.append(.{ .pos = .{.x = x, .y = y}, .vel = .{.x = dx, .y = dy}});
    }

    const width = 101;
    const height = 103;

    for(0..robots.items.len) |i| {
        var robot = &robots.items[i];
            robot.jump(100);
            robot.warp(width, height);
            robot.print();
    }

    var quad0: u32 = 0;
    var quad1: u32 = 0;
    var quad2: u32 = 0;
    var quad3: u32 = 0;

    for(robots.items) |robot| {
        if(robot.pos.x < width / 2 and robot.pos.y < height / 2) {
            quad0 += 1;
        } else if(robot.pos.x > width / 2 and robot.pos.y < height / 2) {
            quad1 += 1;
        } else if(robot.pos.x < width / 2 and robot.pos.y > height / 2) {
            quad2 += 1;
        } else if(robot.pos.x > width / 2 and robot.pos.y > height / 2) {
            quad3 += 1;
        }
    }
    total = quad0 * quad1 * quad2 * quad3;

    return total;
}

fn part_2(comptime input_data: []const u8) !u64 {
    var total : u64 = 0;
    total = 0;
    var data = comptime split_data(input_data);

    var robots = std.ArrayList(Robot).init(std.heap.page_allocator);
    while(data.next()) |line| {
        var it = std.mem.tokenizeScalar(u8, line, ' ');
        const pos = it.next().?;
        const vel = it.next().?;
        var pos_it = std.mem.tokenizeScalar(u8, pos[2..], ',');
        const x = try std.fmt.parseInt(i64, pos_it.next().?, 10);
        const y = try std.fmt.parseInt(i64, pos_it.next().?, 10);
        var vel_it = std.mem.tokenizeScalar(u8, vel[2..], ',');
        const dx = try std.fmt.parseInt(i64, vel_it.next().?, 10);
        const dy = try std.fmt.parseInt(i64, vel_it.next().?, 10);
        try robots.append(.{ .pos = .{.x = x, .y = y}, .vel = .{.x = dx, .y = dy}});
    }

    const robot_copy = try robots.clone();

    const width = 101;
    const height = 103;

    for(0..robots.items.len) |ii| {
        var robot = &robots.items[ii];
            robot.jump(23);
            robot.warp(width, height);
        }
    for(0..101) |i| {
        std.debug.print("Iteration: {}\n", .{i});
        std.time.sleep(100000000);
        var grid = std.AutoHashMap(Coordinate, u32).init(std.heap.page_allocator);
        defer grid.deinit();
        for(0..height) |h| {
            for(0..width) |w| {
                try grid.put(.{.x = @intCast(w), .y = @intCast(h)}, 0);
            }
        }

        for(robots.items) |robot| {
            try grid.put(robot.pos, 1);
        }

        for(0..height) |h| {
            for(0..width) |w| {
                if(grid.get(.{.x = @intCast(w), .y = @intCast(h)}).? == 1) {
                    std.debug.print("#", .{});
                } else {
                    std.debug.print(" ", .{});
                }
            }
            std.debug.print("\n", .{});
        }

    for(0..robots.items.len) |ii| {
        var robot = &robots.items[ii];
            robot.jump(101);
            robot.warp(width, height);
        }
            if(std.meta.eql(robot_copy.items, robots.items)) {
                break;
            }
    }
    return total;
}
