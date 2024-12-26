
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
    return 7;
}

pub fn part_2_expected() u32 {
    return 0;
}


fn part_1(comptime input_data: [] const u8) !u64 {
     var total : u64 = 0;
    total = 0;
    var data = comptime aoc.split_data(input_data);

    var pcs = std.HashMap([]const u8, PC, PCContext, 80).init(std.heap.page_allocator);

    while(data.next()) |line| {
        var line_it = std.mem.tokenizeScalar(u8, line, '-');
        const first_pc = line_it.next().?;
        const second_pc = line_it.next().?;

        if(pcs.contains(first_pc)) {
            try pcs.getPtr(first_pc).?.links.put(second_pc, {});
        } else {
            try pcs.put(first_pc, .{.name = first_pc});
            try pcs.getPtr(first_pc).?.links.put(second_pc, {});

        }

        if(pcs.contains(second_pc)) {
            try pcs.getPtr(second_pc).?.links.put(first_pc, {});
        } else {
            try pcs.put(second_pc, .{.name = second_pc});
            try pcs.getPtr(second_pc).?.links.put(first_pc, {});
        }
    }

    var trios = std.HashMap(Trio, void, TrioContext, 80).init(std.heap.page_allocator);

    var map_it = pcs.valueIterator();
    while(map_it.next()) |pc| {
        std.debug.print("PC: {s}, ", .{pc.name});
        var pc_it = pc.links.keyIterator();
        while(pc_it.next()) |link| {
            std.debug.print("{s} ", .{link.*});
        }
        std.debug.print("\n", .{});

        var link_it = pc.links.keyIterator();
        while(link_it.next()) |i| {
            var other_link_it = pc.links.keyIterator();
            _ = other_link_it.next();
            while(other_link_it.next()) |j| {
                if(pcs.get(i.*).?.links.contains(j.*) and pcs.get(j.*).?.links.contains(i.*)) {
                    std.debug.print("Found {s} {s} {s}\n", .{pc.name, i.*, j.*});
                    var trio: Trio = undefined;
                    trio.init(pc.name, i.*, j.*);
                    try  trios.put(trio, {});
                   // break :loop;
                }
            }
        }

    }

    var hash_it = trios.keyIterator();
    while(hash_it.next()) |trio| {
        std.debug.print("Trio: {s} {s} {s}\n", .{trio.first, trio.second, trio.third});
        //if(std.mem.containsAtLeast(u8, trio.first, 1, "t") 
        //or std.mem.containsAtLeast(u8, trio.second, 1, "t")
        //or std.mem.containsAtLeast(u8, trio.third, 1, "t")) {
        //    total += 1;
        //}
        if(trio.first[0] == 't' or trio.second[0] == 't' or trio.third[0] == 't') {
            total += 1;
        }
    }

    return total;
}

const PCContext = struct {
    pub fn hash(self: @This(), s: []const u8) u64 {
        _ = self;
        return std.hash.Wyhash.hash(0, s);
    }

    pub fn eql(self: @This(), a: []const u8, b: []const u8) bool {
        _ = self;
        return std.mem.eql(u8, a, b);
    }

};
const PC = struct {
    name: []const u8,
    links: std.StringHashMap(void) = std.StringHashMap(void).init(std.heap.page_allocator),
};

const TrioContext = struct {
    pub fn hash(self: @This(), s: Trio) u64 {
        _ = self;
        var hsh = std.hash.Wyhash.hash(0, s.first);
        hsh ^= std.hash.Wyhash.hash(0, s.second);
        hsh ^= std.hash.Wyhash.hash(0, s.third);

        return hsh;
    }

    pub fn eql(self: @This(), a: Trio, b: Trio) bool {
        _ = self;
        return std.mem.eql(u8, a.first, b.first) and std.mem.eql(u8, a.second, b.second) and std.mem.eql(u8, a.third, b.third);
    }
};

const Trio = struct {
    first: []const u8,
    second: []const u8,
    third: []const u8,

    fn lessThan(_: void, lhs: []const u8, rhs: []const u8) bool {
    return std.mem.order(u8, lhs, rhs) == .lt;
}
    fn init(self: *Trio, one: []const u8, two: []const u8, three: []const u8) void {
        var list: [3][]const u8 = .{one, two, three};
        std.mem.sort([]const u8, &list, {}, lessThan);
        
        self.first = list[0];
        self.second = list[1];
        self.third = list[2];

    }
};

fn part_2(comptime input_data: []const u8) !u64 {
    var total : u64 = 0;
    total = 0;  
    _ = input_data;
    return total;
}
