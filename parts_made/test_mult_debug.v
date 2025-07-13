`timescale 1ns / 1ps

module test_mult_debug;

    // Inputs
    reg [31:0] RegAOut;
    reg [31:0] RegBOut;
    reg clk;
    reg reset;
    reg MultCtrl;

    // Outputs
    wire MultDone;
    wire [31:0] HI;
    wire [31:0] LO;

    // Instantiate the Unit Under Test (UUT)
    mult uut (
        .RegAOut(RegAOut), 
        .RegBOut(RegBOut), 
        .clk(clk), 
        .reset(reset), 
        .MultCtrl(MultCtrl), 
        .MultDone(MultDone), 
        .HI(HI), 
        .LO(LO)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Monitor internal signals
    always @(posedge clk) begin
        if (uut.mult_active) begin
            $display("Ciclo %d: Counter=%d, A_Mult_Comp[1:0]=%b, A_Mult_Comp[64:33]=%h, A_Mult_Comp[32:1]=%h", 
                     $time/10, uut.Counter, uut.A_Multiplicand_ComparePos[1:0], 
                     uut.A_Multiplicand_ComparePos[64:33], uut.A_Multiplicand_ComparePos[32:1]);
        end
    end

    // Test sequence
    initial begin
        // Initialize Inputs
        RegAOut = 0;
        RegBOut = 0;
        reset = 1;
        MultCtrl = 0;

        // Wait for global reset
        #10;
        reset = 0;
        #10;

        // Test simples: 2 * 3 = 6
        $display("Teste Debug: 2 * 3");
        RegAOut = 32'd2;
        RegBOut = 32'd3;
        MultCtrl = 1;
        #10;
        MultCtrl = 0;
        
        // Wait for multiplication to complete
        wait(MultDone == 1);
        #10;
        $display("Resultado Final: HI = %h, LO = %h", HI, LO);
        $display("Esperado: HI = 00000000, LO = 00000006");
        
        #50;
        $finish;
    end

endmodule