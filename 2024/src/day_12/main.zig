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
    return 0;
}

pub fn part_2_expected() u32 {
    return 368;
}

const Coordinate = struct {
    x: u32,
    y: u32,
};

const Region = struct {
    plots: std.ArrayList(Coordinate),
};

var regions = std.hash_map.AutoHashMap(u8, std.hash_map.AutoHashMap(Coordinate, void)).init(std.heap.page_allocator);
var visit = std.hash_map.AutoHashMap(Coordinate, bool).init(std.heap.page_allocator);

fn fill_region(val: u8, start: Coordinate) !std.hash_map.AutoHashMap(Coordinate, void) {
    const region = regions.get(val).?;
    var list = std.ArrayList(Coordinate).init(std.heap.page_allocator);
    var ret = std.hash_map.AutoHashMap(Coordinate, void).init(std.heap.page_allocator);
    try list.append(start);
    try ret.put(start, {});
    while(list.items.len > 0) {
        const coord = list.pop();
        if(visit.get(coord).?) {
            continue;
        }
        try visit.put(coord, true);
        if(coord.x > 0) {
            const left: Coordinate = .{.x = coord.x - 1, .y = coord.y};
            if(region.contains(left)) {
                try list.append(left);
                try ret.put(left, {});
            }
        }
        if(coord.x < 1000) {
            const right: Coordinate = .{.x = coord.x + 1, .y = coord.y};
            if(region.contains(right)) {
                try list.append(right);
                try ret.put(right, {});
            }
        }
        if(coord.y > 0) {
            const up: Coordinate = .{.x = coord.x, .y = coord.y - 1};
            if(region.contains(up)) {
                try list.append(up);
                try ret.put(up, {});
            }
        }
        if(coord.y < 1000) {
            const down: Coordinate = .{.x = coord.x, .y = coord.y + 1};
            if(region.contains(down)) {
                try list.append(down);
                try ret.put(down, {});
            }
        }
    }
    return ret;
}

fn count_neighbours(area: std.hash_map.AutoHashMap(Coordinate, void), coord: Coordinate) u32 {
    var count: u32 = 0;
    if(coord.x > 0) {
        const left: Coordinate = .{.x = coord.x - 1, .y = coord.y};
        if(area.contains(left)) {
            count += 1;
        }
    }
    if(coord.x < 1000) {
        const right: Coordinate = .{.x = coord.x + 1, .y = coord.y};
        if(area.contains(right)) {
            count += 1;
        }
    }
    if(coord.y > 0) {
        const up: Coordinate = .{.x = coord.x, .y = coord.y - 1};
        if(area.contains(up)) {
            count += 1;
        }
    }
    if(coord.y < 1000) {
        const down: Coordinate = .{.x = coord.x, .y = coord.y + 1};
        if(area.contains(down)) {
            count += 1;
        }
    }
    return count;
}

fn has_left_neighbour(area: std.hash_map.AutoHashMap(Coordinate, void), coord: Coordinate) bool {
    if(coord.x > 0) {
        const left: Coordinate = .{.x = coord.x - 1, .y = coord.y};
        if(area.contains(left)) {
            return true;
        }
    }
    return false;
}

fn has_right_neighbour(area: std.hash_map.AutoHashMap(Coordinate, void), coord: Coordinate) bool {
    if(coord.x < 1000) {
        const right: Coordinate = .{.x = coord.x + 1, .y = coord.y};
        if(area.contains(right)) {
            return true;
        }
    }
    return false;
}

fn has_up_neighbour(area: std.hash_map.AutoHashMap(Coordinate, void), coord: Coordinate) bool {
    if(coord.y > 0) {
        const up: Coordinate = .{.x = coord.x, .y = coord.y - 1};
        if(area.contains(up)) {
            return true;
        }
    }
    return false;
}

fn has_down_neighbour(area: std.hash_map.AutoHashMap(Coordinate, void), coord: Coordinate) bool {
    if(coord.y < 1000) {
      const down: Coordinate = .{.x = coord.x, .y = coord.y + 1};
        if(area.contains(down)) {
            return true;
        }
    }
    return false;
}

const Direction = enum {
    Up,
    Down,
    Left,
    Right,
};

const CoordinatePair = struct {
    start: Coordinate,
    end: Coordinate,
};

fn count_amount(lists: std.ArrayList(std.ArrayList(CoordinatePair))) u32 {
    var c: u32 = 0;
    for(lists.items) |item| {
c += @intCast(item.items.len);
    }
    return c;
}

