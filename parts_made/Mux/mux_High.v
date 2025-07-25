// Multiplexador High - Seleciona a fonte dos 32 bits mais significativos (registrador HI)
// Permite escolher entre resultado da multiplicação ou divisão para o registrador HI
// Usado nas instruções MFHI para acessar a parte alta do resultado de operações aritméticas
module mux_High(

    input  wire        seletor,
    input  wire [31:0] mult_high_data,  // Mult_High_Out
    input  wire [31:0] div_high_data,   // Div_High_Out
    output reg [31:0] mux_high_out

);

    always @(*) begin
        case (seletor)
            1'b0: mux_high_out = mult_high_data; // Mult_High_Out
            1'b1: mux_high_out = div_high_data;  // Div_High_Out
            default: mux_high_out = 32'b0;
        endcase
    end

endmodule