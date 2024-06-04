status: Status,
body: []const u8,

allocator: std.mem.Allocator,

pub fn deinit(s: Response) void {
    s.allocator.free(s.body);
}

const std = @import("std");
const Response = @This();
const Status = std.http.Status;
