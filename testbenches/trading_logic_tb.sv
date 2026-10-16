
`timescale 1ns / 1ps

module trading_logic_tb;

    logic clk;
    logic reset;

    logic [15:0] best_bid;
    logic [15:0] best_ask;
    logic [7:0] bid_quantity;
    logic [7:0] ask_quantity;
    logic bid_valid;
    logic ask_valid;

    logic [15:0] spread;
    logic buy_signal;
    logic sell_signal;
    logic hold_signal;

    // Device Under Test
    trading_logic dut (
        .clk(clk),
        .reset(reset),
        .best_bid(best_bid),
        .best_ask(best_ask),
        .bid_quantity(bid_quantity),
        .ask_quantity(ask_quantity),
        .bid_valid(bid_valid),
        .ask_valid(ask_valid),
        .spread(spread),
        .buy_signal(buy_signal),
        .sell_signal(sell_signal),
        .hold_signal(hold_signal)
    );

    // 100 MHz clock
    always #5 clk = ~clk;

    // Apply inputs and check expected results
    task automatic test_decision(
        input logic [15:0] bid,
        input logic [15:0] ask,
        input logic [7:0] bqty,
        input logic [7:0] aqty,
        input logic bv,
        input logic av,
        input logic [15:0] expected_spread,
        input logic expected_buy,
        input logic expected_sell,
        input logic expected_hold
    );

        @(negedge clk);

        best_bid = bid;
        best_ask = ask;
        bid_quantity = bqty;
        ask_quantity = aqty;
        bid_valid = bv;
        ask_valid = av;

        @(posedge clk);
        #1;

        if (spread !== expected_spread ||
            buy_signal !== expected_buy ||
            sell_signal !== expected_sell ||
            hold_signal !== expected_hold) begin

            $fatal(1, "FAIL: Trading decision mismatch");
        end

        $display(
            "PASS: Bid=%0d Ask=%0d Spread=%0d BUY=%b SELL=%b HOLD=%b",
            bid, ask, spread,
            buy_signal, sell_signal, hold_signal
        );

    endtask

    initial begin
        clk = 0;
        reset = 1;

        best_bid = 0;
        best_ask = 0;
        bid_quantity = 0;
        ask_quantity = 0;
        bid_valid = 0;
        ask_valid = 0;

        // Reset
        repeat (3) @(negedge clk);
        reset = 0;

        // Test 1: $0.03 spread -> BUY
        test_decision(
            15025, 15028, 100, 75,
            1, 1, 3, 1, 0, 0
        );

        // Test 2: $0.10 spread -> SELL
        test_decision(
            15025, 15035, 100, 75,
            1, 1, 10, 0, 1, 0
        );

        // Test 3: $0.05 spread -> BUY
        test_decision(
            15025, 15030, 100, 75,
            1, 1, 5, 1, 0, 0
        );

        // Test 4: Equal prices -> HOLD
        test_decision(
            15025, 15025, 100, 75,
            1, 1, 0, 0, 0, 1
        );

        // Test 5: Invalid ask -> HOLD
        test_decision(
            15025, 15030, 100, 75,
            1, 0, 0, 0, 0, 1
        );

        // Test 6: Zero bid quantity -> HOLD
        test_decision(
            15025, 15030, 0, 75,
            1, 1, 0, 0, 0, 1
        );

        // Test 7: Crossed prices -> HOLD
        test_decision(
            15035, 15025, 100, 75,
            1, 1, 0, 0, 0, 1
        );

        repeat (3) @(posedge clk);
        #1;

        $display("ALL TRADING LOGIC TESTS PASSED");
        $finish;
    end

endmodule