handle: *c.CURL,
options: ClientOptions,

pub const ClientOptions = struct {
    follow_redirects: bool = true,
    timeout_ms: usize = 10_000,
};

pub fn init(options: ClientOptions) CurlError!Client {
    const client = Client{
        .handle = c.curl_easy_init() orelse return CurlError.FailedInit,
        .options = options,
    };

    try client.setOpt(.{ .writefunction = writeFunction });
    try client.setOpt(.{ .follow_location = options.follow_redirects });
    try client.setOpt(.{ .timeout_ms = options.timeout_ms });

    return client;
}

pub fn deinit(s: Client) void {
    c.curl_easy_cleanup(s.handle);
}

pub fn send(s: Client, allocator: std.mem.Allocator, r: Request) CurlError!Response {
    var buf = std.ArrayList(u8).init(allocator);

    try s.setOpt(.{ .url = r.url });
    try s.setOpt(.{ .writedata = &buf });

    if (r.body) |body| {
        try s.setOpt(.{ .postfields = body });
    }

    try checkError(c.curl_easy_perform(s.handle));

    var response_code: c_long = 0;
    try checkError(c.curl_easy_getinfo(s.handle, c.CURLINFO_RESPONSE_CODE, &response_code));

    return .{
        .status = @enumFromInt(response_code),
        .body = try buf.toOwnedSlice(),
        .allocator = allocator,
    };
}

pub fn setOpt(s: Client, o: CurlOpt) CurlError!void {
    try checkError(switch (o) {
        .follow_location => |x| c.curl_easy_setopt(s.handle, c.CURLOPT_FOLLOWLOCATION, &x),
        .postfields => |x| c.curl_easy_setopt(s.handle, c.CURLOPT_POSTFIELDS, x.ptr),
        .timeout_ms => |x| c.curl_easy_setopt(s.handle, c.CURLOPT_TIMEOUT_MS, x),
        .url => |x| c.curl_easy_setopt(s.handle, c.CURLOPT_URL, x.ptr),
        .useragent => |x| c.curl_easy_setopt(s.handle, c.CURLOPT_USERAGENT, x.ptr),
        .writedata => |x| c.curl_easy_setopt(s.handle, c.CURLOPT_WRITEDATA, x),
        .writefunction => |x| c.curl_easy_setopt(s.handle, c.CURLOPT_WRITEFUNCTION, x),
        else => @panic("TODO"),
    });
}

pub fn writeFunction(ptr: [*]u8, size: usize, nmemb: usize, userdata: *anyopaque) callconv(.C) usize {
    var buf: *std.ArrayList(u8) = @alignCast(@ptrCast(userdata));

    buf.appendSlice(ptr[0..nmemb]) catch return 0;

    return size * nmemb;
}

const std = @import("std");
const log = std.log.scoped(.client);

const util = @import("util.zig");
const c = util.c;
const errors = @import("errors.zig");
const checkError = errors.checkError;
const Client = @This();
const CurlError = errors.CurlError;
const Request = @import("Request.zig");
const Response = @import("Response.zig");

const CurlOpt = union(enum) {
    follow_location: bool,
    postfields: []const u8,
    readdata: []const u8,
    readfunction: *const fn ([*]u8, usize, usize, *anyopaque) callconv(.C) usize,
    timeout_ms: usize,
    url: [:0]const u8,
    useragent: [:0]const u8,
    writedata: *std.ArrayList(u8),
    writefunction: *const fn ([*]u8, usize, usize, *anyopaque) callconv(.C) usize,
};
