// Teste das Instruções I-type do Control Unit
`timescale 1ns/1ps

module test_i_type;
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
    
    // Geração do clock
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
    
    // Task para testar instrução I-type aritmética
    task test_i_arithmetic;
        input [31:0] instr;
        input [3:0] expected_alu;
        input expected_extend;
        input expected_reg_write;
        begin
            reset_system();
            instruction = instr;
            wait_cycles(3); // FETCH -> DECODE -> EXECUTE
            
            $display("ALU Control: %b (esperado: %b)", alu_control, expected_alu);
            $display("MUX Extend: %b (esperado: %b)", mux_extend, expected_extend);
            $display("Register Write: %b (esperado: %b)", register_write, expected_reg_write);
            $display("MUX ALU2: %b (deve ser 01 para imediato)", mux_alu_2);
            $display("MUX WR Registers: %b (deve ser 00 para rt)", mux_wr_registers);
            $display("Estado: %d", current_state);
            $display("---");
        end
    endtask
    
    // Task para testar instrução de load
    task test_load;
        input [31:0] instr;
        input [1:0] expected_load_size;
        begin
            reset_system();
            instruction = instr;
            wait_cycles(4); // FETCH -> DECODE -> EXECUTE -> MEMORY
            
            $display("Load Size Control: %b (esperado: %b)", load_size_control, expected_load_size);
            $display("Memory Write: %b (deve ser 0 para load)", memory_write);
            $display("Register Write: %b (deve ser 1 para load)", register_write);
            $display("MUX WD Registers: %b (deve ser 01 para memória)", mux_wd_registers);
            $display("Estado: %d (deve ser MEMORY)", current_state);
            $display("---");
        end
    endtask
    
    // Task para testar instrução de store
    task test_store;
        input [31:0] instr;
        input [1:0] expected_store_size;
        begin
            reset_system();
            instruction = instr;
            wait_cycles(4); // FETCH -> DECODE -> EXECUTE -> MEMORY
            
            $display("Store Size Control: %b (esperado: %b)", store_size_control, expected_store_size);
            $display("Memory Write: %b (deve ser 1 para store)", memory_write);
            $display("Register Write: %b (deve ser 0 para store)", register_write);
            $display("Estado: %d (deve ser MEMORY)", current_state);
            $display("---");
        end
    endtask
    
    // Task para testar instrução de branch
    task test_branch;
        input [31:0] instr;
        input zero_condition;
        input expected_pc_write;
        begin
            reset_system();
            instruction = instr;
            zero_flag = zero_condition;
            wait_cycles(3); // FETCH -> DECODE -> EXECUTE
            
            $display("Zero Flag: %b", zero_flag);
            $display("PC Write Enable: %b (esperado: %b)", pc_write_enable, expected_pc_write);
            $display("MUX PC: %b", mux_pc);
            $display("ALU Control: %b (deve ser 0110 para subtração)", alu_control);
            $display("Estado: %d", current_state);
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
        test_i_arithmetic(32'h20010064, 4'b0010, 1'b0, 1'b1);
        
        // Teste 2: LUI - Load Upper Immediate
        $display("Teste 2: LUI $1, 0x1234");
        reset_system();
        instruction = 32'h3C011234; // LUI $1, 0x1234
        wait_cycles(3); // FETCH -> DECODE -> EXECUTE
        $display("Register Write: %b (deve ser 1)", register_write);
        $display("MUX WD Registers: %b (deve ser 10 para imediato deslocado)", mux_wd_registers);
        $display("MUX WR Registers: %b (deve ser 00 para rt)", mux_wr_registers);
        $display("Estado: %d", current_state);
        $display("---");
        
        // === INSTRUÇÕES DE LOAD ===
        $display("\n=== INSTRUÇÕES DE LOAD ===\n");
        
        // Teste 3: LW - Load Word
        $display("Teste 3: LW $1, 0($2)");
        test_load(32'h8C410000, 2'b00);
        
        // Teste 4: LB - Load Byte
        $display("Teste 4: LB $1, 0($2)");
        test_load(32'h80410000, 2'b10);
        
        // === INSTRUÇÕES DE STORE ===
        $display("\n=== INSTRUÇÕES DE STORE ===\n");
        
        // Teste 5: SW - Store Word
        $display("Teste 5: SW $1, 0($2)");
        test_store(32'hAC410000, 2'b00);
        
        // Teste 6: SB - Store Byte
        $display("Teste 6: SB $1, 0($2)");
        test_store(32'hA0410000, 2'b10);
        
        // === INSTRUÇÕES DE BRANCH ===
        $display("\n=== INSTRUÇÕES DE BRANCH ===\n");
        
        // Teste 7: BEQ - Branch Equal (condição verdadeira)
        $display("Teste 7: BEQ $1, $2, 4 (zero_flag = 1)");
        test_branch(32'h10220004, 1'b1, 1'b1);
        
        // Teste 8: BEQ - Branch Equal (condição falsa)
        $display("Teste 8: BEQ $1, $2, 4 (zero_flag = 0)");
        test_branch(32'h10220004, 1'b0, 1'b0);
        
        // Teste 9: BNE - Branch Not Equal (condição verdadeira)
        $display("Teste 9: BNE $1, $2, 4 (zero_flag = 0)");
        test_branch(32'h14220004, 1'b0, 1'b1);
        
        // Teste 10: BNE - Branch Not Equal (condição falsa)
        $display("Teste 10: BNE $1, $2, 4 (zero_flag = 1)");
        test_branch(32'h14220004, 1'b1, 1'b0);
        
        // === INSTRUÇÕES ESPECIAIS ===
        $display("\n=== INSTRUÇÕES ESPECIAIS ===\n");
        
        // Teste 11: SLLM - Shift Left Logical Multiple (instrução customizada)
        $display("Teste 11: SLLM $1, $2, 4");
        reset_system();
        instruction = 32'h70220004; // SLLM $1, $2, 4 (opcode customizado)
        wait_cycles(3); // FETCH -> DECODE -> EXECUTE
        $display("Register Write: %b", register_write);
        $display("Shift Control: %b", shift_control);
        $display("Estado: %d", current_state);
        $display("---");
        
        // === VERIFICAÇÃO DE MUXES PARA I-TYPE ===
        $display("\n=== VERIFICAÇÃO DE MUXES ===\n");
        
        // Teste 12: Verificação de MUXes - ADDI
        $display("Teste 12: Verificação de MUXes - ADDI $1, $2, 100");
        reset_system();
        instruction = 32'h20410064; // ADDI $1, $2, 100
        wait_cycles(3); // FETCH -> DECODE -> EXECUTE
        $display("MUX A: %b (deve ser 00 para registrador)", mux_a);
        $display("MUX B: %b (deve ser 01 para imediato)", mux_b);
        $display("MUX ALU1: %b (deve ser 00 para A)", mux_alu_1);
        $display("MUX ALU2: %b (deve ser 01 para imediato)", mux_alu_2);
        $display("MUX WD Registers: %b (deve ser 00 para ALU)", mux_wd_registers);
        $display("MUX WR Registers: %b (deve ser 00 para rt)", mux_wr_registers);
        $display("MUX Extend: %b (deve ser 0 para sign extend)", mux_extend);
        $display("---");
        
        // Teste 13: Verificação de MUXes - LW
        $display("Teste 13: Verificação de MUXes - LW $1, 0($2)");
        reset_system();
        instruction = 32'h8C410000; // LW $1, 0($2)
        wait_cycles(4); // FETCH -> DECODE -> EXECUTE -> MEMORY
        $display("MUX Address: %b (deve ser 0 para ALU)", mux_address);
        $display("MUX WD Registers: %b (deve ser 01 para memória)", mux_wd_registers);
        $display("Load Size Control: %b (deve ser 00 para word)", load_size_control);
        $display("---");
        
        $display("\n=== TODOS OS TESTES I-TYPE CONCLUÍDOS ===\n");
        $finish;
    end
    
endmodule