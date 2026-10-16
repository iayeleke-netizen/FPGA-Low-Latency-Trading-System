

`timescale 1ns / 1ps

module fpga_trading_top_tb;

    // ==========================================
    // SIGNAL DECLARATIONS
    // ==========================================

    logic clk = 0;
    logic reset;

    logic [31:0] market_data_in;
    logic data_valid;
    logic is_ask_in;

    logic [1:0] order_type;
    logic [15:0] order_price;
    logic [7:0] order_quantity;
    logic order_valid;

    logic [15:0] spread;
    logic buy_signal;
    logic sell_signal;
    logic hold_signal;

    integer order_count;
    integer buy_count;
    integer sell_count;

    // ==========================================
    // LATENCY MEASUREMENT VARIABLES
    // ==========================================

    time accepted_time;
    time generated_time;
    time latency_ns;

    integer latency_cycles;

    // ==========================================
    // DEVICE UNDER TEST
    // ==========================================

    fpga_trading_top dut (
        .clk(clk),
        .reset(reset),

        .market_data_in(market_data_in),
        .data_valid(data_valid),
        .is_ask_in(is_ask_in),

        .order_type(order_type),
        .order_price(order_price),
        .order_quantity(order_quantity),
        .order_valid(order_valid),

        .spread(spread),
        .buy_signal(buy_signal),
        .sell_signal(sell_signal),
        .hold_signal(hold_signal)
    );

    // 100 MHz clock
    always #5 clk = ~clk;

    // ==========================================
    // ORDER COUNTERS
    // ==========================================

    always @(posedge clk) begin
        if (reset) begin
            order_count <= 0;
            buy_count <= 0;
            sell_count <= 0;
        end
        else if (order_valid) begin
            order_count <= order_count + 1;

            if (order_type == 2'b01)
                buy_count <= buy_count + 1;

            if (order_type == 2'b10)
                sell_count <= sell_count + 1;
        end
    end

    // ==========================================
    // SEND MARKET UPDATE
    // ==========================================

    task automatic send_update(
        input logic [7:0] id,
        input logic [15:0] p,
        input logic [7:0] qty,
        input logic side
    );

        @(negedge clk);

        market_data_in = {id, p, qty};
        is_ask_in = side;
        data_valid = 1'b1;

        @(negedge clk);
        data_valid = 1'b0;

    endtask

    // ==========================================
    // VERIFY GENERATED ORDER
    // ==========================================

    task automatic check_order(
        input logic [1:0] expected_type,
        input logic [15:0] expected_price,
        input logic [7:0] expected_qty,
        input logic expected_valid
    );

        integer observed;
        integer i;

        observed = 0;

        for (i = 0; i < 8; i = i + 1) begin

            @(posedge clk);
            #1;

            if (order_valid) begin
                observed = observed + 1;

                if (!expected_valid ||
                    order_type !== expected_type ||
                    order_price !== expected_price ||
                    order_quantity !== expected_qty) begin

                    $fatal(1,
                        "FAIL: Unexpected order");
                end
            end
        end

        if (expected_valid && observed != 1)
            $fatal(1,
                "FAIL: Expected one order, observed %0d",
                observed);

        if (!expected_valid && observed != 0)
            $fatal(1,
                "FAIL: Expected no order, observed %0d",
                observed);

        $display(
            "PASS: Expected order behavior verified"
        );

    endtask

    // ==========================================
    // MEASURE PIPELINE LATENCY
    // ==========================================

    task automatic measure_order_latency(
        input logic [7:0] id,
        input logic [15:0] p,
        input logic [7:0] qty,
        input logic side,
        input logic [1:0] expected_type,
        input logic [15:0] expected_price,
        input logic [7:0] expected_qty
    );

        integer i;
        integer observed;

        observed = 0;

        // Present market data before clock edge
        @(negedge clk);

        market_data_in = {id, p, qty};
        is_ask_in = side;
        data_valid = 1'b1;

        // Record exact input acceptance edge
        @(posedge clk);
        accepted_time = $time;

        // Remove input after acceptance
        @(negedge clk);
        data_valid = 1'b0;

        // Observe pipeline output
        for (i = 0; i < 12; i = i + 1) begin

            @(posedge clk);
            #1;

            if (order_valid) begin

                observed = observed + 1;

                // Verify order contents
                if (order_type !== expected_type ||
                    order_price !== expected_price ||
                    order_quantity !== expected_qty)
                    $fatal(1,
                        "FAIL: Latency test order mismatch");

                generated_time = $time;

                // Remove 1 ns testbench sampling delay
                latency_ns =
                    generated_time - accepted_time - 1;

                latency_cycles = latency_ns / 10;

                $display(
                    "LATENCY: %0d cycles (%0t ns)",
                    latency_cycles,
                    latency_ns
                );
            end
        end

        if (observed != 1)
            $fatal(1,
                "FAIL: Expected one order, observed %0d",
                observed);

        $display(
            "PASS: Latency measurement verified"
        );

    endtask

    // ==========================================
    // MAIN TEST SEQUENCE
    // ==========================================

    initial begin

        reset = 1;
        market_data_in = 0;
        data_valid = 0;
        is_ask_in = 0;

        accepted_time = 0;
        generated_time = 0;
        latency_ns = 0;
        latency_cycles = 0;

        // Initial reset
        repeat (3) @(negedge clk);
        reset = 0;

        // --------------------------------------
        // TEST 1: BID ONLY
        // --------------------------------------

        send_update(1, 15025, 100, 0);
        check_order(0, 0, 0, 0);

        // --------------------------------------
        // TEST 2: BUY ORDER
        // --------------------------------------

        send_update(1, 15028, 75, 1);
        check_order(2'b01, 15028, 10, 1);

        // --------------------------------------
        // TEST 3: SELL ORDER
        // --------------------------------------

        send_update(1, 15035, 75, 1);
        check_order(2'b10, 15025, 10, 1);

        // --------------------------------------
        // TEST 4: IGNORE DIFFERENT STOCK
        // --------------------------------------

        send_update(2, 25050, 50, 0);
        check_order(0, 0, 0, 0);

        // --------------------------------------
        // TEST 5: CLEAR BID
        // --------------------------------------

        send_update(1, 15025, 0, 0);
        check_order(0, 0, 0, 0);

        // --------------------------------------
        // TEST 6: RESTORE BID
        // --------------------------------------

        send_update(1, 15030, 100, 0);
        check_order(2'b01, 15035, 10, 1);

        // --------------------------------------
        // TEST 7: IDLE - NO DUPLICATE ORDERS
        // --------------------------------------

        check_order(0, 0, 0, 0);

        $display(
            "ALL INTEGRATION TESTS PASSED"
        );

        // ======================================
        // ISOLATED LATENCY MEASUREMENT
        // ======================================

        // Reset pipeline
        @(negedge clk);
        reset = 1'b1;

        repeat (3) @(negedge clk);
        reset = 1'b0;

        // Establish BID
        send_update(1, 15025, 100, 0);
        check_order(0, 0, 0, 0);

        // Measure ASK -> BUY latency
        measure_order_latency(
            1, 15028, 75, 1,
            2'b01, 15028, 10
        );

        $display(
            "LATENCY MEASUREMENT COMPLETE"
        );

        $display(
            "ALL TESTS COMPLETED SUCCESSFULLY"
        );

        $finish;

    end

endmodule