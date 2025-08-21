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

    const result = add(34, 16);
    try stdout.print("Result: {d}\n", .{result});

    const stderr = std.io.getStdErr().writer();
    try stderr.print("Result: {d}\n", .{result});

    // 5.3 How to investigate the data type of your objects
    {
        const number: i32 = 5;
        try expect(@TypeOf(number) == i32);
        try stdout.print("{any}\n", .{@TypeOf(number)});
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
