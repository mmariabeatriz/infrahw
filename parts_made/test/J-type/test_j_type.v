// Teste das instuções J-type
`timescale 1ns/1ps

module test_j_type;
    // Sinais de entrada
    reg clk;
    reg reset;
    reg [31:0] instruction;
    reg zero_flag;
    reg overflow;
    reg div_zero;
    
    // Sinais de saída
    wire [4:0] current_state;
    wire [5:0] opcode;
    wire [4:0] rs, rt, rd;
    wire [4:0] shamt;
    wire [5:0] funct;
    wire [15:0] immediate;
    wire [25:0] address;
    wire [3:0] alu_control;
    wire alu_zero, alu_overflow;
    wire reg_dst, jump, branch, mem_read, mem_to_reg;
    wire [1:0] alu_op;
    wire mem_write, alu_src, reg_write;
    wire pc_write, pc_write_cond;
    wire [1:0] pc_source;
    
    // Instanciação do módulo control_unit
    control_unit uut (
        .clk(clk),
        .reset(reset),
        .instruction(instruction),
        .zero_flag(zero_flag),
        .overflow(overflow),
        .div_zero(div_zero),
        
        // Instruction fields (outputs)
        .opcode(opcode),
        .rs(rs),
        .rt(rt),
        .rd(rd),
        .shamt(shamt),
        .funct(funct),
        .immediate(immediate),
        .address(address),
        
        // ALU controls
        .alu_control(alu_control),
        .alu_zero(alu_zero),
        .alu_overflow(alu_overflow),
        
        // Control signals
        .reg_dst(reg_dst),
        .jump(jump),
        .branch(branch),
        .mem_read(mem_read),
        .mem_to_reg(mem_to_reg),
        .alu_op(alu_op),
        .mem_write(mem_write),
        .alu_src(alu_src),
        .reg_write(reg_write),
        
        // PC controls
        .pc_write(pc_write),
        .pc_write_cond(pc_write_cond),
        .pc_source(pc_source),
        
        // State output
        .current_state(current_state)
    );
    
    // Clock
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    
    // Task para reset do sistema
    task reset_system;
        begin
            reset = 1;
            instruction = 32'h00000000;
            zero_flag = 0;
            overflow = 0;
            div_zero = 0;
            #20;
            reset = 0;
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
    
    // Task para executar instrução J-type e exibir sinais de controle
    task execute_j_instruction;
        input [5:0] op;
        input [25:0] target_address;
        begin
            instruction = {op, target_address};
            wait_cycles(2); // FETCH -> DECODE (J-type executa no DECODE)
            
            $display("=== Instrução J-type para endereço 0x%h ===", target_address);
            display_control_signals();
            $display("");
        end
    endtask
    
    // Task para exibir sinais de controle relevantes
    task display_control_signals;
        begin
            $display("Sinais de Controle:");
            $display("  PC Write: %b", pc_write);
            $display("  PC Source: %b", pc_source);
            $display("  Register Write: %b", reg_write);
            $display("  Jump: %b", jump);
            $display("  Memory Write: %b", mem_write);
            $display("  ALU Control: %b", alu_control);
            $display("  Current State: %d", current_state);
        end
    endtask
    
    // Configuração para dump VCD
    initial begin
        $dumpfile("test_j_type.vcd");
        $dumpvars(0, test_j_type);
    end
    
    // Testes principais
    initial begin
        $display("=== TESTE DAS INSTRUÇÕES J-TYPE IMPLEMENTADAS ===\n");
        $display("Testando apenas J (opcode 6'h02) e JAL (opcode 6'h03)\n");
        
        // === TESTE 1: INSTRUÇÃO J (JUMP) ===
        $display("=== TESTE 1: INSTRUÇÃO J (JUMP) ===\n");
        
        reset_system();
        
        // Teste básico do J
        $display("Testando J para endereço 0x1000:");
        execute_j_instruction(6'h02, 26'h001000);
        
        // Teste J com endereço diferente
        $display("Testando J para endereço 0x2000:");
        execute_j_instruction(6'h02, 26'h002000);
        
        // === TESTE 2: INSTRUÇÃO JAL (JUMP AND LINK) ===
        $display("=== TESTE 2: INSTRUÇÃO JAL (JUMP AND LINK) ===\n");
        
        reset_system();
        
        // Teste básico do JAL
        $display("Testando JAL para endereço 0x3000:");
        execute_j_instruction(6'h03, 26'h003000);
        
        // Teste JAL com endereço diferente
        $display("Testando JAL para endereço 0x4000:");
        execute_j_instruction(6'h03, 26'h004000);
        
        // === TESTE 3: VERIFICAÇÃO DE SINAIS DE CONTROLE ===
        $display("=== TESTE 3: VERIFICAÇÃO DE SINAIS DE CONTROLE ===\n");
        
        reset_system();
        
        // Teste detalhado do J
        $display("Análise detalhada - J:");
        opcode = 6'h02; // J
        immediate = 16'h1000;
        wait_cycles(2);
        $display("  J deve: PC Write=1, MUX PC=11, Reg Write=0");
        display_control_signals();
        $display("");
        
        // Teste detalhado do JAL
        reset_system();
        $display("Análise detalhada - JAL:");
        opcode = 6'h03; // JAL
        immediate = 16'h2000;
        wait_cycles(3); // JAL precisa de 3 ciclos
        $display("  JAL deve: PC Write=1, MUX PC=11, Reg Write=1, MUX WR Reg=10, MUX WD Reg=010");
        display_control_signals();
        $display("");
        
        $display("\n=== TESTES J-TYPE CONCLUÍDOS ===\n");
        $display("Instruções testadas:");
        $display("- J (opcode 6'h02): Jump incondicional");
        $display("- JAL (opcode 6'h03): Jump and Link");
        $finish;
    end
    
    // Monitor para acompanhar mudanças críticas
    always @(posedge clk) begin
        if (pc_write) begin
            $display("[MONITOR] PC Write ativo - MUX PC: %b, Opcode: %h, Immediate: %h", 
                     mux_pc, opcode, immediate);
        end
    end
    
endmodule