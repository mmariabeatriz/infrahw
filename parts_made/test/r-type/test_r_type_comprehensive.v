// Teste Abrangente das Instruções R-type do Control Unit
// Inclui sequências de instruções para testar operações completas
`timescale 1ns/1ps

module test_r_type_comprehensive;
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
    wire mux_memory_wd;
    wire mux_high;
    wire mux_low;
    wire mux_extend;
    wire mux_b;
    wire mux_shift_src;
    wire [1:0] mux_shift_amt;
    wire [1:0] mux_a;
    wire [1:0] mux_ula1;
    wire [1:0] mux_ula2;
    wire [1:0] mux_pc;
    wire [1:0] mux_register_wr;
    wire [2:0] mux_address;
    wire [2:0] mux_register_wd;
    wire address_rg_load;
    wire epc_load;
    wire mdr_load;
    wire ir_load;
    wire high_load;
    wire low_load;
    wire a_load;
    wire b_load;
    wire ula_out_load;
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
        .mux_memory_wd(mux_memory_wd),
        .mux_high(mux_high),
        .mux_low(mux_low),
        .mux_extend(mux_extend),
        .mux_b(mux_b),
        .mux_shift_src(mux_shift_src),
        .mux_shift_amt(mux_shift_amt),
        .mux_a(mux_a),
        .mux_ula1(mux_ula1),
        .mux_ula2(mux_ula2),
        .mux_pc(mux_pc),
        .mux_register_wr(mux_register_wr),
        .mux_address(mux_address),
        .mux_register_wd(mux_register_wd),
        .address_rg_load(address_rg_load),
        .epc_load(epc_load),
        .mdr_load(mdr_load),
        .ir_load(ir_load),
        .high_load(high_load),
        .low_load(low_load),
        .a_load(a_load),
        .b_load(b_load),
        .ula_out_load(ula_out_load),
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
            opcode = 6'b0;
            immediate = 16'b0;
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
    
    // Task para executar instrução I-type (ADDIU)
    task execute_addiu;
        input [4:0] rt_reg;
        input [4:0] rs_reg;
        input [15:0] imm_value;
        input [255:0] description;
        begin
            $display("Executando: %s", description);
            opcode = 6'b001001; // ADDIU
            immediate = {rs_reg, rt_reg, imm_value[5:0]}; // Simplificado para teste
            wait_cycles(4); // FETCH -> DECODE -> EXECUTE -> WRITEBACK
            $display("  ULA: %b, Reg_WR: %b, MUX_Register_WR: %b", ula, reg_wr, mux_register_wr);
        end
    endtask
    
    // Task para executar instrução R-type
    task execute_r_type;
        input [4:0] rs_reg;
        input [4:0] rt_reg;
        input [4:0] rd_reg;
        input [5:0] funct_code;
        input [255:0] description;
        begin
            $display("Executando: %s", description);
            opcode = 6'b000000; // R-type
            immediate = {rs_reg, rt_reg, rd_reg, 5'b0, funct_code};
            wait_cycles(4); // FETCH -> DECODE -> EXECUTE -> WRITEBACK
            $display("  ULA: %b, Shift: %b, Reg_WR: %b, MUX_Register_WR: %b", ula, shift, reg_wr, mux_register_wr);
            $display("  Mult_Init: %b, Div_Init: %b, HI_Load: %b, LO_Load: %b", mult_init, div_init, high_load, low_load);
        end
    endtask
    
    // Task para executar instrução de shift com immediate
    task execute_shift_imm;
        input [4:0] rt_reg;
        input [4:0] rd_reg;
        input [4:0] shamt;
        input [5:0] funct_code;
        input [255:0] description;
        begin
            $display("Executando: %s", description);
            opcode = 6'b000000; // R-type
            immediate = {5'b0, rt_reg, rd_reg, shamt, funct_code};
            wait_cycles(4);
            $display("  Shift: %b, Reg_WR: %b, MUX_Shift_Amt: %b", shift, reg_wr, mux_shift_amt);
        end
    endtask
    
    // Configuração para dump VCD
    initial begin
        $dumpfile("test_r_type_comprehensive.vcd");
        $dumpvars(0, test_r_type_comprehensive);
    end
    
    // Testes principais
    initial begin
        $display("=== TESTE ABRANGENTE DAS INSTRUÇÕES R-TYPE ===\n");
        
        // === TESTE 1: AND ===
        $display("\n=== TESTE 1: AND ===");
        reset_system();
        execute_addiu(5'd1, 5'd0, 16'd13, "addiu $1, $zero, 13");
        execute_addiu(5'd2, 5'd0, 16'd10, "addiu $2, $zero, 10");
        execute_r_type(5'd1, 5'd2, 5'd3, 6'b100100, "and $3, $1, $2");
        $display("Resultado esperado: $3 = 13 & 10 = 8");
        
        // === TESTE 2: DIV, MFHI, MFLO ===
        $display("\n=== TESTE 2: DIV, MFHI, MFLO ===");
        reset_system();
        execute_addiu(5'd1, 5'd0, 16'd23, "addiu $1, $zero, 23");
        execute_addiu(5'd2, 5'd0, 16'd7, "addiu $2, $zero, 7");
        execute_r_type(5'd1, 5'd2, 5'd0, 6'b011010, "div $1, $2");
        // Simular conclusão da divisão
        div_stop = 1;
        wait_cycles(2);
        div_stop = 0;
        execute_r_type(5'd0, 5'd0, 5'd3, 6'b010000, "mfhi $3");
        execute_r_type(5'd0, 5'd0, 5'd4, 6'b010010, "mflo $4");
        $display("Resultado esperado: $3 = 23 %% 7 = 2, $4 = 23 / 7 = 3");
        
        // === TESTE 3: MULT, MFHI, MFLO ===
        $display("\n=== TESTE 3: MULT, MFHI, MFLO ===");
        reset_system();
        execute_addiu(5'd1, 5'd0, 16'd4, "addiu $1, $zero, 4");
        execute_addiu(5'd2, 5'd0, 16'd3, "addiu $2, $zero, 3");
        execute_r_type(5'd1, 5'd2, 5'd0, 6'b011000, "mult $1, $2");
        // Simular conclusão da multiplicação
        mult_stop = 1;
        wait_cycles(2);
        mult_stop = 0;
        execute_r_type(5'd0, 5'd0, 5'd2, 6'b010000, "mfhi $2");
        execute_r_type(5'd0, 5'd0, 5'd1, 6'b010010, "mflo $1");
        $display("Resultado esperado: HI = 0, LO = 4 * 3 = 12");
        
        // === TESTE 4: SLL ===
        $display("\n=== TESTE 4: SLL ===");
        reset_system();
        execute_addiu(5'd3, 5'd0, 16'd32, "addiu $3, $zero, 32");
        execute_shift_imm(5'd3, 5'd3, 5'd4, 6'b000000, "sll $3, $3, 4");
        $display("Resultado esperado: $3 = 32 << 4 = 512");
        
        // === TESTE 5: SLT ===
        $display("\n=== TESTE 5: SLT ===");
        reset_system();
        execute_addiu(5'd1, 5'd0, 16'd3, "addiu $1, $zero, 3");
        execute_addiu(5'd2, 5'd0, 16'd4, "addiu $2, $zero, 4");
        execute_r_type(5'd1, 5'd2, 5'd3, 6'b101010, "slt $3, $1, $2");
        $display("Resultado esperado: $3 = (3 < 4) = 1");
        execute_r_type(5'd2, 5'd2, 5'd3, 6'b101010, "slt $3, $2, $2");
        $display("Resultado esperado: $3 = (4 < 4) = 0");
        execute_addiu(5'd3, 5'd0, 16'd1, "addiu $3, $zero, 1");
        execute_r_type(5'd2, 5'd1, 5'd3, 6'b101010, "slt $3, $2, $1");
        $display("Resultado esperado: $3 = (4 < 3) = 0");
        
        // === TESTE 6: SRA ===
        $display("\n=== TESTE 6: SRA ===");
        reset_system();
        execute_addiu(5'd1, 5'd0, 16'hFFFA, "addiu $1, $zero, -6"); // -6 em complemento de 2
        execute_shift_imm(5'd1, 5'd1, 5'd1, 6'b000011, "sra $1, $1, 1");
        $display("Resultado esperado: $1 = -6 >> 1 = -3");
        
        // === TESTE 7: SUB ===
        $display("\n=== TESTE 7: SUB ===");
        reset_system();
        execute_addiu(5'd1, 5'd0, 16'd15, "addiu $1, $zero, 15");
        execute_addiu(5'd2, 5'd0, 16'd10, "addiu $2, $zero, 10");
        execute_r_type(5'd1, 5'd2, 5'd3, 6'b100010, "sub $3, $1, $2");
        $display("Resultado esperado: $3 = 15 - 10 = 5");
        
        // === TESTE 8: XCHG ===
        $display("\n=== TESTE 8: XCHG ===");
        reset_system();
        execute_addiu(5'd1, 5'd0, 16'd2, "addiu $1, $zero, 2");
        execute_addiu(5'd2, 5'd0, 16'd3, "addiu $2, $zero, 3");
        execute_r_type(5'd1, 5'd2, 5'd0, 6'b000101, "xchg $1, $2");
        $display("Resultado esperado: $1 = 3, $2 = 2");
        
        // === TESTE 9: ADD ===
        $display("\n=== TESTE 9: ADD ===");
        reset_system();
        execute_addiu(5'd1, 5'd0, 16'd10, "addiu $1, $zero, 10");
        execute_addiu(5'd2, 5'd0, 16'd5, "addiu $2, $zero, 5");
        execute_r_type(5'd1, 5'd2, 5'd3, 6'b100000, "add $3, $1, $2");
        $display("Resultado esperado: $3 = 10 + 5 = 15");
        
        // === TESTE 10: JR ===
        $display("\n=== TESTE 10: JR ===");
        reset_system();
        execute_addiu(5'd31, 5'd0, 16'd100, "addiu $31, $zero, 100");
        execute_r_type(5'd31, 5'd0, 5'd0, 6'b001000, "jr $31");
        $display("Resultado esperado: PC = valor de $31 = 100");
        
        $display("\n=== TODOS OS TESTES R-TYPE ABRANGENTES CONCLUÍDOS ===\n");
        $finish;
    end
    
    // Monitor para acompanhar sinais importantes
    always @(posedge clk) begin
        if (reg_wr || mult_init || div_init || high_load || low_load) begin
            $display("[%0t] Reg_WR=%b, Mult_Init=%b, Div_Init=%b, HI_Load=%b, LO_Load=%b", 
                     $time, reg_wr, mult_init, div_init, high_load, low_load);
        end
    end
    
endmodule