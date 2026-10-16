
`timescale 1ns / 1ps

module market_data_receiver_tb;

    logic clk;
    logic reset;

    logic [31:0] market_data_in;
    logic data_valid;
    logic is_ask_in;

    logic [7:0] stock_id;
    logic [15:0] price;
    logic [7:0] quantity;
    logic is_ask_out;
    logic output_valid;

    // Device Under Test
    market_data_receiver dut (
        .clk(clk),
        .reset(reset),
        .market_data_in(market_data_in),
        .data_valid(data_valid),
        .is_ask_in(is_ask_in),
        .stock_id(stock_id),
        .price(price),
        .quantity(quantity),
        .is_ask_out(is_ask_out),
        .output_valid(output_valid)
    );

    // 100 MHz clock
    always #5 clk = ~clk;

    // Send a market update and verify the output
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

        @(posedge clk);
        #1;

        if (output_valid !== 1'b1 ||
            stock_id !== id ||
            price !== p ||
            quantity !== qty ||
            is_ask_out !== side) begin

            $fatal(1, "FAIL: Market data mismatch");
        end

        $display(
            "PASS: Stock=%0d Price=%0d Qty=%0d Side=%s",
            stock_id,
            price,
            quantity,
            is_ask_out ? "ASK" : "BID"
        );

        @(negedge clk);
        data_valid = 1'b0;

        @(posedge clk);
        #1;

        if (output_valid !== 1'b0)
            $fatal(1, "FAIL: output_valid did not clear");

    endtask

    initial begin
        clk = 0;
        reset = 1;
        market_data_in = 0;
        data_valid = 0;
        is_ask_in = 0;

        // Reset
        repeat (3) @(negedge clk);
        reset = 0;

        // Test 1: BID at $150.25
        send_update(1, 15025, 100, 0);

        // Test 2: ASK at $150.30
        send_update(1, 15030, 75, 1);

        // Test 3: BID at $250.50
        send_update(2, 25050, 50, 0);

        // Test 4: ASK at $250.55
        send_update(2, 25055, 80, 1);

        // Test 5: Clear an ASK quote
        send_update(1, 15030, 0, 1);

        repeat (3) @(posedge clk);
        #1;

        $display("ALL UPDATED MARKET DATA TESTS PASSED");
        $finish;
    end

endmodule