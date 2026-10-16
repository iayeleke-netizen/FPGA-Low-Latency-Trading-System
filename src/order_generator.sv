
module order_generator (
    input  logic        clk,
    input  logic        reset,

    input  logic        decision_valid,
    input  logic        buy_signal,
    input  logic        sell_signal,

    input  logic [15:0] best_bid,
    input  logic [15:0] best_ask,
    input  logic [7:0]  bid_quantity,
    input  logic [7:0]  ask_quantity,

    output logic [1:0]  order_type,
    output logic [15:0] order_price,
    output logic [7:0]  order_quantity,
    output logic        order_valid
);

    // Order type encoding
    localparam logic [1:0] NO_ORDER = 2'b00;
    localparam logic [1:0] BUY      = 2'b01;
    localparam logic [1:0] SELL     = 2'b10;

    // Desired quantity: 10 shares
    localparam logic [7:0] DEFAULT_QTY = 8'd10;

    always_ff @(posedge clk) begin
        if (reset) begin
            order_type     <= NO_ORDER;
            order_price    <= 16'd0;
            order_quantity <= 8'd0;
            order_valid    <= 1'b0;
        end
        else begin
            // A new order is valid for one cycle
            order_valid <= 1'b0;

            // Clear the order fields by default
            order_type     <= NO_ORDER;
            order_price    <= 16'd0;
            order_quantity <= 8'd0;

            if (decision_valid) begin

                // Generate BUY order
                if (buy_signal && !sell_signal &&
                    ask_quantity != 0 &&
                    best_ask != 0) begin

                    order_type  <= BUY;
                    order_price <= best_ask;

                    if (ask_quantity >= DEFAULT_QTY)
                        order_quantity <= DEFAULT_QTY;
                    else
                        order_quantity <= ask_quantity;

                    order_valid <= 1'b1;
                end

                // Generate SELL order
                else if (sell_signal && !buy_signal &&
                         bid_quantity != 0 &&
                         best_bid != 0) begin

                    order_type  <= SELL;
                    order_price <= best_bid;

                    if (bid_quantity >= DEFAULT_QTY)
                        order_quantity <= DEFAULT_QTY;
                    else
                        order_quantity <= bid_quantity;

                    order_valid <= 1'b1;
                end
            end
        end
    end

endmodule