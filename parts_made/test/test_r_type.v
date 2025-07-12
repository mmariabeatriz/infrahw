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
    
    // Task para testar instrução R-type
    task test_r_instruction;
        input [5:0] op;
        input [15:0] imm;
        input [2:0] expected_ula;
        input [2:0] expected_shift;
        input expected_reg_write;
        input expected_hi_write;
        input expected_lo_write;
        begin
            reset_system();
            opcode = op;
            immediate = imm;
            wait_cycles(3); // FETCH -> DECODE -> EXECUTE
            
            $display("ULA Control: %b (esperado: %b)", ula, expected_ula);
            $display("Shift Control: %b (esperado: %b)", shift, expected_shift);
            $display("Register Write: %b (esperado: %b)", reg_wr, expected_reg_write);
            $display("HI Write: %b (esperado: %b)", high_load, expected_hi_write);
            $display("LO Write: %b (esperado: %b)", low_load, expected_lo_write);
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
        
        // Teste 1: ADD - Adição (opcode = 000000, funct = 100000)
        $display("Teste 1: ADD $1, $2, $3");
        test_r_instruction(6'b000000, 16'h0820, 3'b010, 3'b000, 1'b1, 1'b0, 1'b0);
        
        // Teste 2: SUB - Subtração (opcode = 000000, funct = 100010)
        $display("Teste 2: SUB $1, $2, $3");
        test_r_instruction(6'b000000, 16'h0822, 3'b110, 3'b000, 1'b1, 1'b0, 1'b0);
        
        // Teste 3: AND - E lógico (opcode = 000000, funct = 100100)
        $display("Teste 3: AND $1, $2, $3");
        test_r_instruction(6'b000000, 16'h0824, 3'b000, 3'b000, 1'b1, 1'b0, 1'b0);
        
        // Teste 4: SLT - Set Less Than (opcode = 000000, funct = 101010)
        $display("Teste 4: SLT $1, $2, $3");
        test_r_instruction(6'b000000, 16'h082A, 3'b111, 3'b000, 1'b1, 1'b0, 1'b0);
        
        // Teste 5: SLL - Shift Left Logical (opcode = 000000, funct = 000000)
        $display("Teste 5: SLL $1, $2, 4");
        test_r_instruction(6'b000000, 16'h1100, 3'b000, 3'b000, 1'b1, 1'b0, 1'b0);
        
        // Teste 6: SRA - Shift Right Arithmetic (opcode = 000000, funct = 000011)
        $display("Teste 6: SRA $1, $2, 4");
        test_r_instruction(6'b000000, 16'h1103, 3'b000, 3'b010, 1'b1, 1'b0, 1'b0);
        
        // Teste 7: JR - Jump Register (opcode = 000000, funct = 001000)
        $display("Teste 7: JR $31");
        test_r_instruction(6'b000000, 16'h0008, 3'b000, 3'b000, 1'b0, 1'b0, 1'b0);
        
        // Teste 8: MFHI - Move From HI (opcode = 000000, funct = 010000)
        $display("Teste 8: MFHI $1");
        test_r_instruction(6'b000000, 16'h0810, 3'b000, 3'b000, 1'b1, 1'b0, 1'b0);
        
        // Teste 9: MFLO - Move From LO (opcode = 000000, funct = 010010)
        $display("Teste 9: MFLO $1");
        test_r_instruction(6'b000000, 16'h0812, 3'b000, 3'b000, 1'b1, 1'b0, 1'b0);
        
        // Teste 10: MULT - Multiplicação (opcode = 000000, funct = 011000)
        $display("Teste 10: MULT $2, $3");
        test_r_instruction(6'b000000, 16'h0018, 3'b000, 3'b000, 1'b0, 1'b1, 1'b1);
        
        // Teste 11: DIV - Divisão (opcode = 000000, funct = 011010)
        $display("Teste 11: DIV $2, $3");
        test_r_instruction(6'b000000, 16'h001A, 3'b000, 3'b000, 1'b0, 1'b1, 1'b1);
        
        // Teste 12: XCHG - Exchange (opcode = 000000, funct = 111111)
        $display("Teste 12: XCHG $1, $2");
        test_r_instruction(6'b000000, 16'h083F, 3'b000, 3'b000, 1'b1, 1'b0, 1'b0);
        
        // Teste 13: Verificação de MUXes para R-type
        $display("Teste 13: Verificação de MUXes - ADD $1, $2, $3");
        reset_system();
        opcode = 6'b000000;
        immediate = 16'h0820;
        wait_cycles(3); // FETCH -> DECODE -> EXECUTE
        $display("MUX A: %b (deve ser 00 para registrador)", mux_a);
         $display("MUX B: %b (deve ser 00 para registrador)", mux_b);
         $display("MUX ALU1: %b (deve ser 00 para A)", mux_alu1);
         $display("MUX ALU2: %b (deve ser 00 para B)", mux_alu2);
         $display("MUX WD Registers: %b (deve ser 00 para ALU)", mux_wd_registers);
         $display("MUX WR Registers: %b (deve ser 01 para rd)", mux_wr_registers);
         $display("---");
         
         $display("\n=== TESTES CONCLUÍDOS ===");
         $finish;
     end
    
endmodule