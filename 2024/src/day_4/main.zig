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
    const result = try part_2(real_data);
    std.debug.print("{}\n", .{result});
}

fn search(row: i32, col: i32, data: [] const u8, row_length: i32) u32 {
    var total: u32 = 0;
    for (0..3) |row_off| {
        for (0..3) |col_off| {
            const row_offset: i32 = @as(i32, @intCast(row_off)) - 1;
            const col_offset: i32 = @as(i32, @intCast(col_off)) - 1;
            // if (row_offset == 0 and col_offset == 0) {
            //     continue;
            // }
            var current_row: i32 = row + row_offset;
            var current_col: i32 = col + col_offset;

            if(current_row > row_length - 1 or current_row < 0) {
                continue;
            }
            if(current_col >= row_length or current_col < 0) {
                continue;
            }
            var index: usize = @intCast(current_row * (row_length + 1) + current_col);
            // std.debug.print("first current_row: {}, first current_col: {}, index: {}, {c}\n", .{current_row, current_col, index, data[index]});

            if(data[index] == 'M') {
                // std.debug.print("M at: {}, {}\n", .{current_row, current_col});
                current_row += row_offset;
                current_col += col_offset;

                // std.debug.print("new current_row: {}, new current_col: {}\n", .{current_row, current_col});
                if(current_row > row_length - 1 or current_row < 0) {
                    continue;
                }
                if(current_col >= row_length or current_col < 0) {
                    continue;
                }
                index = @intCast(current_row * (row_length + 1) + current_col);

                if(data[index] == 'A') {

                // std.debug.print("A at: {}, {}\n", .{current_row, current_col});
                    current_row += row_offset;
                    current_col += col_offset;

                    if(current_row > row_length - 1 or current_row < 0) {
                        continue;
                    }
                    if(current_col >= row_length or current_col < 0) {
                        continue;
                    }
                    index = @intCast(current_row * (row_length + 1) + current_col);
                    if(data[index] == 'S') {
                        // std.debug.print("S at: {}, {}\n", .{current_row, current_col});
                        total += 1;
                    } else {
                        continue;
                    }
                } else {
                    continue;
                }
            } else {
                continue;
            }
        }
    }
    
    return total;
}

