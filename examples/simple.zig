pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer if (gpa.deinit() != .ok) @panic("memory leak");
    const allocator = gpa.allocator();

    curl.Global.init();
    defer curl.Global.deinit();

    const client = try curl.Client.init(.{});
    defer client.deinit();

    const response = client.send(allocator, .{
        .method = .GET,
        .url = "127.0.0.1:8321",
    }) catch |err| {
        std.debug.print("{}: {s}\n", .{ err, curl.errors.getErrorMessage(err) });
        return;
    };
    defer response.deinit();

    std.debug.print("{s}\n", .{response.body});
}

const std = @import("std");
const curl = @import("curl");
