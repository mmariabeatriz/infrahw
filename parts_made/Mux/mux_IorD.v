module mux_IorD (

    input  wire [2:0]  seletor,
    input  wire [31:0] alu_result,      // ALU_Result
    input  wire [31:0] aluout_data,     // ALUOut_Out
    output wire [31:0] mux_iord_out

);

    always @(*) begin
        case (seletor)
            3'b000: mux_iord_out = alu_result;  // ALU_Result
            3'b001: mux_iord_out = aluout_data; // ALUOut_Out
            3'b010: mux_iord_out = 32'd253;     // Constante 253
            3'b011: mux_iord_out = 32'd254;     // Constante 254
            3'b100: mux_iord_out = 32'd255;     // Constante 255
            default: mux_iord_out = 32'b0;
        endcase
    end

endmodule