const std = @import("std");

const stdin = std.io.getStdIn().reader();
const stdout = std.io.getStdOut().writer();

pub fn main() !void {
    std.log.debug("Hello", .{});

    try stdout.writeAll("This message was written into stdout.\n");

    // try stdout.writeAll("Type your name!\n");
    // try echoInput();

    // 13.2.3 Using buffered IO in Zig
    {
        var file = try std.fs.cwd().openFile("src/main.zig", .{});
        defer file.close();
        var buffered = std.io.bufferedReader(file.reader());
        var bufreader = buffered.reader();

        var buffer: [1000]u8 = undefined;
        @memset(buffer[0..], 0);

        _ = try bufreader.readUntilDelimiterOrEof(buffer[0..], '\n');
        try stdout.print("{s}\n", .{buffer});
    }

    // 13.7.2 Creating new directories
    const cwd_root = std.fs.cwd();
    // try cwd_root.makeDir("output"); Will fail if folder exist already.
    try cwd_root.makePath("output");

    const output_dir = try cwd_root.openDir("output", .{});
    try output_dir.makePath("src/decoders/jpg/");
    try output_dir.deleteDir("src/decoders/jpg/");

    // 13.5.1 Creating files (and reading them back)
    {
        const file = try output_dir.createFile("output.txt", .{ .read = true });
        defer file.close();

        var fw = file.writer();
        _ = try fw.writeAll("We are going to read this line\n");

        var buffer: [300]u8 = undefined;
        @memset(buffer[0..], 0);
        try file.seekTo(0);
        var fr = file.reader();
        _ = try fr.readAll(buffer[0..]);
        try stdout.print("{s}\n", .{buffer});
    }

    // 13.5.2 Opening files and appending data to it
    {
        const file = try output_dir.openFile("output.txt", .{ .mode = .write_only });
        defer file.close();
        try file.seekFromEnd(0);
        var fw = file.writer();
        _ = try fw.writeAll("Some random text to write\n");
    }

    // 13.5.4 Copying files
    {
        try output_dir.copyFile("output.txt", output_dir, "output-copy.txt", .{});
        try output_dir.copyFile("output.txt", output_dir, "output-copy-2.txt", .{});

        // 13.5.3 Deleting files
        try output_dir.deleteFile("output-copy-2.txt");
    }

    // writeFile
    {
        try output_dir.writeFile(.{ .sub_path = "output-writeFile.txt", .data = "TestText\n" });
    }

    // 13.7.1 Iterating through the files in a directory
    {
        const cwd = std.fs.cwd();
        const dir = try cwd.openDir(".", .{ .iterate = true });
        var it = dir.iterate(); // walk for recursive
        while (try it.next()) |entry| {
            try stdout.print("File name: {s}\n", .{entry.name});
        }
    }
}

fn echoInput() !void {
    var buffer: [20]u8 = undefined;
    @memset(buffer[0..], 0);
    _ = try stdin.readUntilDelimiterOrEof(buffer[0..], '\n');
    try stdout.print("Your name is: {s}\n", .{buffer});
}

const expect = std.testing.expect;
test "testing simple sum" {
    const a: u8 = 2;
    const b: u8 = 2;
    try expect((a + b) == 4);
}
