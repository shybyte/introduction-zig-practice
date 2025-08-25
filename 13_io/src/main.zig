const std = @import("std");

const stdin = std.fs.File.stdin().deprecatedWriter();
const stdout = std.fs.File.stdin().deprecatedWriter();

pub fn main() !void {
    std.log.debug("Hello", .{});

    try stdout.writeAll("This message was written into stdout.\n");

    // try stdout.writeAll("Type your name!\n");
    // try echoInput();

    // 13.2.3 Using buffered IO in Zig
    {
        var file = try std.fs.cwd().openFile("src/main.zig", .{});
        defer file.close();

        var buffer: [1000]u8 = undefined;
        var buffered = file.reader(&buffer);

        var buffer2: [40]u8 = undefined;
        @memset(buffer2[0..], 0);

        _ = try buffered.interface.adaptToOldInterface().readUntilDelimiter(&buffer2, '\n');
        // _ = try buffered.read(buffer2[0..10]);
        // _ = try bufreader.readSliceAll('\n');
        std.log.debug("Read src/main.zig: {s}\n", .{buffer2});
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

        var fw = file.deprecatedWriter();
        _ = try fw.writeAll("We are going to read this line\n");

        var buffer: [300]u8 = undefined;
        @memset(buffer[0..], 0);
        try file.seekTo(0);
        var fr = file.deprecatedReader();
        _ = try fr.readAll(buffer[0..]);
        std.log.debug("{s}\n", .{buffer});
    }

    // 13.5.2 Opening files and appending data to it
    {
        const file = try output_dir.openFile("output.txt", .{ .mode = .write_only });
        defer file.close();
        try file.seekFromEnd(0);
        var fw = file.deprecatedWriter();
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
            std.log.debug("File name: {s}\n", .{entry.name});
        }
    }
}

fn echoInput() !void {
    var buffer: [20]u8 = undefined;
    @memset(buffer[0..], 0);
    _ = try stdin.readUntilDelimiterOrEof(buffer[0..], '\n');
    std.log.debug("Your name is: {s}\n", .{buffer});
}

const expect = std.testing.expect;
test "testing simple sum" {
    const a: u8 = 2;
    const b: u8 = 2;
    try expect((a + b) == 4);
}
