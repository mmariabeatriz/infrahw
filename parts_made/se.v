// Unidade de Extensão de Sinal (SE) - Estende valores de 16 bits para 32 bits
// Preserva o sinal do número: estende com 1s se negativo, com 0s se positivo
// Usado para processar valores imediatos em instruções I-type
module se (
    input  wire [15:0] data_in,
    output wire [31:0] data_out
);

    // Sign extend 16-bit to 32-bit
    // If MSB is 1, extend with 1s; otherwise extend with 0s
    assign data_out = (data_in[15]) ? {{16{1'b1}}, data_in} : {{16{1'b0}}, data_in};

endmodule