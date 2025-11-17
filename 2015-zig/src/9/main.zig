const std = @import("std");

const data = @embedFile("data.txt");

var places: std.StringHashMap(u32) = undefined;
var distances: std.StringHashMap(u32) = undefined;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    places = std.StringHashMap(u32).init(allocator);
    defer places.deinit();
    distances = std.StringHashMap(u32).init(allocator);
    defer distances.deinit();

    var count: u32 = std.math.maxInt(u32);
    _ = &count;
    var lines = std.mem.tokenizeScalar(u8, data, '\n');
    while (lines.next()) |l| {
        const line = std.mem.trimEnd(u8, l, "\r");
        var tokens = std.mem.tokenizeScalar(u8, line, ' ');
        const city1 = tokens.next().?;
        if (!places.contains(city1)) {
            try places.put(city1, places.count() + 1);
        }

        // to
        _ = tokens.next().?;

        const city2 = tokens.next().?;
        if (!places.contains(city2)) {
            try places.put(city2, places.count() + 1);
        }

        // =
        _ = tokens.next().?;

        const distance = try std.fmt.parseInt(u32, tokens.next().?, 10);

        const slice = try std.fmt.allocPrint(allocator, "{}{}", .{ places.get(city1).?, places.get(city2).? });
        const rev_slice = try std.fmt.allocPrint(allocator, "{}{}", .{ places.get(city2).?, places.get(city1).? });
        try distances.put(slice, distance);
        try distances.put(rev_slice, distance);
    }

    var routes = std.StringHashMap(void).init(allocator);
    inline for (1..9) |a| {
        inline for (1..9) |b| {
            if (b == a) continue;
            inline for (1..9) |c| {
                if (c == b or c == a) continue;
                inline for (1..9) |d| {
                    if (d == c or d == b or d == a) continue;
                    inline for (1..9) |e| {
                        if (e == d or e == c or e == b or e == a) continue;
                        inline for (1..9) |f| {
                            @setEvalBranchQuota(10000000);

                            if (f == e or f == d or f == c or f == b or f == a) continue;
                            inline for (1..9) |g| {
                                if (g == f or g == e or g == d or g == c or g == b or g == a) continue;
                                inline for (1..9) |h| {
                                    if (h == g or h == f or h == e or h == d or h == c or h == b or h == a) continue;

                                    var buf: [8]u8 = undefined;
                                    var rev_buf: [8]u8 = undefined;
                                    const slice = try std.fmt.bufPrint(&buf, "{}{}{}{}{}{}{}{}", .{ a, b, c, d, e, f, g, h });
                                    const rev_slice = try std.fmt.bufPrint(&rev_buf, "{}{}{}{}{}{}{}{}", .{ h, g, f, e, d, c, b, a });

                                    if (!routes.contains(rev_slice)) {
                                        try routes.put(slice, {});
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    var iter = routes.iterator();
    while (iter.next()) |route| {
        std.debug.print("New route: {s}\n", .{route.key_ptr.*});
        const dist = try walk(route.key_ptr.*);
        if (count > dist) {
            count = dist;
        }
    }

    std.debug.print("Count: {}\n", .{count});
}

fn walk(route: []const u8) !u32 {
    std.debug.print("Hop: {s}\n", .{route});

    if (route.len == 2) {
        return distances.get(route).?;
    }
    const hop = distances.get(route[0..2]).?;

    if (distances.get(route[1..])) |rest| {
        return hop + rest;
    }

    const new_walk = try walk(route[1..]);
    try distances.put(route[1..], new_walk);
    return hop + new_walk;
}
