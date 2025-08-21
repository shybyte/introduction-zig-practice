const std = @import("std");
const stdout = std.io.getStdOut().writer();

pub fn main() !void {
    std.log.debug("Hello", .{});
}

const expect = std.testing.expect;
test "testing simple sum" {
    const a: u8 = 2;
    const b: u8 = 2;
    try expect((a + b) == 4);
}

const Allocator = std.mem.Allocator;

fn some_memory_leak(allocator: Allocator) !void {
    const buffer = try allocator.alloc(u32, 10);
    _ = buffer;
    // Return without freeing the
    // allocated memory
}

fn without_memory_leak(allocator: Allocator) !void {
    const buffer = try allocator.alloc(u32, 10);
    defer allocator.free(buffer);
}

test "memory leak" {
    const allocator = std.testing.allocator;

    // Fails at runtime with "memory address 0x7a0fd0900000 leaked:"
    // try some_memory_leak(allocator);

    try without_memory_leak(allocator);
}

const expectError = std.testing.expectError;

fn alloc_error(allocator: Allocator) !void {
    var ibuffer = try allocator.alloc(u8, 100);
    defer allocator.free(ibuffer);
    ibuffer[0] = 2;
}

test "testing error" {
    var buffer: [10]u8 = undefined;
    var fba = std.heap.FixedBufferAllocator.init(&buffer);
    const allocator = fba.allocator();
    try expectError(error.OutOfMemory, alloc_error(allocator));
}

test "values are equal?" {
    const v1 = 15;
    const v2 = 15;
    try std.testing.expectEqual(v1, v2);
}

test "arrays are equal?" {
    const array1 = [3]u32{ 1, 2, 3 };
    const array2 = [3]u32{ 1, 2, 3 };
    try std.testing.expectEqualSlices(u32, &array1, &array2);
}

test "strings are equal?" {
    const str1 = "Hello, world!";
    const str2 = "Hello, world!";
    try std.testing.expectEqualStrings(str1, str2);
}
