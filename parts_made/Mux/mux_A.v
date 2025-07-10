module mux_A(

    input  wire [1:0]  seletor,
    input  wire [31:0] memory_data,     // Memory_Out
    input  wire [31:0] read_data1,      // Read_Data1_Out
    input  wire [31:0] read_data2,      // Read_Data2_Out
    output wire [31:0] mux_A_out

);

    always @(*) begin
        case (seletor)
            2'b00: mux_A_out = memory_data; // Memory_Out
            2'b01: mux_A_out = read_data1;  // Read_Data1_Out
            2'b10: mux_A_out = read_data2;  // Read_Data2_Out
            default: mux_A_out = 32'b0;
        endcase
    end

endmodule