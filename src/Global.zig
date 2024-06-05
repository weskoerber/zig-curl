pub fn init() void {
    _ = c.curl_global_init(c.CURL_GLOBAL_ALL);
}

pub fn deinit() void {
    c.curl_global_cleanup();
}

const c = @import("cimport.zig").c;
