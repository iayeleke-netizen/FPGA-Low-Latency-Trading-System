
module fpga_trading_hardware_top (
    input  logic        clk,
    input  logic        btnC,
    input  logic        btnU,
    input  logic [15:0] sw,
    output logic [15:0] led
);

    // =========================================
    // BASYS 3 HARDWARE INPUTS
    // =========================================

    logic reset;
    logic update_pulse;
    logic btnU_meta;
    logic btnU_sync;
    logic btnU_previous;

    // Synchronize the button to FPGA clock
    always_ff @(posedge clk) begin
        btnU_meta     <= btnU;
        btnU_sync     <= btnU_meta;
        btnU_previous <= btnU_sync;
    end

    // Generate one update per button press
    assign update_pulse = btnU_sync && !btnU_previous;

    // Reset button
    assign reset = btnC;

    // =========================================
    // MARKET DATA INPUTS
    // =========================================

    logic [31:0] market_data_in;
    logic        data_valid;
    logic        is_ask_in;

    // Stock ID = 1
    // Price = 15000 + switch value
    // Quantity = 100

    assign market_data_in = {
        8'd1,
        (16'd15000 + {8'd0, sw[7:0]}),
        8'd100
    };

    assign is_ask_in = sw[8];
    assign data_valid = update_pulse;

    // =========================================
    // TRADING SYSTEM OUTPUTS
    // =========================================

    logic [1:0]  order_type;
    logic [15:0] order_price;
    logic [7:0]  order_quantity;
    logic        order_valid;

    logic [15:0] spread;
    logic buy_signal;
    logic sell_signal;
    logic hold_signal;

    // =========================================
    // INSTANTIATE TRADING SYSTEM
    // =========================================

    fpga_trading_top trading_system (
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

    // =========================================
    // LATCH LAST GENERATED ORDER
    // =========================================

    logic [1:0] last_order_type;
    logic [15:0] last_order_price;
    logic [7:0] last_order_quantity;
    logic       order_seen;

    always_ff @(posedge clk) begin
        if (reset) begin
            last_order_type     <= 2'b00;
            last_order_price    <= 16'd0;
            last_order_quantity <= 8'd0;
            order_seen          <= 1'b0;
        end
        else if (order_valid) begin
            last_order_type     <= order_type;
            last_order_price    <= order_price;
            last_order_quantity <= order_quantity;
            order_seen          <= 1'b1;
        end
    end

    // =========================================
    // LED OUTPUT DISPLAY
    // =========================================

    // LED15 = An order has been generated
    // LED14 = BUY
    // LED13 = SELL
    // LED12 = HOLD
    // LED11:0 = Last order price (lower 12 bits)

    always_comb begin
        led = 16'd0;

        led[15] = order_seen;
        led[14] = (last_order_type == 2'b01);
        led[13] = (last_order_type == 2'b10);
        led[12] = hold_signal;
        led[11:0] = last_order_price[11:0];
    end

endmodule
