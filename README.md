# UART Transceiver using Verilog HDL

## Overview

This project is a simple UART (Universal Asynchronous Receiver Transmitter) designed in Verilog HDL. I built this project while learning RTL design to understand how UART communication works at the hardware level.

The design includes a baud rate generator, UART transmitter, UART receiver, and a top-level module that connects everything together. A self-checking testbench is also included to verify the design using loopback simulation.

---

## Project Details

- **Project Name:** UART_Project
- **Top Module:** uart_top
- **Language:** Verilog HDL
- **Simulation Tool:** Xilinx Vivado Simulator
- **Vivado Version:** 2025.1
- **Target FPGA:** Basys 3 (Artix-7 XC7A35T)

---

## Features

- UART Transmitter
- UART Receiver
- Baud Rate Generator
- 16× Oversampling Receiver
- Parameterized Clock Frequency
- Parameterized Baud Rate
- Frame Error Detection
- Self-checking Testbench
- Loopback Verification

---

## Project Structure

```
UART_Project
│
├── rtl/
│   ├── baud_gen.v
│   ├── uart_tx.v
│   ├── uart_rx.v
│   └── uart_top.v
│
├── tb/
│   └── uart_tb.v
│
├── waveforms/
│   └── Waveform.png
│
├── docs/
│   └── UART_Block_Diagram.png
│
└── README.md
```

---

## UART Frame Format

```
Start Bit |          Data Bits        | Stop Bit

     0    | D0 D1 D2 D3 D4 D5 D6 D7   |    1
```

- Idle State : High
- Start Bit : Low
- Data Length : 8 Bits
- Data Order : LSB First
- Stop Bit : High

---

## Simulation

A loopback connection was used for testing by connecting the transmitter output directly to the receiver input.

The following test data was transmitted successfully:

| Data | Status |
|------|--------|
| 0x55 | PASS |
| 0xA5 | PASS |
| 0x00 | PASS |
| 0xFF | PASS |
| 0x3C | PASS |

No framing errors were detected during the simulation.

---

## Results

The simulation waveform confirms that every transmitted byte was received correctly.

- All test cases passed
- No frame errors
- Transmitted and received data matched successfully

---

## What I Learned

This project helped me understand:

- UART communication protocol
- RTL design using Verilog HDL
- Finite State Machine (FSM) design
- Baud rate generation
- 16× oversampling technique
- Writing a self-checking testbench
- Functional simulation and waveform analysis

---

## Future Improvements

Some features that can be added in future versions are:

- Parity bit support
- Configurable stop bits
- FIFO buffer
- Hardware implementation on Basys 3 FPGA
- APB/AXI interface

---

## Author

**Saravana Kumar**

Electronics and Communication Engineering

Passionate about RTL Design, Digital Design, FPGA, and ASIC Design.
