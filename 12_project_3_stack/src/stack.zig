const std = @import("std");
const Allocator = std.mem.Allocator;

pub fn Stack(comptime T: type) type {
    return struct {
        items: []T,
        capacity: usize,
        length: usize,
        allocator: Allocator,
        const Self = @This();

        pub fn init(allocator: Allocator, capacity: usize) !Stack(T) {
            var buf = try allocator.alloc(T, capacity);
            return .{
                .items = buf[0..],
                .capacity = capacity,
                .length = 0,
                .allocator = allocator,
            };
        }

        pub fn push(self: *Self, val: T) !void {
            if ((self.length + 1) > self.capacity) {
                var new_buf = try self.allocator.alloc(T, self.capacity * 2);
                @memcpy(new_buf[0..self.capacity], self.items);
                self.allocator.free(self.items);
                self.items = new_buf;
                self.capacity = self.capacity * 2;
            }

            self.items[self.length] = val;
            self.length += 1;
        }

        pub fn pop(self: *Self) ?T {
            if (self.length == 0) return null;

            self.length -= 1;
            const value = self.items[self.length];
            self.items[self.length] = undefined;
            return value;
        }

        pub fn isEmpty(self: *Self) bool {
            return self.length == 0;
        }

        pub fn deinit(self: *Self) void {
            self.allocator.free(self.items);
        }
    };
}
