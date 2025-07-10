module load_size(

     input  wire [1:0] command,
     input  wire [31:0] mdr,
     output wire [15:0] data_out2, //para baixo (mux extend) (mux_wd_registers)
     output reg [31:0] data_out //para cima (mux_wd_registers)

);
   
   /*
O load size é um bloco que irá receber um valor de 32 bits do MDR e um sinal de 2 bits da unidade de controle
Ele tem duas saidas:

Saida 1: 
	Irá analisar um sinal de entrada de 2 bits (00 -> byte, 01 -> halfword e 10 -> word)
	Em 00, deverá pegar o byte (1x8 = 8) menos significativo (8 últimos) do MDR e concatenar um montao de zero a esquerda até virar um numero de 32 bits
	Em 01, deverá pegar os 2 bytes (2x8 = 16) menos significativos (16 últimos) do MDR e concatenar um montao de zero a esquerda até virar um numero de 32 bits
	Em 10, deverá colocar na saida o valor vindo do MDR
Saida 2:
	SEMPRE irá pegar o byte (1x8 = 8) mais significativo (8 primeiros) do MDR e concatenar um montão de zero a esquerda até virar um numero de 16 bits
   */

   assign data_out2 = {{8{1'b0}}, mdr[31:24]};

   always @ (*) begin

        if (command == 2'b10) begin //load word
            data_out = mdr;
        end
        else if (command == 2'b00) begin //load byte
            data_out = {24'd0, mdr[7:0]};
        end
        else if (command == 2'b01) begin //load halfword
            data_out = {16'd0, mdr[15:0]};
        end
    end

endmodule

