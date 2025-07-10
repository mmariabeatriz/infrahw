module mux_WD_Registers(

    input  wire [2:0]  seletor,
    input  wire [31:0] aluout_data,     // ALUOut_Out
    input  wire [31:0] memory_data,     // Memory_Out
    input  wire [31:0] mdr_data,        // MDR_Out
    input  wire [31:0] hi_data,         // HI_Out
    input  wire [31:0] lo_data,         // LO_Out
    input  wire [31:0] shift_data,      // Shift_Out
    input  wire [31:0] pc_plus4_data,   // PC_Plus4_Out
    output wire [31:0] mux_wd_reg_out
);

    always @(*) begin
        case (seletor)
            3'b000: mux_wd_reg_out = 32'd227;        // Constante 227
            3'b001: mux_wd_reg_out = aluout_data;    // ALUOut_Out
            3'b010: mux_wd_reg_out = memory_data;    // Memory_Out
            3'b011: mux_wd_reg_out = mdr_data;       // MDR_Out
            3'b100: mux_wd_reg_out = hi_data;        // HI_Out
            3'b101: mux_wd_reg_out = lo_data;        // LO_Out
            3'b110: mux_wd_reg_out = shift_data;     // Shift_Out
            3'b111: mux_wd_reg_out = pc_plus4_data;  // PC_Plus4_Out
            default: mux_wd_reg_out = 32'b0;
        endcase
    end

endmodule