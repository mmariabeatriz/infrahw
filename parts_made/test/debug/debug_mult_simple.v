`timescale 1ns / 1ps

module debug_mult_simple;
    reg clk;
    reg [31:0] A, B;
    reg mult_ctrl;
    wire [31:0] HI, LO;
    wire stop;
    
    // Instanciação do módulo mult
    mult uut (
        .clk(clk),
        .A(A),
        .B(B),
        .mult_ctrl(mult_ctrl),
        .HI(HI),
        .LO(LO),
        .stop(stop)
    );
    
    // Geração do clock
    always #5 clk = ~clk;
    
    // Monitor para depuração
    always @(posedge clk) begin
        $display("Time=%0t: mult_ctrl=%b, stop=%b, HI=%d, LO=%d", $time, mult_ctrl, stop, HI, LO);
    end
    
    initial begin
        clk = 0;
        mult_ctrl = 0;
        A = 0;
        B = 0;
        
        #10;
        
        // Teste simples: 6 * 7
        $display("\nIniciando teste: 6 * 7");
        A = 32'd6;
        B = 32'd7;
        mult_ctrl = 1;
        
        // Aguardar por no máximo 1000 ciclos
        fork
            begin
                repeat(1000) @(posedge clk);
                $display("\nERRO: Timeout - multiplicação não concluída!");
            end
            begin
                wait(stop);
                $display("\nMultiplicação concluída!");
                $display("Resultado: HI=%d, LO=%d", HI, LO);
                $display("Esperado: HI=0, LO=42");
            end
        join_any
        disable fork;
        
        mult_ctrl = 0;
        #20;
        
        $finish;
    end
    
endmodule