const std = @import("std");

pub fn main() !void {
    const addr = try std.net.Address.resolveIp("127.0.0.1", 8321);
    var tcp_server = try addr.listen(.{
        .reuse_address = true,
        .reuse_port = true,
    });
    defer tcp_server.deinit();

    var head_buffer: [4096]u8 = undefined;
    var log_buffer: [256]u8 = undefined;
    var stdout = std.io.getStdOut();
    while (true) {
        const connection = try tcp_server.accept();
        var server = std.http.Server.init(connection, &head_buffer);

        var request = try server.receiveHead();

        _ = try stdout.write(try std.fmt.bufPrint(&log_buffer, "{s} {s} {s}\n", .{ @tagName(request.head.method), request.head.target, @tagName(request.head.version) }));

        var buffered_reader = std.io.bufferedReader(try request.reader());

        var fifo = std.fifo.LinearFifo(u8, .Slice).init(&buffered_reader.buf);
        try fifo.pump(buffered_reader.reader(), stdout.writer());

        try request.respond("{}", .{});
    }
}
