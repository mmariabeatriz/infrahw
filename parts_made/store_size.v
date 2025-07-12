// Módulo para controle de tmanho de dados em operações de store
// Suporta store byte (8 bits) e store halfword (16 bits)
module store_size (
    
    input  wire        command,   // Comando de controle: 0=byte, 1=halfword
    input  wire [31:0] mdr,       // Dados atuais da memória (Memory Data Register)
    input  wire [31:0] b,         // Dados do registrador a serem armazenados
    output reg  [31:0] data_out   // Dados formatados para escrita na memória

);

// Lógica combinacional para formatação dos dados baseada no comando
always @ (*) begin
        if (command == 0) begin      // Store Byte (SB): preserva bits 31-8, substitui bits 7-0
            data_out = {mdr[31:8], b[7:0]};
        end
        else begin                   // Store Halfword (SH): preserva bits 31-16, substitui bits 15-0
            data_out = {mdr[31:16], b[15:0]};
        end
    end

endmodule
