// Multiplexador B - Seleciona a fonte de dados para o registrador B
// Permite escolher entre dados do registrador 2 ou dados da memória
// Usado para controlar qual valor será armazenado no registrador B durante a execução
module mux_B(

    input  wire        seletor,
    input  wire [31:0] read_data2,     // Read_Data2_Out
    input  wire [31:0] memory_data,    // Memory_Out
    output reg [31:0] mux_B_out

);

    always @(*) begin
        case (seletor)
            1'b0: mux_B_out = read_data2;   // Read_Data2_Out
            1'b1: mux_B_out = memory_data;  // Memory_Out
            default: mux_B_out = 32'b0;
        endcase
    end

endmodule