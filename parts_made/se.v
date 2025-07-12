module se (
    input  wire [15:0] data_in,
    output wire [31:0] data_out
);

    // Sign extend 16-bit to 32-bit
    // If MSB is 1, extend with 1s; otherwise extend with 0s
    assign data_out = (data_in[15]) ? {{16{1'b1}}, data_in} : {{16{1'b0}}, data_in};

endmodule