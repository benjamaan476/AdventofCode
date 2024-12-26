const std = @import("std");
const test_data = @embedFile("test_data.txt");
const real_data = @embedFile("data.txt");

fn split_data(comptime data: []const u8) std.mem.TokenIterator(u8, .scalar) {
    const trimmed_data = std.mem.trim(u8, data, " \t\n");
    return std.mem.tokenizeScalar(u8, trimmed_data, '\n');
        // const game = std.mem.tokenizeAny(u8, line, ':');
        // const game_name = game.next();
        // const game_data = game.next();
        // const game_data_tokens = std.mem.tokenizeAny(u8, game_data, ';');
        // var game_data_array = [_]u8{};
        // for (game_data_tokens.next()) |game_data_token| {
        //     const game_data_token_tokens = std.mem.tokenizeAny(u8, game_data_token, ',');
        //     for (game_data_token_tokens.next()) |game_data_token_token| {
        //         game_data_array = game_data_array ++ game_data_token_token;
        //     }
        // }
        // result = result ++ game_name ++ game_data_array;
}

pub fn main() !void {
    const result = try part_1(real_data);
    std.debug.print("{}\n", .{result});
}

const Colour = enum {
    Red,
    Green,
    Blue,
};

fn get_colour(colour: []const u8) Colour {
    
    if(std.mem.eql(u8, colour, "red")) return Colour.Red;
    if(std.mem.eql(u8, colour, "green")) return Colour.Green;
    if(std.mem.eql(u8, colour, "blue")) return Colour.Blue;
     
    unreachable;
}

fn parse_dice(dice: []const u8) struct {value: u8, colour: Colour} {
    var it = std.mem.tokenizeScalar(u8, dice, ' ');
    const value = std.fmt.parseInt(u8, it.next().?, 10);
    const colour = get_colour(it.next().?);
    return .{.value = value catch 0, .colour = colour};
}

fn part_1(comptime input_data: [] const u8) !u32 {

    var total : u32 = 0;
    var data = split_data(input_data);

    var first_col = std.ArrayList(i32).init(std.heap.page_allocator);
    defer first_col.deinit();
    var second_col = std.ArrayList(i32).init(std.heap.page_allocator);

    while (data.next()) |line| {
        var it = std.mem.tokenizeScalar(u8, line, ' ');
        const first = std.fmt.parseInt(i32, it.next().?, 10) catch 0;
        const second = std.fmt.parseInt(i32, it.next().?, 10) catch 0;
       try first_col.append(first);
       try second_col.append(second);
    }
    
    std.mem.sort(i32, first_col.items, {}, comptime std.sort.desc(i32));
    std.mem.sort(i32, second_col.items, {}, comptime std.sort.desc(i32));

    for(first_col.items, second_col.items) |first, second| {
        total += @abs(first - second);
    }
    return total;
}

fn part_2(comptime input_data: []const u8) !u32 {

var total : u32 = 0;
    var data = split_data(input_data);

    var first_col = std.ArrayList(i32).init(std.heap.page_allocator);
    defer first_col.deinit();
    var second_col = std.ArrayList(i32).init(std.heap.page_allocator);

    while (data.next()) |line| {
        var it = std.mem.tokenizeScalar(u8, line, ' ');
        const first = std.fmt.parseInt(i32, it.next().?, 10) catch 0;
        const second = std.fmt.parseInt(i32, it.next().?, 10) catch 0;
       try first_col.append(first);
       try second_col.append(second);
    }
    
    for(first_col.items) |first| {
        const first_total = std.mem.count(i32, second_col.items, &[_]i32{first});
        total += @as(u32, @intCast(first)) * @as(u32, @intCast(first_total));
    }
    return total;
}


test "part 1" {
    try std.testing.expectEqual(11, part_1(test_data));
}

test "part 2" {
    try std.testing.expectEqual(31, part_2(test_data));
}
