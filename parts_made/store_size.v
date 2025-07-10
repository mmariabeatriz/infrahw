module store_size (
    
    input  wire        command,
    input  wire [31:0] mdr,
    input  wire [31:0] b,
    output reg  [31:0] data_out

);

always @ (*) begin
        if (command == 0) begin //byte
            data_out = {mdr[31:8], b[7:0]};
        end
        else begin //halfword
            data_out = {mdr[31:16], b[15:0]};
        end
    end

endmodule 
