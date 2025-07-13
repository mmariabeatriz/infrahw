// Unidade de LS (Load Size)
// Entrada:
// RegMDROut(32 bits): valor obtido da memória
// LSControl(2 bits): seleção de como irá ser salvo o valor no banco de registradores
// Saída: LSControlOut(32 bits): valor a ser armazenado no banco de registradores

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

