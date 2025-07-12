module alu_control (

       input  wire gt,
       input  wire zero,
       input  wire pc_write,
       input  wire isBEQ,
       input  wire isBNE,

       output wire data_out

);
    assign data_out = (pc_write) | (isBEQ & zero) | (isBNE & ~zero);

endmodule