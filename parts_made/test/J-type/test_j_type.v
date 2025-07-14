`timescale 1ns/1ps

module test_j_type;
    // Sinais
    reg clk;
    reg reset;
    reg [31:0] instruction;
    
    // Saídas da control_unit
    wire [3:0] alu_control;
    wire [3:0] alu_op;
    wire reg_write;
    wire mem_read;
    wire mem_write;
    wire pc_write;
    wire branch;
    wire jump;
    wire alu_src;
    wire reg_dst;
    wire mem_to_reg;
    wire [1:0] load_size_control;
    wire [1:0] store_size_control;
    wire [1:0] shift_amt_selector;
    wire [1:0] pc_source;
    wire pc_write_cond;
    wire [4:0] current_state;
    
    // Instanciação da control_unit
    control_unit uut (
        .clk(clk),
        .reset(reset),
        .instruction(instruction),
        .alu_control(alu_control),
        .alu_op(alu_op),
        .reg_write(reg_write),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .pc_write(pc_write),
        .branch(branch),
        .jump(jump),
        .alu_src(alu_src),
        .reg_dst(reg_dst),
        .mem_to_reg(mem_to_reg),
        .load_size_control(load_size_control),
        .store_size_control(store_size_control),
        .shift_amt_selector(shift_amt_selector),
        .pc_source(pc_source),
        .pc_write_cond(pc_write_cond),
        .current_state(current_state)
    );
    
    // Gerador de clock
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // Clock de 10ns
    end
    
    // Task para reset
    task do_reset;
        begin
            reset = 1;
            #20;
            reset = 0;
            #10;
        end
    endtask
    
    // Task para esperar ciclos
    task wait_cycles;
        input integer cycles;
        begin
            repeat(cycles) @(posedge clk);
        end
    endtask
    
    // Task para executar instrução
    task execute_instruction;
        input [31:0] instr;
        input [7*8:1] name;
        begin
            $display("Executando %s: %h", name, instr);
            instruction = instr;
            wait_cycles(5); // Espera 5 ciclos para execução completa
        end
    endtask
    
    // Teste principal
    initial begin
        $dumpfile("test_j_type.vcd");
        $dumpvars(0, test_j_type);
        
        $display("=== Iniciando Teste J-type ===");
        
        // Reset inicial
        do_reset();
        
        $display("\n=== Testando Instruções J-type ===");
        
        // Teste J - Jump para linha 12
        // j 12 -> opcode=000010, address=000000000000000000001100 (12)
        execute_instruction(32'b00001000000000000000000000001100, "J");
        
        wait_cycles(3);
        
        // Teste JAL - p/  linha 0, salva PC+4 no reg 31
        // jal 0 -> opcode=000011, address=000000000000000000000000 (0)
        execute_instruction(32'b00001100000000000000000000000000, "JAL");
        
        wait_cycles(5);
        
        $display("\n=== Teste J-type Concluído ===");
        $finish;
    end
    
endmodule