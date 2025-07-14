// Multiplexador Shift_Src - Seleciona a fonte de dados para operações de deslocamento
// Permite escolher entre dados do registrador A ou registrador B
// Controla qual valor será deslocado nas instruções de shift (SLL, SRA, etc.)
module mux_Shift_Src(

    input  wire        seletor,
    input  wire [31:0] reg_A_data,     // A_Out
    input  wire [31:0] reg_B_data,     // B_Out
    output reg [31:0] mux_shift_src_out

);

    always @(*) begin
        case (seletor)
            1'b0: mux_shift_src_out = reg_A_data;  // A_Out
            1'b1: mux_shift_src_out = reg_B_data;  // B_Out
            default: mux_shift_src_out = 32'b0;
        endcase
    end

endmodule