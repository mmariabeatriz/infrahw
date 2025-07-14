// Multiplexador Extend - Seleciona qual valor de 16 bits será estendido
// Permite escolher entre dados de load size ou valor imediato da instrução
// Usado para controlar qual valor será processado pela unidade de extensão de sinal
module mux_Extend(
    input  wire        seletor,
    input  wire [15:0] load_size_data,  // Entrada de dados de load size
    input  wire [15:0] immediate_data,  // IMMEDIATE
    output reg  [15:0] mux_extend_out   // Mudado para reg para usar com always
);

    always @(*) begin
        case (seletor)
            1'b0: mux_extend_out = load_size_data;
            1'b1: mux_extend_out = immediate_data;
            default: mux_extend_out = 16'b0;
        endcase
    end

endmodule