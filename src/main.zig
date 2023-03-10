const clap = @import("clap");
const std = @import("std");

pub fn main() !void {
    // First we specify what parameters our program can take.
    // We can use `parseParamsComptime` to parse a string into an array of `Param(Help)`
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
        std.os.exit(1);
    };
    defer res.deinit();

    if (res.args.help) {
        var writer = std.io.getStdOut().writer();
        try writer.print(
            \\Usage:
            \\  reg [options]                                  Reads all discovered registers.
            \\  reg [options] <register>                       Reads the value of the given register.
            \\  reg [options] <register> <value>               Writes the value to the given register.
            \\  reg [options] <register> <value> <metadata>    Creates a new register with the given metadata and value.
            \\  reg [options] <register> - <metadata>          Creates a new register with the given metadata, reads values from stdin.
            \\
            \\Value may be any JSON expression or 'null'.
            \\
            \\Options:
            \\
        , .{});

        var result = clap.help(writer, clap.Help, &params, .{});

        try writer.print(
            \\Environment:
            \\  MQTT    MQTT broker host and optional port, e.g. 'localhost:1883'.
        , .{});

        return result;
    }

    // if (res.args.number) |n|
    //     debug.print("--number = {}\n", .{n});
    // for (res.args.string) |s|
    //     debug.print("--string = {s}\n", .{s});
    for (res.positionals) |pos|
        std.debug.print("{s}\n", .{pos});
}
