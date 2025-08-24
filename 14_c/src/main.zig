const std = @import("std");
const stdout = std.io.getStdOut().writer();

const c = @cImport({
    @cDefine("_NO_CRT_STDIO_INLINE", "1");
    @cInclude("stdio.h");
    @cInclude("math.h");
});

const user_c = @cImport({
    @cInclude("user.h");
});

pub fn main() !void {
    std.log.debug("Hello", .{});

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    // 14.2.1 Strategy 1: using translate-c
    // zig translate-c /usr/include/stdio.h -lc -I/usr/include  -D_NO_CRT_STDIO_INLINE=1 > stdio.c.zig
    {
        const stdio_c = @import("stdio.c.zig");
        const x: f32 = 1772.94122;
        _ = stdio_c.printf("%.3f\n", x);
    }

    // 14.2.2 Strategy 2: using @cImport()
    {
        const x: f32 = 15.2;
        const y = c.powf(x, @as(f32, 2.6));
        _ = c.printf("%.3f\n", y);
    }

    // 14.3.1 The “auto-conversion” scenario
    {
        // const path: []const u8 = "build.zig";
        // This would cause:
        //      error: expected type '[*c]const u8', found '[]const u8'
        //      const file = c.fopen(path, "rb");

        const path = "build.zig";
        // const file = c.fopen("build.zig", "rb");
        const file = c.fopen(path, "rb");

        if (file == null) {
            @panic("Could not open file!");
        }

        if (c.fclose(file) != 0) {
            return error.CouldNotCloseFileDescriptor;
        }
    }

    // 14.3.2 The “need-conversion” scenario
    {
        const path: []const u8 = "build.zig";

        const file = c.fopen(path.ptr, "rb");

        // Alternative:
        // const c_path: [*c]const u8 = @ptrCast(path);
        // const file = c.fopen(c_path, "rb");

        if (file == null) {
            @panic("Could not open file!");
        }

        if (c.fclose(file) != 0) {
            return error.CouldNotCloseFileDescriptor;
        }
    }

    // 14.4 Creating C objects in Zig
    {
        var new_user: user_c.User = undefined;
        new_user.id = 1;
        var user_name = try allocator.alloc(u8, 12);
        defer allocator.free(user_name);
        @memcpy(user_name[0..(user_name.len - 1)], "pedropark99");
        user_name[user_name.len - 1] = 0;
        new_user.name = user_name.ptr;

        std.log.debug("new_user {}", .{new_user});

        // Using a helper
        const user_name2 = try toCString(allocator, "pedropark99");
        defer allocator.free(user_name2);
        new_user.name = user_name2.ptr;

        const new_user2: user_c.User = .{
            .id = 1,
            .name = "pedropark99", // already null-terminated
        };

        std.log.debug("new user 2 {}", .{new_user2});

        const new_user3: user_c.User = .{
            .id = 1,
            .name = "pedropark99", // already null-terminated
        };
        _ = new_user3;
    }

    // 14.5 Passing C structs across Zig functions
    {
        var user: user_c.User = .{
            .id = 1,
            .name = "pedropark99", // already null-terminated
        };

        set_user_id(1234, &user);
        print_user_id(user);
    }
}

fn toCString(allocator: std.mem.Allocator, s: []const u8) ![:0]u8 {
    // :0 means "null-terminated slice"
    var buf = try allocator.alloc(u8, s.len + 1);
    @memcpy(buf[0..s.len], s);
    buf[s.len] = 0;
    return buf[0..s.len :0]; // reinterpret as null-terminated slice
}

fn set_user_id(id: u64, user: *user_c.User) void {
    user.*.id = id;
    // Mistake in https://pedropark99.github.io/zig-book/Chapters/14-zig-c-interop.html#sec-pass-c-structs
    // Works but should no work according to the book
    user.id = id;
}

// Mistake in https://pedropark99.github.io/zig-book/Chapters/14-zig-c-interop.html#sec-pass-c-structs
// According to the book, explicitly using a pointer is needed.
fn print_user_id(user: user_c.User) void {
    std.log.debug("user id {}", .{user.id});
}

const expect = std.testing.expect;
test "testing simple sum" {
    const a: u8 = 2;
    const b: u8 = 2;
    try expect((a + b) == 4);
}
