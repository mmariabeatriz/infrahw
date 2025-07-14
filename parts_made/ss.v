// Unidade de Store Size (SS) - Controla o tamanho dos dados armazenados na memória
// Permite armazenar byte, halfword ou word, preservando dados não modificados
// Usado nas instruções SB, SH e SW para escrever dados de diferentes tamanhos

module ss (
    input  wire [1:0]  RegSSControl,    // Seleção: 00=byte, 01=halfword, 10=word
    input  wire [31:0] RegBOut,         // Valor novo a ser salvo na memória
    input  wire [31:0] RegMDROut,       // Valor antigo na memória
    output reg  [31:0] SSControlOut     // Valor a ser armazenado na memória
);

    always @(*) begin
        case (RegSSControl)
            2'b00: SSControlOut = {RegMDROut[31:8], RegBOut[7:0]};    // Store byte - preserva 3 bytes antigos
            2'b01: SSControlOut = {RegMDROut[31:16], RegBOut[15:0]};  // Store halfword - preserva 2 bytes antigos
            2'b10: SSControlOut = RegBOut;                            // Store word - substitui palavra completa
            default: SSControlOut = RegMDROut;                        // Caso padrão - mantém valor antigo
        endcase
    end

endmodule
