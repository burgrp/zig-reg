const std = @import("std");
const reqistry = @import("registry.zig");

pub const GlobalOptions = struct {
    debug: bool,
    registry: reqistry.Registry,
};

pub fn read_register(global_options: GlobalOptions, reg_name: []const u8, watch: bool) !void {
    if (global_options.debug and watch) {
        std.debug.print("watch mode is enabled\n", .{});
    }
    std.debug.print("register name: {s}\n", .{reg_name});
}
