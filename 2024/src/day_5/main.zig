const std = @import("std");
const test_data = @embedFile("test_data.txt");
const real_data = @embedFile("data.txt");

fn split_data(comptime data: []const u8) std.mem.SplitIterator(u8, .scalar) {
    const trimmed_data = std.mem.trim(u8, data, " \t\n");
    return std.mem.splitScalar(u8, trimmed_data, '\n');
}

pub fn main() !void {
    const result = try part_2(real_data);
    std.debug.print("{}\n", .{result});
}

fn split_rule(rule: []const u8) Rule {
    var it = std.mem.tokenizeScalar(u8, rule, '|');
    const min = std.fmt.parseInt(i32, it.next().?, 10) catch 0;
    const max = std.fmt.parseInt(i32, it.next().?, 10) catch 0;
    return .{.first = min, .second = max};
}

fn split_update(page: []const u8) std.ArrayList(i32) {
    const trim = std.mem.trim(u8, page, " \t\n");
    var first_col = std.ArrayList(i32).init(std.heap.page_allocator);
    // defer first_col.deinit();

    var it = std.mem.tokenizeScalar(u8, trim, ',');
    while(it.next()) |item| {
        const value = std.fmt.parseInt(i32, item, 10) catch 0;
        first_col.append(value) catch unreachable;
    }
    return first_col;
}

fn validate_update(update: std.ArrayList(i32)) bool {

    for(update.items, 0..) |item, i| {
        for(i+1..update.items.len) |j| {
            const next_item = update.items[j];
            for(rules.items) |rule| {
                //Rule reversed
                if((next_item == rule.first and item == rule.second)) {
                    return false;
                }
            }
        }
    }
    return true;
}

const Rule = struct {
    first: i32,
    second: i32,
};

var rules: std.ArrayList(Rule) = std.ArrayList(Rule).init(std.heap.page_allocator);

fn part_1(comptime input_data: [] const u8) !u32 {

    var total : u32 = 0;
    var data = comptime split_data(input_data);

    var parse_rules = true;
    while (data.next()) |line| {
        if(std.mem.eql(u8, line, "")) {
            parse_rules = false;
            continue;
        }
        if(parse_rules) {
            try rules.append(split_rule(line));

        } else {
            const pages = split_update(line);
            if(validate_update(pages)) {
                total += @intCast(pages.items[pages.items.len / 2]);
            }
        }

    }
    return total;
}


fn sort_update(update: *std.ArrayList(i32)) void{

    for(update.items, 0..) |item, i| {
        for(i+1..update.items.len) |j| {
            const next_item = update.items[j];
            for(rules.items) |rule| {
                //Rule reversed
                if((next_item == rule.first and item == rule.second)) {
                    std.mem.swap(i32, &update.items[i], &update.items[j]);
                    break;
                    // return false;
                }
            }
        }
    }
}

fn part_2(comptime input_data: []const u8) !u32 {
    var total : u32 = 0;
    var data = comptime split_data(input_data);

    var parse_rules = true;
    while (data.next()) |line| {
        if(std.mem.eql(u8, line, "")) {
            parse_rules = false;
            continue;
        }
        if(parse_rules) {
            try rules.append(split_rule(line));

        } else {
            var pages = split_update(line);
            if(validate_update(pages)) {
                // total += @intCast(pages.items[pages.items.len / 2]);
            } else {
                // std.debug.print("Before: {any}\n", .{pages.items});
                // sort_update(&pages);
                while(!validate_update(pages)) {
                sort_update(&pages);
                }
                // std.debug.print("After: {any}\n", .{pages.items});
                total += @intCast(pages.items[pages.items.len / 2]);
            }
        }

    }
    return total;

}


test "part 1" {
    try std.testing.expectEqual(143, part_1(test_data));
}

test "part 2" {
    try std.testing.expectEqual(123, part_2(test_data));
}
