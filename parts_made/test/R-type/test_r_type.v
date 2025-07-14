// Teste das Instruções R-type
`timescale 1ns/1ps

module test_r_type;
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
    
    // Task para executar uma instrução
    task execute_instruction;
        input [31:0] instr;
        begin
            instruction = instr;
            wait_cycles(3); // FETCH -> DECODE -> EXECUTE
        end
    endtask
    
    // Início dos testes
    initial begin
        $dumpfile("test_r_type.vcd");
        $dumpvars(0, test_r_type);
        
        reset_system();
        
        $display("=== TESTE 1: AND ===");
        execute_instruction({6'h08, 5'd0, 5'd1, 16'd12});    // addiu $1, $zero, 12
        execute_instruction({6'h08, 5'd0, 5'd2, 16'd14});    // addiu $2, $zero, 14
        execute_instruction({6'h00, 5'd1, 5'd2, 5'd3, 5'd0, 6'h24}); // and $3, $1, $2
        $display("Teste AND concluído\n");
        
        $display("=== TESTE 2: DIV, MFHI, MFLO ===");
        execute_instruction({6'h08, 5'd0, 5'd1, 16'd21});    // addiu $1, $zero, 21
        execute_instruction({6'h08, 5'd0, 5'd2, 16'd7});     // addiu $2, $zero, 7
        execute_instruction({6'h00, 5'd1, 5'd2, 5'd0, 5'd0, 6'h1a}); // div $1, $2
        execute_instruction({6'h00, 5'd0, 5'd0, 5'd3, 5'd0, 6'h10}); // mfhi $3
        execute_instruction({6'h00, 5'd0, 5'd0, 5'd4, 5'd0, 6'h12}); // mflo $4
        $display("Teste DIV, MFHI, MFLO concluído\n");
        
        $display("=== TESTE 3: MULT, MFHI, MFLO ===");
        execute_instruction({6'h08, 5'd0, 5'd1, 16'd4});     // addiu $1, $zero, 4
        execute_instruction({6'h08, 5'd0, 5'd2, 16'd3});     // addiu $2, $zero, 3
        execute_instruction({6'h00, 5'd1, 5'd2, 5'd0, 5'd0, 6'h18}); // mult $1, $2
        execute_instruction({6'h00, 5'd0, 5'd0, 5'd2, 5'd0, 6'h10}); // mfhi $2
        execute_instruction({6'h00, 5'd0, 5'd0, 5'd1, 5'd0, 6'h12}); // mflo $1
        $display("Teste MULT, MFHI, MFLO concluído\n");
        
        $display("=== TESTE 4: SLL ===");
        execute_instruction({6'h08, 5'd0, 5'd3, 16'd32});    // addiu $3, $zero, 32
        execute_instruction({6'h00, 5'd0, 5'd3, 5'd3, 5'd4, 6'h00}); // sll $3, $3, 4
        $display("Teste SLL concluído\n");
        
        $display("=== TESTE 5: SLT ===");
        execute_instruction({6'h08, 5'd0, 5'd1, 16'd3});     // addiu $1, $zero, 3
        execute_instruction({6'h08, 5'd0, 5'd2, 16'd4});     // addiu $2, $zero, 4
        execute_instruction({6'h00, 5'd1, 5'd2, 5'd3, 5'd0, 6'h2a}); // slt $3, $1, $2
        execute_instruction({6'h00, 5'd2, 5'd2, 5'd3, 5'd0, 6'h2a}); // slt $3, $2, $2
        execute_instruction({6'h08, 5'd0, 5'd3, 16'd1});     // addiu $3, $zero, 1
        execute_instruction({6'h00, 5'd2, 5'd1, 5'd3, 5'd0, 6'h2a}); // slt $3, $2, $1
        $display("Teste SLT concluído\n");
        
        $display("=== TESTE 6: SRA ===");
        execute_instruction({6'h08, 5'd0, 5'd1, 16'hfffa});  // addiu $1, $zero, -6
        execute_instruction({6'h00, 5'd0, 5'd1, 5'd1, 5'd1, 6'h03}); // sra $1, $1, 1
        $display("Teste SRA concluído\n");
        
        $display("=== TESTE 7: SUB ===");
        execute_instruction({6'h08, 5'd0, 5'd1, 16'd15});    // addiu $1, $zero, 15
        execute_instruction({6'h08, 5'd0, 5'd2, 16'd10});    // addiu $2, $zero, 10
        execute_instruction({6'h00, 5'd1, 5'd2, 5'd3, 5'd0, 6'h22}); // sub $3, $1, $2
        $display("Teste SUB concluído\n");
        
        $display("=== TESTE 8: XCHG ===");
        execute_instruction({6'h08, 5'd0, 5'd1, 16'd2});     // addiu $1, $zero, 2
        execute_instruction({6'h08, 5'd0, 5'd2, 16'd3});     // addiu $2, $zero, 3
        execute_instruction({6'h00, 5'd1, 5'd2, 5'd0, 5'd0, 6'h05}); // xchg $1, $2
        $display("Teste XCHG concluído\n");
        
        $display("=== TESTE 9: ADD ===");
        execute_instruction({6'h08, 5'd0, 5'd1, 16'd3});     // addiu $1, $zero, 3
        execute_instruction({6'h08, 5'd0, 5'd2, 16'd4});     // addiu $2, $zero, 4
        execute_instruction({6'h00, 5'd1, 5'd2, 5'd3, 5'd0, 6'h20}); // add $3, $1, $2
        $display("Teste ADD concluído\n");
        
        $display("=== TESTE 10: JR ===");
        execute_instruction({6'h08, 5'd0, 5'd31, 16'd20});   // addiu $31, $zero, 20
        execute_instruction({6'h00, 5'd31, 5'd0, 5'd0, 5'd0, 6'h08}); // jr $31
        execute_instruction({6'h08, 5'd0, 5'd0, 16'd20});    // addiu $0, $zero, 20
        $display("Teste JR concluído\n");
        
        $display("=== TODOS OS TESTES R-TYPE CONCLUÍDOS ===");
        $finish;
    end
    
endmodule