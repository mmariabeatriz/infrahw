module mux_Shift_Amt (
    input wire [1:0] seletor,
    input wire [31:0] reg_B_data,
    input wire [15:0] immediate_data,
    input wire [31:0] mem_data,
    input wire [4:0] shamt_data,
    output reg [4:0] mux_shift_amt_out
);

    always @(*) begin
        case (seletor)
            2'b00: mux_shift_amt_out = reg_B_data[4:0];
            2'b01: mux_shift_amt_out = immediate_data[10:6];
            2'b10: mux_shift_amt_out = mem_data[4:0];
            2'b11: mux_shift_amt_out = shamt_data;
            default: mux_shift_amt_out = 5'b0;
        endcase
    end

endmodule