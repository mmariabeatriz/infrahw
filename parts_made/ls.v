// Unidade de Load Size (LS) - Controla o tamanho dos dados carregados da memória
// Permite carregar byte, halfword ou word, ajustando o formato para 32 bits
// Usado nas instruções LB, LH e LW para processar dados de diferentes tamanhos

module ls(
    input  wire [1:0] LSControl,        // Seleção: 00=byte, 01=halfword, 10=word
    input  wire [31:0] RegMDROut,       // Valor obtido da memória
    output reg  [31:0] LSControlOut     // Valor a ser armazenado no banco de registradores
);

    always @(*) begin
        case (LSControl)
            2'b00: LSControlOut = {24'b0, RegMDROut[7:0]};   // Load byte - 1 byte, resto com 0
            2'b01: LSControlOut = {16'b0, RegMDROut[15:0]};  // Load halfword - 2 bytes, resto com 0
            2'b10: LSControlOut = RegMDROut;                 // Load word - 4 bytes completos
            default: LSControlOut = 32'b0;                   // Caso padrão
        endcase
    end

endmodule

