const std = @import("std");
const test_data = @embedFile("test_data.txt");
const real_data = @embedFile("data.txt");

const part_1_test = 14;
const part_2_test = 34;

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

const Coordinate = struct {
    x: i32,
    y: i32,
};

const Pair = struct {
    first: Coordinate,
    second: Coordinate,

    fn antinode(self: Pair) !void {
        const gradient_y = self.second.y - self.first.y;
        const gradient_x = self.second.x - self.first.x;

        var pos_x = self.first.x;
        var pos_y = self.first.y;

        while((pos_x >= 0) and pos_x < map_width and pos_y >= 0 and pos_y < map_height) {
            pos_x -= gradient_x;
            pos_y -= gradient_y;
            if(pos_x < 0 or pos_x >= map_width or pos_y < 0 or pos_y >= map_height) {
                break;
            }

            const distance_first_x = @abs(pos_x - self.first.x);
            const distance_first_y = @abs(pos_y - self.first.y);
            const distance_second_x = @abs(pos_x - self.second.x);
            const distance_second_y = @abs(pos_y - self.second.y);

            const first_dist = @max(distance_first_x, distance_first_y);
            const second_dist = @max(distance_second_x, distance_second_y);

            if(first_dist == 2 * second_dist or second_dist == 2 * first_dist) {
                try antinodes.put(.{.x = pos_x, .y = pos_y}, {});
            }
        }
        pos_x = self.first.x;
        pos_y = self.first.y;
        while((pos_x >= 0) and pos_x < map_width and pos_y >= 0 and pos_y < map_height) {
            pos_x += gradient_x;
            pos_y += gradient_y;

            if(pos_x < 0 or pos_x >= map_width or pos_y < 0 or pos_y >= map_height) {
                break;
            }
            const distance_first_x = @abs(pos_x - self.first.x);
            const distance_first_y = @abs(pos_y - self.first.y);
            const distance_second_x = @abs(pos_x - self.second.x);
            const distance_second_y = @abs(pos_y - self.second.y);

            const first_dist = @max(distance_first_x, distance_first_y);
            const second_dist = @max(distance_second_x, distance_second_y);

            if(first_dist == 2 * second_dist or second_dist == 2 * first_dist) {
                try antinodes.put(.{.x = pos_x, .y = pos_y}, {});
            }
        }
    }

    fn antinode_2(self: Pair) !void {
        const gradient_y = self.second.y - self.first.y;
        const gradient_x = self.second.x - self.first.x;

        var pos_x = self.first.x;
        var pos_y = self.first.y;

        while((pos_x >= 0) and pos_x < map_width and pos_y >= 0 and pos_y < map_height) {
            pos_x -= gradient_x;
            pos_y -= gradient_y;
            if(pos_x < 0 or pos_x >= map_width or pos_y < 0 or pos_y >= map_height) {
                break;
            }

            // const first_dist = @max(distance_first_x, distance_first_y);
            // const second_dist = @max(distance_second_x, distance_second_y);

            // if(first_dist == 2 * second_dist or second_dist == 2 * first_dist) {
                try antinodes.put(.{.x = pos_x, .y = pos_y}, {});
            // }
        }
        pos_x = self.first.x;
        pos_y = self.first.y;
        while((pos_x >= 0) and pos_x < map_width and pos_y >= 0 and pos_y < map_height) {
            pos_x += gradient_x;
            pos_y += gradient_y;

            if(pos_x < 0 or pos_x >= map_width or pos_y < 0 or pos_y >= map_height) {
                break;
            }
            // const distance_first_x = @abs(pos_x - self.first.x);
            // const distance_first_y = @abs(pos_y - self.first.y);
            // const distance_second_x = @abs(pos_x - self.second.x);
            // const distance_second_y = @abs(pos_y - self.second.y);
            //
            // const first_dist = @max(distance_first_x, distance_first_y);
            // const second_dist = @max(distance_second_x, distance_second_y);
            //
            // if(first_dist == 2 * second_dist or second_dist == 2 * first_dist) {
                try antinodes.put(.{.x = pos_x, .y = pos_y}, {});
            // }
        }
    }
};

var antennae = std.hash_map.AutoHashMap(u8, std.ArrayList(Coordinate)).init(std.heap.page_allocator);
var antinodes = std.hash_map.AutoHashMap(Coordinate, void).init(std.heap.page_allocator);

fn part_1(comptime input_data: [] const u8) !u128 {
    var total : u128 = 0;
    var data = comptime split_data(input_data);

    var j: u32 = 0;
    while(data.next()) |line| : (j += 1) {
        total = 0;
        for(line, 0..) |item, i| {
            if(item == '.') {
                continue;
            }
            if(!antennae.contains(item))
            {
                const list: std.ArrayList(Coordinate) = std.ArrayList(Coordinate).init(std.heap.page_allocator);
                try antennae.put(item, list);
            }
                try antennae.getPtr(item).?.append(.{.x = @intCast(i), .y = @intCast(j)});
        }
    }
    map_height = @intCast(j);
    map_width = @intCast(j);

    var it = antennae.iterator();
    while(it.next()) |group| {
        for(0..group.value_ptr.items.len) |ii| {
            for(ii + 1..group.value_ptr.items.len) |jj| {
                var pair: Pair = .{.first = group.value_ptr.items[ii], .second = group.value_ptr.items[jj]};
                try pair.antinode();
            }

        }
    }
    var itt = antinodes.keyIterator();
    while (itt.next()) |coord| {
        const x = coord.x;
        const y = coord.y;
        std.debug.print("Antinode: {d} {d}\n", .{x, y});
    }
    total = antinodes.count();
    return total;
}


fn part_2(comptime input_data: []const u8) !u128 {
    var total : u128 = 0;
    var data = comptime split_data(input_data);

    var j: u32 = 0;
    while(data.next()) |line| : (j += 1) {
        total = 0;
        for(line, 0..) |item, i| {
            if(item == '.') {
                continue;
            }
            if(!antennae.contains(item))
            {
                const list: std.ArrayList(Coordinate) = std.ArrayList(Coordinate).init(std.heap.page_allocator);
                try antennae.put(item, list);
            }
                try antennae.getPtr(item).?.append(.{.x = @intCast(i), .y = @intCast(j)});
        }
    }
    map_height = @intCast(j);
    map_width = @intCast(j);

    var it = antennae.iterator();
    while(it.next()) |group| {
        for(0..group.value_ptr.items.len) |ii| {
            for(ii + 1..group.value_ptr.items.len) |jj| {
                var pair: Pair = .{.first = group.value_ptr.items[ii], .second = group.value_ptr.items[jj]};
                try pair.antinode_2();
                try antinodes.put(pair.first, {});
                try antinodes.put(pair.second, {});
            }

        }
    }
    var itt = antinodes.keyIterator();
    while (itt.next()) |coord| {
        const x = coord.x;
        const y = coord.y;
        std.debug.print("Antinode: {d} {d}\n", .{x, y});
    }
    total = antinodes.count();
    return total;
}
