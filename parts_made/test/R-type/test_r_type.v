// Teste das Instruções R-type do Control Unit
`timescale 1ns/1ps

module test_r_type;
    // Sinais de entrada
    reg clk;
    reg reset;
    reg [31:0] instruction;
    reg zero_flag;
    reg overflow;
    reg div_zero;
    
    // Sinais de saída - campos da instrução
    wire [5:0] opcode;
    wire [4:0] rs;
    wire [4:0] rt;
    wire [4:0] rd;
    wire [4:0] shamt;
    wire [5:0] funct;
    wire [15:0] immediate;
    wire [25:0] address;
    
    // Sinais de controle da ALU
    wire [3:0] alu_control;
    wire alu_zero;
    wire alu_overflow;
    
    // Sinais de controle principais
    wire reg_dst;
    wire jump;
    wire branch;
    wire mem_read;
    wire mem_to_reg;
    wire [3:0] alu_op;
    wire mem_write;
    wire alu_src;
    wire reg_write;
    
    // Controles de Load/Store
    wire [1:0] load_size_control;
    wire [1:0] store_size_control;
    
    // Controles do PC
    wire pc_write;
    wire pc_write_cond;
    wire [1:0] pc_source;
    
    // Estado atual
    wire [4:0] current_state;
    
    // Instanciação do módulo control_unit
    control_unit uut (
        .clk(clk),
        .reset(reset),
        .instruction(instruction),
        .zero_flag(zero_flag),
        .overflow(overflow),
        .div_zero(div_zero),
        
        // Campos da instrução
        .opcode(opcode),
        .rs(rs),
        .rt(rt),
        .rd(rd),
        .shamt(shamt),
        .funct(funct),
        .immediate(immediate),
        .address(address),
        
        // Controles da ALU
        .alu_control(alu_control),
        .alu_zero(alu_zero),
        .alu_overflow(alu_overflow),
        
        // Sinais de controle principais
        .reg_dst(reg_dst),
        .jump(jump),
        .branch(branch),
        .mem_read(mem_read),
        .mem_to_reg(mem_to_reg),
        .alu_op(alu_op),
        .mem_write(mem_write),
        .alu_src(alu_src),
        .reg_write(reg_write),
        
        // Controles de Load/Store
        .load_size_control(load_size_control),
        .store_size_control(store_size_control),
        
        // Controles do PC
        .pc_write(pc_write),
        .pc_write_cond(pc_write_cond),
        .pc_source(pc_source),
        
        // Estado atual
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
    
    // Task para executar ADDIU (I-type)
    task execute_addiu;
        input [4:0] rt;
        input [4:0] rs;
        input [15:0] imm;
        begin
            $display("  Executando: ADDIU $%0d, $%0d, %0d", rt, rs, imm);
            instruction = {6'h09, rs, rt, imm}; // ADDIU: opcode[31:26], rs[25:21], rt[20:16], imm[15:0]
            wait_cycles(6); // Aguardar processamento completo
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
            instruction = {6'h00, rs, rt, rd, shamt, funct}; // R-type: opcode[31:26], rs[25:21], rt[20:16], rd[15:11], shamt[10:6], funct[5:0]
            
            // Aguardar até que o estado não seja FETCH ou DECODE
            while (current_state == 5'b00001 || current_state == 5'b00010) begin
                @(posedge clk);
            end
            
            // Capturar sinais no estado específico da instrução (antes de voltar para FETCH)
            $display("    ALU_Control: %04b, ALU_OP: %04b, Reg_Write: %b, Current_State: %05b", 
                     alu_control, alu_op, reg_write, current_state);
            $display("    Reg_Dst: %b, ALU_Src: %b, Mem_to_Reg: %b, PC_Write: %b", 
                     reg_dst, alu_src, mem_to_reg, pc_write);
                     
            wait_cycles(2); // Aguardar conclusão
        end
    endtask
    
    // Task para aguardar operações de multiplicação/divisão
    task wait_mult_div_operation;
        begin
            // Aguardar alguns ciclos para operações de mult/div
            wait_cycles(2);
        end
    endtask
    
    // Configuração para dump VCD
    initial begin
        $dumpfile("test_r_type.vcd");
        $dumpvars(0, test_r_type);
    end
    
    // Testes principais
    initial begin
        $display("=== TESTE DAS INSTRUÇÕES R-TYPE - VERSÃO REESCRITA ===\n");
        
        // ========================================
        // TESTE 1: AND
        // addiu $1, $zero, 13
        // addiu $2, $zero, 10  
        // and $3, $1, $2
        // ========================================
        $display("=== TESTE 1: AND ===");
        reset_system();
        
        execute_addiu(1, 0, 13);  // addiu $1, $zero, 13
        execute_addiu(2, 0, 10);  // addiu $2, $zero, 10
        $display("  Executando: AND $3, $1, $2");
        execute_r_type(1, 2, 3, 0, 6'h24); // AND
        
        $display("Teste AND concluído\n");
        
        // ========================================
        // TESTE 2: DIV, MFHI, MFLO
        // addiu $1, $zero, 23
        // addiu $2, $zero, 7
        // div $1, $2
        // mfhi $3
        // mflo $4
        // ========================================
        $display("=== TESTE 2: DIV, MFHI, MFLO ===");
        reset_system();
        
        execute_addiu(1, 0, 23);  // addiu $1, $zero, 23
        execute_addiu(2, 0, 7);   // addiu $2, $zero, 7
        $display("  Executando: DIV $1, $2");
        execute_r_type(1, 2, 0, 0, 6'h1A); // DIV
        wait_mult_div_operation(); // Aguardar operação de divisão
        $display("  Executando: MFHI $3");
        execute_r_type(0, 0, 3, 0, 6'h10); // MFHI
        $display("  Executando: MFLO $4");
        execute_r_type(0, 0, 4, 0, 6'h12); // MFLO
        
        $display("Teste DIV, MFHI, MFLO concluído\n");
        
        // ========================================
        // TESTE 3: MULT, MFHI, MFLO
        // addiu $1, $zero, 4
        // addiu $2, $zero, 3
        // mult $1, $2
        // mfhi $2
        // mflo $1
        // ========================================
        $display("=== TESTE 3: MULT, MFHI, MFLO ===");
        reset_system();
        
        execute_addiu(1, 0, 4);   // addiu $1, $zero, 4
        execute_addiu(2, 0, 3);   // addiu $2, $zero, 3
        $display("  Executando: MULT $1, $2");
        execute_r_type(1, 2, 0, 0, 6'h18); // MULT
        wait_mult_div_operation(); // Aguardar operação de multiplicação
        $display("  Executando: MFHI $2");
        execute_r_type(0, 0, 2, 0, 6'h10); // MFHI
        $display("  Executando: MFLO $1");
        execute_r_type(0, 0, 1, 0, 6'h12); // MFLO
        
        $display("Teste MULT, MFHI, MFLO concluído\n");
        
        // ========================================
        // TESTE 4: SLL
        // addiu $3, $zero, 32
        // sll $3, $3, 4
        // ========================================
        $display("=== TESTE 4: SLL ===");
        reset_system();
        
        execute_addiu(3, 0, 32);  // addiu $3, $zero, 32
        $display("  Executando: SLL $3, $3, 4");
        execute_r_type(0, 3, 3, 4, 6'h00); // SLL
        
        $display("Teste SLL concluído\n");
        
        // ========================================
        // TESTE 5: SLT
        // addiu $1, $zero, 3
        // addiu $2, $zero, 4
        // slt $3, $1, $2
        // slt $3, $2, $2
        // addiu $3, $zero, 1
        // slt $3, $2, $1
        // ========================================
        $display("=== TESTE 5: SLT ===");
        reset_system();
        
        execute_addiu(1, 0, 3);   // addiu $1, $zero, 3
        execute_addiu(2, 0, 4);   // addiu $2, $zero, 4
        $display("  Executando: SLT $3, $1, $2");
        execute_r_type(1, 2, 3, 0, 6'h2A); // SLT (3 < 4 = 1)
        $display("  Executando: SLT $3, $2, $2");
        execute_r_type(2, 2, 3, 0, 6'h2A); // SLT (4 < 4 = 0)
        execute_addiu(3, 0, 1);   // addiu $3, $zero, 1
        $display("  Executando: SLT $3, $2, $1");
        execute_r_type(2, 1, 3, 0, 6'h2A); // SLT (4 < 3 = 0)
        
        $display("Teste SLT concluído\n");
        
        // ========================================
        // TESTE 6: SRA
        // addiu $1, $zero, -6 (complemento de 2)
        // sra $1, $1, 1
        // ========================================
        $display("=== TESTE 6: SRA ===");
        reset_system();
        
        execute_addiu(1, 0, 16'hFFFA); // addiu $1, $zero, -6 (0xFFFA = -6 em complemento de 2)
        $display("  Executando: SRA $1, $1, 1");
        execute_r_type(0, 1, 1, 1, 6'h03); // SRA
        
        $display("Teste SRA concluído\n");
        
        // ========================================
        // TESTE 7: SUB
        // addiu $1, $zero, 15
        // addiu $2, $zero, 10
        // sub $3, $1, $2
        // ========================================
        $display("=== TESTE 7: SUB ===");
        reset_system();
        
        execute_addiu(1, 0, 15);  // addiu $1, $zero, 15
        execute_addiu(2, 0, 10);  // addiu $2, $zero, 10
        $display("  Executando: SUB $3, $1, $2");
        execute_r_type(1, 2, 3, 0, 6'h22); // SUB
        
        $display("Teste SUB concluído\n");
        
        // ========================================
        // TESTE 8: XCHG
        // addiu $1, $zero, 2
        // addiu $2, $zero, 3
        // xchg $1, $2
        // ========================================
        $display("=== TESTE 8: XCHG ===");
        reset_system();
        
        execute_addiu(1, 0, 2);   // addiu $1, $zero, 2
        execute_addiu(2, 0, 3);   // addiu $2, $zero, 3
        $display("  Executando: XCHG $1, $2");
        execute_r_type(1, 2, 0, 0, 6'h05); // XCHG
        
        $display("Teste XCHG concluído\n");
        
        // ========================================
        // TESTE 9: ADD
        // addiu $1, $zero, 10
        // addiu $2, $zero, 5
        // add $3, $1, $2
        // ========================================
        $display("=== TESTE 9: ADD ===");
        reset_system();
        
        execute_addiu(1, 0, 10);  // addiu $1, $zero, 10
        execute_addiu(2, 0, 5);   // addiu $2, $zero, 5
        $display("  Executando: ADD $3, $1, $2");
        execute_r_type(1, 2, 3, 0, 6'h20); // ADD
        
        $display("Teste ADD concluído\n");
        
        // ========================================
        // TESTE 10: JR
        // addiu $31, $zero, 100
        // jr $31
        // ========================================
        $display("=== TESTE 10: JR ===");
        reset_system();
        
        execute_addiu(31, 0, 100); // addiu $31, $zero, 100 (carregar endereço em $ra)
        $display("  Executando: JR $31");
        execute_r_type(31, 0, 0, 0, 6'h08); // JR
        
        $display("Teste JR concluído\n");
        
        $display("\n=== RESUMO DOS SINAIS PARA GTKWAVE ===");
        $display("Sinais principais para visualização:");
        $display("- clk, reset");
        $display("- instruction[31:0], current_state[4:0]");
        $display("- opcode[5:0], rs[4:0], rt[4:0], rd[4:0], funct[5:0]");
        $display("- alu_control[3:0], alu_op[3:0]");
        $display("- reg_write, mem_write, pc_write");
        $display("- reg_dst, alu_src, mem_to_reg");
        $display("- branch, jump, pc_source[1:0]");
        $display("- load_size_control[1:0], store_size_control[1:0]");
        $display("- zero_flag, overflow, div_zero");
        $display("- alu_zero, alu_overflow");
        
        $display("\n=== TODOS OS TESTES R-TYPE CONCLUÍDOS ===");
        $finish;
    end
    
endmodule