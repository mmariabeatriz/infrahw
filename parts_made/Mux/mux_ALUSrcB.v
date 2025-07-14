// Multiplexador ALUSrcB - Seleciona a segunda entrada da ALU
// Permite escolher entre dados do registrador B, constante 4, valor com extensão de sinal ou valor deslocado
// Controla qual valor será usado como segundo operando nas operações da ALU
module mux_ALUSrcB (

    input  wire [1:0] seletor,
    input  wire [31:0] Reg_B_info,
    input  wire [31:0] sigEx,
    input  wire [31:0] sigLef,
    output wire [31:0] mux_alusrcb_out

);

    always @(*) begin
        case (seletor)
            2'b00: mux_alusrcb_out = Reg_B_info;  // B_Out
            2'b01: mux_alusrcb_out = 32'd4;        // Constante 4
            2'b10: mux_alusrcb_out = sigEx;        // Sign_Extend16_32_Out
            2'b11: mux_alusrcb_out = sigLef;       // Sl_32_32_Out
            default: mux_alusrcb_out = 32'b0;
        endcase
    end


endmodule
