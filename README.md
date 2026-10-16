# FPGA-Based Low-Latency Trading System

## Project Overview

This project implements a low-latency trading system using SystemVerilog on the Digilent Basys 3 FPGA development board. The system processes incoming market data, maintains a simplified order book, evaluates trading conditions, and generates BUY or SELL orders based on the difference between bid and ask prices.

The project was developed using AMD Vivado and verified through behavioral simulations, timing analysis, and physical FPGA hardware testing.

The primary objective was to design and implement a modular FPGA trading pipeline capable of processing market data and generating trading decisions with low processing latency.

## Hardware and Software

- Digilent Basys 3 FPGA Development Board
- AMD Vivado Design Suite
- SystemVerilog
- 100 MHz FPGA Clock
- Vivado Simulator (XSim)

## System Architecture

The design consists of five main components:

1. **Market Data Receiver:** Receives incoming stock price, quantity, stock ID, and bid/ask information.
2. **Order Book:** Stores the latest bid and ask prices and quantities for a single stock.
3. **Trading Logic:** Calculates the bid-ask spread and determines whether to BUY, SELL, or HOLD.
4. **Order Generator:** Generates orders containing the order type, price, and quantity.
5. **Top-Level Integration:** Connects the modules and coordinates the trading pipeline.

### Trading Pipeline

Market Data Input → Market Data Receiver → Order Book → Trading Logic → Order Generator → Order Output

The hardware demonstration uses switches and pushbuttons to provide market data inputs and LEDs to display trading results.

## Trading Strategy

The system evaluates the spread between the stored bid and ask prices.

| Condition | Decision |
|---|---|
| Spread between 1 and 5 | BUY |
| Spread greater than 5 | SELL |
| Spread of 0 or invalid trading conditions | HOLD |

The spread is calculated as:

**Spread = Ask Price − Bid Price**

The system generates orders based on the current trading decision.

- BUY orders use the ask price.
- SELL orders use the bid price.
- Order quantity is limited to 10 units or the available quantity, whichever is smaller.
- HOLD conditions do not generate orders.

This is a demonstration strategy developed to verify FPGA processing and order generation rather than a production trading algorithm.

## SystemVerilog Modules

### Market Data Receiver

The market data receiver accepts a 32-bit market data packet containing:

- 8-bit stock ID
- 16-bit stock price
- 8-bit quantity

The receiver extracts the packet information and forwards valid market updates to the order book.

### Order Book

The order book stores the latest bid and ask information for a single stock.

Stored information includes:

- Best bid price
- Best ask price
- Bid quantity
- Ask quantity
- Bid valid status
- Ask valid status

A zero-quantity update invalidates the corresponding quote.

### Trading Logic

The trading logic calculates the bid-ask spread and determines the appropriate trading decision.

The module generates BUY, SELL, and HOLD signals based on the configured spread conditions.

### Order Generator

The order generator converts trading decisions into order information
