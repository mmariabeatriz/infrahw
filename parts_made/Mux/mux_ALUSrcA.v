// Multiplexador ALUSrcA - Seleciona a primeira entrada da ALU
// Permite escolher entre PC, dados do registrador A ou constante 0
// Controla qual valor será usado como primeiro operando nas operações da ALU
module mux_ALUSrcA(

    input  wire [1:0] seletor,
    input  wire [31:0] pc_data,         // PC_Out
    input  wire [31:0] reg_A_data,      // A_Out
    output wire [31:0] mux_alusrca_out

);

    always @(*) begin
        case (seletor)
            2'b00: mux_alusrca_out = pc_data;     // PC_Out
            2'b01: mux_alusrca_out = reg_A_data;  // A_Out
            2'b10: mux_alusrca_out = 32'd0;       // Constante 0
            default: mux_alusrca_out = 32'b0;
        endcase
    end

endmodule