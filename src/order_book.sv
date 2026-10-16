
module order_book (
    input  logic        clk,
    input  logic        reset,

    input  logic        update_valid,
    input  logic        is_ask,
    input  logic [15:0] price_in,
    input  logic [7:0]  quantity_in,

    output logic [15:0] best_bid,
    output logic [15:0] best_ask,
    output logic [7:0]  bid_quantity,
    output logic [7:0]  ask_quantity,
    output logic        bid_valid,
    output logic        ask_valid
);

    always_ff @(posedge clk) begin
        if (reset) begin
            best_bid     <= 16'd0;
            best_ask     <= 16'd0;
            bid_quantity <= 8'd0;
            ask_quantity <= 8'd0;
            bid_valid    <= 1'b0;
            ask_valid    <= 1'b0;
        end
        else if (update_valid) begin
            if (is_ask) begin
                best_ask     <= price_in;
                ask_quantity <= quantity_in;
                ask_valid    <= (quantity_in != 0);
            end
            else begin
                best_bid     <= price_in;
                bid_quantity <= quantity_in;
                bid_valid    <= (quantity_in != 0);
            end
        end
    end

endmodule