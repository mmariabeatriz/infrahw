module shift_left32_32 (
    input  wire [31:0] data_in,
    output wire [31:0] data_out
);

    // Desloca à esquerda 2 posições (multiplica por 4)
    assign data_out = data_in << 2;

endmodule