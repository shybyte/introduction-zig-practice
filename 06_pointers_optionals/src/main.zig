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

    {
        const number: u8 = 5;
        const pointer: *const u8 = &number;

        // error: cannot assign to constant
        // pointer.* = 6;
        _ = pointer;
    }

    {
        var number: u8 = 5;
        const pointer: *u8 = &number;
        const doubled = 2 * pointer.*;
        std.debug.print("{d}\n", .{number});
        std.debug.print("{d}\n", .{doubled});
        pointer.* = 2;
        std.debug.print("{d}\n", .{number});
    }

    {
        const u = User.init(1, "pedro", "email@gmail.com");
        const pointer = &u;
        pointer.*.print_name();
        pointer.print_name();
    }

    {
        const c1: u8 = 5;
        const c2: u8 = 6;
        var pointer = &c1;
        try stdout.print("{d}\n", .{pointer.*});
        pointer = &c2;
        try stdout.print("{d}\n", .{pointer.*});
    }

    // 6.3 Pointer arithmetic
    {
        const ar = [_]i32{ 1, 2, 3, 4 };
        var ptr: [*]const i32 = &ar;
        try stdout.print("{d}\n", .{ptr[0]});
        ptr += 1;
        try stdout.print("{d}\n", .{ptr[0]});
        ptr += 1;
        try stdout.print("{d}\n", .{ptr[0]});

        const sl = ar[0..ar.len];
        _ = sl;
    }

    // 6.4 Optionals and Optional Pointers
    {
        var number: u8 = 5;
        // compile error: expected type 'u8', found '@TypeOf(null)'
        //  number = null;
        number = 4;

        var num: ?i32 = 5;
        num = null;
    }

    // 6.4.2 Optional pointers
    {
        var num: i32 = 5;
        var ptr: ?*i32 = &num;
        ptr = null;
        num = 6;

        var num_optional: ?i32 = 5;
        // ptr_to_optional have type `*?i32`, instead of `?*i32`.
        const ptr_to_optional: *?i32 = &num_optional;
        _ = ptr_to_optional;
    }

    // 6.4.3 Null handling in optionals
    {
        const num: ?i32 = 5;
        if (num) |not_null_num| {
            try stdout.print("Optional has a value: {d}\n", .{not_null_num});
        }

        const x: ?i32 = null;
        const dbl = (x orelse 15) * 2;
        try stdout.print("{d}\n", .{dbl});

        std.log.debug("{}\n", .{unwrap(23)});

        // panic: attempt to use null value
        // std.log.debug("{}\n", .{unwrap(null)});
    }
}

fn unwrap(x: ?i32) i32 {
    return x.?;
}

const std = @import("std");
const User = @import("user.zig").User;
