const std = @import("std");
const OpenError = std.fs.File.OpenError;
const stdout = std.io.getStdOut().writer();

pub fn main() !void {
    std.log.debug("Hello", .{});

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    // 11.1 Dynamic Arrays
    {
        var buffer = try std.ArrayList(u8)
            .initCapacity(allocator, 100);
        defer buffer.deinit(allocator);

        try buffer.append(allocator, 'H');
        try buffer.append(allocator, 'e');
        try buffer.append(allocator, 'l');
        try buffer.append(allocator, 'l');
        try buffer.append(allocator, 'o');
        try buffer.appendSlice(allocator, " World!");

        std.log.debug("arrayList: {s}", .{buffer.items});

        const removed = buffer.orderedRemove(1);
        std.log.debug("removed '{c}' arrayList: {s}", .{ removed, buffer.items });

        const removed2 = buffer.swapRemove(1); // Faster!
        std.log.debug("removed '{c}' arrayList: {s}", .{ removed2, buffer.items });

        try buffer.appendSlice(allocator, " Next");
        try buffer.insert(allocator, 4, '?');
        try buffer.insertSlice(allocator, 2, " insertedSlice ");
        std.log.debug("arrayList: {s}", .{buffer.items});
    }

    // 11.2 Maps or HashTables

    {
        {
            const AutoHashMap = std.hash_map.AutoHashMap;
            var hash_table = AutoHashMap(u32, u16).init(allocator);
            defer hash_table.deinit();

            try hash_table.put(54321, 89);
            try hash_table.put(50050, 55);
            try hash_table.put(57709, 41);
            std.debug.print("N of values stored: {d}\n", .{hash_table.count()});
            std.debug.print("Value at key 50050: {d}\n", .{hash_table.get(50050).?});

            if (hash_table.remove(57709)) {
                std.debug.print("Value at key 57709 successfully removed!\n", .{});
            }
            std.debug.print("N of values stored: {d}\n", .{hash_table.count()});

            // 11.2.3 Iterating through the hashtable
            var it = hash_table.iterator();
            while (it.next()) |kv| {
                // Access the current key
                std.debug.print("Key: {d} | ", .{kv.key_ptr.*});
                // Access the current value
                std.debug.print("Value: {d}\n", .{kv.value_ptr.*});
            }

            var kit = hash_table.keyIterator();
            while (kit.next()) |key| {
                std.debug.print("Key: {d}\n", .{key.*});
            }

            var vit = hash_table.valueIterator();
            while (vit.next()) |value| {
                std.debug.print("Value: {d}\n", .{value.*});
            }
        }

        // 11.2.4 The ArrayHashMap hashtable => keeps insertion order

        // 11.2.5 The StringHashMap hashtable
        {
            var ages = std.StringHashMap(u8).init(allocator);
            defer ages.deinit();

            try ages.put("Pedro", 25);
            try ages.put("Matheus", 21);
            try ages.put("Abgail", 42);

            var it = ages.iterator();
            while (it.next()) |kv| {
                std.debug.print("Key: {s} | ", .{kv.key_ptr.*});
                std.debug.print("Age: {d}\n", .{kv.value_ptr.*});
            }
        }

        // 1.2.6 The StringArrayHashMap hashtable => keeps insertion order
    }

    // 11.3 Linked lists
    // Provided code does not work with Zig 0.14

    // 11.4 Multi array structure ("structs of arrays!)
    {
        const Person = struct {
            name: []const u8,
            age: u8,
            height: f32,
        };
        const PersonArray = std.MultiArrayList(Person);

        var people = PersonArray{};
        defer people.deinit(allocator);

        try people.append(allocator, .{ .name = "Auguste", .age = 15, .height = 1.54 });
        try people.append(allocator, .{ .name = "Elena", .age = 26, .height = 1.65 });
        try people.append(allocator, .{ .name = "Michael", .age = 64, .height = 1.87 });

        for (people.items(.name), people.items(.age)) |*name, *age| {
            std.log.debug("{s} has age: {d}\n", .{ name.*, age.* });
        }

        var slice = people.slice();
        for (slice.items(.age)) |*age| {
            age.* += 10;
        }
        for (slice.items(.name), slice.items(.age)) |*n, *a| {
            std.log.debug("Name: {s}, Age: {d}\n", .{ n.*, a.* });
        }
    }
}

const expect = std.testing.expect;
test "testing simple sum" {
    const a: u8 = 2;
    const b: u8 = 2;
    try expect((a + b) == 4);
}
