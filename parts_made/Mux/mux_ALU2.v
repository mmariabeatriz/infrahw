module mux_ALU2 (

    input  wire [1:0] seletor,
    input  wire [31:0] Reg_B_info,
    input  wire [31:0] sigEx,
    input  wire [31:0] sigLef,
    output wire [31:0] mux_ALU2_out

);

/*

data_0 --|
4 -------|--out1-------|\
data_2 --|               |--data_out--->
data_3 --|--out2-------|/

*/

    always @(*) begin
        case (seletor)
            2'b00: mux_ALU2_out = Reg_B_info;  // B_Out
            2'b01: mux_ALU2_out = 32'd4;        // Constante 4
            2'b10: mux_ALU2_out = sigEx;        // Sign_Extend16_32_Out
            2'b11: mux_ALU2_out = sigLef;       // Shift_Left32_32_Out
            default: mux_ALU2_out = 32'b0;
        endcase
    end


endmodule
