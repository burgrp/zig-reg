const clap = @import("clap");
const std = @import("std");
const commands = @import("commands.zig");
const registry = @import("registry.zig");

pub fn main() !void {
    std.os.exit(try main_code());
}

fn main_code() !u8 {
    const params = comptime clap.parseParamsComptime(
        \\-h, --help             Display this help and exit.
        \\-d, --debug            Enable debug mode.
        \\-w, --watch            Stay in the loop and watch for changes while reading register value.
        \\<str>...
    );

    var diag = clap.Diagnostic{};
    var res = clap.parse(clap.Help, &params, clap.parsers.default, .{
        .diagnostic = &diag,
    }) catch |err| {
        diag.report(std.io.getStdErr().writer(), err) catch {};
        return 1;
    };
    defer res.deinit();

    if (res.args.help) {
        var writer = std.io.getStdOut().writer();
        try writer.print(
            \\Usage:
            \\  reg [options]                                  Reads all discovered registers.
            \\  reg [options] <register>                       Reads the value of the given register.
            \\  reg [options] <register> <value>               Writes the value to the given register.
            \\  reg [options] <register> <metadata> <value>    Creates a new register with the given metadata and value.
            \\  reg [options] <register> <metadata> -          Creates a new register with the given metadata, reads values from stdin.
            \\
            \\Value may be any JSON expression or 'null'.
            \\
            \\Options:
            \\
        , .{});

        try clap.help(writer, clap.Help, &params, .{});

        try writer.print(
            \\Environment:
            \\  MQTT    MQTT broker host and optional port, e.g. 'localhost:1883'.
            \\
        , .{});

        return 1;
    }

    var global_options = commands.GlobalOptions{
        .debug = res.args.debug,
        .registry = registry.Registry{
            .debug = res.args.debug,
        },
    };

    if (std.os.getenv("MQTT")) |mqtt| {
        try global_options.registry.open(mqtt);
    } else {
        std.debug.print("MQTT environment variable not set.\n", .{});
        return 1;
    }

    switch (res.positionals.len) {
        1 => {
            try commands.read_register(global_options, res.positionals[0], res.args.debug);
        },
        else => {
            std.debug.print("Invalid number of arguments\n", .{});
            return 1;
        },
    }

    return 0;
}
