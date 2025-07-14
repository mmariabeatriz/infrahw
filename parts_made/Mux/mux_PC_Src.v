// Multiplexador PC_Src - Seleciona a fonte do próximo valor do Program Counter
// Permite escolher entre EPC, resultado da ALU, ALUOut ou endereço concatenado
// Controla o fluxo de execução do programa (sequencial, branch, jump, exceção)
module mux_PC_Src(

    input  wire [1:0] seletor,
    input  wire [31:0] epc_data,        // EPC_Out
    input  wire [31:0] alu_result,      // ALU_Result
    input  wire [31:0] aluout_data,     // ALUOut_Out
    input  wire [31:0] concat_data,     // Concat_28to32_Out
    output wire [31:0] mux_PC_out

);

    always @(*) begin
        case (seletor)
            2'b00: mux_PC_out = epc_data;    // EPC_Out
            2'b01: mux_PC_out = alu_result;  // ALU_Result
            2'b10: mux_PC_out = aluout_data; // ALUOut_Out
            2'b11: mux_PC_out = concat_data; // Concat_28to32_Out
            default: mux_PC_out = 32'b0;
        endcase
    end

endmodule