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

    // 2.1.2 Switch statements
    {
        const Role = enum { SE, DPE, DE, DA, PM, PO, KS };
        var area: []const u8 = undefined;
        const role = Role.SE;
        switch (role) {
            .PM, .SE, .DPE, .PO => {
                area = "Platform";
            },
            .DE, .DA => {
                area = "Data & Analytics";
            },
            .KS => {
                area = "Sales";
            },
        }
        try stdout.print("{s}\n", .{area});

        // 2.1.2.2 The else branch and assignment
        {
            const level: u8 = 3;
            const category = switch (level) {
                1, 2 => "beginner",
                3 => "professional",
                else => {
                    @panic("Not supported level!");
                },
                // else => unreachable,
            };
            try stdout.print("{s}\n", .{category});
        }

        // 2.1.2.3 Using ranges in switch
        // It works with character ranges too: 'a'...'z'
        {
            const level: u8 = 3;
            const category = switch (level) {
                0...25 => "beginner",
                26...75 => "intermediary",
                76...100 => "professional",
                else => {
                    @panic("Not supported level!");
                },
            };
            try stdout.print("{s}\n", .{category});
        }

        // 2.1.2.4 Labeled switch statements
        {
            xsw: switch (@as(u8, 1)) {
                1 => {
                    try stdout.print("First branch\n", .{});
                    continue :xsw 2;
                },
                2 => continue :xsw 3,
                3 => break :xsw, // alternatively "return" to return from function
                4 => {},
                else => {
                    try stdout.print("Unmatched case, value: {d}\n", .{@as(u8, 1)});
                },
            }
        }
    }

    // 2.1.3 The defer keyword
    {
        defer std.debug.print("Exiting Scope ...\n", .{});
        std.log.debug("Doing Stuff", .{});
    }

    // 2.1.4 The errdefer keyword
    test_errdefer() catch {};

    // 2.1.5 For loops
    {
        const name = [_]u8{ 'P', 'e', 'd', 'r', 'o' };
        for (name) |char| {
            try stdout.print("{d} | ", .{char});
        }
        try stdout.print("\n", .{});

        for (name, 0..) |char, i| {
            try stdout.print("{d}:{d} | ", .{ char, i });
        }
        try stdout.print("\n", .{});
    }

    // 2.1.6 While loops
    {
        var i: u8 = 1;
        while (i < 5) {
            try stdout.print("{d} | ", .{i});
            i += 1;
        }
        std.log.debug("\ni at end of loop: {} \n", .{i});

        i = 1;
        while (i < 5) : (i += 1) {
            if (i > 3) {
                continue;
            }
            try stdout.print("{d} | ", .{i});
        }
        std.log.debug("\ni at end of loop: {}", .{i});
    }

    // 2.1.7 Using break and continue
    {
        var i: usize = 0;
        while (true) {
            if (i == 10) {
                break;
            }
            i += 1;
        }
        try std.testing.expect(i == 10);
        try stdout.print("Everything worked!\n", .{});

        const ns = [_]u8{ 1, 2, 3, 4, 5, 6 };
        for (ns) |j| {
            if ((j % 2) == 0) {
                continue;
            }
            try stdout.print("{d} | ", .{j});
        }
        try stdout.print("\n", .{});
    }

    // 2.2 Function parameters are immutable
    {
        const y = add2(4);
        std.debug.print("{d}\n", .{y});

        var x: u32 = 4;
        add2Pointer(&x);
        std.debug.print("Result: {d}\n", .{x});
    }

    // 2.3 Structs and OOP
    {
        const u = user.User.init(1, "pedro", "email@gmail.com");
        u.print_name();
        //  error: 'print_name_private' is not marked 'pub'
        // u.print_name_private();
    }

    // 2.3.1 The pub keyword
    {
        user.testUser();
    }

    // 2.3.2 Anonymous struct literals
    {
        const eu = user.User{ .id = 1, .name = "Nora", .email = "someemail@gmail.com" };
        _ = eu;
        const eu_anom: user.User = .{ .id = 1, .name = "Anonymous", .email = "someemail@gmail.com" };
        _ = eu_anom;
    }

    // 2.3.3 Struct declarations must be constant
    {
        const Vec3 = struct {
            x: f64,
            y: f64,
            z: f64,
        };

        const vec: Vec3 = .{ .x = 1, .y = 2, .z = 3 };
        _ = vec;
    }

    // 2.3.5 About the struct state
    {
        // const would not work (expected type '*user.User', found '*const user.User')
        var mut_user = user.User{ .id = 1, .name = "Old Name", .email = "someemail@gmail.com" };
        mut_user.changeName("New Name");
        std.log.debug("Changed User: {s}", .{mut_user.name});
    }

    // 2.5 Type casting
    {
        const x: usize = 500;
        const y = @as(u32, x);
        try expect(@TypeOf(y) == u32);

        const y_float: f32 = @floatFromInt(x);
        try expect(@TypeOf(y_float) == f32);

        const bytes align(@alignOf(u32)) = [_]u8{ 0x12, 0x12, 0x12, 0x12 };
        const u32_ptr: *const u32 = @ptrCast(&bytes);
        try expect(@TypeOf(u32_ptr) == *const u32);
    }

    // 2.6 Modules
    {
        // Module can be used/written like a struct.

        // https://github.com/kprotty/zap/blob/blog/src/thread_pool.zig
        // const ThreadPool = @import("thread_pool.zig");
        // const num_cpus = std.Thread.getCpuCount() catch @panic("failed to get cpu core count");
        // const num_threads = std.math.cast(u16, num_cpus) catch std.math.maxInt(u16);
        // const pool = ThreadPool.init(.{ .max_threads = num_threads });
        // defer pool.deinit();

        const Counter = @import("counter.zig");
        var counter = Counter.init(3);
        counter.count();
        std.log.debug("counter: {}", .{counter.value});
    }
}

fn return_error() !void {
    return error.FooError;
}

fn test_errdefer() !void {
    var i: usize = 1;
    errdefer std.log.err("Value of i: {d}\n", .{i});
    defer i = 2;
    try return_error();
}

// 2.2 Function parameters are immutable
// In case of structs, arrays, the compiler might use a reference as optimization.
fn add2(x: u32) u32 {
    // compile error: cannot assign to constant
    // x = x + 2;
    return x + 2;
}

fn add2Pointer(x: *u32) void {
    const d: u32 = 2;
    x.* = x.* + d;
}

test "simple test" {
    var list = std.ArrayList(i32).init(std.testing.allocator);
    defer list.deinit(); // Try commenting this out and see if zig detects the memory leak!
    try list.append(42);
    try std.testing.expectEqual(@as(i32, 42), list.pop());
}

const std = @import("std");
const expect = std.testing.expect;
const user = @import("user.zig");
