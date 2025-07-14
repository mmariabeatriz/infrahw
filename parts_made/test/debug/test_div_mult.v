// Testbench para validação dos módulos DIV e MULT
// Testa operações básicas de divisão e multiplicação

`timescale 1ns/1ps

module test_div_mult;
    // Sinais de clock e reset
    reg clk;
    reg reset;
    
    // Sinais para DIV
    reg [31:0] div_a, div_b;
    reg div_ctrl;
    wire div_done, div_zero;
    wire [31:0] div_hi, div_lo;
    
    // Sinais para MULT
    reg [31:0] mult_a, mult_b;
    reg mult_ctrl;
    wire mult_done;
    wire [31:0] mult_hi, mult_lo;
    
    // Instanciação dos módulos
    div uut_div (
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
    
    mult uut_mult (
        .A(mult_a),
        .B(mult_b),
        .clk(clk),
        .mult_ctrl(mult_ctrl),
        .stop(mult_done),
        .HI(mult_hi),
        .LO(mult_lo)
    );
    
    // Geração do clock
    always #5 clk = ~clk;
    
    // Processo de teste
    initial begin
        $dumpfile("test_div_mult.vcd");
        $dumpvars(0, test_div_mult);
        
        // Inicialização
        clk = 0;
        reset = 1;
        div_ctrl = 0;
        mult_ctrl = 0;
        div_a = 0;
        div_b = 0;
        mult_a = 0;
        mult_b = 0;
        
        // Reset
        #20 reset = 0;
        
        $display("=== Iniciando Testes DIV e MULT ===");
        
        // Teste 1: Divisão simples (20 / 4 = 5, resto 0)
        $display("\nTeste 1: DIV 20 / 4");
        #10;
        div_a = 32'd20;
        div_b = 32'd4;
        div_ctrl = 1;
        
        wait(div_done);
        $display("Resultado: LO=%d (quociente), HI=%d (resto)", div_lo, div_hi);
        $display("Esperado: LO=5, HI=0");
        
        div_ctrl = 0;
        #10;
        
        // Teste 2: Divisão com resto (23 / 7 = 3, resto 2)
        $display("\nTeste 2: DIV 23 / 7");
        #10;
        div_a = 32'd23;
        div_b = 32'd7;
        div_ctrl = 1;
        
        // Monitor interno durante a divisão
        $display("Monitorando valores internos:");
        $monitor("dividend=%d, divisor=%d, quotient=%d, remainder=%d, div_active=%b", 
                 uut_div.dividend, uut_div.divisor, uut_div.quotient, uut_div.remainder, uut_div.div_active);
        
        wait(div_done);
        $display("Resultado: LO=%d (quociente), HI=%d (resto)", div_lo, div_hi);
        $display("Esperado: LO=3, HI=2");
        
        $monitor; // Desabilita monitor
        div_ctrl = 0;
        #20;
        
        // Teste 3: Divisão por zero
        $display("\nTeste 3: DIV 10 / 0 (divisão por zero)");
        div_a = 32'd10;
        div_b = 32'd0;
        div_ctrl = 1;
        
        wait(div_done);
        $display("Div0 flag: %b", div_zero);
        $display("Esperado: Div0=1");
        
        div_ctrl = 0;
        #10;
        
        // Teste 4: Multiplicação simples (6 * 7 = 42)
        $display("\nTeste 4: MULT 6 * 7");
        mult_a = 32'd6;
        mult_b = 32'd7;
        mult_ctrl = 1;
        
        wait(mult_done);
        $display("Resultado: HI=%d, LO=%d", mult_hi, mult_lo);
        $display("Esperado: HI=0, LO=42");
        mult_ctrl = 0;
        #20;
        
        // Teste 5: Multiplicação com números negativos (-5 * 3 = -15)
        $display("\nTeste 5: MULT -5 * 3");
        mult_a = 32'hFFFFFFFB; // -5 em complemento de 2
        mult_b = 32'd3;
        mult_ctrl = 1;
        
        wait(mult_done);
        $display("Resultado: HI=%d, LO=%d", $signed(mult_hi), $signed(mult_lo));
        $display("Esperado: HI=-1, LO=-15");
        
        mult_ctrl = 0;
        #20;
        
        // Teste 6: Multiplicação grande (65536 * 65536)
        $display("\nTeste 6: MULT 65536 * 65536");
        mult_a = 32'd65536;
        mult_b = 32'd65536;
        mult_ctrl = 1;
        
        wait(mult_done);
        $display("Resultado: HI=%d, LO=%d", mult_hi, mult_lo);
        $display("Esperado: HI=1, LO=0 (4294967296 = 2^32)");
        
        mult_ctrl = 0;
        #10;
        
        $display("\n=== Testes Concluídos ===");
        $finish;
    end
    
    // Monitor para timeout
    initial begin
        #50000; // 50us timeout
        $display("ERRO: Timeout nos testes!");
        $finish;
    end
    
endmodule