module mux_PC(

    input  wire [1:0] seletor,
    input  wire [31:0] epc_data,        // EPC_Out
    input  wire [31:0] ula_result,      // ULA_Result
    input  wire [31:0] ulaout_data,     // ULAOut_Out
    input  wire [31:0] concat_data,     // Concat_28to32_Out
    output wire [31:0] mux_PC_out

);

    always @(*) begin
        case (seletor)
            2'b00: mux_PC_out = epc_data;    // EPC_Out
            2'b01: mux_PC_out = ula_result;  // ULA_Result
        2'b10: mux_PC_out = ulaout_data; // ULAOut_Out
            2'b11: mux_PC_out = concat_data; // Concat_28to32_Out
            default: mux_PC_out = 32'b0;
        endcase
    end

endmodule