
module fpga_trading_top (
    input  logic        clk,
    input  logic        reset,

    input  logic [31:0] market_data_in,
    input  logic        data_valid,
    input  logic        is_ask_in,

    output logic [1:0]  order_type,
    output logic [15:0] order_price,
    output logic [7:0]  order_quantity,
    output logic        order_valid,

    output logic [15:0] spread,
    output logic        buy_signal,
    output logic        sell_signal,
    output logic        hold_signal
);

    // ====================================
    // STAGE 1: MARKET DATA RECEIVER
    // ====================================

    logic [7:0]  stock_id;
    logic [15:0] price;
    logic [7:0]  quantity;
    logic        is_ask;
    logic        receiver_valid;

    market_data_receiver receiver (
        .clk(clk),
        .reset(reset),
        .market_data_in(market_data_in),
        .data_valid(data_valid),
        .is_ask_in(is_ask_in),
        .stock_id(stock_id),
        .price(price),
        .quantity(quantity),
        .is_ask_out(is_ask),
        .output_valid(receiver_valid)
    );

    logic book_update_valid;

    assign book_update_valid =
        receiver_valid && (stock_id == 8'd1);

    // ====================================
    // STAGE 2: ORDER BOOK
    // ====================================

    logic [15:0] best_bid;
    logic [15:0] best_ask;
    logic [7:0]  bid_quantity;
    logic [7:0]  ask_quantity;
    logic        bid_valid;
    logic        ask_valid;

    order_book book (
        .clk(clk),
        .reset(reset),
        .update_valid(book_update_valid),
        .is_ask(is_ask),
        .price_in(price),
        .quantity_in(quantity),
        .best_bid(best_bid),
        .best_ask(best_ask),
        .bid_quantity(bid_quantity),
        .ask_quantity(ask_quantity),
        .bid_valid(bid_valid),
        .ask_valid(ask_valid)
    );

    // ====================================
    // STAGE 3: TRADING DECISION
    // ====================================

    logic decision_valid;
    logic decision_valid_delayed;

    always_ff @(posedge clk) begin
        if (reset)
            decision_valid <= 1'b0;
        else
            decision_valid <= book_update_valid;
    end

    trading_logic strategy (
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

    // ====================================
    // PIPELINE ALIGNMENT REGISTERS
    // ====================================

    // Capture the order-book values used
    // by the trading decision.

    logic [15:0] aligned_bid;
    logic [15:0] aligned_ask;
    logic [7:0]  aligned_bid_qty;
    logic [7:0]  aligned_ask_qty;

    always_ff @(posedge clk) begin
        if (reset) begin
            aligned_bid     <= 16'd0;
            aligned_ask     <= 16'd0;
            aligned_bid_qty <= 8'd0;
            aligned_ask_qty <= 8'd0;
        end
        else begin
            aligned_bid     <= best_bid;
            aligned_ask     <= best_ask;
            aligned_bid_qty <= bid_quantity;
            aligned_ask_qty <= ask_quantity;
        end
    end

    // Align valid signal with trading
    // decision and captured order data.

    always_ff @(posedge clk) begin
        if (reset)
            decision_valid_delayed <= 1'b0;
        else
            decision_valid_delayed <= decision_valid;
    end

    // ====================================
    // STAGE 4: ORDER GENERATOR
    // ====================================

    order_generator generator (
        .clk(clk),
        .reset(reset),

        .decision_valid(decision_valid_delayed),

        .buy_signal(buy_signal),
        .sell_signal(sell_signal),

        .best_bid(aligned_bid),
        .best_ask(aligned_ask),

        .bid_quantity(aligned_bid_qty),
        .ask_quantity(aligned_ask_qty),

        .order_type(order_type),
        .order_price(order_price),
        .order_quantity(order_quantity),
        .order_valid(order_valid)
    );

endmodule