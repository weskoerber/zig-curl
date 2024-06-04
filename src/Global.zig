pub fn init() void {
    _ = c.curl_global_init(c.CURL_GLOBAL_ALL);
}

pub fn deinit() void {
    c.curl_global_cleanup();
}

const util = @import("util.zig");
const c = util.c;
