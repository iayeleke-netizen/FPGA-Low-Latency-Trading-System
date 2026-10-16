
`timescale 1ns / 1ps

module order_generator_tb;

    logic clk;
    logic reset;

    logic decision_valid;
    logic buy_signal;
    logic sell_signal;

    logic [15:0] best_bid;
    logic [15:0] best_ask;
    logic [7:0] bid_quantity;
    logic [7:0] ask_quantity;

    logic [1:0] order_type;
    logic [15:0] order_price;
    logic [7:0] order_quantity;
    logic order_valid;

    // Device Under Test
    order_generator dut (
        .clk(clk),
        .reset(reset),
        .decision_valid(decision_valid),
        .buy_signal(buy_signal),
        .sell_signal(sell_signal),
        .best_bid(best_bid),
        .best_ask(best_ask),
        .bid_quantity(bid_quantity),
        .ask_quantity(ask_quantity),
        .order_type(order_type),
        .order_price(order_price),
        .order_quantity(order_quantity),
        .order_valid(order_valid)
    );

    // 100 MHz clock
    always #5 clk = ~clk;

    // Apply a decision and verify the generated order
    task automatic test_order(
        input logic dv,
        input logic buy,
        input logic sell,
        input logic [15:0] bid,
        input logic [15:0] ask,
        input logic [7:0] bqty,
        input logic [7:0] aqty,
        input logic [1:0] expected_type,
        input logic [15:0] expected_price,
        input logic [7:0] expected_qty,
        input logic expected_valid
    );

        @(negedge clk);

        decision_valid = dv;
        buy_signal = buy;
        sell_signal = sell;

        best_bid = bid;
        best_ask = ask;
        bid_quantity = bqty;
        ask_quantity = aqty;

        @(posedge clk);
        #1;

        if (order_type !== expected_type ||
            order_price !== expected_price ||
            order_quantity !== expected_qty ||
            order_valid !== expected_valid) begin

            $fatal(1, "FAIL: Order generator mismatch");
        end

        $display(
            "PASS: Type=%b Price=%0d Quantity=%0d Valid=%b",
            order_type,
            order_price,
            order_quantity,
            order_valid
        );

        // Deassert decision_valid and check that
        // the order output clears on the next clock
        @(negedge clk);
        decision_valid = 1'b0;
        buy_signal = 1'b0;
        sell_signal = 1'b0;

        @(posedge clk);
        #1;

        if (order_valid !== 1'b0 ||
            order_type !== 2'b00 ||
            order_price !== 16'd0 ||
            order_quantity !== 8'd0)
            $fatal(1, "FAIL: Order outputs did not clear");

    endtask

    initial begin
        clk = 0;
        reset = 1;

        decision_valid = 0;
        buy_signal = 0;
        sell_signal = 0;

        best_bid = 0;
        best_ask = 0;
        bid_quantity = 0;
        ask_quantity = 0;

        // Reset
        repeat (3) @(negedge clk);
        reset = 0;

        // Test 1: BUY 10 shares at $150.28
        test_order(
            1, 1, 0,
            15025, 15028, 100, 75,
            2'b01, 15028, 10, 1
        );

        // Test 2: SELL 10 shares at $150.25
        test_order(
            1, 0, 1,
            15025, 15035, 100, 75,
            2'b10, 15025, 10, 1
        );

        // Test 3: HOLD - no order
        test_order(
            1, 0, 0,
            15025, 15030, 100, 75,
            2'b00, 0, 0, 0
        );

        // Test 4: BUY with only 5 shares available
        test_order(
            1, 1, 0,
            15025, 15028, 100, 5,
            2'b01, 15028, 5, 1
        );

        // Test 5: SELL with only 3 shares available
        test_order(
            1, 0, 1,
            15025, 15035, 3, 75,
            2'b10, 15025, 3, 1
        );

        // Test 6: BUY with zero ask quantity
        test_order(
            1, 1, 0,
            15025, 15028, 100, 0,
            2'b00, 0, 0, 0
        );

        // Test 7: Both BUY and SELL asserted
        test_order(
            1, 1, 1,
            15025, 15035, 100, 75,
            2'b00, 0, 0, 0
        );

        // Test 8: Decision not valid
        test_order(
            0, 1, 0,
            15025, 15028, 100, 75,
            2'b00, 0, 0, 0
        );

        repeat (3) @(posedge clk);
        #1;

        $display("ALL ORDER GENERATOR TESTS PASSED");
        $finish;
    end

endmodule