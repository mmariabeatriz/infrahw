module mux_Address (

    input  wire [2:0]  seletor,
    input  wire [31:0] ula_result,      // ULA_Result
    input  wire [31:0] ulaout_data,     // ULAOut_Out
    output wire [31:0] mux_address_out

);

    always @(*) begin
        case (seletor)
            3'b000: mux_address_out = ula_result;  // ULA_Result
        3'b001: mux_address_out = ulaout_data; // ULAOut_Out
            3'b010: mux_address_out = 32'd253;     // Constante 253
            3'b011: mux_address_out = 32'd254;     // Constante 254
            3'b100: mux_address_out = 32'd255;     // Constante 255
            default: mux_address_out = 32'b0;
        endcase
    end

endmodule