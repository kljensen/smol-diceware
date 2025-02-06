const std = @import("std");

const word_list = @embedFile("eff_long_wordlist.txt");

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

pub fn main() !void {
   var gpa = std.heap.GeneralPurposeAllocator(.{}){};
   const allocator = gpa.allocator();
   defer _ = gpa.deinit();

   const args = try std.process.argsAlloc(allocator);
   defer std.process.argsFree(allocator, args);

   var length: usize = 3;
   var delimiter: []const u8 = " ";
   var capitalize = false;
   
   var i: usize = 1;
   while (i < args.len) : (i += 1) {
       const arg = args[i];
       if (std.mem.eql(u8, arg, "-h") or std.mem.eql(u8, arg, "--help")) {
           try std.io.getStdOut().writer().print("{s}", .{help_text});
           return;
       } else if (std.mem.eql(u8, arg, "-l") or std.mem.eql(u8, arg, "--length")) {
           i += 1;
           if (i >= args.len) {
               std.debug.print("Error: Missing value for length\n", .{});
               return error.InvalidArgument;
           }
           length = try std.fmt.parseInt(usize, args[i], 10);
       } else if (std.mem.eql(u8, arg, "-d") or std.mem.eql(u8, arg, "--delimiter")) {
           i += 1;
           if (i >= args.len) {
               std.debug.print("Error: Missing value for delimiter\n", .{});
               return error.InvalidArgument;
           }
           delimiter = args[i];
       } else if (std.mem.eql(u8, arg, "-c") or std.mem.eql(u8, arg, "--capitalize")) {
           capitalize = true;
       }
   }

   // Count total words
   var words = std.mem.tokenize(u8, word_list, "\n");
   var word_count: usize = 0;
   while (words.next()) |_| word_count += 1;

   // Generate and print words
   var word_list_array = std.ArrayList([]const u8).init(allocator);
   defer word_list_array.deinit();

   var j: usize = 0;
   while (j < length) : (j += 1) {
       words = std.mem.tokenize(u8, word_list, "\n");
       const idx = std.crypto.random.intRangeAtMost(usize, 0, word_count - 1);
       
       var k: usize = 0;
       while (words.next()) |word| : (k += 1) {
           if (k == idx) {
               if (capitalize) {
                   var cap_word = try allocator.alloc(u8, word.len);
                   defer allocator.free(cap_word);
                   std.mem.copy(u8, cap_word, word);
                   cap_word[0] = std.ascii.toUpper(cap_word[0]);
                   try word_list_array.append(cap_word);
               } else {
                   try word_list_array.append(word);
               }
               break;
           }
       }
   }

   // Join and print words
   for (word_list_array.items, 0..) |word, index| {
       try std.io.getStdOut().writer().print("{s}", .{word});
       if (index < word_list_array.items.len - 1) {
           try std.io.getStdOut().writer().print("{s}", .{delimiter});
       }
   }
   try std.io.getStdOut().writer().print("\n", .{});
}
