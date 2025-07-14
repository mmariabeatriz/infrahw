`timescale 1ns / 1ps

module debug_mult_neg;
    reg clk, reset;
    reg [31:0] RegAOut, RegBOut;
    reg MultCtrl;
    wire [31:0] HI, LO;
    wire MultDone;
    
    // Instanciar o módulo mult
    mult uut_mult (
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
        clk = 0;
        reset = 1;
        MultCtrl = 0;
        RegAOut = 0;
        RegBOut = 0;
        
        #10 reset = 0;
        
        // Teste: -5 * 3
        $display("=== Teste: -5 * 3 ===");
        RegAOut = 32'hFFFFFFFB;  // -5 em complemento de 2
        RegBOut = 32'd3;         // 3
        
        $display("RegAOut = %h (%d)", RegAOut, $signed(RegAOut));
        $display("RegBOut = %h (%d)", RegBOut, $signed(RegBOut));
        $display("sign_result = %b", uut_mult.sign_result);
        $display("multiplicand = %d", uut_mult.multiplicand);
        $display("multiplier = %d", uut_mult.multiplier);
        
        MultCtrl = 1;
        wait(MultDone);
        
        $display("Resultado: HI=%d, LO=%d", $signed(HI), $signed(LO));
        $display("Esperado: HI=-1, LO=-15");
        
        $finish;
    end
endmodule