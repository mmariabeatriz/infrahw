module concat_26to28(
    input wire [4:0] RT,
    input wire [4:0] RS,
    input wire [15:0] Imediato,
    output wire [25:0] concatena_out
);

    assign concatena_out = {RT, RS, Imediato};

endmodule