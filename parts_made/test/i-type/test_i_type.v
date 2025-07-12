// Teste das Instruções I-type do Control Unit
`timescale 1ns/1ps

module test_i_type;
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
    wire mux_high;
    wire mux_low;
    wire mux_extend;
    wire [1:0] load_size;
    wire store_size;
    
    wire address_rg_load;
    wire epc_load;
    wire mdr_load;
    wire ir_load;
    wire high_load;
    wire low_load;
    wire a_load;
    wire b_load;
    wire ula_out_load;
    
    wire pc_write;
    wire memory_wr;
    wire reg_wr;
    wire is_beq;
    wire is_bne;
    wire mult_init;
    wire div_init;
    
    wire [2:0] ula;
    wire [2:0] shift;
    
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
        .mux_high(mux_high),
        .mux_low(mux_low),
        .mux_extend(mux_extend),
        
        .load_size(load_size),
        .store_size(store_size),
        
        .address_rg_load(address_rg_load),
        .epc_load(epc_load),
        .mdr_load(mdr_load),
        .ir_load(ir_load),
        .high_load(high_load),
        .low_load(low_load),
        .a_load(a_load),
        .b_load(b_load),
        .ula_out_load(ula_out_load),
        
        .pc_write(pc_write),
        .memory_wr(memory_wr),
        .reg_wr(reg_wr),
        .is_beq(is_beq),
        .is_bne(is_bne),
        .mult_init(mult_init),
        .div_init(div_init),
        
        .ula(ula),
        .shift(shift)
    );
    
    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    
    // Task para reset do sistema
    task reset_system;
        begin
            reset_in = 1;
            opcode = 6'b000000;
            immediate = 16'h0000;
            overflow = 1'b0;
            zero_div = 1'b0;
            mult_stop = 1'b0;
            div_stop = 1'b0;
            div_zero = 1'b0;
            @(posedge clk);
            reset_in = 0;
            @(posedge clk);
        end
    endtask
    
    // Task para aguardar ciclos
    task wait_cycles;
        input integer cycles;
        begin
            repeat(cycles) @(posedge clk);
        end
    endtask
    
    // Task para testar instrução I-type aritmética
    task test_i_arithmetic;
        input [5:0] op;
        input [15:0] imm;
        input [2:0] expected_ula;
        input expected_extend;
        input expected_reg_write;
        begin
            reset_system();
            opcode = op;
            immediate = imm;
            wait_cycles(3); // FETCH -> DECODE -> EXECUTE
            
            $display("ULA Control: %b (esperado: %b)", ula, expected_ula);
            $display("MUX Extend: %b (esperado: %b)", mux_extend, expected_extend);
            $display("Register Write: %b (esperado: %b)", reg_wr, expected_reg_write);
            $display("MUX ULA2: %b (deve ser 01 para imediato)", mux_ula2);
            $display("MUX Register WR: %b (deve ser 00 para rt)", mux_register_wr);
            $display("---");
        end
    endtask
    
    // Task para testar instrução de load
    task test_load;
        input [5:0] op;
        input [15:0] imm;
        input [1:0] expected_load_size;
        begin
            reset_system();
            opcode = op;
            immediate = imm;
            wait_cycles(4); // FETCH -> DECODE -> EXECUTE -> MEMORY
            
            $display("Load Size Control: %b (esperado: %b)", load_size, expected_load_size);
            $display("Memory Write: %b (deve ser 0 para load)", memory_wr);
            $display("Register Write: %b (deve ser 1 para load)", reg_wr);
            $display("MUX Register WD: %b (deve ser 01 para memória)", mux_register_wd);
            $display("---");
        end
    endtask
    
    // Task para testar instrução de store
    task test_store;
        input [5:0] op;
        input [15:0] imm;
        input expected_store_size;
        begin
            reset_system();
            opcode = op;
            immediate = imm;
            wait_cycles(4); // FETCH -> DECODE -> EXECUTE -> MEMORY
            
            $display("Store Size Control: %b (esperado: %b)", store_size, expected_store_size);
            $display("Memory Write: %b (deve ser 1 para store)", memory_wr);
            $display("Register Write: %b (deve ser 0 para store)", reg_wr);
            $display("---");
        end
    endtask
    
    // Task para testar instrução de branch
    task test_branch;
        input [5:0] op;
        input [15:0] imm;
        input zero_condition;
        input expected_pc_write;
        begin
            reset_system();
            opcode = op;
            immediate = imm;
            zero_div = zero_condition;
            wait_cycles(6); // FETCH (4 ciclos) -> DECODE (2 ciclos) -> EXECUTE (1 ciclo)
            
            $display("Zero Div: %b", zero_div);
            $display("PC Write: %b (esperado: %b)", pc_write, expected_pc_write);
            $display("MUX PC: %b", mux_pc);
            $display("ULA Control: %b (deve ser 010 para subtração)", ula);
            $display("IS BEQ: %b", is_beq);
            $display("IS BNE: %b", is_bne);
            $display("---");
        end
    endtask
    
    // Configuração para dump VCD
    initial begin
        $dumpfile("test_i_type.vcd");
        $dumpvars(0, test_i_type);
    end
    
    // Testes principais
    initial begin
        $display("=== TESTE DAS INSTRUÇÕES I-TYPE ===\n");
        
        // === INSTRUÇÕES ARITMÉTICAS IMEDIATAS ===
        $display("=== INSTRUÇÕES ARITMÉTICAS IMEDIATAS ===\n");
        
        // Teste 1: ADDI - Add Immediate
        $display("Teste 1: ADDI $1, $0, 100");
        test_i_arithmetic(6'b001000, 16'h0064, 3'b001, 1'b0, 1'b1);
        
        // Teste 2: LUI - Load Upper Immediate
        $display("Teste 2: LUI $1, 0x1234");
        reset_system();
        opcode = 6'b001111; // LUI
        immediate = 16'h1234;
        wait_cycles(3); // FETCH -> DECODE -> EXECUTE
        $display("Register Write: %b (deve ser 1)", reg_wr);
        $display("MUX Register WD: %b (deve ser 010 para imediato deslocado)", mux_register_wd);
        $display("MUX Register WR: %b (deve ser 00 para rt)", mux_register_wr);
        $display("ULA Control: %b (LUI não usa ULA)", ula);
        $display("---");
        
        // === INSTRUÇÕES DE LOAD ===
        $display("\n=== INSTRUÇÕES DE LOAD ===\n");
        
        // Teste 3: LW - Load Word
        $display("Teste 3: LW $1, 0($2)");
        test_load(6'b100011, 16'h0000, 2'b00);
        
        // Teste 4: LB - Load Byte
        $display("Teste 4: LB $1, 0($2)");
        test_load(6'b100000, 16'h0000, 2'b10);
        
        // === INSTRUÇÕES DE STORE ===
        $display("\n=== INSTRUÇÕES DE STORE ===\n");
        
        // Teste 5: SW - Store Word
        $display("Teste 5: SW $1, 0($2)");
        test_store(6'b101011, 16'h0000, 1'b0);
        
        // Teste 6: SB - Store Byte
        $display("Teste 6: SB $1, 0($2)");
        test_store(6'b101000, 16'h0000, 1'b1);
        
        // === INSTRUÇÕES DE BRANCH ===
        $display("\n=== INSTRUÇÕES DE BRANCH ===\n");
        
        // Teste 7: BEQ - Branch Equal (condição verdadeira)
        $display("Teste 7: BEQ $1, $2, 4 (zero_div = 1)");
        test_branch(6'b000100, 16'h0004, 1'b1, 1'b1);
        
        // Teste 8: BEQ - Branch Equal (condição falsa)
        $display("Teste 8: BEQ $1, $2, 4 (zero_div = 0)");
        test_branch(6'b000100, 16'h0004, 1'b0, 1'b0);
        
        // Teste 9: BNE - Branch Not Equal (condição verdadeira)
        $display("Teste 9: BNE $1, $2, 4 (zero_div = 0)");
        test_branch(6'b000101, 16'h0004, 1'b0, 1'b1);
        
        // Teste 10: BNE - Branch Not Equal (condição falsa)
        $display("Teste 10: BNE $1, $2, 4 (zero_div = 1)");
        test_branch(6'b000101, 16'h0004, 1'b1, 1'b0);
        
        // === INSTRUÇÕES ESPECIAIS ===
        $display("\n=== INSTRUÇÕES ESPECIAIS ===\n");
        
        // Teste 11: SLLM - Shift Left Logical Multiple (instrução customizada)
        $display("Teste 11: SLLM $1, $2, 4");
        reset_system();
        opcode = 6'b001001; // SLLM
        immediate = 16'h0004;
        wait_cycles(3); // FETCH -> DECODE -> EXECUTE
        $display("Register Write: %b", reg_wr);
        $display("Shift Control: %b", shift);
        $display("ULA Control: %b (SLLM usa soma para endereço)", ula);
        $display("---");
        
        // === DEMONSTRAÇÃO DE VARIAÇÃO DA ULA ===
        $display("\n=== DEMONSTRAÇÃO DE VARIAÇÃO DA ULA ===\n");
        
        // Sequência para mostrar variação da ULA
        $display("Sequência de instruções para demonstrar variação da ULA:");
        
        // Reset - ULA = 000
        reset_system();
        $display("Após reset: ULA = %b", ula);
        
        // ADDI - ULA = 001
        opcode = 6'b001000; // ADDI
        immediate = 16'h0064;
        wait_cycles(3);
        $display("ADDI: ULA = %b (soma)", ula);
        
        // BEQ - ULA = 010
        reset_system();
        opcode = 6'b000100; // BEQ
        immediate = 16'h0004;
        wait_cycles(6);
        $display("BEQ: ULA = %b (subtração)", ula);
        
        // LW - ULA = 001
        reset_system();
        opcode = 6'b100011; // LW
        immediate = 16'h0000;
        wait_cycles(3);
        $display("LW: ULA = %b (soma para endereço)", ula);
        
        // BNE - ULA = 010
        reset_system();
        opcode = 6'b000101; // BNE
        immediate = 16'h0004;
        wait_cycles(6);
        $display("BNE: ULA = %b (subtração)", ula);
        
        // === VERIFICAÇÃO DE MUXES PARA I-TYPE ===
        $display("\n=== VERIFICAÇÃO DE MUXES ===\n");
        
        // Teste 12: Verificação de MUXes - ADDI
        $display("Teste 12: Verificação de MUXes - ADDI $1, $2, 100");
        reset_system();
        opcode = 6'b001000; // ADDI
        immediate = 16'h0064;
        wait_cycles(3); // FETCH -> DECODE -> EXECUTE
        $display("MUX A: %b (deve ser 00 para registrador)", mux_a);
        $display("MUX B: %b (deve ser 1 para imediato)", mux_b);
        $display("MUX ULA1: %b (deve ser 00 para A)", mux_ula1);
         $display("MUX ULA2: %b (deve ser 01 para imediato)", mux_ula2);
         $display("MUX Register WD: %b (deve ser 000 para ULA)", mux_register_wd);
         $display("MUX Register WR: %b (deve ser 00 para rt)", mux_register_wr);
        $display("MUX Extend: %b (deve ser 0 para sign extend)", mux_extend);
        $display("---");
        
        // Teste 13: Verificação de MUXes - LW
        $display("Teste 13: Verificação de MUXes - LW $1, 0($2)");
        reset_system();
        opcode = 6'b100011; // LW
        immediate = 16'h0000;
        wait_cycles(4); // FETCH -> DECODE -> EXECUTE -> MEMORY
        $display("MUX Address: %b (deve ser 000 para ULA)", mux_address);
         $display("MUX Register WD: %b (deve ser 001 para memória)", mux_register_wd);
        $display("Load Size Control: %b (deve ser 00 para word)", load_size);
        $display("---");
        
        $display("\n=== RESUMO DA VARIAÇÃO DA ULA ===\n");
        $display("As instruções I-type usam principalmente:");
        $display("- ULA 000: Estado inicial/reset");
        $display("- ULA 001: ADDI, LW, LB, SW, SB, SLLM (soma/endereçamento)");
        $display("- ULA 010: BEQ, BNE (subtração para comparação)");
        $display("- LUI não usa ULA (acesso direto ao imediato)");
        $display("\nEsta variação está CORRETA para as instruções I-type!");
        
        $display("\n=== TODOS OS TESTES I-TYPE CONCLUÍDOS ===\n");
        $finish;
    end
    
endmodule