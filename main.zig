const std = @import("std");
const word_list = @import("word_list.zig");

const help_text =
    \\Usage: word-gen [OPTIONS]
    \\
    \\Options:
    \\  -l, --length <LENGTH>        How many words to generate [default: 3]
    \\  -d, --delimiter <DELIMITER>  Delimiter to use for joining words
    \\  -c, --capitalize            Capitalize words
    \\  -h, --help                  Print help
    \\
;

const Error = error{
    InvalidArgument,
    OutOfRange,
    Overflow, // Added for parseInt
    InvalidCharacter, // Added for parseInt
};

const Config = struct {
    length: usize = 3,
    delimiter: []const u8 = " ",
    capitalize: bool = false,
    show_help: bool = false,
};

fn parseArgs(iterator: *std.process.ArgIterator) Error!Config {
    var config = Config{};

    while (iterator.next()) |arg| {
        if (std.mem.eql(u8, arg, "-h") or std.mem.eql(u8, arg, "--help")) {
            config.show_help = true;
            return config;
        } else if (std.mem.eql(u8, arg, "-l") or std.mem.eql(u8, arg, "--length")) {
            const len_str = iterator.next() orelse {
                std.debug.print("Error: Missing value for length\n", .{});
                return Error.InvalidArgument;
            };
            config.length = try std.fmt.parseInt(usize, len_str, 10);
        } else if (std.mem.startsWith(u8, arg, "-d")) {
            config.delimiter = if (arg.len > 2)
                arg[2..] // Handle -d'x' case
            else
                iterator.next() orelse { // Handle -d 'x' case
                    std.debug.print("Error: Missing value for delimiter\n", .{});
                    return Error.InvalidArgument;
                };
        } else if (std.mem.startsWith(u8, arg, "--delimiter=")) {
            config.delimiter = arg[11..];
        } else if (std.mem.eql(u8, arg, "--delimiter")) {
            config.delimiter = iterator.next() orelse {
                std.debug.print("Error: Missing value for delimiter\n", .{});
                return Error.InvalidArgument;
            };
        } else if (std.mem.eql(u8, arg, "-c") or std.mem.eql(u8, arg, "--capitalize")) {
            config.capitalize = true;
        }
    }

    return config;
}

pub fn main() !void {
    var arg_iterator = std.process.args();
    _ = arg_iterator.skip(); // Skip executable name

    const config = try parseArgs(&arg_iterator);

    if (config.show_help) {
        try std.io.getStdOut().writer().print("{s}", .{help_text});
        return;
    }

    const word_count = word_list.WORD_LIST.len;
    if (word_count == 0) {
        std.debug.print("Error: Word list is empty\n", .{});
        return Error.InvalidArgument;
    }

    var stdout = std.io.getStdOut().writer();
    var i: usize = 0;
    while (i < config.length) : (i += 1) {
        const idx = std.crypto.random.intRangeAtMost(usize, 0, word_count - 1);
        var word = word_list.WORD_LIST[idx];

        if (config.capitalize) {
            var buffer: [128]u8 = undefined;
            if (word.len > buffer.len) {
                return Error.OutOfRange;
            }
            @memcpy(buffer[0..word.len], word);
            if (word.len > 0) {
                buffer[0] = std.ascii.toUpper(buffer[0]);
            }
            word = buffer[0..word.len];
        }

        try stdout.print("{s}", .{word});
        if (i < config.length - 1) {
            try stdout.print("{s}", .{config.delimiter});
        }
    }
    try stdout.print("\n", .{});
}

