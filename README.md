# FPGA-Based Low-Latency Trading System

## Project Overview

This project implements an FPGA-based low-latency trading system using SystemVerilog on the Digilent Basys 3 FPGA development board.

The system receives incoming market data, maintains a simplified order book, calculates the bid-ask spread, evaluates trading conditions, and automatically generates BUY or SELL orders.

The design was developed using AMD Vivado and verified through SystemVerilog testbenches, behavioral simulations, timing analysis, and physical FPGA hardware testing.

The primary objective of this project was to design and implement a modular, pipelined digital system capable of processing market data and generating trading decisions with low processing latency.

## Key Features

- FPGA-based market data processing
- 32-bit market data packet reception
- Single-stock bid and ask order book
- Automated BUY, SELL, and HOLD decision logic
- Hardware order generation
- Register-based pipelined architecture
- Back-to-back market data verification
- 3-clock-cycle simulated processing latency
- 100 MHz FPGA implementation
- Physical hardware verification on the Basys 3

## Hardware and Software

| Hardware / Software | Description |
|---|---|
| FPGA Board | Digilent Basys 3 |
| FPGA Clock | 100 MHz |
| Hardware Description Language | SystemVerilog |
| Development Environment | AMD Vivado |
| Simulation Software | Vivado Simulator (XSim) |
| Hardware Inputs | Switches and Pushbuttons |
| Hardware Outputs | LEDs |

## System Architecture

The design consists of five main processing components:

1. **Market Data Receiver:** Receives and processes incoming stock information.
2. **Order Book:** Maintains the latest bid and ask prices and quantities.
3. **Trading Logic:** Calculates the bid-ask spread and determines whether to BUY, SELL, or HOLD.
4. **Order Generator:** Generates orders containing the order type, price, and quantity.
5. **Top-Level Integration:** Connects the modules into a complete trading pipeline.

### Trading Pipeline

```text
                  MARKET DATA INPUT
                          |
                          v
                +--------------------+
                | Market Data        |
                | Receiver           |
                +--------------------+
                          |
                          v
                +--------------------+
                | Order Book         |
                | Bid / Ask Storage  |
                +--------------------+
                          |
                          v
                +--------------------+
                | Trading Logic      |
                | BUY / SELL / HOLD  |
                +--------------------+
                          |
                          v
                +--------------------+
                | Order Generator    |
                +--------------------+
                          |
                          v
                   ORDER OUTPUT
```

The hardware demonstration uses switches and pushbuttons to provide market data and LEDs to display the trading results.

## Market Data Packet Format

The market data receiver processes a 32-bit packet.

| Field | Width |
|---|---|
| Stock ID | 8 bits |
| Price | 16 bits |
| Quantity | 8 bits |
| Total | 32
