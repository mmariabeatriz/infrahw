module mux_Extend(

    input  wire        seletor,
    input  wire [15:0] load_size_data,  // Load_Size_OutDown
    input  wire [15:0] immediate_data,  // IMMEDIATE
    output wire [15:0] mux_extend_out

);

    always @(*) begin
        case (seletor)
            1'b0: mux_extend_out = load_size_data; // Load_Size_OutDown
            1'b1: mux_extend_out = immediate_data; // IMMEDIATE
            default: mux_extend_out = 16'b0;
        endcase
    end

endmodule