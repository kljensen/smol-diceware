const std = @import("std");
const word_list = @import("word_list.zig");

const help_text =
    \\Usage: word-gen [OPTIONS]
    \\
    \\Options:
    \\  -l, --length <LENGTH>        How many words to generate [default: 3]
    \\      --length=<LENGTH>       Alternate form for specifying length
    \\  -d, --delimiter <DELIMITER> Delimiter to use for joining words
    \\      --delimiter=<DELIMITER> Alternate form for specifying delimiter
    \\  -c, --capitalize            Capitalize words
    \\  -h, --help                  Print help
    \\
;

const Error = error{
    InvalidArgument,
    OutOfRange,
    Overflow,         // For parseInt errors
    InvalidCharacter, // For parseInt errors
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
        // --help / -h
        if (std.mem.eql(u8, arg, "-h") or std.mem.eql(u8, arg, "--help")) {
            config.show_help = true;
            return config;
        }

        // --length=<num>
        else if (std.mem.startsWith(u8, arg, "--length=")) {
            const len_str = arg[9..]; // everything after `--length=`
            const parse_result = std.fmt.parseInt(usize, len_str, 10) catch {
                std.debug.print("Error: '{s}' is not a valid integer for --length\n", .{len_str});
                return Error.InvalidArgument;
            };
            config.length = parse_result;
        }

        // --length (next token)
        else if (std.mem.eql(u8, arg, "--length") or std.mem.eql(u8, arg, "-l")) {
            const len_str = iterator.next() orelse {
                std.debug.print("Error: Missing value for length\n", .{});
                return Error.InvalidArgument;
            };
            const parse_result = std.fmt.parseInt(usize, len_str, 10) catch {
                std.debug.print("Error: '{s}' is not a valid integer for length\n", .{len_str});
                return Error.InvalidArgument;
            };
            config.length = parse_result;
        }

        // --delimiter=<delim>
        else if (std.mem.startsWith(u8, arg, "--delimiter=")) {
            config.delimiter = arg[11..]; // everything after `--delimiter=`
        }

        // --delimiter (next token)
        else if (std.mem.eql(u8, arg, "--delimiter")) {
            const delim_str = iterator.next() orelse {
                std.debug.print("Error: Missing value for delimiter\n", .{});
                return Error.InvalidArgument;
            };
            config.delimiter = delim_str;
        }

        // -d (next token), e.g. `-d ,`
        else if (std.mem.eql(u8, arg, "-d")) {
            const delim_str = iterator.next() orelse {
                std.debug.print("Error: Missing value for delimiter\n", .{});
                return Error.InvalidArgument;
            };
            config.delimiter = delim_str;
        }

        // -dXYZ (no space after)
        else if (std.mem.startsWith(u8, arg, "-d") and arg.len > 2) {
            // e.g. `-d,`
            config.delimiter = arg[2..];
        }

        // -c / --capitalize
        else if (std.mem.eql(u8, arg, "-c") or std.mem.eql(u8, arg, "--capitalize")) {
            config.capitalize = true;
        }

        // Unknown argument
        else {
            std.debug.print("Error: Unknown argument: '{s}'\n", .{arg});
            return Error.InvalidArgument;
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

    // Generate and print the requested number of words
    var i: usize = 0;
    while (i < config.length) : (i += 1) {
        const idx = std.crypto.random.intRangeAtMost(usize, 0, word_count - 1);
        var word = word_list.WORD_LIST[idx];

        // Capitalize if requested
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

        // Print delimiter unless we're at the last word
        if (i < config.length - 1) {
            try stdout.print("{s}", .{config.delimiter});
        }
    }

    try stdout.print("\n", .{});
}
