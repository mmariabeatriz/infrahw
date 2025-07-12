// Teste das Instruções R-type do Control Unit
`timescale 1ns/1ps

module test_r_type;
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
    
    // Tarefa para reset
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
            #10;
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
    
    // Task para testar instrução R-type
    task test_r_instruction;
        input [5:0] op;
        input [5:0] funct_code;
        input [7:0] test_num;
        input [255:0] test_name;
        begin
            $display("\nTeste %0d: %s", test_num, test_name);
            reset_system();
            opcode = op;
            immediate = {10'b0, funct_code}; // Coloca funct nos bits [5:0]
            wait_cycles(5); // Aumenta ciclos para permitir execução completa
            
            $display("Opcode: %h", opcode);
            $display("Funct: %h", funct_code);
            $display("ULA Control: %b", ula);
            $display("Shift Control: %b", shift);
            $display("Register Write: %b", reg_wr);
            $display("MUX ULA1: %b (deve ser 00 para rs)", mux_ula1);
            $display("MUX ULA2: %b (deve ser 00 para rt)", mux_ula2);
            $display("MUX Register WR: %b (deve ser 01 para rd)", mux_register_wr);
            $display("MUX Register WD: %b (deve ser 00 para ULAOut)", mux_register_wd);
            $display("Mult Init: %b", mult_init);
            $display("Div Init: %b", div_init);
            $display("---");
        end
    endtask
    
    // Configuração para dump VCD
    initial begin
        $dumpfile("test_r_type.vcd");
        $dumpvars(0, test_r_type);
    end
    
    // Testes principais
    initial begin
        $display("=== TESTE DAS INSTRUÇÕES R-TYPE ===\n");
        
        // Teste 1: ADD (R-type)
        test_r_instruction(6'b000000, 6'b100000, 8'd1, "ADD - Adição");
        
        // Teste 2: SUB (R-type)
        test_r_instruction(6'b000000, 6'b100010, 8'd2, "SUB - Subtração");
        
        // Teste 3: AND (R-type)
        test_r_instruction(6'b000000, 6'b100100, 8'd3, "AND - E lógico");
        
        // Teste 4: SLT (R-type)
        test_r_instruction(6'b000000, 6'b101010, 8'd4, "SLT - Set Less Than");
        
        // Teste 5: SLL (R-type)
        test_r_instruction(6'b000000, 6'b000000, 8'd5, "SLL - Shift Left Logical");
        
        // Teste 6: SRA (R-type)
        test_r_instruction(6'b000000, 6'b000011, 8'd6, "SRA - Shift Right Arithmetic");
        
        // Teste 7: JR (R-type)
        test_r_instruction(6'b000000, 6'b001000, 8'd7, "JR - Jump Register");
        
        // Teste 8: MFHI (R-type)
        test_r_instruction(6'b000000, 6'b010000, 8'd8, "MFHI - Move From HI");
        
        // Teste 9: MFLO (R-type)
        test_r_instruction(6'b000000, 6'b010010, 8'd9, "MFLO - Move From LO");
        
        // Teste 10: MULT (R-type)
        test_r_instruction(6'b000000, 6'b011000, 8'd10, "MULT - Multiplicação");
        
        // Teste 11: DIV (R-type)
        test_r_instruction(6'b000000, 6'b011010, 8'd11, "DIV - Divisão");
        
        // Teste 12: XCHG (R-type)
        test_r_instruction(6'b000000, 6'b000101, 8'd12, "XCHG - Exchange");
        
        // Teste 13: Instrução inválida
        test_r_instruction(6'b111111, 6'b111111, 8'd13, "Instrução inválida");
        
        $display("\n=== TODOS OS TESTES R-TYPE CONCLUÍDOS ===\n");
        $finish;
    end
    
endmodule