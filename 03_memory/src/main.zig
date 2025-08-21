//! By convention, main.zig is where your main function lives in the case that
//! you are building an executable. If you are making a library, the convention
//! is to delete this file and start with root.zig instead.

pub fn main() !void {
    // Prints to stderr (it's a shortcut based on `std.io.getStdErr()`)
    std.debug.print("All your {s} are belong to us.\n", .{"codebase"});

    // stdout is for the actual output of your application, for example if you
    // are implementing gzip, then only the compressed bytes should be sent to
    // stdout, not any debugging messages.
    const stdout = std.io.getStdOut().writer();
    try stdout.print("Run `zig build test` to run the tests\n", .{});

    // 3.1.4 Stack
    {
        const r = add(5, 27);
        // Will fail it runtime: r.* = 1;
        _ = r;
    }

    // 3.2 Stack overflows
    {
        // Will fail
        // var very_big_alloc: [1000 * 1000 * 24]u64 = undefined;
        var very_big_alloc: [1000 * 24]u64 = undefined;
        @memset(very_big_alloc[0..], 0);
    }

    // 3.3 Allocators
    {
        var gpa = std.heap.GeneralPurposeAllocator(.{}){};
        const allocator = gpa.allocator();
        const name = "Pedro";
        const output = try std.fmt.allocPrint(allocator, "Hello {s}!!!", .{name});
        defer allocator.free(output);
        try stdout.print("{s}\n", .{output});
    }

    // 3.3.7 Arena allocator
    {
        var gpa = std.heap.GeneralPurposeAllocator(.{}){};
        var aa = std.heap.ArenaAllocator.init(gpa.allocator());
        defer aa.deinit();
        const allocator = aa.allocator();

        const in1 = try allocator.alloc(u8, 5);
        const in2 = try allocator.alloc(u8, 10);
        const in3 = try allocator.alloc(u8, 15);
        _ = in1;
        _ = in2;
        _ = in3;
    }

    // 3.3.9 The create() and destroy() methods
    {
        var gpa = std.heap.GeneralPurposeAllocator(.{}){};
        const allocator = gpa.allocator();
        const user = try allocator.create(User);
        defer allocator.destroy(user);

        user.* = User.init(0, "Pedro");
    }

    // 3.3.8 The alloc() and free() methods
    {
        const stdin = std.io.getStdIn();
        var gpa = std.heap.GeneralPurposeAllocator(.{}){};
        const allocator = gpa.allocator();
        var input = try allocator.alloc(u8, 50);
        defer allocator.free(input);
        for (0..input.len) |i| {
            input[i] = 0; // initialize all fields to zero.
        }
        // read user input
        const input_reader = stdin.reader();
        _ = try input_reader.readUntilDelimiterOrEof(input, '\n');
        std.debug.print("{s}\n", .{input});
    }
}

fn add(x: u8, y: u8) *const u8 {
    const result = x + y;
    return &result;
}

const User = struct {
    id: usize,
    name: []const u8,

    pub fn init(id: usize, name: []const u8) User {
        return .{ .id = id, .name = name };
    }
};

test "simple test" {
    var list = std.ArrayList(i32).init(std.testing.allocator);
    defer list.deinit(); // Try commenting this out and see if zig detects the memory leak!
    try list.append(42);
    try std.testing.expectEqual(@as(i32, 42), list.pop());
}

const std = @import("std");
const expect = std.testing.expect;
