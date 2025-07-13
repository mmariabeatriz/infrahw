// Teste das Instruções I-type do Control Unit
`timescale 1ns/1ps

module test_i_type;
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
    
    // Task para executar uma instrução I-type
    task execute_i_instruction;
        input [5:0] op;
        input [15:0] imm;
        begin
            opcode = op;
            immediate = imm;
            wait_cycles(4); // FETCH -> DECODE -> EXECUTE -> (MEMORY se necessário)
        end
    endtask
    
    // Task para exibir sinais de controle
    task display_control_signals;
        input [80*8-1:0] instr_name;
        begin
            $display("  %s - Sinais de Controle:", instr_name);
            $display("    ULA: %b | Extend: %b | RegWr: %b | MemWr: %b", ula, mux_extend, reg_wr, memory_wr);
            $display("    MUX_ALU2: %b | MUX_WR_Reg: %b | MUX_WD_Reg: %b", mux_alu2, mux_wr_registers, mux_wd_registers);
            $display("    LoadSize: %b | StoreSize: %b | PC_Write: %b", load_size, store_size, pc_write);
            $display("    BEQ: %b | BNE: %b | Shift: %b", is_beq, is_bne, shift);
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