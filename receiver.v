module receiver (
    input  wire       clk,
    input  wire       rstn,
    input  wire       serial_in,

    output reg        ready,
    output reg [6:0]  data_out,
    output reg        parity_ok_n
);

    reg flag_receiver;
    reg [3:0] bit_count_receiver;
    reg [7:0] shift_reg_receiver;
    integer i;

    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            flag_receiver      <= 1'b0;
            bit_count_receiver <= 4'd0;
            shift_reg_receiver <= 8'd0;
            ready              <= 1'b0;
            parity_ok_n        <= 1'b1;
            data_out           <= 7'd0;
        end else if (!serial_in && !flag_receiver) begin

            flag_receiver      <= 1'b1;
            bit_count_receiver <= 4'd8;   // 7 bits de dados + paridade
            shift_reg_receiver <= 8'd0;
            ready              <= 1'b0;
        end else if (flag_receiver) begin
            if (bit_count_receiver > 0) begin
                shift_reg_receiver <= { shift_reg_receiver[6:0], serial_in };
                bit_count_receiver <= bit_count_receiver - 1;
            end else begin
                flag_receiver <= 1'b0;
                for (i = 0; i < 7; i = i + 1) begin
                    data_out[i] <= shift_reg_receiver[7 - i];
                end
                parity_ok_n <= ((^shift_reg_receiver[7:1]) == shift_reg_receiver[0]) ? 1'b0 : 1'b1;
                ready       <= 1'b1;
            end
        end
    end
endmodule
