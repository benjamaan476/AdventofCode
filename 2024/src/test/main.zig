const std = @import("std");
const test_data = @embedFile("test_data.txt");
const real_data = @embedFile("data.txt");

const red_count = 12;
const green_count = 13;
const blue_count = 14;

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
    while (data.next()) |line| {
        var it = std.mem.tokenizeScalar(u8, line, ':');
        const game = it.next().?;
        const good_game = game: {
            const game_data = it.rest();
            var dice_tokens = std.mem.tokenizeScalar(u8, game_data, ';');

            while (dice_tokens.next()) |dice_token| {
                const trimmed_dice_tokens = std.mem.trim(u8, dice_token, " \t\n");
                var dice = std.mem.tokenizeScalar(u8, trimmed_dice_tokens, ',');

                while (dice.next()) |die| {
                    const d = parse_dice(die);
                    const colour = d.colour;
                    const colour_value = d.value;

                    switch (colour) {
                        .Red => if(colour_value > red_count) break :game false,
                        .Green => if(colour_value > green_count) break :game false,
                        .Blue => if(colour_value > blue_count) break :game false,
                    }
                }
            }

            break :game true;
        };
        if(good_game)
        {
            const str = std.fmt.parseInt(u8, game[5..], 10) catch 0;
            // std.debug.print("added: {}\n", .{str});
            total += str;
        }
    }
    return total;
}

fn part_2(comptime input_data: []const u8) !u32 {

var total : u32 = 0;
    var data = split_data(input_data);
    while (data.next()) |line| {
        var it = std.mem.tokenizeScalar(u8, line, ':');
        _ = it.next().?;
        const good_game = game: {
            const game_data = it.rest();
            var dice_tokens = std.mem.tokenizeScalar(u8, game_data, ';');

                var red_total: u16 = 0;
                var green_total: u16 = 0;
                var blue_total: u16 = 0;
            while (dice_tokens.next()) |dice_token| {
                const trimmed_dice_tokens = std.mem.trim(u8, dice_token, " \t\n");
                var dice = std.mem.tokenizeScalar(u8, trimmed_dice_tokens, ',');

                while (dice.next()) |die| {
                    const d = parse_dice(die);
                    const colour = d.colour;
                    const colour_value = d.value;

                    switch (colour) {
                        .Red => red_total += colour_value,
                        .Green => green_total += colour_value,
                        .Blue => blue_total += colour_value,
                    }

                    if(red_total > red_count) break :game 0;
                    if(green_total > green_count) break :game 0;
                    if(blue_total > blue_count) break :game 0;
                }
            }

            break :game red_total * green_total * blue_total;
        };
        if(good_game > 0)
        {
            // const str = std.fmt.parseInt(u8, game[5..], 10) catch 0;
            // std.debug.print("added: {}\n", .{str});
            total += good_game;
        }
    }
    return total;
}


test "part 1" {
    try std.testing.expectEqual(8, part_1(test_data));
}

test "part 2" {
    try std.testing.expectEqual(8, part_2(test_data));
}
