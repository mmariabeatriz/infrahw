// Multiplexador Low - Seleciona a fonte dos 32 bits menos significativos (registrador LO)
// Permite escolher entre resultado da multiplicação ou divisão para o registrador LO
// Usado nas instruções MFLO para acessar a parte baixa do resultado de operações aritméticas
module mux_Low(

    input  wire        seletor,
    input  wire [31:0] mult_low_data,   // Mult_Low_Out
    input  wire [31:0] div_low_data,    // Div_Low_Out
    output wire [31:0] mux_low_out

);

    always @(*) begin
        case (seletor)
            1'b0: mux_low_out = mult_low_data;  // Mult_Low_Out
            1'b1: mux_low_out = div_low_data;   // Div_Low_Out
            default: mux_low_out = 32'b0;
        endcase
    end

endmodule