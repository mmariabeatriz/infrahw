`timescale 1ns / 1ps

module test_booth_mult;
    reg clk, reset;
    reg [31:0] RegAOut, RegBOut;
    reg MultCtrl;
    wire [31:0] HI, LO;
    wire MultDone;
    
    // Instanciar o módulo mult
    mult uut (
        .clk(clk),
        .reset(reset),
        .RegAOut(RegAOut),
        .RegBOut(RegBOut),
        .MultCtrl(MultCtrl),
        .HI(HI),
        .LO(LO),
        .MultDone(MultDone)
    );
    
    // Clock
    always #5 clk = ~clk;
    
    initial begin
        $dumpfile("test_booth_mult.vcd");
        $dumpvars(0, test_booth_mult);
        
        clk = 0;
        reset = 1;
        MultCtrl = 0;
        RegAOut = 0;
        RegBOut = 0;
        
        #10 reset = 0;
        
        // Teste 1: 6 * 7 = 42
        $display("=== Teste 1: 6 * 7 ===");
        RegAOut = 32'd6;
        RegBOut = 32'd7;
        MultCtrl = 1;
        #10 MultCtrl = 0;
        
        wait(MultDone);
        $display("Resultado: HI=%d, LO=%d", $signed(HI), $signed(LO));
        $display("Esperado: HI=0, LO=42");
        
        #20;
        
        // Teste 2: -5 * 3 = -15
        $display("=== Teste 2: -5 * 3 ===");
        RegAOut = 32'hFFFFFFFB;  // -5
        RegBOut = 32'd3;
        MultCtrl = 1;
        #10 MultCtrl = 0;
        
        wait(MultDone);
        $display("Resultado: HI=%d, LO=%d", $signed(HI), $signed(LO));
        $display("Esperado: HI=-1, LO=-15");
        
        #20;
        
        // Teste 3: 65536 * 65536 = 4294967296
        $display("=== Teste 3: 65536 * 65536 ===");
        RegAOut = 32'd65536;
        RegBOut = 32'd65536;
        MultCtrl = 1;
        #10 MultCtrl = 0;
        
        wait(MultDone);
        $display("Resultado: HI=%d, LO=%d", HI, LO);
        $display("Esperado: HI=1, LO=0");
        
        #100;
        $finish;
    end
    
    // Monitor para debug
    initial begin
        $monitor("Tempo=%0t, count=%d, mult_active=%b, MultDone=%b, A_Q_Q1=%h", 
                 $time, uut.count, uut.mult_active, MultDone, uut.A_Q_Q1);
    end
endmodule