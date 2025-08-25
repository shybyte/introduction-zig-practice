const std = @import("std");
const OpenError = std.fs.File.OpenError;
const stdout = std.io.getStdOut().writer();

pub fn main() !void {
    std.log.debug("Hello", .{});

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    // 12.1 Understanding comptime in Zig
    const random_number: u32 = @intCast(@rem(std.time.nanoTimestamp(), 100)); // Generates a random number between 0 and 99
    std.log.debug("Random number: {}\n", .{random_number});

    // 12.1.1 Applying over a function argument
    {
        const doubled = twice(5678);
        _ = doubled;

        // error: unable to resolve comptime value
        // _ = twice(random_number);
    }

    // 12.1.2 Applying over an expression
    {
        // test fibonacci at run-time
        try expect(fibonacci(7) == 13);
        // test fibonacci at compile-time
        try comptime expect(fibonacci(7) == 13);

        // error: unable to resolve comptime value
        // try comptime expect(fibonacci(random_number) == 13);
    }

    // 12.1.3 Applying over a block
    comptime {
        const n1 = 5;
        const n2 = 2;
        const n3 = n1 + n2;
        try expect(fibonacci(n3) == 13);

        // would fail at compile time
        // try expect(fibonacci(n3) == 14);
    }

    // 12.2 Introducing Generics
    {
        std.log.debug("Max {d}", .{max(u32, 1, 2)});
        std.log.debug("Max {d}", .{max(i32, -2, 2)});
    }

    // 12.4 Writing the stack data structure
    {
        const Stack = @import("stack.zig").Stack;

        var stack = try Stack(i8).init(allocator, 10);

        try stack.push(1);
        try stack.push(2);
        try stack.push(3);

        std.log.debug("Popped value: {?}", .{stack.pop()}); // Should log 3
        std.log.debug("Popped value: {?}", .{stack.pop()}); // Should log 2
        std.log.debug("Popped value: {?}", .{stack.pop()}); // Should log 1

        // Check if the stack is empty
        std.log.debug("Is stack empty? {}", .{stack.isEmpty()});
    }
}

// 12.1 Understanding comptime in Zig
// 12.1.1 Applying over a function argument

fn twice(comptime num: u32) u32 {
    return num * 2;
}

fn IntArray(comptime length: usize) type {
    return [length]i64;
}

// 12.1.2 Applying over an expression

fn fibonacci(index: u32) u32 {
    if (index < 2) return index;
    return fibonacci(index - 1) + fibonacci(index - 2);
}

// 12.2 Introducing Generics
fn max(comptime T: type, a: T, b: T) T {
    return if (a > b) a else b;
}

const expect = std.testing.expect;
test "testing simple sum" {
    const a: u8 = 2;
    const b: u8 = 2;
    try expect((a + b) == 4);
}
