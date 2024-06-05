pub fn main() !void {
    const allocator = std.heap.c_allocator;

    // Perform global init
    curl.Global.init();
    defer curl.Global.deinit();

    // Init the client
    const client = try curl.Client.init(.{});
    defer client.deinit();

    // Send a request
    const response = client.send(allocator, .{
        .method = .GET,
        .url = "127.0.0.1:8321",
    }) catch |err| {
        std.debug.print("{}: {s}\n", .{ err, curl.errors.getErrorMessage(err) });
        return;
    };
    defer response.deinit();

    // Print the response body
    std.debug.print("{s}\n", .{response.body});
}

const std = @import("std");
const curl = @import("curl");
