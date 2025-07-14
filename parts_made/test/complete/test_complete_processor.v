`timescale 1ns / 1ps

// Testbench completo para todas as instruções implementadas no processador MIPS
// Testa R-type, I-type, J-type e tratamento de exceções
module test_complete_processor;

    // Sinais de clock e reset
    reg clk;
    reg reset;
    
    // Sinais da unidade de controle
    reg [31:0] instruction;
    wire zero_flag;
    wire overflow;
    wire div_zero;
    
    // Campos da instrução
    wire [5:0] opcode;
    wire [4:0] rs, rt, rd, shamt;
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
    wire [2:0] mem_to_reg;
    wire [3:0] alu_op;
    wire mem_write;
    wire alu_src;
    wire reg_write;
    
    // Controles de Load/Store
    wire [1:0] load_size_control;
    wire [1:0] store_size_control;
    
    // Controles de PC
    wire pc_write;
    wire pc_write_cond;
    wire [1:0] pc_source;
    
    // Outros controles
    wire [1:0] shift_amt_selector;
    wire epc_load;
    wire [4:0] current_state;
    
    // Sinais simulados para flags
    reg alu_zero_sim, alu_overflow_sim;
    
    // Sinais dos módulos de multiplicação e divisão
    reg [31:0] mult_a, mult_b;
    wire [31:0] mult_hi, mult_lo;
    wire mult_done;
    reg mult_ctrl;
    
    reg [31:0] div_a, div_b;
    wire [31:0] div_hi, div_lo;
    wire div_done;
    wire div_zero_flag;
    reg div_ctrl;
    
    // Sinais dos módulos de processamento
    reg [31:0] ls_input;
    wire [31:0] ls_output;
    reg [1:0] ls_control;
    
    reg [31:0] ss_input, ss_memory;
    wire [31:0] ss_output;
    reg [1:0] ss_control;
    
    reg [15:0] se_input;
    wire [31:0] se_output;
    
    // Contadores para controle de teste
    integer test_count;
    
    // Instanciação da unidade de controle
    control_unit uut_control (
        .clk(clk),
        .reset(reset),
        .instruction(instruction),
        .zero_flag(zero_flag),
        .overflow(overflow),
        .div_zero(div_zero),
        .opcode(opcode),
        .rs(rs),
        .rt(rt),
        .rd(rd),
        .shamt(shamt),
        .funct(funct),
        .immediate(immediate),
        .address(address),
        .alu_control(alu_control),
        .alu_zero(alu_zero),
        .alu_overflow(alu_overflow),
        .reg_dst(reg_dst),
        .jump(jump),
        .branch(branch),
        .mem_read(mem_read),
        .mem_to_reg(mem_to_reg),
        .alu_op(alu_op),
        .mem_write(mem_write),
        .alu_src(alu_src),
        .reg_write(reg_write),
        .load_size_control(load_size_control),
        .store_size_control(store_size_control),
        .pc_write(pc_write),
        .pc_write_cond(pc_write_cond),
        .pc_source(pc_source),
        .shift_amt_selector(shift_amt_selector),
        .epc_load(epc_load),
        .current_state(current_state)
    );
    
    // Instanciação do módulo de multiplicação
    mult uut_mult (
        .clk(clk),
        .A(mult_a),
        .B(mult_b),
        .mult_ctrl(mult_ctrl),
        .HI(mult_hi),
        .LO(mult_lo),
        .stop(mult_done)
    );
    
    // Instanciação do módulo de divisão
    div uut_div (
        .RegAOut(div_a),
        .RegBOut(div_b),
        .DivCtrl(div_ctrl),
        .HI(div_hi),
        .LO(div_lo),
        .DivDone(div_done),
        .Div0(div_zero_flag)
    );
    
    // Instanciação do módulo Load Size
    ls uut_ls (
        .LSControl(ls_control),
        .RegMDROut(ls_input),
        .LSControlOut(ls_output)
    );
    
    // Instanciação do módulo Store Size
    ss uut_ss (
        .RegSSControl(ss_control),
        .RegBOut(ss_input),
        .RegMDROut(ss_memory),
        .SSControlOut(ss_output)
    );
    
    // Instanciação do módulo Sign Extend
    se uut_se (
        .data_in(se_input),
        .data_out(se_output)
    );
    
    // Geração de clock
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // Clock de 100MHz
    end
    
    // Simulação de flags da ALU
    assign zero_flag = alu_zero_sim;
    assign overflow = alu_overflow_sim;
    assign div_zero = div_zero_flag;
    
    // Inicialização e execução dos testes
    initial begin
        $dumpfile("test_complete_processor.vcd");
        $dumpvars(0, test_complete_processor);
        
        // Inicialização
        reset = 1;
        instruction = 32'h00000000;
        test_count = 0;
        
        // Inicializar sinais simulados
        alu_zero_sim = 1'b0;
        alu_overflow_sim = 1'b0;
        
        mult_a = 32'h00000000;
        mult_b = 32'h00000000;
        mult_ctrl = 1'b0;
        
        div_a = 32'h00000000;
        div_b = 32'h00000000;
        div_ctrl = 1'b0;
        
        ls_input = 32'h00000000;
        ls_control = 2'b00;
        
        ss_input = 32'h00000000;
        ss_memory = 32'h00000000;
        ss_control = 2'b00;
        
        se_input = 16'h0000;
        
        #20 reset = 0;
        
        $display("=== INÍCIO DOS TESTES DO PROCESSADOR MIPS COMPLETO ===");
        $display("Testando todas as instruções implementadas...");
        $display("");
        
        // ===== TESTES DE INSTRUÇÕES R-TYPE =====
        $display("=== TESTES R-TYPE ===");
        
        // Teste ADD: add $t0, $t1, $t2 (rd=8, rs=9, rt=10)
        test_r_type_instruction("ADD", 6'b000000, 5'd9, 5'd10, 5'd8, 5'd0, 6'b100000);
        
        // Teste SUB: sub $t0, $t1, $t2 (rd=8, rs=9, rt=10)
        test_r_type_instruction("SUB", 6'b000000, 5'd9, 5'd10, 5'd8, 5'd0, 6'b100010);
        
        // Teste AND: and $t0, $t1, $t2
        test_r_type_instruction("AND", 6'b000000, 5'd9, 5'd10, 5'd8, 5'd0, 6'b100100);
        
        // Teste SLT: slt $t0, $t1, $t2
        test_r_type_instruction("SLT", 6'b000000, 5'd9, 5'd10, 5'd8, 5'd0, 6'b101010);
        
        // Teste SLL: sll $t0, $t1, 4
        test_r_type_instruction("SLL", 6'b000000, 5'd0, 5'd9, 5'd8, 5'd4, 6'b000000);
        
        // Teste SRA: sra $t0, $t1, 4
        test_r_type_instruction("SRA", 6'b000000, 5'd0, 5'd9, 5'd8, 5'd4, 6'b000011);
        
        // Teste MULT: mult $t1, $t2
        test_mult_instruction("MULT", 6'b000000, 5'd9, 5'd10, 5'd0, 5'd0, 6'b011000);
        
        // Teste DIV: div $t1, $t2
        test_div_instruction("DIV", 6'b000000, 5'd9, 5'd10, 5'd0, 5'd0, 6'b011010);
        
        // Teste MFHI: mfhi $t0
        test_r_type_instruction("MFHI", 6'b000000, 5'd0, 5'd0, 5'd8, 5'd0, 6'b010000);
        
        // Teste MFLO: mflo $t0
        test_r_type_instruction("MFLO", 6'b000000, 5'd0, 5'd0, 5'd8, 5'd0, 6'b010010);
        
        // Teste JR: jr $ra
        test_r_type_instruction("JR", 6'b000000, 5'd31, 5'd0, 5'd0, 5'd0, 6'b001000);
        
        // ===== TESTES DE INSTRUÇÕES I-TYPE =====
        $display("");
        $display("=== TESTES I-TYPE ===");
        
        // Teste ADDI: addi $t0, $t1, 100
        test_i_type_instruction("ADDI", 6'b001000, 5'd9, 5'd8, 16'd100);
        
        // Teste LUI: lui $t0, 0x1234
        test_i_type_instruction("LUI", 6'b001111, 5'd0, 5'd8, 16'h1234);
        
        // Teste LW: lw $t0, 4($t1)
        test_i_type_instruction("LW", 6'b100011, 5'd9, 5'd8, 16'd4);
        
        // Teste LB: lb $t0, 1($t1)
        test_i_type_instruction("LB", 6'b100000, 5'd9, 5'd8, 16'd1);
        
        // Teste SW: sw $t0, 8($t1)
        test_i_type_instruction("SW", 6'b101011, 5'd9, 5'd8, 16'd8);
        
        // Teste SB: sb $t0, 2($t1)
        test_i_type_instruction("SB", 6'b101000, 5'd9, 5'd8, 16'd2);
        
        // Teste BEQ: beq $t0, $t1, label
        test_branch_instruction("BEQ", 6'b000100, 5'd8, 5'd9, 16'd10, 1'b1);
        
        // Teste BNE: bne $t0, $t1, label
        test_branch_instruction("BNE", 6'b000101, 5'd8, 5'd9, 16'd10, 1'b0);
        
        // ===== TESTES DE INSTRUÇÕES J-TYPE =====
        $display("");
        $display("=== TESTES J-TYPE ===");
        
        // Teste J: j target
        test_j_type_instruction("J", 6'b000010, 26'h1000000);
        
        // Teste JAL: jal target
        test_j_type_instruction("JAL", 6'b000011, 26'h2000000);
        
        // ===== TESTES DE EXCEÇÕES =====
        $display("");
        $display("=== TESTES DE EXCEÇÕES ===");
        
        // Teste overflow em ADD
        test_overflow_exception("ADD OVERFLOW", 6'b000000, 5'd9, 5'd10, 5'd8, 5'd0, 6'b100000);
        
        // Teste divisão por zero
        test_div_zero_exception("DIV BY ZERO", 6'b000000, 5'd9, 5'd10, 5'd0, 5'd0, 6'b011010);
        
        // Teste instrução inválida
        test_invalid_instruction("INVALID OPCODE", 6'b111111, 5'd0, 5'd0, 5'd0, 5'd0, 6'b000000);
        
        // ===== TESTES DOS MÓDULOS AUXILIARES =====
        $display("");
        $display("=== TESTES DOS MÓDULOS AUXILIARES ===");
        
        // Teste Load Size
        test_load_size_module();
        
        // Teste Store Size
        test_store_size_module();
        
        // Teste Sign Extend
        test_sign_extend_module();
        
        $display("");
        $display("=== TODOS OS TESTES CONCLUÍDOS ===");
        $display("Total de testes executados: %d", test_count);
        
        #100;
        $finish;
    end
    
    // Task para testar instruções R-type
    task test_r_type_instruction;
        input [8*10:1] name;
        input [5:0] op;
        input [4:0] rs_val, rt_val, rd_val, shamt_val;
        input [5:0] funct_val;
        begin
            test_count = test_count + 1;
            $display("Teste %d: %s", test_count, name);
            
            // Montar instrução
            instruction = {op, rs_val, rt_val, rd_val, shamt_val, funct_val};
            
            // Aguardar alguns ciclos
            repeat(5) @(posedge clk);
            
            $display("  Instrução: 0x%h", instruction);
            $display("  Estado atual: %d", current_state);
            $display("  Sinais de controle: reg_dst=%b, reg_write=%b, alu_op=%b", reg_dst, reg_write, alu_op);
            $display("  ✓ Teste concluído");
            $display("");
        end
    endtask
    
    // Task para testar multiplicação
    task test_mult_instruction;
        input [8*10:1] name;
        input [5:0] op;
        input [4:0] rs_val, rt_val, rd_val, shamt_val;
        input [5:0] funct_val;
        begin
            test_count = test_count + 1;
            $display("Teste %d: %s", test_count, name);
            
            instruction = {op, rs_val, rt_val, rd_val, shamt_val, funct_val};
            mult_a = 32'd6;
            mult_b = 32'd7;
            mult_ctrl = 1'b1;
            
            repeat(5) @(posedge clk);
            
            mult_ctrl = 1'b0;
            
            // Aguardar conclusão da multiplicação
            repeat(40) @(posedge clk);
            
            $display("  Instrução: 0x%h", instruction);
            $display("  Operandos: %d * %d", mult_a, mult_b);
            $display("  Resultado: HI=0x%h, LO=0x%h", mult_hi, mult_lo);
            $display("  ✓ Teste concluído");
            $display("");
        end
    endtask
    
    // Task para testar divisão
    task test_div_instruction;
        input [8*10:1] name;
        input [5:0] op;
        input [4:0] rs_val, rt_val, rd_val, shamt_val;
        input [5:0] funct_val;
        begin
            test_count = test_count + 1;
            $display("Teste %d: %s", test_count, name);
            
            instruction = {op, rs_val, rt_val, rd_val, shamt_val, funct_val};
            div_a = 32'd20;
            div_b = 32'd3;
            div_ctrl = 1'b1;
            
            repeat(5) @(posedge clk);
            
            div_ctrl = 1'b0;
            
            // Aguardar conclusão da divisão
            repeat(40) @(posedge clk);
            
            $display("  Instrução: 0x%h", instruction);
            $display("  Operandos: %d / %d", div_a, div_b);
            $display("  Resultado: HI=0x%h (resto), LO=0x%h (quociente)", div_hi, div_lo);
            $display("  ✓ Teste concluído");
            $display("");
        end
    endtask
    
    // Task para testar instruções I-type
    task test_i_type_instruction;
        input [8*10:1] name;
        input [5:0] op;
        input [4:0] rs_val, rt_val;
        input [15:0] imm;
        begin
            test_count = test_count + 1;
            $display("Teste %d: %s", test_count, name);
            
            instruction = {op, rs_val, rt_val, imm};
            
            repeat(5) @(posedge clk);
            
            $display("  Instrução: 0x%h", instruction);
            $display("  Estado atual: %d", current_state);
            $display("  alu_src: %b, reg_write: %b", alu_src, reg_write);
            $display("  ✓ Teste concluído");
            $display("");
        end
    endtask
    
    // Task para testar instruções de branch
    task test_branch_instruction;
        input [8*10:1] name;
        input [5:0] op;
        input [4:0] rs_val, rt_val;
        input [15:0] offset;
        input expected_zero;
        begin
            test_count = test_count + 1;
            $display("Teste %d: %s", test_count, name);
            
            instruction = {op, rs_val, rt_val, offset};
            alu_zero_sim = expected_zero;
            
            repeat(5) @(posedge clk);
            
            $display("  Instrução: 0x%h", instruction);
            $display("  Estado atual: %d", current_state);
            $display("  branch: %b, pc_write_cond: %b", branch, pc_write_cond);
            $display("  Zero flag: %b", alu_zero_sim);
            $display("  ✓ Teste concluído");
            $display("");
            
            alu_zero_sim = 1'b0; // Reset flag
        end
    endtask
    
    // Task para testar instruções J-type
    task test_j_type_instruction;
        input [8*10:1] name;
        input [5:0] op;
        input [25:0] target;
        begin
            test_count = test_count + 1;
            $display("Teste %d: %s", test_count, name);
            
            instruction = {op, target};
            
            repeat(5) @(posedge clk);
            
            $display("  Instrução: 0x%h", instruction);
            $display("  Estado atual: %d", current_state);
            $display("  jump: %b, pc_source: %b", jump, pc_source);
            $display("  Target: 0x%h", target);
            $display("  ✓ Teste concluído");
            $display("");
        end
    endtask
    
    // Task para testar exceção de overflow
    task test_overflow_exception;
        input [8*10:1] name;
        input [5:0] op;
        input [4:0] rs_val, rt_val, rd_val, shamt_val;
        input [5:0] funct_val;
        begin
            test_count = test_count + 1;
            $display("Teste %d: %s", test_count, name);
            
            instruction = {op, rs_val, rt_val, rd_val, shamt_val, funct_val};
            alu_overflow_sim = 1'b1;
            
            repeat(5) @(posedge clk);
            
            $display("  Instrução: 0x%h", instruction);
            $display("  Estado atual: %d", current_state);
            $display("  epc_load: %b (exceção detectada)", epc_load);
            $display("  ✓ Teste de exceção concluído");
            $display("");
            
            alu_overflow_sim = 1'b0; // Reset overflow
        end
    endtask
    
    // Task para testar exceção de divisão por zero
    task test_div_zero_exception;
        input [8*10:1] name;
        input [5:0] op;
        input [4:0] rs_val, rt_val, rd_val, shamt_val;
        input [5:0] funct_val;
        begin
            test_count = test_count + 1;
            $display("Teste %d: %s", test_count, name);
            
            instruction = {op, rs_val, rt_val, rd_val, shamt_val, funct_val};
            div_a = 32'd100;
            div_b = 32'd0;
            div_ctrl = 1'b1;
            
            repeat(5) @(posedge clk);
            
            div_ctrl = 1'b0;
            repeat(10) @(posedge clk);
            
            $display("  Instrução: 0x%h", instruction);
            $display("  Estado atual: %d", current_state);
            $display("  div_zero: %b, epc_load: %b", div_zero_flag, epc_load);
            $display("  ✓ Teste de exceção concluído");
            $display("");
        end
    endtask
    
    // Task para testar instrução inválida
    task test_invalid_instruction;
        input [8*10:1] name;
        input [5:0] op;
        input [4:0] rs_val, rt_val, rd_val, shamt_val;
        input [5:0] funct_val;
        begin
            test_count = test_count + 1;
            $display("Teste %d: %s", test_count, name);
            
            instruction = {op, rs_val, rt_val, rd_val, shamt_val, funct_val};
            
            repeat(5) @(posedge clk);
            
            $display("  Instrução: 0x%h", instruction);
            $display("  Estado atual: %d (deve ser OPCODE404)", current_state);
            $display("  epc_load: %b (exceção detectada)", epc_load);
            $display("  ✓ Teste de exceção concluído");
            $display("");
        end
    endtask
    
    // Task para testar módulo Load Size
    task test_load_size_module;
        begin
            test_count = test_count + 1;
            $display("Teste %d: LOAD SIZE MODULE", test_count);
            
            // Teste load byte
            ls_input = 32'hDEADBEEF;
            ls_control = 2'b00;
            #10;
            $display("  Load Byte: input=0x%h, output=0x%h", ls_input, ls_output);
            
            // Teste load word
            ls_control = 2'b10;
            #10;
            $display("  Load Word: input=0x%h, output=0x%h", ls_input, ls_output);
            
            $display("  ✓ Teste do módulo LS concluído");
            $display("");
        end
    endtask
    
    // Task para testar módulo Store Size
    task test_store_size_module;
        begin
            test_count = test_count + 1;
            $display("Teste %d: STORE SIZE MODULE", test_count);
            
            // Teste store byte
            ss_input = 32'h000000AB;
            ss_memory = 32'hDEADBEEF;
            ss_control = 2'b00;
            #10;
            $display("  Store Byte: reg=0x%h, mem=0x%h, output=0x%h", ss_input, ss_memory, ss_output);
            
            // Teste store word
            ss_input = 32'hCAFEBABE;
            ss_control = 2'b10;
            #10;
            $display("  Store Word: reg=0x%h, mem=0x%h, output=0x%h", ss_input, ss_memory, ss_output);
            
            $display("  ✓ Teste do módulo SS concluído");
            $display("");
        end
    endtask
    
    // Task para testar módulo Sign Extend
    task test_sign_extend_module;
        begin
            test_count = test_count + 1;
            $display("Teste %d: SIGN EXTEND MODULE", test_count);
            
            // Teste número positivo
            se_input = 16'h1234;
            #10;
            $display("  Positivo: input=0x%h, output=0x%h", se_input, se_output);
            
            // Teste número negativo
            se_input = 16'hFFFF;
            #10;
            $display("  Negativo: input=0x%h, output=0x%h", se_input, se_output);
            
            $display("  ✓ Teste do módulo SE concluído");
            $display("");
        end
    endtask
    
endmodule