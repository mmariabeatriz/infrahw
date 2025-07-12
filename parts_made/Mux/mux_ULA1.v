module mux_ULA1(

    input  wire [1:0] seletor,
    input  wire [31:0] pc_data,         // PC_Out
    input  wire [31:0] reg_A_data,      // A_Out
    output wire [31:0] mux_ULA1_out

);

    always @(*) begin
        case (seletor)
            2'b00: mux_ULA1_out = pc_data;     // PC_Out
            2'b01: mux_ULA1_out = reg_A_data;  // A_Out
            2'b10: mux_ULA1_out = 32'd0;       // Constante 0
            default: mux_ULA1_out = 32'b0;
        endcase
    end

endmodule