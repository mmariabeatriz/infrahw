module concat_28to32(
    input wire [31:0] PC_out,
    input wire [27:0] SL_out,
    output wire [31:0] conc_out
);

    assign conc_out = {PC_out[31:28], SL_out};

endmodule