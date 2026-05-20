const std = @import("std");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const alloc = gpa.allocator();

    const args = try std.process.argsAlloc(alloc);
    defer std.process.argsFree(alloc, args);

    if (args.len < 2 or std.mem.eql(u8, args[1], "-h") or std.mem.eql(u8, args[1], "--help")) {
        std.debug.print("Usage: byte-count <file>\n  Count bytes, lines, and printable chars.\n", .{});
        return;
    }

    const path = args[1];
    const file = std.fs.cwd().openFile(path, .{}) catch |err| {
        std.debug.print("Error: cannot open '{s}': {}\n", .{ path, err });
        std.process.exit(1);
    };
    defer file.close();

    const data = file.readToEndAlloc(alloc, 100 * 1024 * 1024) catch |err| {
        std.debug.print("Error reading file: {}\n", .{err});
        std.process.exit(1);
    };

    var lines: usize = 0;
    var printable: usize = 0;
    for (data) |b| {
        if (b == '\n') lines += 1;
        if (b >= 32 and b < 127) printable += 1;
    }

    std.debug.print("Bytes:     {d}\n", .{data.len});
    std.debug.print("Lines:     {d}\n", .{lines});
    std.debug.print("Printable: {d}\n", .{printable});
}
