`timescale 1ns / 1ps

module test_i_type;

    // Sinais
    reg clk;
    reg reset;
    reg [31:0] instruction;
    
    // Saídas da control_unit
    wire reg_dst;
    wire alu_src;
    wire [3:0] alu_op;
    wire [3:0] alu_control;
    wire reg_write;
    wire pc_write;
    wire [1:0] pc_source;
    wire branch;
    wire pc_write_cond;
    wire [1:0] shift_amt_selector;
    wire mem_read;
    wire mem_to_reg;
    wire [1:0] load_size_control;
    wire mem_write;
    wire [1:0] store_size_control;
    wire [4:0] current_state;
    
    // Instância da control_unit
    control_unit uut (
        .clk(clk),
        .reset(reset),
        .instruction(instruction),
        .reg_dst(reg_dst),
        .alu_src(alu_src),
        .alu_op(alu_op),
        .alu_control(alu_control),
        .reg_write(reg_write),
        .pc_write(pc_write),
        .pc_source(pc_source),
        .branch(branch),
        .pc_write_cond(pc_write_cond),
        .shift_amt_selector(shift_amt_selector),
        .mem_read(mem_read),
        .mem_to_reg(mem_to_reg),
        .load_size_control(load_size_control),
        .mem_write(mem_write),
        .store_size_control(store_size_control),
        .current_state(current_state)
    );
    
    // Clock
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    
    // Reset
    task reset_system;
        begin
            reset = 1;
            #20;
            reset = 0;
            #10;
        end
    endtask
    
    // Executar instrução
    task exec_instr(input [31:0] instr);
        begin
            instruction = instr;
            repeat(5) @(posedge clk);
        end
    endtask
    
    initial begin
        $dumpfile("test_i_type.vcd");
        $dumpvars(0, test_i_type);
        
        reset_system();
        
        // ADDI
        $display("ADDI");
        exec_instr(32'h2001000F); // addi $1, $zero, 15
        exec_instr(32'h20220019); // addi $2, $1, 25  
        exec_instr(32'h2043FFF6); // addi $3, $2, -10
        
        // BEQ, BNE
        $display("BEQ, BNE");
        exec_instr(32'h20010005); // addi $1, $zero, 5
        exec_instr(32'h20020005); // addi $2, $zero, 5
        exec_instr(32'h10220003); // beq $1, $2, iguais
        exec_instr(32'h200303E7); // addi $3, $zero, 999
        exec_instr(32'h2001000A); // addi $1, $zero, 10
        exec_instr(32'h14220002); // bne $1, $2, diferentes
        exec_instr(32'h20040378); // addi $4, $zero, 888
        exec_instr(32'h2002000A); // addi $2, $zero, 10
        exec_instr(32'h14220002); // bne $1, $2, erro
        exec_instr(32'h20050064); // addi $5, $zero, 100
        exec_instr(32'h20060309); // addi $6, $zero, 777
        
        // LUI
        $display("LUI");
        exec_instr(32'h3C010001); // lui $1, 1
        exec_instr(32'h3C020007); // lui $2, 7
        exec_instr(32'h3C0300FF); // lui $3, 255
        exec_instr(32'h20640200); // addi $4, $3, 512
        
        // SW, LW, SB, LB
        $display("SW, LW, SB, LB");
        exec_instr(32'h3C0100C8); // lui $1, 200
        exec_instr(32'h20210096); // addi $1, $1, 150
        exec_instr(32'h2021004B); // addi $1, $1, 75
        exec_instr(32'hAC010064); // sw $1, 100($zero)
        exec_instr(32'h8C020064); // lw $2, 100($zero)
        exec_instr(32'h80030064); // lb $3, 100($zero)
        exec_instr(32'h80040065); // lb $4, 101($zero)
        
        exec_instr(32'hAC0100C8); // sw $1, 200($zero)
        exec_instr(32'hA00100D2); // sb $1, 210($zero)
        exec_instr(32'h8C0200C8); // lw $2, 200($zero)
        exec_instr(32'h8C0300D2); // lw $3, 210($zero)
        exec_instr(32'h20050033); // addi $5, $zero, 51
        exec_instr(32'hA00500C8); // sb $5, 200($zero)
        exec_instr(32'h8C0600C8); // lw $6, 200($zero)
        
        // SLLM
        $display("SLLM");
        exec_instr(32'h20010005); // addi $1, $zero, 5
        exec_instr(32'h20020003); // addi $2, $zero, 3
        exec_instr(32'hAC020032); // sw $2, 50($zero)
        exec_instr(32'h1C030032); // sllm $3, 50($zero)
        exec_instr(32'h20040007); // addi $4, $zero, 7
        exec_instr(32'h20050004); // addi $5, $zero, 4
        exec_instr(32'hAC05003C); // sw $5, 60($zero)
        exec_instr(32'h1C06003C); // sllm $6, 60($zero)
        
        $display("Testes concluidos");
        $finish;
    end
    
endmodule