// Multiplexador writeDataMem - Seleciona os dados que serão escritos na memória
// Permite escolher entre dados do registrador B ou dados processados pelo store size
// Controla qual valor será armazenado na memória durante operações de store (SW, SB)
module mux_writeDataMem(

    input  wire        seletor,
    input  wire [31:0] reg_B_data,     // B_Out
    input  wire [31:0] store_size_data, // Store_Size_Out
    output reg [31:0] mux_wd_memory_out

);

    always @(*) begin
        case (seletor)
            1'b0: mux_wd_memory_out = reg_B_data;      // B_Out
            1'b1: mux_wd_memory_out = store_size_data; // Store_Size_Out
            default: mux_wd_memory_out = 32'b0;
        endcase
    end

endmodule