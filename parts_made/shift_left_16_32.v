module shift_left_16_32 (
    input  wire [15:0] data_in,
    output wire [31:0] data_out
);

    // Shift left by 16 positions (load upper immediate)
    assign data_out = data_in << 16;

endmodule