fn find_area_and_sides(area: std.hash_map.AutoHashMap(Coordinate, void)) !struct{area: u32, perim: u32} {
    var min_x: u32 = 1000000;
    var min_y: u32 = 1000000;
    var max_x: u32 = 0;
    var max_y: u32 = 0;

    var it = area.iterator();
    while(it.next()) |coord| {
        if(coord.key_ptr.*.x < min_x) {
            min_x = coord.key_ptr.*.x;
        }
        if(coord.key_ptr.*.y < min_y) {
            min_y = coord.key_ptr.*.y;
        }
        if(coord.key_ptr.*.x > max_x) {
            max_x = coord.key_ptr.*.x;
        }
        if(coord.key_ptr.*.y > max_y) {
            max_y = coord.key_ptr.*.y;
        }
    }

    var borders = std.ArrayList(CoordinatePair).init(std.heap.page_allocator);
    for(min_y..max_y + 1) |y| {
        for(min_x..max_x + 1) |x| {
            const coord: Coordinate = .{.x = @intCast(x), .y = @intCast(y)};
            if(area.contains(coord)) {
                if(!has_up_neighbour(area, coord)) {
                    try borders.append(.{.start = coord, .end = .{.x = coord.x + 1, .y = coord.y}});
                }
                if(!has_right_neighbour(area, coord)) {
                    try borders.append(.{.start = .{.x = coord.x + 1, .y = coord.y}, .end = .{.x = coord.x + 1, .y = coord.y + 1}});
                }
                if(!has_down_neighbour(area, coord)) {
                    try borders.append(.{.start = .{.x = coord.x + 1, .y = coord.y + 1}, .end = .{.x = coord.x, .y = coord.y + 1}});
                }
                if(!has_left_neighbour(area, coord)) {
                    try borders.append(.{.start = .{.x = coord.x, .y = coord.y + 1}, .end = .{.x = coord.x, .y = coord.y}});
                }
            }
        }
    }

    var sorted_borders = std.ArrayList(std.ArrayList(CoordinatePair)).init(std.heap.page_allocator);
    var visited = std.AutoHashMap(CoordinatePair, bool).init(std.heap.page_allocator);
    for(borders.items) |entry| {
        try visited.put(entry, false);
    }

    const list = std.ArrayList(CoordinatePair).init(std.heap.page_allocator);
    try sorted_borders.append(list);
    try sorted_borders.items[sorted_borders.items.len - 1].append(borders.items[0]);
    try visited.put(borders.items[0], true);

    var is_hole = false;
    var loop_count: u32 = 0;
    while(count_amount(sorted_borders) < borders.items.len) {
        const end = sorted_borders.items[sorted_borders.items.len - 1].getLast().end;
        // const start = sorted_borders.items[sorted_borders.items.len - 1].getLast().start;
        // const end = sorted_borders.items[sorted_borders.items.len - 1].end;
        loop: for(borders.items) |pair| {
            if(is_hole) {
                if(std.meta.eql(pair.end, end) and visited.get(pair).?) {
                    var visit_it = visited.iterator();
                    while(visit_it.next()) |entry| {
                        if(!entry.value_ptr.*) {
                            const new_list = std.ArrayList(CoordinatePair).init(std.heap.page_allocator);
                            try sorted_borders.append(new_list);
                            try sorted_borders.items[sorted_borders.items.len - 1].append(.{.start = entry.key_ptr.*.end, .end = entry.key_ptr.start});
                            try visited.put(entry.key_ptr.*, true);
                            loop_count += 1;
                            break :loop;
                        }
                    }
                    break :loop;
                } else if(std.meta.eql(pair.end, end)) {
                    try sorted_borders.items[sorted_borders.items.len - 1].append(.{.start = pair.end, .end = pair.start});
                    // try sorted_borders.append(pair);
                    try visited.put(pair, true);
                    break;
                }

            } else
            {
                if(std.meta.eql(pair.start, end) and visited.get(pair).?) {
                    //Find unvisited pair
                    var visit_it = visited.iterator();
                    while(visit_it.next()) |entry| {
                        if(!entry.value_ptr.*) {
                            is_hole = true;
                            const new_list = std.ArrayList(CoordinatePair).init(std.heap.page_allocator);
                            try sorted_borders.append(new_list);
                            try sorted_borders.items[sorted_borders.items.len - 1].append(.{.start = entry.key_ptr.*.end, .end = entry.key_ptr.start});
                            try visited.put(entry.key_ptr.*, true);
                            loop_count += 1;
                            break :loop;
                        }
                    }
                    break :loop;
                } else if(std.meta.eql(pair.start,end)) {
                    try sorted_borders.items[sorted_borders.items.len - 1].append(pair);
                    // try sorted_borders.append(pair);
                    try visited.put(pair, true);
                    break;
                }
            }
        }
    }
    var itt = visited.iterator();
    while(itt.next()) |entry| {
        if(!entry.value_ptr.*) {
            std.debug.print("Unvisited: ({}, {}) -> ({}, {}) \n", .{entry.key_ptr.*.start.x, entry.key_ptr.*.start.y, entry.key_ptr.*.end.x, entry.key_ptr.*.end.y});
        }
    }
    // for(sorted_borders.items) |pair| {
    //     std.debug.print("({}, {}) -> ({}, {}) \n", .{pair.start.x, pair.start.y, pair.end.x, pair.end.y});
    // }

    var perim: u32 = 0;
    for(sorted_borders.items) |sb| {
    var single_border = std.ArrayList(CoordinatePair).init(std.heap.page_allocator);
    try single_border.append(sb.items[0]);
    var horiz = true;
    for(sb.items[1..]) |pair| {
        if(horiz)
        {
            if(pair.start.y == pair.end.y) {
                continue;
            }

            horiz = false;
            try single_border.append(pair);
        } else {
            if(pair.start.x == pair.end.x) {
                continue;
            }
            horiz = true;
            try single_border.append(pair);
        }
    }

    for(single_border.items) |item| {
        std.debug.print("({}, {}) -> ({}, {}) \n", .{item.start.x, item.start.y, item.end.x, item.end.y});
    }
    perim += @intCast(single_border.items.len);
    std.debug.print("\n", .{});
    }

    return .{.area = @intCast(area.count()), .perim = perim};
}

