// Multiplexador regDst - Seleciona o registrador de destino para escrita
// Permite escolher entre RT, registrador 29, registrador 31 ou RD da instrução
// Controla qual registrador receberá o resultado da operação (R-type, I-type, JAL, etc.)
module mux_regDst(

    input  wire [1:0]  seletor,
    input  wire [4:0]  rt_field,        // instruction[20:16]
    input  wire [15:0] rd_field,        // instruction[15:0]
    output wire [4:0]  mux_wr_reg_out

);

    always @(*) begin
        case (seletor)
            2'b00: mux_wr_reg_out = rt_field;        // instruction[20:16]
            2'b01: mux_wr_reg_out = 5'd29;           // Registrador 29
            2'b10: mux_wr_reg_out = 5'd31;           // Registrador 31
            2'b11: mux_wr_reg_out = rd_field[15:11]; // instruction[15:11]
            default: mux_wr_reg_out = 5'b0;
        endcase
    end

endmodule