# Smol Diceware

This is a [diceware](https://en.wikipedia.org/wiki/Diceware) implementation
in zig that is designed to be small and fast. It uses only the [Zig](https://ziglang.org/)
standard library.

## Features

- Generate a specified number of random words.
- Choose a custom delimiter to separate words.
- Option to capitalize the generated words.
- Display help information for usage.

## Usage

```sh
smol-diceware [OPTIONS]
```

### Options

- `-l, --length <LENGTH>`: How many words to generate (default: 3).
- `-d, --delimiter <DELIMITER>`: Delimiter to use for joining words.
- `-c, --capitalize`: Capitalize words.
- `-h, --help`: Print help information.

## Installation

1. Clone the repository:
   ```sh
   git clone <repository-url>
   ```
2. Navigate to the project directory:
   ```sh
   cd <project-directory>
   ```
3. Build the project using Zig:
   ```sh
   zig build
   ```

## Example

Generate 5 capitalized words separated by a comma:
```sh
./zig-out/bin/smol-diceware -l 5 -d "," -c
```

## License (Unlicense)

This is free and unencumbered software released into the public domain.

Anyone is free to copy, modify, publish, use, compile, sell, or
distribute this software, either in source code form or as a compiled
binary, for any purpose, commercial or non-commercial, and by any
means.

In jurisdictions that recognize copyright laws, the author or authors
of this software dedicate any and all copyright interest in the
software to the public domain. We make this dedication for the benefit
of the public at large and to the detriment of our heirs and
successors. We intend this dedication to be an overt act of
relinquishment in perpetuity of all present and future rights to this
software under copyright law.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR
OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.

For more information, please refer to <https://unlicense.org/>
