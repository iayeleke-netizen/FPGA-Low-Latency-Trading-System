
module trading_logic (
    input  logic        clk,
    input  logic        reset,

    input  logic [15:0] best_bid,
    input  logic [15:0] best_ask,
    input  logic [7:0]  bid_quantity,
    input  logic [7:0]  ask_quantity,
    input  logic        bid_valid,
    input  logic        ask_valid,

    output logic [15:0] spread,
    output logic        buy_signal,
    output logic        sell_signal,
    output logic        hold_signal
);

    // Spread threshold: 5 cents
    localparam logic [15:0] SPREAD_THRESHOLD = 16'd5;

    logic [15:0] spread_next;
    logic buy_next;
    logic sell_next;
    logic hold_next;

    // Combinational trading decision
    always_comb begin
        spread_next = 16'd0;
        buy_next = 1'b0;
        sell_next = 1'b0;
        hold_next = 1'b1;

        if (bid_valid && ask_valid &&
            bid_quantity != 0 &&
            ask_quantity != 0 &&
            best_ask > best_bid) begin

            spread_next = best_ask - best_bid;

            if (spread_next <= SPREAD_THRESHOLD) begin
                buy_next = 1'b1;
                hold_next = 1'b0;
            end
            else begin
                sell_next = 1'b1;
                hold_next = 1'b0;
            end
        end
    end

    // Register outputs on rising clock edge
    always_ff @(posedge clk) begin
        if (reset) begin
            spread      <= 16'd0;
            buy_signal  <= 1'b0;
            sell_signal <= 1'b0;
            hold_signal <= 1'b1;
        end
        else begin
            spread      <= spread_next;
            buy_signal  <= buy_next;
            sell_signal <= sell_next;
            hold_signal <= hold_next;
        end
    end

endmodule
