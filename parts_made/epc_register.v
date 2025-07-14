// Registrador EPC (Exception Program Counter) - 32 bits
// Armazena o endereço da instrução que causou a exceção
// Usado no tratamento de exceções (overflow, div0, opcode inexistente)
module epc_register(
    input wire clk,
    input wire reset,
    input wire epc_load,        // Sinal de controle para carregar EPC
    input wire [31:0] pc_in,    // PC atual (endereço da instrução que causou exceção)
    output reg [31:0] epc_out   // Valor armazenado no EPC
);

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            epc_out <= 32'b0;
        end else if (epc_load) begin
            epc_out <= pc_in;
        end
    end

endmodule