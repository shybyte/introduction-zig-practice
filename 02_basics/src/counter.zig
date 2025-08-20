const Self = @This();

value: usize,

pub fn init(initial_value: usize) Self {
    return .{ .value = initial_value };
}

pub fn count(self: *Self) void {
    self.value += 1;
}
