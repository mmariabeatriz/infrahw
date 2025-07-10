// Teste das instuções J-type
`timescale 1ns/1ps

module test_j_type;
    // Sinais de entrada
    reg clk;
    reg reset_in;
    reg [31:0] instruction;
    reg zero_flag;
    reg overflow_flag;
    reg div_zero;
    reg mult_done;
    reg div_done;
    
    // Sinais de saída
    wire [1:0] mux_a;
    wire [1:0] mux_b;
    wire [1:0] mux_alu_1;
    wire [1:0] mux_alu_2;
    wire mux_shift_amt;
    wire mux_shift_src;
    wire [1:0] mux_pc;
    wire mux_address;
    wire [1:0] mux_wd_memory;
    wire [1:0] mux_wd_registers;
    wire [1:0] mux_wr_registers;
    wire mux_extend;
    wire mux_high;
    wire mux_low;
    wire [3:0] alu_control;
    wire [1:0] shift_control;
    wire [1:0] load_size_control;
    wire [1:0] store_size_control;
    wire pc_write_enable;
    wire instruction_write;
    wire memory_write;
    wire register_write;
    wire hi_write;
    wire lo_write;
    wire [1:0] exception_control;
    wire [2:0] current_state;
    wire [3:0] counter;
    
    // Instanciação do módulo control_unit
    control_unit uut (
        .clk(clk),
        .reset_in(reset_in),
        .instruction(instruction),
        .zero_flag(zero_flag),
        .overflow_flag(overflow_flag),
        .div_zero(div_zero),
        .mult_done(mult_done),
        .div_done(div_done),
        .mux_a(mux_a),
        .mux_b(mux_b),
        .mux_alu_1(mux_alu_1),
        .mux_alu_2(mux_alu_2),
        .mux_shift_amt(mux_shift_amt),
        .mux_shift_src(mux_shift_src),
        .mux_pc(mux_pc),
        .mux_address(mux_address),
        .mux_wd_memory(mux_wd_memory),
        .mux_wd_registers(mux_wd_registers),
        .mux_wr_registers(mux_wr_registers),
        .mux_extend(mux_extend),
        .mux_high(mux_high),
        .mux_low(mux_low),
        .alu_control(alu_control),
        .shift_control(shift_control),
        .load_size_control(load_size_control),
        .store_size_control(store_size_control),
        .pc_write_enable(pc_write_enable),
        .instruction_write(instruction_write),
        .memory_write(memory_write),
        .register_write(register_write),
        .hi_write(hi_write),
        .lo_write(lo_write),
        .exception_control(exception_control),
        .current_state(current_state),
        .counter(counter)
    );
    
    // Clock
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    
    // Task para reset do sistema
    task reset_system;
        begin
            reset_in = 1;
            instruction = 32'h00000000;
            zero_flag = 0;
            overflow_flag = 0;
            div_zero = 0;
            mult_done = 0;
            div_done = 0;
            #20;
            reset_in = 0;
            #10;
        end
    endtask
    
    // Task para aguardar ciclos
    task wait_cycles;
        input integer cycles;
        begin
            repeat(cycles) @(posedge clk);
        end
    endtask
    
    // Task para testar instrução J-type
    task test_j_instruction;
        input [31:0] instr;
        input [1:0] expected_mux_pc;
        input expected_pc_write;
        input expected_reg_write;
        input [1:0] expected_wr_reg;
        begin
            reset_system();
            instruction = instr;
            wait_cycles(2); // FETCH -> DECODE (J-type executa no DECODE)
            
            $display("PC Write Enable: %b (esperado: %b)", pc_write_enable, expected_pc_write);
            $display("MUX PC: %b (esperado: %b)", mux_pc, expected_mux_pc);
            $display("Register Write: %b (esperado: %b)", register_write, expected_reg_write);
            $display("MUX WR Registers: %b (esperado: %b)", mux_wr_registers, expected_wr_reg);
            $display("Estado: %d (deve voltar para FETCH)", current_state);
            $display("---");
        end
    endtask
    
    // Task para verificar sequência de estados
    task verify_state_sequence;
        input [31:0] instr;
        begin
            reset_system();
            instruction = instr;
            
            $display("Estado inicial: %d (FETCH)", current_state);
            wait_cycles(1);
            $display("Após 1 ciclo: %d (DECODE)", current_state);
            wait_cycles(1);
            $display("Após 2 ciclos: %d (deve voltar para FETCH)", current_state);
            $display("---");
        end
    endtask
    
    // Configuração para dump VCD
    initial begin
        $dumpfile("test_j_type.vcd");
        $dumpvars(0, test_j_type);
    end
    
    // Testes principais
    initial begin
        $display("=== TESTE DAS INSTRUÇÕES J-TYPE ===\n");
        
        // !!! INSTRUÇÕES DE JUMP BÁSICAS !!!
        $display("=== INSTRUÇÕES DE JUMP BÁSICAS ===\n");
        
        // Teste 1: J - Jump
        $display("Teste 1: J 0x1000 (endereço 0x1000)");
        test_j_instruction(32'h08000400, 2'b10, 1'b1, 1'b0, 2'b00);
        
        // Teste 2: J - Jump com endereço diferente
        $display("Teste 2: J 0x2000 (endereço 0x2000)");
        test_j_instruction(32'h08000800, 2'b10, 1'b1, 1'b0, 2'b00);
        
        // Teste 3: JAL - Jump and Link
        $display("Teste 3: JAL 0x1000 (endereço 0x1000)");
        test_j_instruction(32'h0C000400, 2'b10, 1'b1, 1'b1, 2'b10);
        
        // Teste 4: JAL - Jump and Link com endereço diferente
        $display("Teste 4: JAL 0x3000 (endereço 0x3000)");
        test_j_instruction(32'h0C000C00, 2'b10, 1'b1, 1'b1, 2'b10);
        
        // === VERIFICAÇÃO DETALHADA DE SEQUÊNCIA DE ESTADOS ===
        $display("\n=== VERIFICAÇÃO DE SEQUÊNCIA DE ESTADOS ===\n");
        
        // Teste 5: Sequência de estados para J
        $display("Teste 5: Sequência de estados - J 0x1000");
        verify_state_sequence(32'h08000400);
        
        // Teste 6: Sequência de estados para JAL
        $display("Teste 6: Sequência de estados - JAL 0x1000");
        verify_state_sequence(32'h0C000400);
        
        // === VERIFICAÇÃO DE SINAIS DE CONTROLE ===
        $display("\n=== VERIFICAÇÃO DETALHADA DE SINAIS ===\n");
        
        // Teste 7: Verificação detalhada - J
        $display("Teste 7: Verificação detalhada - J 0x1000");
        reset_system();
        instruction = 32'h08000400; // J 0x1000
        wait_cycles(2); // FETCH -> DECODE
        $display("PC Write Enable: %b (deve ser 1)", pc_write_enable);
        $display("MUX PC: %b (deve ser 10 para jump)", mux_pc);
        $display("Register Write: %b (deve ser 0)", register_write);
        $display("Memory Write: %b (deve ser 0)", memory_write);
        $display("Instruction Write: %b", instruction_write);
        $display("ALU Control: %b", alu_control);
        $display("Exception Control: %b", exception_control);
        $display("---");
        
        // Teste 8: Verificação detalhada - JAL
        $display("Teste 8: Verificação detalhada - JAL 0x1000");
        reset_system();
        instruction = 32'h0C000400; // JAL 0x1000
        wait_cycles(2); // FETCH -> DECODE
        $display("PC Write Enable: %b (deve ser 1)", pc_write_enable);
        $display("MUX PC: %b (deve ser 10 para jump)", mux_pc);
        $display("Register Write: %b (deve ser 1 para salvar RA)", register_write);
        $display("MUX WR Registers: %b (deve ser 10 para $31)", mux_wr_registers);
        $display("MUX WD Registers: %b (deve ser 11 para PC+4)", mux_wd_registers);
        $display("Memory Write: %b (deve ser 0)", memory_write);
        $display("---");
        
        // === TESTE DE ENDEREÇOS ESPECÍFICOS ===
        $display("\n=== TESTE DE ENDEREÇOS ESPECÍFICOS ===\n");
        
        // Teste 9: J com endereço 0 (início da memória)
        $display("Teste 9: J 0x0000 (início da memória)");
        test_j_instruction(32'h08000000, 2'b10, 1'b1, 1'b0, 2'b00);
        
        // Teste 10: J com endereço máximo (26 bits)
        $display("Teste 10: J 0x3FFFFFF (endereço máximo)");
        test_j_instruction(32'h0BFFFFFF, 2'b10, 1'b1, 1'b0, 2'b00);
        
        // Teste 11: JAL com endereço 0
        $display("Teste 11: JAL 0x0000");
        test_j_instruction(32'h0C000000, 2'b10, 1'b1, 1'b1, 2'b10);
        
        // Teste 12: JAL com endereço máximo
        $display("Teste 12: JAL 0x3FFFFFF");
        test_j_instruction(32'h0FFFFFFF, 2'b10, 1'b1, 1'b1, 2'b10);
        
        // === TESTE DE TIMING ===
        $display("\n=== TESTE DE TIMING ===\n");
        
        // Teste 13: Verificação de timing - J
        $display("Teste 13: Timing - J executa em 2 ciclos");
        reset_system();
        instruction = 32'h08000400; // J 0x1000
        
        $display("Ciclo 0 - Estado: %d (FETCH)", current_state);
        wait_cycles(1);
        $display("Ciclo 1 - Estado: %d (DECODE)", current_state);
        $display("Ciclo 1 - PC Write: %b", pc_write_enable);
        wait_cycles(1);
        $display("Ciclo 2 - Estado: %d (FETCH novamente)", current_state);
        $display("---");
        
        // Teste 14: Verificação de timing - JAL
        $display("Teste 14: Timing - JAL executa em 2 ciclos");
        reset_system();
        instruction = 32'h0C000400; // JAL 0x1000
        
        $display("Ciclo 0 - Estado: %d (FETCH)", current_state);
        wait_cycles(1);
        $display("Ciclo 1 - Estado: %d (DECODE)", current_state);
        $display("Ciclo 1 - PC Write: %b, Reg Write: %b", pc_write_enable, register_write);
        wait_cycles(1);
        $display("Ciclo 2 - Estado: %d (FETCH novamente)", current_state);
        $display("---");
        
        // === TESTE DE MÚLTIPLOS JUMPS CONSECUTIVOS ===
        $display("\n=== TESTE DE MÚLTIPLOS JUMPS ===\n");
        
        // Teste 15: Múltiplos jumps consecutivos
        $display("Teste 15: Múltiplos jumps consecutivos");
        reset_system();
        
        // Primeiro jump
        instruction = 32'h08000400; // J 0x1000
        wait_cycles(2);
        $display("Primeiro J - Estado: %d", current_state);
        
        // Segundo jump
        instruction = 32'h08000800; // J 0x2000
        wait_cycles(2);
        $display("Segundo J - Estado: %d", current_state);
        
        // JAL
        instruction = 32'h0C000C00; // JAL 0x3000
        wait_cycles(2);
        $display("JAL - Estado: %d", current_state);
        $display("---");
        
        // === VERIFICAÇÃO DE NÃO INTERFERÊNCIA ===
        $display("\n=== VERIFICAÇÃO DE NÃO INTERFERÊNCIA ===\n");
        
        // Teste 16: J não deve afetar registradores HI/LO
        $display("Teste 16: J não afeta HI/LO");
        reset_system();
        instruction = 32'h08000400; // J 0x1000
        wait_cycles(2);
        $display("HI Write: %b (deve ser 0)", hi_write);
        $display("LO Write: %b (deve ser 0)", lo_write);
        $display("---");
        
        // Teste 17: J não deve afetar memória
        $display("Teste 17: J não afeta memória");
        reset_system();
        instruction = 32'h08000400; // J 0x1000
        wait_cycles(2);
        $display("Memory Write: %b (deve ser 0)", memory_write);
        $display("Load Size Control: %b", load_size_control);
        $display("Store Size Control: %b", store_size_control);
        $display("---");
        
        // Teste 18: JAL não deve afetar HI/LO
        $display("Teste 18: JAL não afeta HI/LO");
        reset_system();
        instruction = 32'h0C000400; // JAL 0x1000
        wait_cycles(2);
        $display("HI Write: %b (deve ser 0)", hi_write);
        $display("LO Write: %b (deve ser 0)", lo_write);
        $display("---");
        
        // === TESTE DE CASOS EXTREMOS ===
        $display("\n=== TESTE DE CASOS EXTREMOS ===\n");
        
        // Teste 19: Jump para o mesmo endereço (loop)
        $display("Teste 19: Jump para o mesmo endereço (loop)");
        reset_system();
        instruction = 32'h08000000; // J 0x0000 (loop infinito)
        wait_cycles(2);
        $display("PC Write: %b (deve ser 1)", pc_write_enable);
        $display("Estado: %d (deve ser FETCH)", current_state);
        
        // Executar mais alguns ciclos para verificar estabilidade
        wait_cycles(4);
        $display("Após mais ciclos - Estado: %d", current_state);
        $display("---");
        
        $display("\n=== TODOS OS TESTES J-TYPE CONCLUÍDOS ===\n");
        $finish;
    end
    
    // Monitor para acompanhar mudanças críticas
    always @(posedge clk) begin
        if (pc_write_enable) begin
            $display("[MONITOR] PC Write ativo - MUX PC: %b, Estado: %d, Instrução: %h", 
                     mux_pc, current_state, instruction);
        end
    end
    
endmodule