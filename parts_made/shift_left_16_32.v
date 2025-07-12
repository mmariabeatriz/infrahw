module shift_left_16_32 (
    input  wire [15:0] data_in,
    output wire [31:0] data_out
);

    // Desloca à esquerda 16 posições (carrega imediato superior)
    assign data_out = data_in << 16;

endmodule