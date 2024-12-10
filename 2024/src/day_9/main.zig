const std = @import("std");
const test_data = @embedFile("test_data.txt");
const real_data = @embedFile("data.txt");

const part_1_test = 1928;
const part_2_test = 2858;

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

var disk = std.ArrayList(i32).init(std.heap.page_allocator);
    var visited = std.ArrayList(bool).init(std.heap.page_allocator);

fn part_1(comptime input_data: [] const u8) !u128 {
    var total : u128 = 0;
    var data = comptime split_data(input_data);

    while(data.next()) |line| {
        total = 0;
        var data_space = true;
        var count: i32 = 0;
        for(line) |char| {
            var num = try std.fmt.parseInt(i32, (&char)[0..1], 10);
            if(data_space) {
                while(num > 0) : (num -= 1) {
                    try disk.append(count);
                }
                count += 1;
                data_space = false;
            } else {
                while(num > 0) : (num -= 1) {
                    try disk.append(-1);
                }
                data_space = true;
            }
        }
    }

    for(disk.items, 0..) |item, i| {
            if(i >= disk.items.len) break;
        if(item == -1) {
            while(disk.items[(disk.items.len - 1)] == -1) {
                _ = disk.pop();
            }
            if(i >= disk.items.len) break;
            disk.items[i] = disk.items[(disk.items.len - 1)];
            _ = disk.pop();
        }
    }
    for(disk.items, 0..) |item, i| {
        if(item == -1) {
            continue;
        }
        total += @as(u128, @intCast(i)) * @as(u128, @intCast(item));
    }
    disk.clearAndFree();
    return total;
}

fn get_last_group_size() struct {size: u8, offset: usize} {
    var count: usize = disk.items.len - 1;
    while(disk.items[count] == -1) : (count -= 1) {
        visited.items[count] = true;
    }
    while(visited.items[count]) : (count -= 1) {
    }
    var offset: usize = disk.items.len - 1 - count;
    while(disk.items[count] == -1) : (count -= 1) {
        offset += 1;
        visited.items[count] = true;
    }
    const last_group_id: i32 = disk.items[count];
    var last_group_size: u8 = 0;
    while(disk.items[count] == last_group_id) : (count -= 1) {
        visited.items[count] = true;
        last_group_size += 1;
    }
    while(disk.items[count] == -1) : (count -= 1) {
        visited.items[count] = true;
    }
     return .{.size = last_group_size, .offset = offset};
}

fn part_2(comptime input_data: []const u8) !u128 {
var total : u128 = 0;
    var data = comptime split_data(input_data);

    while(data.next()) |line| {
        total = 0;
        var data_space = true;
        var count: i32 = 0;
        for(line) |char| {
            var num = try std.fmt.parseInt(i32, (&char)[0..1], 10);
            if(data_space) {
                while(num > 0) : (num -= 1) {
                    try disk.append(count);
                }
                count += 1;
                data_space = false;
            } else {
                while(num > 0) : (num -= 1) {
                    try disk.append(-1);
                }
                data_space = true;
            }
        }
    }

    try visited.resize(disk.items.len);
    for(visited.items, 0..) |_, i| {
        visited.items[i] = false;
    }
    // std.debug.print("Disk: {d}\n", .{disk.items});

    for(disk.items) |item| {
            var spaces = std.ArrayList(struct{space: usize, offset: usize}).init(std.heap.page_allocator);
            defer spaces.deinit();
            var jj: usize = 0;
            while(jj < disk.items.len) : (jj += 1) {
                var count: usize = 0;
                if(disk.items[jj] == -1 and !visited.items[jj]) {
                    while(disk.items[jj + count] == -1) {
                        count += 1;
                    }
                    jj += count;
                try spaces.append(.{.space = count, .offset = jj - count});
                }
            }
            if(spaces.items.len == 0) {
                break;
            }
        if(item == -1) {
            const group = get_last_group_size();
            const last_group_size = group.size;
            const offset = group.offset;

            // std.debug.print("Last group size: {d}, Offset: {d}, Space: {any}\n", .{last_group_size, offset, spaces.items});
            for(spaces.items) |space| {
                if(last_group_size <= space.space)
                {
                    for(0..last_group_size) |j| {
                        disk.items[j + space.offset] = disk.items[(disk.items.len - 1 - j - offset)];
                        visited.items[j + space.offset] = true;
                        disk.items[(disk.items.len - 1 - j - offset)] = -1;
                        visited.items[(disk.items.len - 1 - j - offset)] = true;
                    }
                    break;
                }
            }
            // std.debug.print("Disk: {d}\n", .{disk.items});
            // std.debug.print("Vist: {any}\n", .{visited.items});
        }
    }
    // std.debug.print("Disk: {d}\n", .{disk.items});
    // std.debug.print("Visited: {any}\n", .{visited.items});
    for(disk.items, 0..) |item, i| {
        if(item == -1) {
            continue;
        }
        total += @as(u128, @intCast(i)) * @as(u128, @intCast(item));
    }
    return total;
}
