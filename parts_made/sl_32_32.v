module sl_32_32 (
    input  wire [31:0] data_in,
    output wire [31:0] data_out
);

    // Shift left by 2 positions (multiply by 4)
    assign data_out = data_in << 2;

endmodule