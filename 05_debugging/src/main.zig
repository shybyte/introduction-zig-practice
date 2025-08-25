//! By convention, main.zig is where your main function lives in the case that
//! you are building an executable. If you are making a library, the convention
//! is to delete this file and start with root.zig instead.

pub fn main() !void {
    std.debug.print("All your {s} are belong to us.\n", .{"codebase"});
    std.log.debug("Run `zig build test` to run the tests\n", .{});

    const result = add(34, 16);
    std.log.debug("Result: {d}\n", .{result});

    const stderr = std.fs.File.stderr().deprecatedWriter();
    try stderr.print("Result: {d}\n", .{result});

    // 5.3 How to investigate the data type of your objects
    {
        const number: i32 = 5;
        try expect(@TypeOf(number) == i32);
        std.log.debug("{any}\n", .{@TypeOf(number)});
    }
}

fn add(x: u8, y: u8) u8 {
    return x + y;
}

test "simple test" {
    var list = std.ArrayList(i32).init(std.testing.allocator);
    defer list.deinit(); // Try commenting this out and see if zig detects the memory leak!
    try list.append(42);
    try std.testing.expectEqual(@as(i32, 42), list.pop());
}

const std = @import("std");
const expect = std.testing.expect;
