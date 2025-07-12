// Módulo para controle de tamanho de dados em operações de load
// Suporta load word (32 bits), load byte (8 bits) e load halfword (16 bits)
module load_size(

     input  wire [1:0] command,    // Comando de controle: 00=byte, 01=halfword, 10=word
     input  wire [31:0] mdr,       // Dados lidos da memória (Memory Data Register)
     output wire [15:0] data_out2, // Saída para extensão de sinal (byte mais significativo)
     output reg [31:0] data_out    // Saída principal com dados formatados

);
   
   // Extrai o byte mais significativo para possível extensão de sinalt, 
   assign data_out2 = {{8{1'b0}}, mdr[31:24]};

   // Lógica combinacional para formatação dos dados baseada no comando
   always @ (*) begin

        if (command == 2'b10) begin      // Load Word (LW): carrega 32 bits completos
            data_out = mdr;
        end
        else if (command == 2'b00) begin // Load Byte (LB): carrega 8 bits com zero-extend
            data_out = {24'd0, mdr[7:0]};
        end
        else if (command == 2'b01) begin // Load Halfword (LH): carrega 16 bits com zero-extend
            data_out = {16'd0, mdr[15:0]};
        end
    end

endmodule

