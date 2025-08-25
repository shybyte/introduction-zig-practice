const std = @import("std");
const OpenError = std.fs.File.OpenError;
const stdout = std.io.getStdOut().writer();

pub fn main() !void {
    std.log.debug("Hello", .{});

    const dir = std.fs.cwd();
    _ = dir.openFile("doesnt_exist.txt", .{}) catch |err| {
        std.log.debug("Error {}", .{err});
    };

    _ = try print_name();

    // 10.1.3 Casting error values
    const error_value = cast(B.OutOfMemory);
    const error_value2: A = B.OutOfMemory;
    try std.testing.expect(error_value == A.OutOfMemory);
    try std.testing.expect(error_value2 == B.OutOfMemory);

    try throwAorB(5);

    // 10.2.3 Using if statements
    if (print_name()) |result| {
        std.log.debug("Result {}", .{result});
    } else |err| {
        std.log.debug("Error {}", .{err});
    }

    _ = try checkValue(23);

    // Using switch to handle error cases
    if (checkRange(200)) |result| {
        std.log.debug("result {}", .{result});
    } else |err| switch (err) {
        error.TooLow => std.log.debug("Error: Value too low", .{}),
        RangeError.TooHigh => std.log.debug("Error: Value too high", .{}),

        // compile error: expected type 'error{TooLow,TooHigh}', found '@Type(.enum_literal)'
        // .TooLow => std.log.debug("Error: Value too low", .{}),
    }

    // 10.2.4 The errdefer keyword
    // fn create_user(db: Database, allocator: Allocator) !User {
    // const user = try allocator.create(User);
    // errdefer allocator.destroy(user);

    // // Register new user in the Database.
    // _ = try db.register_user(user);
    // return user;

    // 10.3 Union type in Zig
    {
        const shape = Shape{ .Circle = 5.0 }; // Circle with radius 5.0
        std.log.debug("shape {}", .{shape.Circle});

        // runtime error: access of union field 'Rectangle' while field 'Circle' is active
        // std.log.debug("shape1 {}", .{shape1.Rectangle});

        const shapeTagged = ShapeTagged{ .Circle = 5.0 }; // Circle with radius 5.0
        std.log.debug("shapeTagged {} has area {}", .{ shapeTagged.Circle, area(shapeTagged) });
        std.log.debug("shapeTagged type is {s}", .{@tagName(shapeTagged)});
    }
}

fn print_name() !i32 {
    std.log.debug("My name is Pedro!", .{});
    return 1;
}

// 10.1.2 Error sets

const RangeError = error{
    TooLow,
    TooHigh,
};

fn checkRange(n: i32) RangeError!i32 {
    if (n < 0) return RangeError.TooLow;
    if (n > 100) return RangeError.TooHigh;
    return n;
}

const SimpleError = error{
    SomethingWentWrong,
};

fn checkValue(n: i32) (RangeError || SimpleError)!i32 {
    const n2 = try checkRange(n);

    if (n2 == 42) {
        return SimpleError.SomethingWentWrong;
    }

    return n;
}

// 10.1.3 Casting error values
const A = error{
    ConnectionTimeoutError,
    DatabaseNotFound,
    OutOfMemory,
    InvalidToken,
};
const B = error{
    OutOfMemory,
};

fn cast(err: B) A {
    return err;
}

fn throwAorB(i: i32) A!void {
    if (i == 1) {
        return B.OutOfMemory;
    } else if (i == 2) {
        return A.InvalidToken;
    }
}

// 10.3 Union type in Zig
const Shape = union(enum) {
    Circle: f64, // radius
    Rectangle: struct {
        width: f64,
        height: f64,
    },
};

const ShapeTagged = union(enum) {
    Circle: f64, // radius
    Rectangle: struct {
        width: f64,
        height: f64,
    },
};

fn area(shape: ShapeTagged) f64 {
    return switch (shape) {
        .Circle => |radius| std.math.pi * radius * radius,
        .Rectangle => |rect| rect.width * rect.height,
    };
}

const expect = std.testing.expect;
test "testing simple sum" {
    const a: u8 = 2;
    const b: u8 = 2;
    try expect((a + b) == 4);
}
