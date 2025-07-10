// Teste das Instruções R-type do Control Unit
`timescale 1ns/1ps

module test_r_type;
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
    
    // Task para testar instrução R-type
    task test_r_instruction;
        input [31:0] instr;
        input [3:0] expected_alu;
        input [1:0] expected_shift;
        input expected_reg_write;
        input expected_hi_write;
        input expected_lo_write;
        begin
            reset_system();
            instruction = instr;
            wait_cycles(3); // FETCH -> DECODE -> EXECUTE
            
            $display("ALU Control: %b (esperado: %b)", alu_control, expected_alu);
            $display("Shift Control: %b (esperado: %b)", shift_control, expected_shift);
            $display("Register Write: %b (esperado: %b)", register_write, expected_reg_write);
            $display("HI Write: %b (esperado: %b)", hi_write, expected_hi_write);
            $display("LO Write: %b (esperado: %b)", lo_write, expected_lo_write);
            $display("Estado: %d", current_state);
            $display("---");
        end
    endtask
    
    // Configuração para dump VCD
    initial begin
        $dumpfile("test_r_type.vcd");
        $dumpvars(0, test_r_type);
    end
    
    // Testes principais
    initial begin
        $display("=== TESTE DAS INSTRUÇÕES R-TYPE ===\n");
        
        // Teste 1: ADD - Adição
        $display("Teste 1: ADD $1, $2, $3");
        test_r_instruction(32'h00430820, 4'b0010, 2'b00, 1'b1, 1'b0, 1'b0);
        
        // Teste 2: SUB - Subtração
        $display("Teste 2: SUB $1, $2, $3");
        test_r_instruction(32'h00430822, 4'b0110, 2'b00, 1'b1, 1'b0, 1'b0);
        
        // Teste 3: AND - E lógico
        $display("Teste 3: AND $1, $2, $3");
        test_r_instruction(32'h00430824, 4'b0000, 2'b00, 1'b1, 1'b0, 1'b0);
        
        // Teste 4: SLT - Set Less Than
        $display("Teste 4: SLT $1, $2, $3");
        test_r_instruction(32'h0043082A, 4'b0111, 2'b00, 1'b1, 1'b0, 1'b0);
        
        // Teste 5: SLL - Shift Left Logical
        $display("Teste 5: SLL $1, $2, 4");
        test_r_instruction(32'h00021100, 4'b0000, 2'b00, 1'b1, 1'b0, 1'b0);
        
        // Teste 6: SRA - Shift Right Arithmetic
        $display("Teste 6: SRA $1, $2, 4");
        test_r_instruction(32'h00021103, 4'b0000, 2'b10, 1'b1, 1'b0, 1'b0);
        
        // Teste 7: JR - Jump Register
        $display("Teste 7: JR $31");
        reset_system();
        instruction = 32'h03E00008; // JR $31
        wait_cycles(2); // FETCH -> DECODE
        $display("PC Write Enable: %b", pc_write_enable);
        $display("MUX PC: %b", mux_pc);
        $display("Estado: %d", current_state);
        $display("---");
        
        // Teste 8: MFHI - Move From HI
        $display("Teste 8: MFHI $1");
        test_r_instruction(32'h00000810, 4'b0000, 2'b00, 1'b1, 1'b0, 1'b0);
        
        // Teste 9: MFLO - Move From LO
        $display("Teste 9: MFLO $1");
        test_r_instruction(32'h00000812, 4'b0000, 2'b00, 1'b1, 1'b0, 1'b0);
        
        // Teste 10: MULT - Multiplicação
        $display("Teste 10: MULT $1, $2");
        reset_system();
        instruction = 32'h00220018; // MULT $1, $2
        wait_cycles(3); // FETCH -> DECODE -> EXECUTE
        $display("HI Write: %b", hi_write);
        $display("LO Write: %b", lo_write);
        $display("Estado: %d (deve permanecer em EXECUTE até mult_done)", current_state);
        
        // Simular conclusão da multiplicação
        mult_done = 1;
        wait_cycles(1);
        $display("Após mult_done - Estado: %d", current_state);
        mult_done = 0;
        $display("---");
        
        // Teste 11: DIV - Divisão
        $display("Teste 11: DIV $1, $2");
        reset_system();
        instruction = 32'h0022001A; // DIV $1, $2
        wait_cycles(3); // FETCH -> DECODE -> EXECUTE
        $display("HI Write: %b", hi_write);
        $display("LO Write: %b", lo_write);
        $display("Estado: %d (deve permanecer em EXECUTE até div_done)", current_state);
        
        // Simular conclusão da divisão
        div_done = 1;
        wait_cycles(1);
        $display("Após div_done - Estado: %d", current_state);
        div_done = 0;
        $display("---");
        
        // Teste 12: XCHG - Exchange (instrução customizada)
        $display("Teste 12: XCHG $1, $2");
        test_r_instruction(32'h0022082D, 4'b0000, 2'b00, 1'b1, 1'b0, 1'b0);
        
        // Teste 13: Verificação de MUXes para R-type
        $display("Teste 13: Verificação de MUXes - ADD $1, $2, $3");
        reset_system();
        instruction = 32'h00430820; // ADD $1, $2, $3
        wait_cycles(3); // FETCH -> DECODE -> EXECUTE
        $display("MUX A: %b (deve ser 00 para registrador)", mux_a);
        $display("MUX B: %b (deve ser 00 para registrador)", mux_b);
        $display("MUX ALU1: %b (deve ser 00 para A)", mux_alu_1);
        $display("MUX ALU2: %b (deve ser 00 para B)", mux_alu_2);
        $display("MUX WD Registers: %b (deve ser 00 para ALU)", mux_wd_registers);
        $display("MUX WR Registers: %b (deve ser 01 para rd)", mux_wr_registers);
        $display("---");
        
        $display("\n=== TODOS OS TESTES R-TYPE CONCLUÍDOS ===\n");
        $finish;
    end
    
endmodule