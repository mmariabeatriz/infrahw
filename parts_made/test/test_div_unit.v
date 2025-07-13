module test_div_unit;

    // Sinais de entrada
    reg [31:0] RegAOut;
    reg [31:0] RegBOut;
    reg clk;
    reg reset;
    reg DivCtrl;
    
    // Sinais de saída
    wire DivDone;
    wire Div0;
    wire [31:0] HI;
    wire [31:0] LO;
    
    // Instanciação da unidade de divisão
    div div_unit(
        .RegAOut(RegAOut),
        .RegBOut(RegBOut),
        .clk(clk),
        .reset(reset),
        .DivCtrl(DivCtrl),
        .DivDone(DivDone),
        .Div0(Div0),
        .HI(HI),
        .LO(LO)
    );
    
    // Geração do clock
    always #5 clk = ~clk;
    
    initial begin
        // Inicialização
        clk = 0;
        reset = 1;
        DivCtrl = 0;
        RegAOut = 0;
        RegBOut = 0;
        
        // Aguardar alguns ciclos
        #10;
        reset = 0;
        #10;
        
        $display("=== TESTE DA UNIDADE DE DIVISÃO ===");
        
        // Teste 1: Divisão simples positiva (10 / 3)
        $display("\nTeste 1: 10 / 3");
        RegAOut = 32'd10;
        RegBOut = 32'd3;
        DivCtrl = 1;
        
        // Aguardar conclusão
        wait(DivDone);
        $display("Resultado: LO (quociente) = %d, HI (resto) = %d", LO, HI);
        $display("Esperado: LO = 3, HI = 1");
        
        DivCtrl = 0;
        #10;
        
        // Teste 2: Divisão por zero
        $display("\nTeste 2: Divisão por zero (5 / 0)");
        RegAOut = 32'd5;
        RegBOut = 32'd0;
        DivCtrl = 1;
        
        // Aguardar sinal de erro
        wait(Div0);
        $display("Div0 ativado: %b", Div0);
        $display("HI = %h, LO = %h (deve ser FFFFFFFF)", HI, LO);
        
        DivCtrl = 0;
        #10;
        
        // Teste 3: Divisão com dividendo negativo (-10 / 3)
        $display("\nTeste 3: -10 / 3");
        RegAOut = 32'hFFFFFFF6; // -10 em complemento de 2
        RegBOut = 32'd3;
        DivCtrl = 1;
        
        wait(DivDone);
        $display("Resultado: LO (quociente) = %d, HI (resto) = %d", $signed(LO), $signed(HI));
        $display("Esperado: LO = -3, HI = -1");
        
        DivCtrl = 0;
        #10;
        
        // Teste 4: Divisão com divisor negativo (10 / -3)
        $display("\nTeste 4: 10 / -3");
        RegAOut = 32'd10;
        RegBOut = 32'hFFFFFFFD; // -3 em complemento de 2
        DivCtrl = 1;
        
        wait(DivDone);
        $display("Resultado: LO (quociente) = %d, HI (resto) = %d", $signed(LO), $signed(HI));
        $display("Esperado: LO = -3, HI = 1");
        
        DivCtrl = 0;
        #10;
        
        // Teste 5: Divisão com ambos negativos (-10 / -3)
        $display("\nTeste 5: -10 / -3");
        RegAOut = 32'hFFFFFFF6; // -10 em complemento de 2
        RegBOut = 32'hFFFFFFFD; // -3 em complemento de 2
        DivCtrl = 1;
        
        wait(DivDone);
        $display("Resultado: LO (quociente) = %d, HI (resto) = %d", $signed(LO), $signed(HI));
        $display("Esperado: LO = 3, HI = -1");
        
        DivCtrl = 0;
        #10;
        
        // Teste 6: Divisão exata (12 / 4)
        $display("\nTeste 6: 12 / 4 (divisão exata)");
        RegAOut = 32'd12;
        RegBOut = 32'd4;
        DivCtrl = 1;
        
        wait(DivDone);
        $display("Resultado: LO (quociente) = %d, HI (resto) = %d", LO, HI);
        $display("Esperado: LO = 3, HI = 0");
        
        DivCtrl = 0;
        #10;
        
        $display("\n=== TESTE CONCLUÍDO ===");
        $finish;
    end
    
    // Monitor para acompanhar mudanças
    initial begin
        $monitor("Tempo: %0t | DivCtrl: %b | DivDone: %b | Div0: %b | A: %h | B: %h | LO: %h | HI: %h", 
                 $time, DivCtrl, DivDone, Div0, RegAOut, RegBOut, LO, HI);
    end
    
endmodule