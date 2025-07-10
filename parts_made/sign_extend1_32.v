module sign_extend1_32 (
    input  wire        data_in,
    output wire [31:0] data_out
);

    // Zero extend 1-bit to 32-bit (always unsigned)
    assign data_out = {31'b0, data_in};

endmodule