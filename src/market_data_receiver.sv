
module market_data_receiver (
    input  logic        clk,
    input  logic        reset,

    input  logic [31:0] market_data_in,
    input  logic        data_valid,
    input  logic        is_ask_in,

    output logic [7:0]  stock_id,
    output logic [15:0] price,
    output logic [7:0]  quantity,
    output logic        is_ask_out,
    output logic        output_valid
);

    always_ff @(posedge clk) begin
        if (reset) begin
            stock_id     <= 8'd0;
            price        <= 16'd0;
            quantity     <= 8'd0;
            is_ask_out   <= 1'b0;
            output_valid <= 1'b0;
        end
        else begin
            output_valid <= data_valid;

            if (data_valid) begin
                stock_id   <= market_data_in[31:24];
                price      <= market_data_in[23:8];
                quantity   <= market_data_in[7:0];
                is_ask_out <= is_ask_in;
            end
        end
    end

endmodule