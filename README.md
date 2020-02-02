<img src="./6502-disassembler-logo.svg" width="384px" alt="NES Disassembler written in Lua" />

## Usage

`usage: main.lua <optional flags> <file>`

### Flags 🇦🇶

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
>
> default: `-uhimA (--uppercase, --hex, --illegal, --mode, --no-address)`

Note that duo to how flags are parsed it is impossible to have filenames starting with hyphens ("-"). This is duo to having to remove the file path from the array of arguments to be parsed which could otherwise lead to problems as the filepath is not required for -v / --version. Thereby disallowing hyphens at the start of filepaths is an easy way out.

### Example 💾

```sh
lua src/main.lua file.nes
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

## Install

Just `git clone https://github.com/JannikWibker/6502-disassembler` and install dependencies via luarocks.

### Dependencies

- **dkjson**: `luarocks install dkjson`

## Notes 📝

There are 2 features planned:
- better displaying of branch / jump instructions
- allow not displaying illegal instructions and leave them as raw data (as embedding raw data is not that uncommon and using illegal instructions is pretty rare)

### Format of 6502-asm.json file

The 6502-asm.json file contains definitions for all instructions (even illegal instructions) for the 6502.

The format is as follows (a single mnemonic contains multiple instructions, each is a different version of the same just with another addressing mode)
```json
{
  "<mnemonic>": [
    ["<addressing mode>", "<legal / illegal>", "<format>", "<opcode (hex)>", "<length>", "<cycle count>"]
  ]
}
```

> There are only a handful of sources for all of the illegal instructions for the 6502, all with differing names and sometimes even functionality. A great effort went into finding all of these oddities and documenting them (as well as implementing at least one version of each instruction in the disassembler). This documentation is only available in german (many parts can be understood without speaking german as it mostly consists of tables with opcodes, mnemonics, ...) and can be found [here](https://docs.jannik.ml/#/microcontroller/6502).
