module controller (

       input  wire gt,
       input  wire zero,
       input  wire pc_write,
       input  wire isBEQ,
       input  wire isBNE,

       output wire data_out

);

/*

pc_write ------------------------------------------\
                                                    |
zero  ----&                                         |
isBEQ ----&---out1-----||\\                          |
                          |                         |-----data_out--->
zero  -~>-&               |---out5---\              |
isBNE ----&---out2-----||/            |             |
                                      |             |
                                      |---out7-----/

*/

    assign data_out = (pc_write) | (isBEQ & zero) | (isBNE & ~zero);

endmodule