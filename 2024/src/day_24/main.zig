
const std = @import("std");
const aoc = @import("../aoc.zig");
const test_data = @embedFile("test_data.txt");
const real_data = @embedFile("data.txt");

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
    return 4;
}

pub fn part_2_expected() u32 {
    return 0;
}

const Op = enum{And, Or, Xor};

const Gate = struct {
    first: []const u8,
    second: []const u8,
    op: Op,
    out: []const u8,

    fn eval(self: Gate, wires: *std.StringHashMap(u1)) !void {
        //Already evaluated
        if(wires.contains(self.out)) {
            return;
        }

        const first_wire = if(wires.contains(self.first)) 
            wires.get(self.first).?
         else return;

        const second_wire = if(wires.contains(self.second)) 
            wires.get(self.second).?
        else return;

           const val = switch(self.op) {
               .And => first_wire & second_wire,
               .Or => first_wire | second_wire,
               .Xor => first_wire ^ second_wire,
           };

           try wires.put(self.out, val);
           if(self.out[0] == 'z') {
               z_gate_count += 1;
           }
    }
};

var z_gate_count: u8 = 0;

fn part_1(comptime input_data: [] const u8) !u64 {
    var total : u64 = 0;
    total = 0;
    var data = comptime aoc.split_data(input_data);

    var wires = std.StringHashMap(u1).init(std.heap.page_allocator);
    var gates = std.ArrayList(Gate).init(std.heap.page_allocator);
    var z_count: u8 = 0;

    var parse_wires = true;
    while(data.next()) |line| {
        if(std.mem.eql(u8, line, "")) {
            parse_wires = false;
            continue;
        }

        if(parse_wires) {
            var line_it = std.mem.tokenizeSequence(u8, line, ": ");
            const name = line_it.next().?;
            const val = try std.fmt.parseInt(u1, line_it.next().?, 10);
           try wires.put(name, val);
        } else {
            var split_it = std.mem.tokenizeSequence(u8, line, " -> ");
            const gates_str = split_it.next().?;
            const wire = split_it.next().?;

            if(wire[0] == 'z') {
                z_count += 1;
            }

            var gates_it = std.mem.tokenizeScalar(u8, gates_str, ' ');
            const first = gates_it.next().?;
            const gate = gates_it.next().?;
            const second = gates_it.next().?;

            const op: Op = switch(gate[0]) {
                'A' => .And,
                'O' => .Or,
                'X' => .Xor,
                else => unreachable,
            };

            try gates.append(.{.first = first, .second = second, .op = op, .out = wire});
        }
    }

    while(z_gate_count < z_count) {
        for(gates.items) |gate| {
               try gate.eval(&wires);
        }
    }

    for(gates.items) |gate| {
        std.debug.print("{s}, {}\n", .{gate.out, wires.get(gate.out).?});
    }

    for(0..z_count) |i| {
        var name: [3]u8 = undefined;
        _ = try std.fmt.bufPrint(&name, "z{d:0>2}", .{i});
        const val = @as(u64, @intCast(wires.get(&name).?));
        std.debug.print("Gate name: {s}, val: {}\n", .{name, val});
        total += val << @intCast(i);
    }

    return total;
}

fn part_2(comptime input_data: []const u8) !u64 {
    var total : u64 = 0;
    total = 0;
    var data = comptime aoc.split_data(input_data);

    var wires = std.StringHashMap(u1).init(std.heap.page_allocator);
    var gates = std.ArrayList(Gate).init(std.heap.page_allocator);
    var z_count: u8 = 0;

    var parse_wires = true;
    while(data.next()) |line| {
        if(std.mem.eql(u8, line, "")) {
            parse_wires = false;
            continue;
        }

        if(parse_wires) {
            var line_it = std.mem.tokenizeSequence(u8, line, ": ");
            const name = line_it.next().?;
            const val = try std.fmt.parseInt(u1, line_it.next().?, 10);
           try wires.put(name, val);
        } else {
            var split_it = std.mem.tokenizeSequence(u8, line, " -> ");
            const gates_str = split_it.next().?;
            const wire = split_it.next().?;

            if(wire[0] == 'z') {
                z_count += 1;
            }

            var gates_it = std.mem.tokenizeScalar(u8, gates_str, ' ');
            const first = gates_it.next().?;
            const gate = gates_it.next().?;
            const second = gates_it.next().?;

            const op: Op = switch(gate[0]) {
                'A' => .And,
                'O' => .Or,
                'X' => .Xor,
                else => unreachable,
            };

            try gates.append(.{.first = first, .second = second, .op = op, .out = wire});
        }
    }

    var x_count: u64 = 0;
    for(0..z_count - 1) |i| {
        var name: [3]u8 = undefined;
        _ = try std.fmt.bufPrint(&name, "x{d:0>2}", .{i});
        const val = @as(u64, @intCast(wires.get(&name).?));
       // std.debug.print("Gate name: {s}, val: {}\n", .{name, val});
        x_count += val << @intCast(i);
    }

    var y_count: u64 = 0;
    for(0..z_count - 1) |i| {
        var name: [3]u8 = undefined;
        _ = try std.fmt.bufPrint(&name, "y{d:0>2}", .{i});
        const val = @as(u64, @intCast(wires.get(&name).?));
       // std.debug.print("Gate name: {s}, val: {}\n", .{name, val});
        y_count += val << @intCast(i);
    }

    const required_z = x_count + y_count;

    while(z_gate_count < z_count) {
        for(gates.items) |gate| {
               try gate.eval(&wires);
        }
    }

    for(gates.items) |gate| {
        std.debug.print("{s}, {}\n", .{gate.out, wires.get(gate.out).?});
    }

    for(0..z_count) |i| {
        var name: [3]u8 = undefined;
        _ = try std.fmt.bufPrint(&name, "z{d:0>2}", .{i});
        const val = @as(u64, @intCast(wires.get(&name).?));
        std.debug.print("Gate name: {s}, val: {}\n", .{name, val});
        total += val << @intCast(i);
    }

    return total;
}
