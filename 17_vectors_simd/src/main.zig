const std = @import("std");

pub fn main() !void {
    std.log.debug("Chapter 17 Vectors and SIMD", .{});

    // var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    // const allocator = gpa.allocator();

    // 17.2 Vectors
    {
        const v2 = @Vector(4, u32){ 10, 22, 5, 12 };
        const v1 = @Vector(4, u32){ 4, 12, 37, 9 };
        const v3 = v1 + v2;
        std.log.debug("{any}\n", .{v3});
    }

    // 17.2.1 Transforming arrays into vectors
    {
        const a1 = [4]u32{ 4, 12, 37, 9 };
        const v1: @Vector(4, u32) = a1;
        const v2: @Vector(2, u32) = a1[1..3].*;
        _ = v1;
        _ = v2;
    }

    // 17.2.2 The @splat() function
    {
        const v1: @Vector(10, u32) = @splat(16);
        std.log.debug("{any}\n", .{v1});
    }
}
