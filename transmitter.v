module transmitter (
    input  wire       clk,
    input  wire       rstn,
    input  wire       start,
    input  wire [6:0] data_in,

    output reg        serial_out
);

    reg flag_transmitting;
    reg [3:0] bit_count_transmitter;
    reg [7:0] shift_reg_transmitter;

    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            flag_transmitting     <= 1'b0;
            bit_count_transmitter <= 4'd0;
            shift_reg_transmitter <= 8'd0;
            serial_out            <= 1'b1;  // idle (linha alta)
        end else if (start && !flag_transmitting) begin
            // start ativo-alto: inicia transmissão
            flag_transmitting     <= 1'b1;
            shift_reg_transmitter <= { ^data_in, data_in }; // {paridade par, d6..d0}
            serial_out            <= 1'b0; // start bit
            bit_count_transmitter <= 4'd8;   // 7 bits + paridade
        end else if (flag_transmitting) begin
            if (bit_count_transmitter > 0) begin
                // envia próximo bit LSB primeiro
                serial_out            <= shift_reg_transmitter[0]; // Envia o bit menos significativo
                shift_reg_transmitter <= shift_reg_transmitter >> 1;
                bit_count_transmitter <= bit_count_transmitter - 1;
            end else begin
                // stop bit e volta ao idle
                flag_transmitting <= 1'b0;
                serial_out        <= 1'b1;
            end
        end
    end


endmodule