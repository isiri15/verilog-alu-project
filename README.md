# 8-bit ALU — Verilog Design & Verification

A fully functional 8-bit Arithmetic Logic Unit (ALU) designed in Verilog, verified with a self-checking testbench and waveform-based functional verification.

## Features

- Arithmetic operations: ADD, SUB (with carry/borrow and overflow detection)
- Logic operations: AND, OR, XOR, NOT
- Shift operations: Logical shift left (SHL), logical shift right (SHR)
- Comparisons: Equality (EQ), Greater-than (GT)
- Status flags: Zero flag, carry flag, signed overflow flag

## Files

| File | Description |
|------|--------------|
| alu.v | 8-bit ALU RTL design (parameterized width) |
| tb_alu.v | Self-checking testbench with automated pass/fail reporting |

## Verification

Result: 15/15 tests passed

Functional correctness was also confirmed visually via waveform inspection in EPWave.