fn find_area_and_perim(area: std.hash_map.AutoHashMap(Coordinate, void)) struct{area: u32, perim: u32} {
    var perim: u32 = 0;
    var it = area.iterator();
    while(it.next()) |coord| {

        perim += 4 - count_neighbours(area, coord.key_ptr.*); 
    }
    return .{.area = area.count(), .perim = perim};
}

fn part_1(comptime input_data: [] const u8) !u64 {
    var total : u64 = 0;
    var data = comptime split_data(input_data);

    var j: u32 = 0;
    while(data.next()) |line| : (j += 1) {
        for(line, 0..) |char, i| {
            if(!regions.contains(char))
            {
                const list = std.hash_map.AutoHashMap(Coordinate, void).init(std.heap.page_allocator);
                try regions.put(char, list);
            }

            const coord: Coordinate = .{.x = @intCast(i), .y = @intCast(j)};
            try regions.getPtr(char).?.put(coord, {});
            try visit.put(coord, false);
        }
    }


    var it = regions.iterator();
    while(it.next()) |region| {
        var value_it = region.value_ptr.keyIterator();
        while(value_it.next()) |coord| {
            if(visit.get(coord.*).?) {
                continue;
            }
            const area = try fill_region(region.key_ptr.*, coord.*);
            const ap = find_area_and_perim(area);
            // std.debug.print("Region: {c}, Area: {}, Perim: {}\n", .{region.key_ptr.*, ap.area, ap.perim});
            total += ap.area * ap.perim;
        }
    }


    regions.clearAndFree();
    visit.clearAndFree();
    return 0;
}

fn part_2(comptime input_data: []const u8) !u64 {
    var total : u64 = 0;
    var data = comptime split_data(input_data);

    var j: u32 = 0;
    while(data.next()) |line| : (j += 1) {
        for(line, 0..) |char, i| {
            if(!regions.contains(char))
            {
                const list = std.hash_map.AutoHashMap(Coordinate, void).init(std.heap.page_allocator);
                try regions.put(char, list);
            }

            const coord: Coordinate = .{.x = @intCast(i), .y = @intCast(j)};
            try regions.getPtr(char).?.put(coord, {});
            try visit.put(coord, false);
        }
    }


    var it = regions.iterator();
    while(it.next()) |region| {
        var value_it = region.value_ptr.keyIterator();
        while(value_it.next()) |coord| {
            if(visit.get(coord.*).?) {
                continue;
            }
            const area = try fill_region(region.key_ptr.*, coord.*);
            const ap = try find_area_and_sides(area);
            // std.debug.print("Region: {c}, Area: {}, Perim: {}\n", .{region.key_ptr.*, ap.area, ap.perim});
            total += ap.area * ap.perim;
        }
    }


    regions.clearAndFree();
    return total;}
