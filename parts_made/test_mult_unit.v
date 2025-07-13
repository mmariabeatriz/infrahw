`timescale 1ns / 1ps

module test_mult_unit;

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

        // Test 1: 4 * 3 = 12
        $display("Teste 1: 4 * 3");
        RegAOut = 32'd4;
        RegBOut = 32'd3;
        MultCtrl = 1;
        #10;
        MultCtrl = 0;
        
        // Wait for multiplication to complete
        wait(MultDone == 1);
        #10;
        $display("  Resultado: HI = %h, LO = %h", HI, LO);
        $display("  Esperado: HI = 00000000, LO = 0000000c");
        if (HI == 32'h00000000 && LO == 32'h0000000c)
            $display("  PASSOU!");
        else
            $display("  FALHOU!");
        #20;

        // Test 2: -5 * 6 = -30
        $display("Teste 2: -5 * 6");
        RegAOut = 32'hfffffffb; // -5 in two's complement
        RegBOut = 32'd6;
        MultCtrl = 1;
        #10;
        MultCtrl = 0;
        
        wait(MultDone == 1);
        #10;
        $display("  Resultado: HI = %h, LO = %h", HI, LO);
        $display("  Esperado: HI = ffffffff, LO = ffffffe2"); // -30 in two's complement
        if (HI == 32'hffffffff && LO == 32'hffffffe2)
            $display("  PASSOU!");
        else
            $display("  FALHOU!");
        #20;

        // Test 3: Large numbers: 0x80000000 * 2
        $display("Teste 3: 0x80000000 * 2");
        RegAOut = 32'h80000000; // -2147483648
        RegBOut = 32'd2;
        MultCtrl = 1;
        #10;
        MultCtrl = 0;
        
        wait(MultDone == 1);
        #10;
        $display("  Resultado: HI = %h, LO = %h", HI, LO);
        #20;

        $display("Testes concluídos!");
        $finish;
    end

endmodule