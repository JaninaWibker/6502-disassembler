# NES Disassembler written in Lua

## Usage

`usage: main.lua <optional flags> <file>`

### Flags

```
  -u, --uppercase    Turns all instructions and hex values to uppercase (default)
  -l, --lowercase    Turns all instructions and hex values to lowercase
  -h, --hex          Turns ON the hex output
  -H, --no-hex       Turns OFF the hex output
  -i, --illegal      Display 'illegal' after all illegal instructions
  -I, --no-illegal   Turns --illegal OFF
  -m, --mode         Display the addressing mode for each instruction
  -M, --no-mode      Turns --mode OFF
  -a, --address      Display memory addresses in front of everything else
  -A, --no-address   Turns --address OFF
  -r, --reset        Reset all options to OFF
  -R, --reset-on     Reset all options to ON
  -v, --version      Print version
```

> generally flags in upper case can be used to turn off the corresponding lower case flag

> format:  `[memory] [hex] [instruction] [arguments] ([mode]; [illegal])`
> default: `-uhimA (--uppercase, --hex, --illegal, --mode, --no-address)`

Note that duo to how flags are parsed it is impossible to have filenames starting with hyphens ("-"). This is duo to having to remove the file path from the array of arguments to be parsed which could otherwise lead to problems as the filepath is not required for -v / --version. Thereby disallowing hyphens at the start of filepaths is an easy way out.

### Example

```sh
lua src/main.lua Super\ Mario\ Bros.\ \(World\).nes
78          SEI             (Implied)
D8          CLD             (Implied)
A9 16       LDA #$10        (Immediate)
8D 32 0     STA $2000       (Absolute)
A2 255      LDX #$FF        (Immediate)
9A          TXS             (Implied)
AD 32 2     LDA $2002       (Absolute)
10 251      BPL ?$FB        (Relative)
AD 32 2     LDA $2002       (Absolute)
10 251      BPL ?$FB        (Relative)
...
```

## Dependencies

- **dkjson**: `luarocks install dkjson`
