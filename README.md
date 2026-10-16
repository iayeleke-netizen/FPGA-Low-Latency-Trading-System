## Project Verification Screenshots

### Hardware Testing

**BUY Order Test**

![Hardware BUY](screenshots/hardware_buy_test.png)

**SELL Order Test**

![Hardware SELL](screenshots/hardware_sell_test.png)

**HOLD Test**

![Hardware HOLD](screenshots/hardware_hold_test.png)

### Trading Logic Verification

The trading logic was tested to verify BUY, SELL, and HOLD decisions based on the bid-ask spread.

![Trading Logic](screenshots/trading_logic_waveform.png)

### Order Generator Verification

The order generator was tested to verify order type, price, quantity, and valid signals.

![Order Generator](screenshots/order_generator_waveform.png)

### Automated Pipeline Verification

Seven consecutive BUY orders were successfully verified.

![Pipeline Verification](screenshots/fpga_pipeline_verification_console.png)

### Latency Verification

The trading pipeline demonstrated a simulated latency of 3 clock cycles (30 ns at 100 MHz).

![Latency Results](screenshots/fpga_latency_results.png)

### FPGA Timing Analysis

The implemented design met the 100 MHz timing constraint with zero failing endpoints.

![Timing Analysis](screenshots/fpga_trading_hardware_timing.png)
