// Teste das instuções J-type
`timescale 1ns/1ps

module test_j_type;
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
    wire [1:0] mux_wd_memory;
    wire mux_high;
    wire mux_low;
    wire mux_extend;
    wire [1:0] mux_b;
    wire mux_shift_src;
    wire mux_shift_amt;
    wire [1:0] mux_a;
    wire [1:0] mux_alu1;
    wire [1:0] mux_alu2;
    wire [1:0] mux_pc;
    wire [1:0] mux_wr_registers;
    wire mux_address;
    wire [1:0] mux_wd_registers;
    wire address_rg_load;
    wire epc_load;
    wire mdr_load;
    wire ir_load;
    wire high_load;
    wire low_load;
    wire a_load;
    wire b_load;
    wire alu_out_load;
    wire [1:0] store_size;
    wire [1:0] load_size;
    wire memory_wr;
    wire reg_wr;
    wire pc_write;
    wire is_beq;
    wire is_bne;
    wire [2:0] ula;
    wire [1:0] shift;
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
    
    // Clock
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
    
    // Task para executar instrução J-type e exibir sinais de controle
    task execute_j_instruction;
        input [5:0] op;
        input [25:0] target_address;
        begin
            opcode = op;
            immediate = target_address[15:0]; // Parte baixa do endereço
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
            $display("  MUX PC: %b", mux_pc);
            $display("  Register Write: %b", reg_wr);
            $display("  MUX WR Registers: %b", mux_wr_registers);
            $display("  MUX WD Registers: %b", mux_wd_registers);
            $display("  Memory Write: %b", memory_wr);
            $display("  ULA Control: %b", ula);
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