module shift_left26_28 (
    input  wire [25:0] data_in,
    output wire [27:0] data_out
);

    // Desloca à esquerda 2 posições (multiplica por 4)
    assign data_out = {data_in, 2'b00};

endmodule