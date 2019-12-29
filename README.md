# NES Disassembler written in Lua

## Usage

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