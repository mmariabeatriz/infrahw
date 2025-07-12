module sl_26_28 (
    input  wire [25:0] data_in,
    output wire [27:0] data_out
);

    // Shift left by 2 positions (multiply by 4)
    assign data_out = {data_in, 2'b00};

endmodule