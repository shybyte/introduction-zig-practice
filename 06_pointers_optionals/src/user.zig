const std = @import("std");

pub const User = struct {
    id: u64,
    name: []const u8,
    email: []const u8,

    pub fn init(id: u64, name: []const u8, email: []const u8) User {
        return User{ .id = id, .name = name, .email = email };
    }

    pub fn print_name(self: User) void {
        // error: cannot assign to constant
        // self.name = "New";

        self.print_name_private();
    }

    fn print_name_private(self: User) void {
        std.log.debug("User name: {s}\n", .{self.name});
    }

    pub fn changeName(self: *User, name: []const u8) void {
        self.name = name;
    }
};

pub fn testUser() void {
    const u = User.init(1, "Marco", "email@gmail.com");
    u.print_name();
}
