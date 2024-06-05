method: std.http.Method,
url: [:0]const u8,
headers: ?std.StringArrayHashMap([]const u8) = null,
body: ?[]const u8 = null,

pub fn deinit(s: *Request) void {
    if (s.headers) |*headers| {
        headers.deinit();
        s.headers = null;
    }
}

pub fn addHeader(s: *Request, allocator: std.mem.Allocator, header: std.http.Header) !void {
    if (s.headers == null) s.headers = std.StringArrayHashMap([]const u8).init(allocator);

    try s.headers.?.put(header.name, header.value);
}

const std = @import("std");
const Request = @This();
