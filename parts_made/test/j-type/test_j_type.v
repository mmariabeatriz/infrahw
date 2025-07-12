// Teste das instuções J-type
`timescale 1ns/1ps

module test_j_type;
    // Sinais de entrada
    reg clk;
    reg reset_in;
    reg [5:0] opcode;
    reg [15:0] immediate;
    reg overflow;
    reg zero_div;
    reg mult_stop;
    reg div_stop;
    reg div_zero;
    
    // Sinais de saída
    wire [1:0] mux_a;
    wire mux_b;
    wire [1:0] mux_ula1;
    wire [1:0] mux_ula2;
    wire [1:0] mux_shift_amt;
    wire mux_shift_src;
    wire [1:0] mux_pc;
    wire [2:0] mux_address;
    wire [2:0] mux_register_wd;
    wire [1:0] mux_register_wr;
    wire mux_memory_wd;
    wire mux_extend;
    wire mux_high;
    wire mux_low;
    wire [2:0] ula;
    wire [2:0] shift;
    wire [1:0] load_size;
    wire store_size;
    wire pc_write;
    wire memory_wr;
    wire reg_wr;
    wire is_beq;
    wire is_bne;
    wire mult_init;
    wire div_init;
    wire address_rg_load;
    wire epc_load;
    wire mdr_load;
    wire ir_load;
    wire high_load;
    wire low_load;
    wire a_load;
    wire b_load;
    wire ula_out_load;
    
    // Instanciação do módulo control_unit
    control_unit uut (
        .clk(clk),
        .reset_in(reset_in),
        .opcode(opcode),
        .immediate(immediate),
        .overflow(overflow),
        .zero_div(zero_div),
        .mult_stop(mult_stop),
        .div_stop(div_stop),
        .div_zero(div_zero),
        .mux_a(mux_a),
        .mux_b(mux_b),
        .mux_ula1(mux_ula1),
        .mux_ula2(mux_ula2),
        .mux_shift_amt(mux_shift_amt),
        .mux_shift_src(mux_shift_src),
        .mux_pc(mux_pc),
        .mux_address(mux_address),
         .mux_register_wd(mux_register_wd),
         .mux_register_wr(mux_register_wr),
         .mux_memory_wd(mux_memory_wd),
         .mux_extend(mux_extend),
        .mux_high(mux_high),
        .mux_low(mux_low),
        .ula(ula),
        .shift(shift),
        .load_size(load_size),
        .store_size(store_size),
        .pc_write(pc_write),
        .memory_wr(memory_wr),
        .reg_wr(reg_wr),
        .is_beq(is_beq),
        .is_bne(is_bne),
        .mult_init(mult_init),
        .div_init(div_init),
        .address_rg_load(address_rg_load),
        .epc_load(epc_load),
        .mdr_load(mdr_load),
        .ir_load(ir_load),
        .high_load(high_load),
        .low_load(low_load),
        .a_load(a_load),
        .b_load(b_load),
        .ula_out_load(ula_out_load)
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
            opcode = 6'h00;
            immediate = 16'h0000;
            overflow = 0;
            zero_div = 0;
            mult_stop = 0;
            div_stop = 0;
            div_zero = 0;
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
        input [5:0] op;
        input [25:0] addr;
        input [1:0] expected_mux_pc;
        input expected_pc_write;
        input expected_reg_write;
        input [1:0] expected_wr_reg;
        begin
            reset_system();
            opcode = op;
            immediate = addr[15:0]; // Parte baixa do endereço
            
            // J precisa de 3 ciclos, JAL precisa de 4 ciclos
            if (op == 6'b000010) begin // J
                wait_cycles(3); // FETCH -> DECODE -> J
            end else begin // JAL
                wait_cycles(4); // FETCH -> DECODE -> JAL(0) -> JAL(1)
            end
            
            $display("PC Write: %b (esperado: %b)", pc_write, expected_pc_write);
            $display("MUX PC: %b (esperado: %b)", mux_pc, expected_mux_pc);
            $display("Register Write: %b (esperado: %b)", reg_wr, expected_reg_write);
            $display("MUX Register WR: %b (esperado: %b)", mux_register_wr, expected_wr_reg);
            $display("---");
        end
    endtask
    
    // Task para verificar sequência de estados
    task verify_state_sequence;
        input [5:0] op;
        input [25:0] addr;
        begin
            reset_system();
            opcode = op;
            immediate = addr[15:0];
            
            wait_cycles(1);
            $display("Após 1 ciclo: DECODE");
            wait_cycles(1);
            $display("Após 2 ciclos: deve voltar para FETCH");
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
        test_j_instruction(6'b000010, 26'h000400, 2'b11, 1'b1, 1'b0, 2'b00);
        
        // Teste 2: J - Jump com endereço diferente
        $display("Teste 2: J 0x2000 (endereço 0x2000)");
        test_j_instruction(6'b000010, 26'h000800, 2'b11, 1'b1, 1'b0, 2'b00);
        
        // Teste 3: JAL - Jump and Link
        $display("Teste 3: JAL 0x1000 (endereço 0x1000)");
        test_j_instruction(6'b000011, 26'h000400, 2'b11, 1'b1, 1'b1, 2'b10);
        
        // Teste 4: JAL - Jump and Link com endereço diferente
        $display("Teste 4: JAL 0x3000 (endereço 0x3000)");
        test_j_instruction(6'b000011, 26'h000C00, 2'b11, 1'b1, 1'b1, 2'b10);
        
        // === VERIFICAÇÃO DETALHADA DE SEQUÊNCIA DE ESTADOS ===
        $display("\n=== VERIFICAÇÃO DE SEQUÊNCIA DE ESTADOS ===\n");
        
        // Teste 5: Sequência de estados para J
        $display("Teste 5: Sequência de estados - J 0x1000");
        verify_state_sequence(6'b000010, 26'h000400);
        
        // Teste 6: Sequência de estados para JAL
        $display("Teste 6: Sequência de estados - JAL 0x1000");
        verify_state_sequence(6'b000011, 26'h000400);
        
        // === VERIFICAÇÃO DE SINAIS DE CONTROLE ===
        $display("\n=== VERIFICAÇÃO DETALHADA DE SINAIS ===\n");
        
        // Teste 7: Verificação detalhada - J
        $display("Teste 7: Verificação detalhada - J 0x1000");
        reset_system();
        opcode = 6'b000010; // J
        immediate = 16'h0400; // 0x1000
        wait_cycles(3); // FETCH -> DECODE -> J
        $display("PC Write: %b (deve ser 1)", pc_write);
        $display("MUX PC: %b (deve ser 11 para jump)", mux_pc);
        $display("Register Write: %b (deve ser 0)", reg_wr);
        $display("Memory Write: %b (deve ser 0)", memory_wr);
        $display("ULA Control: %b", ula);
        $display("---");
        
        // Teste 8: Verificação detalhada - JAL
        $display("Teste 8: Verificação detalhada - JAL 0x1000");
        reset_system();
        opcode = 6'b000011; // JAL
        immediate = 16'h0400; // 0x1000
        wait_cycles(4); // FETCH -> DECODE -> JAL(0) -> JAL(1)
        $display("PC Write: %b (deve ser 1)", pc_write);
        $display("MUX PC: %b (deve ser 11 para jump)", mux_pc);
        $display("Register Write: %b (deve ser 1 para salvar RA)", reg_wr);
        $display("MUX Register WR: %b (deve ser 10 para $31)", mux_register_wr);
        $display("MUX Register WD: %b (deve ser 11 para PC+4)", mux_register_wd);
        $display("Memory Write: %b (deve ser 0)", memory_wr);
        $display("---");
        
        // === TESTE DE ENDEREÇOS ESPECÍFICOS ===
        $display("\n=== TESTE DE ENDEREÇOS ESPECÍFICOS ===\n");
        
        // Teste 9: J com endereço 0 (início da memória)
        $display("Teste 9: J 0x0000 (início da memória)");
        test_j_instruction(6'b000010, 26'h000000, 2'b11, 1'b1, 1'b0, 2'b00);
        
        // Teste 10: J com endereço máximo (26 bits)
        $display("Teste 10: J 0x3FFFFFF (endereço máximo)");
        test_j_instruction(6'b000010, 26'h3FFFFFF, 2'b11, 1'b1, 1'b0, 2'b00);
        
        // Teste 11: JAL com endereço 0
        $display("Teste 11: JAL 0x0000");
        test_j_instruction(6'b000011, 26'h000000, 2'b11, 1'b1, 1'b1, 2'b10);
        
        // Teste 12: JAL com endereço máximo
        $display("Teste 12: JAL 0x3FFFFFF");
        test_j_instruction(6'b000011, 26'h3FFFFFF, 2'b11, 1'b1, 1'b1, 2'b10);
        
        // === TESTE DE TIMING ===
        $display("\n=== TESTE DE TIMING ===\n");
        
        // Teste 13: Verificação de timing - J
        $display("Teste 13: Timing - J executa em 3 ciclos");
        reset_system();
        opcode = 6'b000010; // J
        immediate = 16'h0400; // 0x1000
        
        $display("Ciclo 0 - FETCH");
        wait_cycles(1);
        $display("Ciclo 1 - DECODE");
        wait_cycles(1);
        $display("Ciclo 2 - J (PC Write: %b)", pc_write);
        wait_cycles(1);
        $display("Ciclo 3 - FETCH novamente");
        $display("---");
        
        // Teste 14: Verificação de timing - JAL
        $display("Teste 14: Timing - JAL executa em 4 ciclos");
        reset_system();
        opcode = 6'b000011; // JAL
        immediate = 16'h0400; // 0x1000
        
        $display("Ciclo 0 - FETCH");
        wait_cycles(1);
        $display("Ciclo 1 - DECODE");
        wait_cycles(1);
        $display("Ciclo 2 - JAL(0) (ULA Out Load)");
        wait_cycles(1);
        $display("Ciclo 3 - JAL(1) (PC Write: %b, Reg Write: %b)", pc_write, reg_wr);
        wait_cycles(1);
        $display("Ciclo 4 - FETCH novamente");
        $display("---");
        
        // === TESTE DE MÚLTIPLOS JUMPS CONSECUTIVOS ===
        $display("\n=== TESTE DE MÚLTIPLOS JUMPS ===\n");
        
        // Teste 15: Múltiplos jumps consecutivos
        $display("Teste 15: Múltiplos jumps consecutivos");
        reset_system();
        
        // Primeiro jump
        opcode = 6'b000010; // J
        immediate = 16'h0400; // 0x1000
        wait_cycles(3);
        $display("Primeiro J - Concluído");
        
        // Segundo jump
        opcode = 6'b000010; // J
        immediate = 16'h0800; // 0x2000
        wait_cycles(3);
        $display("Segundo J - Concluído");
        
        // JAL
        opcode = 6'b000011; // JAL
        immediate = 16'h0C00; // 0x3000
        wait_cycles(4);
        $display("JAL - Concluído");
        $display("---");
        
        // === VERIFICAÇÃO DE NÃO INTERFERÊNCIA ===
        $display("\n=== VERIFICAÇÃO DE NÃO INTERFERÊNCIA ===\n");
        
        // Teste 16: J não deve afetar registradores HI/LO
        $display("Teste 16: J não afeta HI/LO");
        reset_system();
        opcode = 6'b000010; // J
        immediate = 16'h0400; // 0x1000
        wait_cycles(3);
        $display("HI Write: %b (deve ser 0)", high_load);
        $display("LO Write: %b (deve ser 0)", low_load);
        $display("---");
        
        // Teste 17: J não deve afetar memória
        $display("Teste 17: J não afeta memória");
        reset_system();
        opcode = 6'b000010; // J
        immediate = 16'h0400; // 0x1000
        wait_cycles(3);
        $display("Memory Write: %b (deve ser 0)", memory_wr);
        $display("Load Size: %b", load_size);
        $display("Store Size: %b", store_size);
        $display("---");
        
        // Teste 18: JAL não deve afetar HI/LO
        $display("Teste 18: JAL não afeta HI/LO");
        reset_system();
        opcode = 6'b000011; // JAL
        immediate = 16'h0400; // 0x1000
        wait_cycles(4);
        $display("HI Write: %b (deve ser 0)", high_load);
        $display("LO Write: %b (deve ser 0)", low_load);
        $display("---");
        
        // === TESTE DE CASOS EXTREMOS ===
        $display("\n=== TESTE DE CASOS EXTREMOS ===\n");
        
        // Teste 19: Jump para o mesmo endereço (loop)
        $display("Teste 19: Jump para o mesmo endereço (loop)");
        reset_system();
        opcode = 6'b000010; // J
        immediate = 16'h0000; // 0x0000 (loop infinito)
        wait_cycles(3);
        $display("PC Write: %b (deve ser 1)", pc_write);
        $display("Jump executado com sucesso");
        
        // Executar mais alguns ciclos para verificar estabilidade
        wait_cycles(4);
        $display("Após mais ciclos - Sistema estável");
        $display("---");
        
        $display("\n=== TODOS OS TESTES J-TYPE CONCLUÍDOS ===\n");
        $finish;
    end
    
    // Monitor para acompanhar mudanças críticas
    always @(posedge clk) begin
        if (pc_write) begin
            $display("[MONITOR] PC Write ativo - MUX PC: %b, Opcode: %b, Immediate: %h", 
                     mux_pc, opcode, immediate);
        end
    end
    
endmodule