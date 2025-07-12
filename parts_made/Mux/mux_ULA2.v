module mux_ULA2 (

    input  wire [1:0] seletor,
    input  wire [31:0] Reg_B_info,
    input  wire [31:0] sigEx,
    input  wire [31:0] sigLef,
    output wire [31:0] mux_ULA2_out

);

    always @(*) begin
        case (seletor)
            2'b00: mux_ULA2_out = Reg_B_info;  // B_Out
            2'b01: mux_ULA2_out = 32'd4;        // Constante 4
            2'b10: mux_ULA2_out = sigEx;        // Sign_Extend16_32_Out
            2'b11: mux_ULA2_out = sigLef;       // Shift_Left32_32_Out
            default: mux_ULA2_out = 32'b0;
        endcase
    end


endmodule
