
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

pub fn part_1_expected() u64 {
    return 0;
}

pub fn part_2_expected() u64 {
    return 117440;
}

fn adv(self: *Cpu, operand: u3) void {
    const numerator = self.register_a;
    self.register_a = numerator >> @intCast(self.combo_operator(operand));
}

fn bxl(self: *Cpu, operand: u3) void {
    self.register_b ^= operand;
}

fn bst(self: *Cpu, operand: u3) void {
    self.register_b = self.combo_operator(operand) % 8;
}

fn jnz(self: *Cpu, operand: u3) void {
    if(self.register_a != 0) {
        self.jump_flag = true;
        self.program_counter = operand;
    }
}

fn bxc(self: *Cpu, operand: u3) void {
    _ = operand;
    self.register_b ^= self.register_c;
}

fn out(self: *Cpu, operand: u3) void {
    const value: u3 = @intCast(self.combo_operator(operand) % 8);
    // std.debug.print("{},", .{value});
    program_output.append(value) catch unreachable;
}

fn bdv(self: *Cpu, operand: u3) void {
    const numerator = self.register_a;
    self.register_b = numerator >> @intCast(self.combo_operator(operand));
}

fn cdv(self: *Cpu, operand: u3) void {
    const numerator = self.register_a;
    self.register_c = numerator >> @intCast(self.combo_operator(operand));
}

const Cpu = struct {

    register_a: u64 = 0,
    register_b: u64 = 0,
    register_c: u64 = 0,
    program_counter: u64 = 0,
    program: std.ArrayList(u3) = std.ArrayList(u3).init(std.heap.page_allocator),
    instruction: std.ArrayList(*const fn(*Cpu, u3) void) = std.ArrayList(*const fn(*Cpu, u3) void).init(std.heap.page_allocator),
    jump_flag: bool = false,

    fn combo_operator(self: Cpu, operand: u3) u64 {
        switch(operand) {
            0 => return 0,
            1 => return 1,
            2 => return 2,
            3 => return 3,
            4 => return self.register_a,
            5 => return self.register_b,
            6 => return self.register_c,
            else => unreachable,
        }
    }


    fn init(self: *Cpu) void {
        self.instruction.append(adv) catch unreachable;
        self.instruction.append(bxl) catch unreachable;
        self.instruction.append(bst) catch unreachable;
        self.instruction.append(jnz) catch unreachable;
        self.instruction.append(bxc) catch unreachable;
        self.instruction.append(out) catch unreachable;
        self.instruction.append(bdv) catch unreachable;
        self.instruction.append(cdv) catch unreachable;
    }

    fn reset(self: *Cpu, a: u64) void {
        self.register_a = a;
        self.register_b = 0;
        self.register_c = 0;
        self.program_counter = 0;
        self.jump_flag = false;
    }

    fn run(self: *Cpu) void {
        while(self.program_counter < self.program.items.len) {
            const instr = self.instruction.items[self.program.items[self.program_counter]];
            self.program_counter += 1;
            instr(self, self.program.items[self.program_counter]);
            self.program_counter += 1;

            if(self.jump_flag) {
                self.jump_flag = false;
                self.program_counter -= 1;
                continue;
            }

            // if(!std.mem.eql(u3, self.program.items[0..program_output.items.len], program_output.items)) {
            //     return;
            // }
        }
    }
};

fn part_1(comptime input_data: [] const u8) !u64 {
    var total : u64 = 0;
    total = 0;
    var data = comptime aoc.split_data(input_data);

    var register_a: u64 = 0;
    var register_b: u64 = 0;
    var register_c: u64 = 0;
    var program = std.ArrayList(u3).init(std.heap.page_allocator);

    while(data.next()) |line| {
        if(std.mem.eql(u8, line, "")) {
            continue;
        } else if(line[0] == 'R') {
            var line_it = std.mem.tokenizeScalar(u8, line, ' ');
            _ = line_it.next();
            const register = line_it.next().?;
            const val = line_it.next().?;
            if(register[0] == 'A') {
                std.debug.print("Register A: {s}\n", .{val});
                register_a = try std.fmt.parseInt(u64, val, 10);
            } else if(register[0] == 'B') {
                register_b = try std.fmt.parseInt(u64, val, 10);
            } else if(register[0] == 'C') {
                register_c = try std.fmt.parseInt(u64, val, 10);
            }
        } else {
            var line_it = std.mem.tokenizeScalar(u8, line, ' ');
            _ = line_it.next();
            var memory_it = std.mem.tokenizeScalar(u8, line_it.next().?, ',');
            while(memory_it.next()) |instr| {
                const memory = try std.fmt.parseInt(u3, instr, 10);
                try program.append(memory);
            }
        }
    }

    var cpu = Cpu{.register_a = register_a, .register_b = register_b, .register_c = register_c, .program = program};
    cpu.init();
    cpu.run();
        for(program_output.items) |instr| {
            std.debug.print("{},", .{instr});
        }
    return total;
}

var program_output: std.ArrayList(u3) = std.ArrayList(u3).init(std.heap.page_allocator);

fn contains_three(value: u64) bool {
    var v = value;
    while(v != 0) {
        if(v % 10 == 3) {
            return true;
        }
        v /= 10;
    }
    return false;
}

fn part_2(comptime input_data: []const u8) !u64 {
    var total : u64 = 0;
    total = 0;
    var data = comptime aoc.split_data(input_data);

    var register_a: u64 = 0;
    var register_b: u64 = 0;
    var register_c: u64 = 0;
    var program = std.ArrayList(u3).init(std.heap.page_allocator);

    while(data.next()) |line| {
        if(std.mem.eql(u8, line, "")) {
            continue;
        } else if(line[0] == 'R') {
            var line_it = std.mem.tokenizeScalar(u8, line, ' ');
            _ = line_it.next();
            const register = line_it.next().?;
            const val = line_it.next().?;
            if(register[0] == 'A') {
                std.debug.print("Register A: {s}\n", .{val});
                register_a = try std.fmt.parseInt(u64, val, 10);
            } else if(register[0] == 'B') {
                register_b = try std.fmt.parseInt(u64, val, 10);
            } else if(register[0] == 'C') {
                register_c = try std.fmt.parseInt(u64, val, 10);
            }
        } else {
            var line_it = std.mem.tokenizeScalar(u8, line, ' ');
            _ = line_it.next();
            var memory_it = std.mem.tokenizeScalar(u8, line_it.next().?, ',');
            while(memory_it.next()) |instr| {
                const memory = try std.fmt.parseInt(u3, instr, 10);
                try program.append(memory);
            }
        }
    }

    var cpu = Cpu{.register_a = 0, .register_b = register_b, .register_c = register_c, .program = program};
    cpu.init();

    var i:u64 = 500030000000;
    while(true) : (i += 1){

        if(!contains_three(i)) {
            continue;
        }

        program_output.clearAndFree();
        cpu.reset(i);
        cpu.run();

        std.debug.print("Iteration: {d}, ", .{i});
        // std.debug.print("Output:\n", .{});
        for(program_output.items) |instr| {
            std.debug.print("{},", .{instr});
        }
        std.debug.print("\r", .{});
        // std.debug.print("Program:\n", .{});
        // for(program.items) |instr| {
        //     std.debug.print("{},", .{instr});
        // }
        // std.debug.print("\n", .{});
        if(std.mem.eql(u3, program_output.items, program.items)) {
            return i;
        }
    }
    total = i;
    return total;
}
