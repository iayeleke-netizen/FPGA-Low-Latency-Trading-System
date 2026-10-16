# FPGA-Based Low-Latency Trading System

## Project Overview

This project implements a low-latency trading system using SystemVerilog on the Digilent Basys 3 FPGA development board. The system processes incoming market data, maintains a simplified order book, evaluates trading conditions, and generates BUY or SELL orders based on the difference between bid and ask prices.

The project was developed using AMD Vivado and verified through behavioral simulations, timing analysis, and physical FPGA hardware testing.

## Hardware and Software

- Digilent Basys 3 FPGA Development Board
- AMD Vivado Design Suite
- SystemVerilog
- 100 MHz FPGA Clock

## System Architecture

The design consists of five main components:

1. **Market Data Receiver:** Receives incoming stock price and quantity information.
2. **Order Book:** Stores the latest bid and ask prices and quantities for a single stock.
3. **Trading Logic:** Calculates the bid-ask spread and determines whether to BUY, SELL, or HOLD.
4. **Order Generator:** Generates orders containing the order type, price, and quantity.
5. **Top-Level Integration:** Connects the modules and coordinates the trading pipeline.

## Trading Strategy

The system evaluates the spread between the best bid and ask prices.

- **BUY:** Spread between 1 and 5.
- **SELL:** Spread greater than 5.
- **HOLD:** Spread of 0 or when valid trading conditions are not met.

This is a demonstration strategy used to test FPGA processing and order generation, rather than a production trading algorithm.

## Simulation and Verification

The design was tested using SystemVerilog testbenches in Vivado.

Verification included:

- Market data reception
- Bid and ask order book updates
- Trading decision generation
- Order generation
- Full-system integration
- Back-to-back market data processing

The back-to-back simulation successfully verified seven expected BUY orders without reported errors.

## Latency Performance

The integrated trading pipeline demonstrated a latency of 3 clock cycles in simulation.

With a 100 MHz clock:

- Clock period: 10 ns
- Pipeline latency: 3 cycles
- **Simulated processing latency: 30 ns**

This measurement represents internal FPGA processing latency in the tested simulation, not end-to-end network trading latency.

## FPGA Implementation

The design was synthesized and implemented in Vivado for the Basys 3 FPGA.

The implemented design met its 100 MHz clock timing constraint.

- Worst Negative Slack (WNS): +4.438 ns
- Total Negative Slack (TNS): 0 ns
- Worst Hold Slack (WHS): +0.109 ns
- Failing timing endpoints: 0

## Hardware Testing

The design was programmed onto the Basys 3 FPGA and tested using physical switches, pushbuttons, and LEDs.

Three trading conditions were verified:

| Test | Expected Behavior | Result |
|---|---|---|
| BUY | Generate BUY order | Passed |
| SELL | Generate SELL order | Passed |
| HOLD | Do not generate an order | Passed |

The hardware tests confirmed the expected trading decisions and order indications.

## Project Results

The completed prototype demonstrates:

- Modular RTL design using SystemVerilog
- FPGA-based market data processing
- Register-based order book storage
- Automated trading decision logic
- Order generation
- Testbench development and functional verification
- Timing-constrained FPGA implementation
- Physical hardware validation

## Future Improvements

Potential extensions include:

- Support for multiple stocks
- A deeper, multi-level order book
- Configurable trading strategies
- Ethernet market data input
- Additional performance and latency optimization
- More extensive automated verification

## Project Purpose

This project was developed to gain practical experience with FPGA architecture, RTL design, hardware verification, and low-latency digital systems relevant to FPGA and hardware engineering roles in electronic trading.


Project Verification Screenshots

1. Market Data Receiver



2. Order Book



3. Trading Logic

The trading logic evaluates the bid-ask spread and generates BUY, SELL, or HOLD decisions.



4. Order Generator

The order generator creates orders containing the order type, price, and quantity.



5. Full Pipeline Verification

Seven consecutive BUY orders were successfully verified using an automated SystemVerilog testbench.



6. Latency Verification

The integrated trading pipeline demonstrated a latency of 3 clock cycles (30 ns at 100 MHz) in simulation.



7. FPGA Timing Analysis

The implemented FPGA design met its 100 MHz clock timing constraint with zero failing endpoints.



8. Physical Hardware Testing

BUY Order Test



SELL Order Test



HOLD Test

