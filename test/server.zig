pub fn main() !void {
    const ip = "127.0.0.1";
    const port = 8321;
    log.debug("attempting to listen on {s}:{d}", .{ ip, port });
    const addr = try std.net.Address.resolveIp(ip, port);
    var tcp_server = try addr.listen(.{
        .reuse_address = true,
        .reuse_port = true,
    });
    defer tcp_server.deinit();
    log.debug("listening on {}", .{addr});

    var head_buffer: [4096]u8 = undefined;
    var log_buffer: [256]u8 = undefined;
    var stdout = std.io.getStdOut();
    while (true) {
        log.debug("waiting for new connection", .{});
        const connection = try tcp_server.accept();
        log.debug("connection accepted", .{});
        var server = std.http.Server.init(connection, &head_buffer);

        log.debug("reading head", .{});
        var request = try server.receiveHead();

        println(&log_buffer, "{s} {s} {s}", .{
            @tagName(request.head.method),
            request.head.target,
            @tagName(request.head.version),
        });

        var headers = request.iterateHeaders();
        while (headers.next()) |header| {
            println(&log_buffer, "{s}: {s}", .{
                header.name,
                header.value,
            });
        }

        println(&log_buffer, "", .{});

        log.debug("reading body", .{});

        var buffered_reader = std.io.bufferedReader(try request.reader());

        var fifo = std.fifo.LinearFifo(u8, .{ .Static = 256 }).init();
        try fifo.pump(buffered_reader.reader(), stdout.writer());

        println(&log_buffer, "\n", .{});

        log.debug("sending response", .{});
        try request.respond("{}", .{});
    }
}

fn println(buf: []u8, comptime fmt: []const u8, args: anytype) void {
    const str = std.fmt.bufPrint(buf, fmt ++ "\n", args) catch @panic("format error");
    _ = std.io.getStdOut().write(str) catch @panic("cannot write to stdout");
}

const std = @import("std");
const log = std.log.scoped(.server);
