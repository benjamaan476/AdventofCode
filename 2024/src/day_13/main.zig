const std = @import("std");
const test_data = @embedFile("test_data.txt");
const real_data = @embedFile("data.txt");

fn split_data(comptime data: []const u8) std.mem.SplitIterator(u8, .scalar) {
    const trimmed_data = std.mem.trim(u8, data, " \t\n");
    return std.mem.splitScalar(u8, trimmed_data, '\n');
}

pub fn day(part: u8, comptime is_test: bool) !i64 {
    const data = comptime if(is_test) test_data else real_data;

    if(part == 1) {
        return part_1(data);
    }
    else if (part == 2) {
        return part_2(data);
    } else unreachable;
}

pub fn part_1_expected() i64 {
    return 480;
}

pub fn part_2_expected() i64 {
    return 0;
}

const Coordinate = struct {
    x: i64,
    y: i64,
};

fn gcd(a: i64, b: i64, x: *i64, y: *i64) i64 {
    if(b == 0) {
        x.* = 1;
        y.* = 0;
        return a;
    }

    var x1: i64 = 0;
    var y1: i64 = 0;
    const d = gcd(b, @rem(a,b), &x1, &y1);
    x.* = y1;
    y.* = x1 - y1 * (@divFloor(a,b));

    return d;
}

fn part_1(comptime input_data: [] const u8) !i64 {
    var total : i64 = 0;
    var data = comptime split_data(input_data);

    var games = std.ArrayList(struct {prize: Coordinate, a: Coordinate, b: Coordinate}).init(std.heap.page_allocator);
    var j: i64 = 0;
        var a_button: Coordinate = .{.x = 0, .y = 0};
        var b_button: Coordinate = .{.x = 0, .y = 0};
    while(data.next()) |line| : (j += 1) {
        var button_label: u8 = undefined;
        if(std.mem.eql(u8, line,"")) {
            continue;
        }
        if(line[0] == 'B') {
            var token = std.mem.splitScalar(u8, line, ':');
            const button = token.next().?;
            button_label = button[button.len - 1];
            var coords = token.next().?;

            coords = std.mem.trim(u8, coords, " \t\n");
            var xy = std.mem.splitScalar(u8, coords, ',');
            if(button_label == 'A') {
                var x = xy.next().?;
                var y = xy.next().?;
                a_button = .{.x = try std.fmt.parseInt(i64, x[2..], 10), .y = try std.fmt.parseInt(i64, y[2..], 10)};

            } else if(button_label == 'B') {
                var x = xy.next().?;
                var y = xy.next().?;
                b_button = .{.x = try std.fmt.parseInt(i64, x[2..], 10), .y = try std.fmt.parseInt(i64, y[2..], 10)};
            }
        } else if (line[0] == 'P') {
            var token = std.mem.splitScalar(u8, line, ':');
            _ = token.next();
            var prize = token.next().?;
            prize = std.mem.trim(u8, prize, " \t\n");
            var xy = std.mem.splitScalar(u8, prize, ',');
            var x = xy.next().?;
            x = std.mem.trim(u8, x, " \t\n");
            var y = xy.next().?;
            y = std.mem.trim(u8, y, " \t\n");
            const prize_x = try std.fmt.parseInt(i64, x[2..], 10);// + 10000000000000;
            const prize_y = try std.fmt.parseInt(i64, y[2..], 10);// + 10000000000000;

            try games.append(.{.prize = .{.x = prize_x, .y = prize_y}, .a = a_button, .b = b_button});
        }
    }

    for(games.items) |game| {
        var x0: i64 = 0;
        var x1: i64 = 0;
        var d = gcd(game.a.x, game.b.x, &x0, &x1);
        if(@mod(game.prize.x, d) != 0) {
            continue;
        }

        x0 = @divFloor(x0 * game.prize.x, d);
        x1 = @divFloor(x1 * game.prize.x, d);

        var i: i32 = -1000;
        while(x0 < 0 or x1 < 0) : (i += 1){

            x0 += i * @divFloor(game.b.x, d);
            x1 -= i * @divFloor(game.a.x, d);
            
            std.debug.print("x0: {}, x1: {}\n", .{x0, x1});
        }


        std.debug.print("x0: {}, x1: {}\n", .{x0, x1});
        var y0: i64 = 0;
        var y1: i64 = 0;
        d = gcd(game.a.y, game.b.y, &y0, &y1);
        if(@mod(game.prize.y, d) != 0) {
            continue;
        }

        if(x0 == y0 and x1 == y1) {
            total += 1;
        }
    }
    return total;
}


fn part_2(comptime input_data: []const u8) !i64 {
    var total : i64 = 0;
    var data = comptime split_data(input_data);

    var j: i64 = 0;
    while(data.next()) |line| : (j += 1) {
        _ = line; 
    }

    total = 0;
    return total;
}
