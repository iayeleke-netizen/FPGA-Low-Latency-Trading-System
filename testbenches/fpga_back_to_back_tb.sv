
`timescale 1ns / 1ps

module fpga_back_to_back_tb;

    logic clk = 0;
    logic reset = 1;

    logic [31:0] market_data_in = 0;
    logic data_valid = 0;
    logic is_ask_in = 0;

    logic [1:0] order_type;
    logic [15:0] order_price;
    logic [7:0] order_quantity;
    logic order_valid;

    logic [15:0] spread;
    logic buy_signal;
    logic sell_signal;
    logic hold_signal;

    integer total_orders = 0;
    integer buy_orders = 0;
    integer sell_orders = 0;
    integer errors = 0;

    // Expected results for the seven orders
    logic [15:0] expected_prices [0:6];

    // 100 MHz clock
    always #5 clk = ~clk;

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

    // Send a new update every clock cycle
    task automatic send_fast_update(
        input logic [7:0] id,
        input logic [15:0] p,
        input logic [7:0] qty,
        input logic side
    );
        @(negedge clk);
        market_data_in = {id, p, qty};
        is_ask_in = side;
        data_valid = 1'b1;
    endtask

    // Check every generated order
    always @(posedge clk) begin
        if (!reset && order_valid) begin

            if (total_orders >= 7) begin
                $fatal(1,
                    "FAIL: Extra order generated");
            end

            if (order_type !== 2'b01) begin
                $fatal(1,
                    "FAIL: Expected BUY order");
            end

            if (order_price !==
                expected_prices[total_orders]) begin

                $fatal(1,
                    "FAIL: Order %0d wrong price. Expected=%0d Actual=%0d",
                    total_orders + 1,
                    expected_prices[total_orders],
                    order_price);
            end

            if (order_quantity !== 8'd10) begin
                $fatal(1,
                    "FAIL: Order %0d wrong quantity",
                    total_orders + 1);
            end

            total_orders = total_orders + 1;
            buy_orders = buy_orders + 1;

            $display(
                "PASS: Order %0d BUY Price=%0d Qty=%0d Time=%0t",
                total_orders,
                order_price,
                order_quantity,
                $time
            );
        end
    end

    initial begin

        // Expected BUY order prices
        expected_prices[0] = 15028;
        expected_prices[1] = 15029;
        expected_prices[2] = 15030;
        expected_prices[3] = 15030;
        expected_prices[4] = 15030;
        expected_prices[5] = 15031;
        expected_prices[6] = 15032;

        $display(
            "STARTING AUTOMATED PIPELINE TEST"
        );

        repeat (3) @(negedge clk);
        reset = 0;

        // Initial BID
        send_fast_update(1, 15025, 100, 0);

        // Three consecutive ASK updates
        send_fast_update(1, 15028, 75, 1);
        send_fast_update(1, 15029, 80, 1);
        send_fast_update(1, 15030, 90, 1);

        // Two consecutive BID updates
        send_fast_update(1, 15026, 100, 0);
        send_fast_update(1, 15027, 100, 0);

        // Two more ASK updates
        send_fast_update(1, 15031, 75, 1);
        send_fast_update(1, 15032, 75, 1);

        @(negedge clk);
        data_valid = 0;

        // Allow pipeline to drain
        repeat (12) @(posedge clk);
        #1;

        if (total_orders !== 7)
            $fatal(1,
                "FAIL: Expected 7 orders, got %0d",
                total_orders);

        $display(
            "================================"
        );
        $display(
            "ALL 7 PIPELINE ORDERS VERIFIED"
        );
        $display(
            "BACK-TO-BACK TEST PASSED"
        );
        $display(
            "================================"
        );

        $finish;

    end

endmodule