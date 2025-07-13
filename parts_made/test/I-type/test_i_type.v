// Teste das Instruções I-type do Control Unit
`timescale 1ns/1ps

module test_i_type;
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
    
    // Geração do clock
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
    
    // Task para executar uma instrução I-type
    task execute_i_instruction;
        input [5:0] op;
        input [4:0] rs;
        input [4:0] rt;
        input [15:0] imm;
        begin
            instruction = {op, rs, rt, imm};
            wait_cycles(4); // FETCH -> DECODE -> EXECUTE -> (MEMORY se necessário)
        end
    endtask
    
    // Task para exibir sinais de controle
    task display_control_signals;
        input [80*8-1:0] instr_name;
        begin
            $display("  %s - Sinais de Controle:", instr_name);
            $display("    ALU_Control: %b | RegWrite: %b | MemWrite: %b | State: %d", alu_control, reg_write, mem_write, current_state);
            $display("    RegDst: %b | ALUSrc: %b | MemToReg: %b", reg_dst, alu_src, mem_to_reg);
            $display("    Branch: %b | Jump: %b | PC_Write: %b", branch, jump, pc_write);
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
        
        // === 1. TESTE ADDI - Operações Aritméticas ===
        $display("=== 1. TESTE ADDI - Operações Aritméticas ===\n");
        reset_system();
        
        $display("Sequência: Construindo valor 5000 usando ADDI");
        $display("  ADDI $1, $0, 1000  // $1 = 0 + 1000 = 1000");
        execute_i_instruction(6'h08, 16'h03E8); // ADDI $1, $0, 1000
        display_control_signals("ADDI");
        
        $display("  ADDI $1, $1, 1000  // $1 = 1000 + 1000 = 2000");
        execute_i_instruction(6'h08, 16'h43E8); // ADDI $1, $1, 1000 (rs=1, rt=1)
        display_control_signals("ADDI");
        
        $display("  ADDI $1, $1, 3000  // $1 = 2000 + 3000 = 5000");
        execute_i_instruction(6'h08, 16'h4BB8); // ADDI $1, $1, 3000
        display_control_signals("ADDI");
        
        // === 2. TESTE BEQ/BNE - Branches Condicionais ===
        $display("\n=== 2. TESTE BEQ/BNE - Branches Condicionais ===\n");
        reset_system();
        
        $display("Preparação: Carregando valores iguais nos registradores");
        $display("  ADDI $1, $0, 100   // $1 = 100");
        execute_i_instruction(6'h08, 16'h0064); // ADDI $1, $0, 100
        display_control_signals("ADDI");
        
        $display("  ADDI $2, $0, 100   // $2 = 100");
        execute_i_instruction(6'h08, 16'h0864); // ADDI $2, $0, 100 (rt=2)
        display_control_signals("ADDI");
        
        $display("Teste BEQ com valores iguais:");
        $display("  BEQ $1, $2, 4      // Branch se $1 == $2 (deve fazer branch)");
        execute_i_instruction(6'h04, 16'h4404); // BEQ $1, $2, 4
        display_control_signals("BEQ");
        
        $display("Teste BNE com valores iguais:");
        $display("  BNE $1, $2, 4      // Branch se $1 != $2 (não deve fazer branch)");
        execute_i_instruction(6'h05, 16'h4404); // BNE $1, $2, 4
        display_control_signals("BNE");
        
        // === 3. TESTE LB/LW - Load Operations ===
        $display("\n=== 3. TESTE LB/LW - Load Operations ===\n");
        reset_system();
        
        $display("Preparação: Configurando endereço base");
        $display("  ADDI $2, $0, 100   // $2 = 100 (endereço base)");
        execute_i_instruction(6'h08, 16'h0864); // ADDI $2, $0, 100
        display_control_signals("ADDI");
        
        $display("Teste LW - Load Word:");
        $display("  LW $3, 4($2)       // $3 = MEM[$2 + 4] = MEM[104]");
        execute_i_instruction(6'h23, 16'h4C04); // LW $3, 4($2)
        display_control_signals("LW");
        
        $display("Teste LB - Load Byte:");
        $display("  LB $4, 8($2)       // $4 = MEM[$2 + 8] = MEM[108] (byte)");
        execute_i_instruction(6'h20, 16'h5008); // LB $4, 8($2)
        display_control_signals("LB");
        
        // === 4. TESTE LUI - Load Upper Immediate ===
        $display("\n=== 4. TESTE LUI - Load Upper Immediate ===\n");
        reset_system();
        
        $display("Teste LUI - Carregando valor nos 16 bits superiores:");
        $display("  LUI $1, 2730       // $1 = 2730 << 16 = 0xAAA0000");
        execute_i_instruction(6'h0F, 16'h0AAA); // LUI $1, 2730
        display_control_signals("LUI");
        
        $display("Complementando com ADDI:");
        $display("  ADDI $1, $1, 1000  // $1 = 0xAAA0000 + 1000");
        execute_i_instruction(6'h08, 16'h43E8); // ADDI $1, $1, 1000
        display_control_signals("ADDI");
        
        // === 5. TESTE SB/SW - Store Operations ===
        $display("\n=== 5. TESTE SB/SW - Store Operations ===\n");
        reset_system();
        
        $display("Preparação: Carregando valores para armazenar");
        $display("  LUI $1, 2730       // $1 = valor alto");
        execute_i_instruction(6'h0F, 16'h0AAA); // LUI $1, 2730
        display_control_signals("LUI");
        
        $display("  ADDI $1, $1, 5000  // $1 = valor final");
        execute_i_instruction(6'h08, 16'h5388); // ADDI $1, $1, 5000
        display_control_signals("ADDI");
        
        $display("Teste SW - Store Word:");
        $display("  SW $1, 154($0)     // MEM[154] = $1");
        execute_i_instruction(6'h2B, 16'h009A); // SW $1, 154($0)
        display_control_signals("SW");
        
        $display("Teste SB - Store Byte:");
        $display("  SB $1, 200($0)     // MEM[200] = $1[7:0]");
        execute_i_instruction(6'h28, 16'h00C8); // SB $1, 200($0)
        display_control_signals("SB");
        
        // === 6. TESTE SLLM - Shift Left Logical Memory ===
        $display("\n=== 6. TESTE SLLM - Shift Left Logical Memory ===\n");
        reset_system();
        
        $display("Preparação: Carregando valor para shift");
        $display("  ADDI $2, $0, 15    // $2 = 15 (valor a ser shiftado)");
        execute_i_instruction(6'h08, 16'h080F); // ADDI $2, $0, 15
        display_control_signals("ADDI");
        
        $display("Teste SLLM - Shift Left 4 posições:");
        $display("  SLLM $1, $2, 4     // $1 = $2 << 4 = 15 << 4 = 240");
        execute_i_instruction(6'h09, 16'h4404); // SLLM $1, $2, 4
        display_control_signals("SLLM");
        
        // === TESTE INTEGRADO - Exemplo Completo ===
        $display("\n=== TESTE INTEGRADO - Exemplo Completo ===\n");
        reset_system();
        
        $display("Sequência completa como no exemplo fornecido:");
        $display("  LUI $1, 2730       // Carrega valor alto");
        execute_i_instruction(6'h0F, 16'h0AAA);
        display_control_signals("LUI");
        
        $display("  ADDI $1, $1, 1000  // Incrementa 5x");
        execute_i_instruction(6'h08, 16'h43E8);
        execute_i_instruction(6'h08, 16'h43E8);
        execute_i_instruction(6'h08, 16'h43E8);
        execute_i_instruction(6'h08, 16'h43E8);
        execute_i_instruction(6'h08, 16'h43E8);
        display_control_signals("ADDI (final)");
        
        $display("  SW $1, 154($0)     // Armazena na memória");
        execute_i_instruction(6'h2B, 16'h009A);
        display_control_signals("SW");
        
        $display("  LW $2, 154($0)     // Carrega palavra completa");
        execute_i_instruction(6'h23, 16'h089A);
        display_control_signals("LW");
        
        $display("  LB $4, 154($0)     // Carrega apenas 8 bits LSB");
        execute_i_instruction(6'h20, 16'h109A);
        display_control_signals("LB");
        
        $display("\n=== TODOS OS TESTES I-TYPE CONCLUÍDOS ===\n");
        $display("\n=== SINAIS PARA GTKWAVE ===\n");
        $display("Sinais principais para visualização:");
        $display("- clk");
        $display("- reset_in");
        $display("- opcode[5:0]");
        $display("- immediate[15:0]");
        $display("- reg_wr");
        $display("- memory_wr");
        $display("- pc_write");
        $display("- is_beq");
        $display("- is_bne");
        $display("- ula[2:0]");
        $display("- shift[2:0]");
        $display("- mux_alu2[1:0]");
        $display("- mux_wr_registers[1:0]");
        $display("- mux_wd_registers[2:0]");
        $display("- mux_extend");
        $display("- load_size[1:0]");
        $display("- store_size");
        $display("- mux_shift_amt[1:0]");
        $finish;
    end
    
endmodule