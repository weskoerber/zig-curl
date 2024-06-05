pub fn main() !void {
    const allocator = std.heap.c_allocator;

    // Perform global init
    curl.Global.init();
    defer curl.Global.deinit();

    // Init the client
    const client = try curl.Client.init(.{});
    defer client.deinit();

    // Create a request
    var request = curl.Request{
        .method = .GET,
        .url = "127.0.0.1:8321",
        .body = "{\"hello\": \"world\"}",
    };
    defer request.deinit();

    // Add a custom header
    try request.addHeader(allocator, .{
        .name = "X-Custom-Header",
        .value = "header-value",
    });

    // Send a request
    const response = client.send(allocator, request) catch |err| {
        std.debug.print("{}: {s}\n", .{ err, curl.errors.getErrorMessage(err) });
        return;
    };
    defer response.deinit();

    // Print the response body
    std.debug.print("{s}\n", .{response.body});
}

const std = @import("std");
const curl = @import("curl");
