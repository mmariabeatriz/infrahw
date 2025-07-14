// Testbench específico para debug do módulo DIV
`timescale 1ns/1ps

module debug_div;
    reg clk, reset;
    reg [31:0] div_a, div_b;
    reg div_ctrl;
    wire div_done, div_zero;
    wire [31:0] div_hi, div_lo;
    
    // Instanciação do módulo div
    div uut (
        .RegAOut(div_a),
        .RegBOut(div_b),
        .clk(clk),
        .reset(reset),
        .DivCtrl(div_ctrl),
        .DivDone(div_done),
        .Div0(div_zero),
        .HI(div_hi),
        .LO(div_lo)
    );
    
    // Clock
    always #5 clk = ~clk;
    
    initial begin
        $dumpfile("debug_div.vcd");
        $dumpvars(0, debug_div);
        
        // Inicialização
        clk = 0;
        reset = 1;
        div_ctrl = 0;
        div_a = 0;
        div_b = 0;
        
        #20 reset = 0;
        
        // Teste específico: 23 / 7
        $display("=== Debug: 23 / 7 ===");
        #10;
        div_a = 32'd23;
        div_b = 32'd7;
        div_ctrl = 1;
        
        // Monitor interno
        $monitor("Tempo=%0t, dividend=%d, divisor=%d, quotient=%d, remainder=%d, div_active=%b, init_done=%b, div_done=%b", 
                 $time, uut.dividend, uut.divisor, uut.quotient, uut.remainder, uut.div_active, uut.init_done, div_done);
        
        wait(div_done);
        $display("\nResultado Final: LO=%d (quociente), HI=%d (resto)", div_lo, div_hi);
        $display("Esperado: LO=3, HI=2");
        
        #50;
        $finish;
    end
    
endmodule