fn search_2(row: i32, col: i32, data: [] const u8, row_length: i32) u32 {
    var total: u32 = 0;
    // for (0..3) |row_off| {
    //     for (0..3) |col_off| {
            // const row_offset: i32 = @as(i32, @intCast(row_off)) - 1;
            // const col_offset: i32 = @as(i32, @intCast(col_off)) - 1;
            // if (row_offset == 0 and col_offset == 0) {
            //     continue;
            // }
            const m_1_r = row - 1;
const m_1_c = col - 1;

const m_2_c = col - 1;
const m_2_r = row + 1;

const s_1_c = col + 1;
const s_1_r = row - 1;

const s_2_c = col + 1;
const s_2_r = row + 1;

            if(m_1_r > row_length - 1 or m_1_r < 0) {
                return 0;
            }
            if(m_1_c >= row_length or m_1_c < 0) {
                return 0;
            }
            if(m_2_r > row_length - 1 or m_2_r < 0) {
                return 0;
            }
            if(m_2_c >= row_length or m_2_c < 0) {
                return 0;
            }
            if(s_1_r > row_length - 1 or s_1_r < 0) {
                return 0;
            }
            if(s_1_c >= row_length or s_1_c < 0) {
                return 0;
            }
            if(s_2_r > row_length - 1 or s_2_r < 0) {
                return 0;
            }
            if(s_2_c >= row_length or s_2_c < 0) {
                return 0;
            }

            const m_1_index: usize = @intCast(m_1_r * (row_length + 1) + m_1_c);
            const m_2_index: usize = @intCast(m_2_r * (row_length + 1) + m_2_c);
            const s_1_index: usize = @intCast(s_1_r * (row_length + 1) + s_1_c);
            const s_2_index: usize = @intCast(s_2_r * (row_length + 1) + s_2_c);

            std.debug.print("m_1: {c}, m_2: {c}, s_1: {c}, s_2: {c}\n", .{data[m_1_index], data[m_2_index], data[s_1_index], data[s_2_index]});
            if(data[m_1_index] == 'M' and data[s_1_index] == 'S') {
                    if(data[m_2_index] == 'M' and data[s_2_index] == 'S') {
                        total += 1;
                    }
            }

            if(data[m_1_index] == 'M' and data[s_1_index] == 'M') {
                    if(data[m_2_index] == 'S' and data[s_2_index] == 'S') {
                        total += 1;
                    }
            }

            if(data[m_1_index] == 'S' and data[s_1_index] == 'M') {
                    if(data[m_2_index] == 'S' and data[s_2_index] == 'M') {
                        total += 1;
                    }
            }

            if(data[m_1_index] == 'S' and data[s_1_index] == 'S') {
                    if(data[m_2_index] == 'M' and data[s_2_index] == 'M') {
                        total += 1;
                    }
            }

                    //     }
            // }
            // var current_row: i32 = row + row_offset;
            // var current_col: i32 = col + col_offset;
            //
            // if(current_row > row_length - 1 or current_row < 0) {
            //     continue;
            // }
            // if(current_col >= row_length or current_col < 0) {
            //     continue;
            // }
            // var index: usize = @intCast(current_row * (row_length + 1) + current_col);
            // std.debug.print("first current_row: {}, first current_col: {}, index: {}, {c}\n", .{current_row, current_col, index, data[index]});
            //
            // if(data[index] == 'M') {
            //     std.debug.print("M at: {}, {}\n", .{current_row, current_col});
            //     current_row += row_offset;
            //     current_col += col_offset;
            //
            //     std.debug.print("new current_row: {}, new current_col: {}\n", .{current_row, current_col});
            //     if(current_row > row_length - 1 or current_row < 0) {
            //         continue;
            //     }
            //     if(current_col >= row_length or current_col < 0) {
            //         continue;
            //     }
            //     index = @intCast(current_row * (row_length + 1) + current_col);
            //
            //     if(data[index] == 'A') {
            //
            //     std.debug.print("A at: {}, {}\n", .{current_row, current_col});
            //         current_row += row_offset;
            //         current_col += col_offset;
            //
            //         if(current_row > row_length - 1 or current_row < 0) {
            //             continue;
            //         }
            //         if(current_col >= row_length or current_col < 0) {
            //             continue;
            //         }
            //         index = @intCast(current_row * (row_length + 1) + current_col);
            //         if(data[index] == 'S') {
            //             std.debug.print("S at: {}, {}\n", .{current_row, current_col});
            //             total += 1;
            //         } else {
            //             continue;
            //         }
            //     } else {
            //         continue;
            //     }
            // } else {
            //     continue;
            // }
        // }
    // }
    
    return total;
}
fn part_1(comptime input_data: [] const u8) !u32 {

    var total : u32 = 0;
    var data = split_data(input_data);
    const row_length: i32 = @intCast(data.peek().?.len);

    var row: i32 = 0;
    while (data.next()) |line| {
        var col: i32 = 0;
        for(line) |item| {
            if(item == 'X') {
                // std.debug.print("X at: {}, {}\n", .{row, col});
                total += search(row, col, input_data, row_length);
            }
            col += 1;
        }
        row += 1;
    }
    
    return total;
}

fn part_2(comptime input_data: []const u8) !u32 {

    var total : u32 = 0;
    var data = split_data(input_data);
    const row_length: i32 = @intCast(data.peek().?.len);

    var row: i32 = 0;
    while (data.next()) |line| {
        var col: i32 = 0;
        for(line) |item| {
            if(item == 'A') {
                std.debug.print("{c} at: {}, {}\n", .{input_data[@intCast(row * (row_length + 1) + col)], row, col});
                total += search_2(row, col, input_data, row_length);
            }
            col += 1;
        }
        row += 1;
    }
    
    return total;
}


test "part 1" {
    try std.testing.expectEqual(18, part_1(test_data));
}

test "part 2" {
    try std.testing.expectEqual(9, part_2(test_data));
}
