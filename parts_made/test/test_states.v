// Teste dos Estados da Máquina de Estados do Control Unit
`timescale 1ns/1ps

module test_states;
    // Sinais de entrada
    reg clk;
    reg reset_in;
    reg [31:0] instruction;
    reg zero_flag;
    reg overflow_flag;
    reg div_zero;
    reg mult_done;
    reg div_done;
    
    // Sinais de saída (apenas os necessários para monitorar estados)
    wire [2:0] current_state;
    wire [3:0] counter;
    wire pc_write_enable;
    wire instruction_write;
    wire memory_write;
    wire register_write;
    
    // Instanciação do módulo control_unit
    control_unit uut (
        .clk(clk),
        .reset_in(reset_in),
        .instruction(instruction),
        .zero_flag(zero_flag),
        .overflow_flag(overflow_flag),
        .div_zero(div_zero),
        .mult_done(mult_done),
        .div_done(div_done),
        .current_state(current_state),
        .counter(counter),
        .pc_write_enable(pc_write_enable),
        .instruction_write(instruction_write),
        .memory_write(memory_write),
        .register_write(register_write),
        // Conectar outras saídas a fios não utilizados
        .mux_a(),
        .mux_b(),
        .mux_alu_1(),
        .mux_alu_2(),
        .mux_shift_amt(),
        .mux_shift_src(),
        .mux_pc(),
        .mux_address(),
        .mux_wd_memory(),
        .mux_wd_registers(),
        .mux_wr_registers(),
        .mux_extend(),
        .mux_high(),
        .mux_low(),
        .alu_control(),
        .shift_control(),
        .load_size_control(),
        .store_size_control(),
        .hi_write(),
        .lo_write(),
        .exception_control()
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
            instruction = 32'h00000000;
            zero_flag = 0;
            overflow_flag = 0;
            div_zero = 0;
            mult_done = 0;
            div_done = 0;
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
    
    // Task para verificar estado
    task check_state;
        input [2:0] expected_state;
        input [31:0] test_name;
        begin
            if (current_state !== expected_state) begin
                $display("ERRO: Estado esperado %d, obtido %d", expected_state, current_state);
            end else begin
                $display("OK: Estado %d correto", expected_state);
            end
        end
    endtask
    
    // Configuração para dump VCD
    initial begin
        $dumpfile("test_states.vcd");
        $dumpvars(0, test_states);
    end
    
    // Testes principais
    initial begin
        $display("=== TESTE DOS ESTADOS DA MÁQUINA ===\n");
        
        // Teste 1: Reset e Estado Inicial
        $display("Teste 1: Reset e Estado Inicial");
        reset_system();
        check_state(3'b000, "FETCH"); // Estado FETCH
        
        // Teste 2: Transição FETCH -> DECODE
        $display("\nTeste 2: Transição FETCH -> DECODE");
        instruction = 32'h20010001; // ADDI $1, $0, 1
        wait_cycles(1);
        check_state(3'b001, "DECODE"); // Estado DECODE
        
        // Teste 3: Transição DECODE -> EXECUTE (I-type)
        $display("\nTeste 3: Transição DECODE -> EXECUTE");
        wait_cycles(1);
        check_state(3'b010, "EXECUTE"); // Estado EXECUTE
        
        // Teste 4: Transição EXECUTE -> MEMORY (para LW)
        $display("\nTeste 4: Teste com instrução LW (EXECUTE -> MEMORY)");
        reset_system();
        instruction = 32'h8C010000; // LW $1, 0($0)
        wait_cycles(2); // FETCH -> DECODE
        wait_cycles(1); // DECODE -> EXECUTE
        check_state(3'b010, "EXECUTE");
        wait_cycles(1); // EXECUTE -> MEMORY
        check_state(3'b011, "MEMORY"); // Estado MEMORY
        
        // Teste 5: Transição MEMORY -> WRITEBACK
        $display("\nTeste 5: Transição MEMORY -> WRITEBACK");
        wait_cycles(1);
        check_state(3'b100, "WRITEBACK"); // Estado WRITEBACK
        
        // Teste 6: Retorno ao FETCH
        $display("\nTeste 6: Retorno ao FETCH");
        wait_cycles(1);
        check_state(3'b000, "FETCH"); // Volta ao FETCH
        
        // Teste 7: Instrução R-type (sem MEMORY)
        $display("\nTeste 7: Instrução R-type (ADD) - sem estado MEMORY");
        instruction = 32'h00220820; // ADD $1, $1, $2
        wait_cycles(1); // FETCH -> DECODE
        check_state(3'b001, "DECODE");
        wait_cycles(1); // DECODE -> EXECUTE
        check_state(3'b010, "EXECUTE");
        wait_cycles(1); // EXECUTE -> WRITEBACK (pula MEMORY)
        check_state(3'b100, "WRITEBACK");
        
        // Teste 8: Instrução J-type
        $display("\nTeste 8: Instrução J-type (J) - execução direta");
        reset_system();
        instruction = 32'h08000004; // J 4
        wait_cycles(1); // FETCH -> DECODE
        check_state(3'b001, "DECODE");
        wait_cycles(1); // DECODE -> FETCH (execução direta)
        check_state(3'b000, "FETCH");
        
        // Teste 9: Instrução MULT (múltiplos ciclos)
        $display("\nTeste 9: Instrução MULT - múltiplos ciclos");
        reset_system();
        instruction = 32'h00220018; // MULT $1, $2
        wait_cycles(2); // FETCH -> DECODE -> EXECUTE
        check_state(3'b010, "EXECUTE");
        
        // Simular conclusão da multiplicação
        mult_done = 1;
        wait_cycles(1);
        check_state(3'b000, "FETCH"); // Retorna ao FETCH
        mult_done = 0;
        
        // Teste 10: Verificação de contador
        $display("\nTeste 10: Verificação de contador interno");
        reset_system();
        $display("Counter inicial: %d", counter);
        wait_cycles(5);
        $display("Counter após 5 ciclos: %d", counter);
        
        $display("\n=== TODOS OS TESTES DE ESTADO CONCLUÍDOS ===\n");
        $finish;
    end
    
    // Monitor para acompanhar mudanças de estado
    always @(posedge clk) begin
        $display("Ciclo %0t: Estado=%d, Counter=%d, Instruction=%h", 
                 $time, current_state, counter, instruction);
    end
    
endmodule