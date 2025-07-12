module mux_Memory_WD(

    input  wire        seletor,
    input  wire [31:0] reg_B_data,     // B_Out
    input  wire [31:0] store_size_data, // Store_Size_Out
    output wire [31:0] mux_memory_wd_out

);

    always @(*) begin
        case (seletor)
            1'b0: mux_memory_wd_out = reg_B_data;      // B_Out
        1'b1: mux_memory_wd_out = store_size_data; // Store_Size_Out
        default: mux_memory_wd_out = 32'b0;
        endcase
    end

endmodule