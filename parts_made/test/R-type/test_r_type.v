// Teste das Instruções R-type do Control Unit
`timescale 1ns/1ps

module test_r_type;
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
    wire mux_wd_memory;
    wire mux_high;
    wire mux_low;
    wire mux_extend;
    wire mux_b;
    wire mux_shift_src;
    wire [1:0] mux_shift_amt;
    wire [1:0] mux_a;
    wire [1:0] mux_alu1;
    wire [1:0] mux_alu2;
    wire [1:0] mux_pc;
    wire [1:0] mux_wr_registers;
    wire [2:0] mux_address;
    wire [2:0] mux_wd_registers;
    wire address_rg_load;
    wire epc_load;
    wire mdr_load;
    wire ir_load;
    wire high_load;
    wire low_load;
    wire a_load;
    wire b_load;
    wire alu_out_load;
    wire store_size;
    wire [1:0] load_size;
    wire memory_wr;
    wire reg_wr;
    wire pc_write;
    wire is_beq;
    wire is_bne;
    wire [2:0] ula;
    wire [2:0] shift;
    wire mult_init;
    wire div_init;
    
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
        .mux_wd_memory(mux_wd_memory),
        .mux_high(mux_high),
        .mux_low(mux_low),
        .mux_extend(mux_extend),
        .mux_b(mux_b),
        .mux_shift_src(mux_shift_src),
        .mux_shift_amt(mux_shift_amt),
        .mux_a(mux_a),
        .mux_alu1(mux_alu1),
        .mux_alu2(mux_alu2),
        .mux_pc(mux_pc),
        .mux_wr_registers(mux_wr_registers),
        .mux_address(mux_address),
        .mux_wd_registers(mux_wd_registers),
        .address_rg_load(address_rg_load),
        .epc_load(epc_load),
        .mdr_load(mdr_load),
        .ir_load(ir_load),
        .high_load(high_load),
        .low_load(low_load),
        .a_load(a_load),
        .b_load(b_load),
        .alu_out_load(alu_out_load),
        .store_size(store_size),
        .load_size(load_size),
        .memory_wr(memory_wr),
        .reg_wr(reg_wr),
        .pc_write(pc_write),
        .is_beq(is_beq),
        .is_bne(is_bne),
        .ula(ula),
        .shift(shift),
        .mult_init(mult_init),
        .div_init(div_init)
    );
    
    // Geração do clock
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
    
    // Task para executar ADDIU (I-type)
    task execute_addiu;
        input [4:0] rt;
        input [4:0] rs;
        input [15:0] imm;
        begin
            $display("  Executando: ADDIU $%0d, $%0d, %0d", rt, rs, imm);
            opcode = 6'h09; // ADDIU
            immediate = {rs, rt, imm[5:0]}; // rs[15:11], rt[10:6], imm[5:0]
            wait_cycles(4); // I-type precisa de mais ciclos
        end
    endtask
    
    // Task para executar instrução R-type
    task execute_r_type;
        input [4:0] rs;
        input [4:0] rt;
        input [4:0] rd;
        input [4:0] shamt;
        input [5:0] funct;
        begin
            opcode = 6'h00; // R-type
            immediate = {rs, rt, rd[4:0], shamt[4:0], funct[5:0]};
            wait_cycles(4); // R-type executa em múltiplos ciclos
            
            // Mostrar sinais de controle relevantes
            $display("    ULA: %b, Shift: %b, Reg_WR: %b, HI_Load: %b, LO_Load: %b", 
                     ula, shift, reg_wr, high_load, low_load);
            $display("    MUX_A: %b, MUX_B: %b, MUX_WD_Reg: %b, MUX_WR_Reg: %b", 
                     mux_a, mux_b, mux_wd_registers, mux_wr_registers);
        end
    endtask
    
    // Task para simular operações de multiplicação/divisão com flags
    task simulate_mult_div_flags;
        input is_mult; // 1 para MULT, 0 para DIV
        begin
            if (is_mult) begin
                // Simular conclusão da multiplicação
                wait_cycles(5);
                mult_stop = 1;
                wait_cycles(1);
                mult_stop = 0;
            end else begin
                // Simular conclusão da divisão
                wait_cycles(5);
                div_stop = 1;
                wait_cycles(1);
                div_stop = 0;
            end
        end
    endtask
    
    // Configuração para dump VCD
    initial begin
        $dumpfile("test_r_type.vcd");
        $dumpvars(0, test_r_type);
    end
    
    // Testes principais
    initial begin
        $display("=== TESTE DAS INSTRUÇÕES R-TYPE - VERSÃO REALÍSTICA ===");
        
        // ========================================
        // TESTE 1: Operações Aritméticas Básicas (ADD/SUB)
        // addiu $1, $zero, 25
        // addiu $2, $zero, 15
        // add $3, $1, $2    // $3 = 25 + 15 = 40
        // sub $4, $1, $2    // $4 = 25 - 15 = 10
        // add $5, $3, $4    // $5 = 40 + 10 = 50
        // ========================================
        $display("=== TESTE 1: Operações Aritméticas Básicas (ADD/SUB) ===");
        reset_system();
        
        execute_addiu(1, 0, 25);  // addiu $1, $zero, 25
        execute_addiu(2, 0, 15);  // addiu $2, $zero, 15
        $display("  Executando: ADD $3, $1, $2 (25 + 15)");
        execute_r_type(1, 2, 3, 0, 6'h20); // ADD
        $display("  Executando: SUB $4, $1, $2 (25 - 15)");
        execute_r_type(1, 2, 4, 0, 6'h22); // SUB
        $display("  Executando: ADD $5, $3, $4 (40 + 10)");
        execute_r_type(3, 4, 5, 0, 6'h20); // ADD
        
        $display("Teste Operações Aritméticas concluído\n");
        
        // ========================================
        // TESTE 2: Multiplicação e Recuperação (MULT/MFHI/MFLO)
        // addiu $1, $zero, 4
        // addiu $2, $zero, 3
        // mult $1, $2       // 4 * 3 = 12 (LO=12, HI=0)
        // mfhi $2           // $2 = HI (parte alta)
        // mflo $1           // $1 = LO (parte baixa)
        // ========================================
        $display("=== TESTE 2: Multiplicação e Recuperação (MULT/MFHI/MFLO) ===");
        reset_system();
        
        execute_addiu(1, 0, 4);   // addiu $1, $zero, 4
        execute_addiu(2, 0, 3);   // addiu $2, $zero, 3
        $display("  Executando: MULT $1, $2 (4 * 3)");
        execute_r_type(1, 2, 0, 0, 6'h18); // MULT
        simulate_mult_div_flags(1); // Simular conclusão da multiplicação
        $display("  Executando: MFHI $2 (recuperar parte alta)");
        execute_r_type(0, 0, 2, 0, 6'h10); // MFHI
        $display("  Executando: MFLO $1 (recuperar parte baixa)");
        execute_r_type(0, 0, 1, 0, 6'h12); // MFLO
        
        $display("Teste Multiplicação concluído\n");
        
        // ========================================
        // TESTE 3: Divisão com Resto (DIV/MFHI/MFLO)
        // addiu $1, $zero, 17
        // addiu $2, $zero, 5
        // div $1, $2        // 17 / 5 = 3 resto 2 (LO=3, HI=2)
        // mflo $3           // $3 = quociente (3)
        // mfhi $4           // $4 = resto (2)
        // ========================================
        $display("=== TESTE 3: Divisão com Resto (DIV/MFHI/MFLO) ===");
        reset_system();
        
        execute_addiu(1, 0, 17);  // addiu $1, $zero, 17
        execute_addiu(2, 0, 5);   // addiu $2, $zero, 5
        $display("  Executando: DIV $1, $2 (17 / 5)");
        execute_r_type(1, 2, 0, 0, 6'h1A); // DIV
        simulate_mult_div_flags(0); // Simular conclusão da divisão
        $display("  Executando: MFLO $3 (quociente)");
        execute_r_type(0, 0, 3, 0, 6'h12); // MFLO
        $display("  Executando: MFHI $4 (resto)");
        execute_r_type(0, 0, 4, 0, 6'h10); // MFHI
        
        $display("Teste Divisão concluído\n");
        
        // ========================================
        // TESTE 4: Operações de Deslocamento (SLL/SRA)
        // addiu $1, $zero, 8
        // sll $2, $1, 2     // $2 = 8 << 2 = 32
        // addiu $3, $zero, -16 (0xFFF0)
        // sra $4, $3, 1     // $4 = -16 >> 1 = -8 (aritmético)
        // ========================================
        $display("=== TESTE 4: Operações de Deslocamento (SLL/SRA) ===");
        reset_system();
        
        execute_addiu(1, 0, 8);   // addiu $1, $zero, 8
        $display("  Executando: SLL $2, $1, 2 (8 << 2)");
        execute_r_type(0, 1, 2, 2, 6'h00); // SLL
        execute_addiu(3, 0, 16'hFFF0); // addiu $3, $zero, -16
        $display("  Executando: SRA $4, $3, 1 (-16 >> 1 aritmético)");
        execute_r_type(0, 3, 4, 1, 6'h03); // SRA
        
        $display("Teste Deslocamento concluído\n");
        
        // ========================================
        // TESTE 5: Operações Lógicas (AND)
        // addiu $1, $zero, 15   // 0x000F
        // addiu $2, $zero, 10   // 0x000A
        // and $3, $1, $2        // 0x000F & 0x000A = 0x000A (10)
        // ========================================
        $display("=== TESTE 5: Operações Lógicas (AND) ===");
        reset_system();
        
        execute_addiu(1, 0, 15);  // addiu $1, $zero, 15 (0x000F)
        execute_addiu(2, 0, 10);  // addiu $2, $zero, 10 (0x000A)
        $display("  Executando: AND $3, $1, $2 (15 & 10)");
        execute_r_type(1, 2, 3, 0, 6'h24); // AND
        
        $display("Teste Operações Lógicas concluído\n");
        
        // ========================================
        // TESTE 6: Comparação (SLT)
        // addiu $1, $zero, 5
        // addiu $2, $zero, 8
        // slt $3, $1, $2    // $3 = (5 < 8) = 1
        // slt $4, $2, $1    // $4 = (8 < 5) = 0
        // slt $5, $1, $1    // $5 = (5 < 5) = 0
        // ========================================
        $display("=== TESTE 6: Comparação (SLT) ===");
        reset_system();
        
        execute_addiu(1, 0, 5);   // addiu $1, $zero, 5
        execute_addiu(2, 0, 8);   // addiu $2, $zero, 8
        $display("  Executando: SLT $3, $1, $2 (5 < 8)");
        execute_r_type(1, 2, 3, 0, 6'h2A); // SLT
        $display("  Executando: SLT $4, $2, $1 (8 < 5)");
        execute_r_type(2, 1, 4, 0, 6'h2A); // SLT
        $display("  Executando: SLT $5, $1, $1 (5 < 5)");
        execute_r_type(1, 1, 5, 0, 6'h2A); // SLT
        
        $display("Teste Comparação concluído\n");
        
        // ========================================
        // TESTE 7: Troca de Valores (XCHG)
        // addiu $1, $zero, 42
        // addiu $2, $zero, 73
        // xchg $1, $2       // Trocar valores de $1 e $2
        // ========================================
        $display("=== TESTE 7: Troca de Valores (XCHG) ===");
        reset_system();
        
        execute_addiu(1, 0, 42);  // addiu $1, $zero, 42
        execute_addiu(2, 0, 73);  // addiu $2, $zero, 73
        $display("  Executando: XCHG $1, $2 (trocar 42 e 73)");
        execute_r_type(1, 2, 0, 0, 6'h05); // XCHG
        
        $display("Teste Troca de Valores concluído\n");
        
        // ========================================
        // TESTE 8: Salto para Registrador (JR)
        // addiu $31, $zero, 200  // Carregar endereço de retorno
        // jr $31                 // Saltar para endereço em $31
        // ========================================
        $display("=== TESTE 8: Salto para Registrador (JR) ===");
        reset_system();
        
        execute_addiu(31, 0, 200); // addiu $31, $zero, 200
        $display("  Executando: JR $31 (saltar para endereço 200)");
        execute_r_type(31, 0, 0, 0, 6'h08); // JR
        
        $display("Teste Salto concluído\n");
        
        // ========================================
        // TESTE 9: Sequência Complexa de Multiplicação
        // addiu $1, $zero, 6
        // addiu $2, $zero, 7
        // mult $1, $2       // 6 * 7 = 42
        // mflo $3           // $3 = 42
        // addiu $4, $zero, 2
        // mult $3, $4       // 42 * 2 = 84
        // mflo $5           // $5 = 84
        // ========================================
        $display("=== TESTE 9: Sequência Complexa de Multiplicação ===");
        reset_system();
        
        execute_addiu(1, 0, 6);   // addiu $1, $zero, 6
        execute_addiu(2, 0, 7);   // addiu $2, $zero, 7
        $display("  Executando: MULT $1, $2 (6 * 7)");
        execute_r_type(1, 2, 0, 0, 6'h18); // MULT
        simulate_mult_div_flags(1);
        $display("  Executando: MFLO $3 (resultado = 42)");
        execute_r_type(0, 0, 3, 0, 6'h12); // MFLO
        execute_addiu(4, 0, 2);   // addiu $4, $zero, 2
        $display("  Executando: MULT $3, $4 (42 * 2)");
        execute_r_type(3, 4, 0, 0, 6'h18); // MULT
        simulate_mult_div_flags(1);
        $display("  Executando: MFLO $5 (resultado = 84)");
        execute_r_type(0, 0, 5, 0, 6'h12); // MFLO
        
        $display("Teste Sequência Complexa concluído\n");
        
        // ========================================
        // TESTE 10: Teste Integrado de Todas as Operações
        // addiu $1, $zero, 12
        // addiu $2, $zero, 3
        // add $3, $1, $2    // $3 = 15
        // sll $4, $3, 1     // $4 = 30
        // sub $5, $4, $2    // $5 = 27
        // and $6, $5, $1    // $6 = 27 & 12 = 8
        // ========================================
        $display("=== TESTE 10: Teste Integrado de Todas as Operações ===");
        reset_system();
        
        execute_addiu(1, 0, 12);  // addiu $1, $zero, 12
        execute_addiu(2, 0, 3);   // addiu $2, $zero, 3
        $display("  Executando: ADD $3, $1, $2 (12 + 3)");
        execute_r_type(1, 2, 3, 0, 6'h20); // ADD
        $display("  Executando: SLL $4, $3, 1 (15 << 1)");
        execute_r_type(0, 3, 4, 1, 6'h00); // SLL
        $display("  Executando: SUB $5, $4, $2 (30 - 3)");
        execute_r_type(4, 2, 5, 0, 6'h22); // SUB
        $display("  Executando: AND $6, $5, $1 (27 & 12)");
        execute_r_type(5, 1, 6, 0, 6'h24); // AND
        
        $display("Teste Integrado concluído\n");
        
        $display("\n=== RESUMO DOS SINAIS PARA GTKWAVE ===");
        $display("Sinais principais para visualização:");
        $display("- clk, reset_in");
        $display("- opcode[5:0], immediate[15:0]");
        $display("- ula[2:0], shift[2:0]");
        $display("- reg_wr, high_load, low_load");
        $display("- mux_a[1:0], mux_b, mux_alu1[1:0], mux_alu2[1:0]");
        $display("- mux_wd_registers[2:0], mux_wr_registers[1:0]");
        $display("- mult_init, div_init, mult_stop, div_stop");
        $display("- a_load, b_load, alu_out_load");
        $display("- pc_write, memory_wr");
        
        $display("\n=== TODOS OS TESTES R-TYPE CONCLUÍDOS ===");
        $finish;
    end
    
endmodule