//! By convention, main.zig is where your main function lives in the case that
//! you are building an executable. If you are making a library, the convention
//! is to delete this file and start with root.zig instead.

pub fn main() !void {
    // Prints to stderr (it's a shortcut based on `std.io.getStdErr()`)
    std.debug.print("All your {s} are belong to us.\n", .{"codebase"});

    std.log.debug("Run `zig build test` to run the tests.\n", .{});

    // 1.4.2 Declaring without an initial value
    var age: u8 = undefined;
    age = 25; // 1.4.4 You must mutate every variable objects
    std.debug.print("Age: {}\n", .{age});

    // 1.4.3 There is no such thing as unused objects
    {
        const unused = 15;
        _ = unused;

        // 1.6 Arrays
        const ns = [4]u8{ 48, 24, 12, 6 };
        std.log.debug("Array element: {d}\n", .{ns[2]});

        const ls = [_]f64{ 432.1, 87.2, 900.05 };
        _ = ls;

        const slice = ns[1..3];
        std.log.debug("slice length: {d}\n", .{slice.len});

        const slice_util_end = ns[1..ns.len];
        _ = slice_util_end;
        const slice_util_end2 = ns[1..];
        _ = slice_util_end2;
    }

    // 1.6.3 Array operators
    {
        const a = [_]u8{ 1, 2, 3 };
        const b = [_]u8{ 4, 5 };
        const c = a ++ b;
        std.log.debug("{any}\n", .{c});
    }

    {
        const a = [_]u8{ 1, 2, 3 };
        const c = a ** 2;
        std.log.debug("{any}\n", .{c});
    }

    // 1.6.4 Runtime versus compile-time known length in slices
    {
        const arr1 = [10]u64{ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 };
        // This slice has a compile-time known range.
        // Because we know both the start and end of the range.
        const slice = arr1[1..4];
        _ = slice;
    }

    // 1.7 Blocks and scopes
    {
        var y: i32 = 123;
        const x = add_one: {
            y += 1;
            break :add_one y; // returns y from the block, needs label
        };
        if (x == 124 and y == 124) {
            std.log.debug("Hey!\n", .{});
        }
    }

    // 1.8 How strings work in Zig?
    {
        const string_object = "This is an example of string literal in Zig";
        std.log.debug("{d}\n", .{string_object.len});
        std.log.debug("{any}\n", .{@TypeOf("A literal value")});

        {
            std.log.debug("Bytes that represents the string object: ", .{});
            for (string_object) |byte| {
                std.log.debug("{X} ", .{byte});
            }
            std.log.debug("\n", .{});
        }

        const str: []const u8 = "A string value";
        std.log.debug("{any}\n", .{@TypeOf(str)});

        const bytes = [_]u8{ 0x48, 0x65, 0x6C, 0x6C, 0x6F };
        std.log.debug("{s}\n", .{bytes});
    }

    // 1.8.3 A better look at the object type
    {
        const simple_array = [_]i32{ 1, 2, 3, 4 };
        const string_obj: []const u8 = "A string object";
        std.debug.print("Type 1: {}\n", .{@TypeOf(simple_array)});
        std.debug.print("Type 2: {}\n", .{@TypeOf("A string literal")});
        std.debug.print("Type 3: {}\n", .{@TypeOf(&simple_array)});
        std.debug.print("Type 4: {}\n", .{@TypeOf(string_obj)});
    }

    // 1.8.4 Byte vs unicode points
    {
        const string_object = "Ⱥ";
        std.log.debug("Bytes that represents the string object: ", .{});
        for (string_object) |char| {
            std.log.debug("{X} ", .{char});
        }

        var utf8 = try std.unicode.Utf8View.init("アメリカ");
        var iterator = utf8.iterator();
        while (iterator.nextCodepointSlice()) |codepoint| {
            std.log.debug(
                "got codepoint {any}\n",
                .{codepoint},
            );
        }
    }

    // 1.8.5 Some useful functions for strings
    {
        const name: []const u8 = "Pedro";
        std.log.debug("{any}\n", .{std.mem.eql(u8, name, "Pedro")});
    }
}

test "simple test" {
    var list = std.ArrayList(i32).init(std.testing.allocator);
    defer list.deinit(); // Try commenting this out and see if zig detects the memory leak!
    try list.append(42);
    try std.testing.expectEqual(@as(i32, 42), list.pop());
}

test "use other module" {
    try std.testing.expectEqual(@as(i32, 150), lib.add(100, 50));
}

test "fuzz example" {
    const Context = struct {
        fn testOne(context: @This(), input: []const u8) anyerror!void {
            _ = context;
            // Try passing `--fuzz` to `zig build test` and see if it manages to fail this test case!
            try std.testing.expect(!std.mem.eql(u8, "canyoufindme", input));
        }
    };
    try std.testing.fuzz(Context{}, Context.testOne, .{});
}

const std = @import("std");

/// This imports the separate module containing `root.zig`. Take a look in `build.zig` for details.
const lib = @import("hello_world_lib");
