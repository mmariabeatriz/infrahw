module load_size(

     input  wire [1:0] command,
     input  wire [31:0] mdr,
     output wire [15:0] data_out2, //para baixo (mux extend) (mux_wd_registers)
     output reg [31:0] data_out //para cima (mux_wd_registers)

);
   
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

