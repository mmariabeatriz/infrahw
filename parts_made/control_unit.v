// UNIDADE DE CONTROLE - MIPS
// Implementa máquina de estados finita para controle do datapath
/*
 * Esta unidade de controle implementa uma máquina de estados finita que coordena
 * a execução de instruções MIPS no processador.
 * 
 * ARQUITETURA:
 * - Máquina de estados com 6 estados principais: FETCH, DECODE, EXECUTE, MEMORY, WRITEBACK
 * - Suporte para instruções R-type, I-type e J-type
 * - Controle de sinais para datapath, memória e registradores
 * - Tratamento de operações especiais (multiplicação, divisão, branches)
 * 
 * FUNCIONAMENTO:
 * 1. FETCH: Busca instrução da memória e incrementa PC
 * 2. DECODE: Decodifica instrução e prepara operandos
 * 3. EXECUTE: Executa operação específica baseada no tipo de instrução
 * 4. MEMORY: Acessa memória (para loads/stores)
 * 5. WRITEBACK: Escreve resultado nos registradores
 * 
 * INSTRUÇÕES:
 * - R-type: ADD, SUB, AND, SLT, SLL, SRA, MULT, DIV, MFHI, MFLO, JR, XCHG
 * - I-type: ADDI, LW, SW, LB, SB, BEQ, BNE, LUI, SLLM
 * - J-type: J, JAL
 */

module control_unit (
    // SINAIS DE ENTRADA
    input wire clk,                    // Clock do sistema
    input wire reset,                  // Reset assíncrono
    input wire [5:0] opcode,          // Código de operação da instrução
    input wire [5:0] funct,           // Campo function (para instruções R-type)
    input wire zero,                  // Flag zero da ULA
    input wire overflow,              // Flag overflow da ULA
    input wire div_zero,              // Flag divisão por zero
    input wire negative,              // Flag resultado negativo
    
    // SINAIS DE CONTROLE DO DATAPATH
    output reg [2:0] mux_ula1,        // Seletor entrada A da ULA
    output reg [1:0] mux_ula2,        // Seletor entrada B da ULA
    output reg [2:0] ula,             // Código de operação da ULA
    output reg [1:0] shift,           // Controle de shift
    output reg [1:0] mux_pc,          // Seletor do próximo PC
    output reg [2:0] mux_address,     // Seletor de endereço de memória
    output reg [1:0] mux_reg_dest,    // Seletor registrador destino
    output reg [2:0] mux_reg_data,    // Seletor dados para registrador
    output reg mux_mem_data,          // Seletor dados para memória
    output reg [1:0] mux_a,           // Seletor entrada A
    output reg mux_b,                 // Seletor entrada B
    output reg mux_extend,            // Tipo de extensão (sinal/zero)
    
    // SINAIS DE CONTROLE DE CARGA (LOAD)
    output reg ir_load,               // Carrega instruction register
    output reg mdr_load,              // Carrega memory data register
    output reg a_load,                // Carrega registrador A
    output reg b_load,                // Carrega registrador B
    output reg ula_out_load,          // Carrega saída da ULA
    output reg address_rg_load,       // Carrega registrador de endereço
    output reg hi_load,               // Carrega registrador HI
    output reg lo_load,               // Carrega registrador LO
    
    // SINAIS DE CONTROLE DE ESCRITA
    output reg pc_write,              // Habilita escrita no PC
    output reg reg_wr,                // Habilita escrita nos registradores
    output reg memory_wr,             // Habilita escrita na memória
    
    // SINAIS DE CONTROLE ESPECIAIS
    output reg [1:0] load_size,       // Tamanho do load (byte/word)
    output reg store_size,            // Tamanho do store (byte/word)
    output reg is_beq,                // Indica instrução BEQ
    output reg is_bne,                // Indica instrução BNE
    output reg mult_init,             // Inicia multiplicação
    output reg div_init,              // Inicia divisão
    
    // SINAIS DE ESTADO (PARA DEBUG)
    output reg [5:0] current_state,   // Estado atual da máquina
    output reg [4:0] counter          // Contador interno de ciclos
);

    // VARIABLES - Variáveis internas da máquina de estados
    wire [5:0] funct;           // Campo function das instruções tipo R
    assign funct = immediate[5:0];

    // STATE PARAMETERS - Definição dos estados da máquina
    // Estados de controle geral
    localparam STATE_RESET      = 6'b000000;  // Estado de reset
    localparam STATE_FETCH      = 6'b000001;  // Busca da instrução
    localparam STATE_DECODE     = 6'b000010;  // Decodificação da instrução
    localparam STATE_OVERFLOW   = 6'b000011;  // Tratamento de overflow
    localparam STATE_OPCODE404  = 6'b000100;  // Instrução inválida
    localparam STATE_DIV0       = 6'b000101;  // Divisão por zero

    // Estados para instruções tipo R
    localparam STATE_ADD        = 6'b000110;  // Soma
    localparam STATE_AND        = 6'b000111;  // AND lógico
    localparam STATE_DIV        = 6'b010000;  // Divisão
    localparam STATE_MULT       = 6'b010001;  // Multiplicação
    localparam STATE_JR         = 6'b010010;  // Jump register
    localparam STATE_MFHI       = 6'b010011;  // Move from HI
    localparam STATE_MFLO       = 6'b010100;  // Move from LO
    localparam STATE_SLL        = 6'b010101;  // Shift left logical
    localparam STATE_SLT        = 6'b010110;  // Set less than
    localparam STATE_SRA        = 6'b010111;  // Shift right arithmetic
    localparam STATE_SUB        = 6'b011001;  // Subtração
    localparam STATE_XCHG       = 6'b011010;  // Exchange (troca registradores)

    // Estados para instruções tipo I
    localparam STATE_ADDI       = 6'b011011;  // Add immediate
    localparam STATE_BEQ        = 6'b011100;  // Branch if equal
    localparam STATE_BNE        = 6'b011101;  // Branch if not equal
    localparam STATE_SLLM       = 6'b011110;  // Shift left logical memory
    localparam STATE_LB         = 6'b011111;  // Load byte
    localparam STATE_LUI        = 6'b100000;  // Load upper immediate
    localparam STATE_LW         = 6'b100001;  // Load word
    localparam STATE_SB         = 6'b100010;  // Store byte
    localparam STATE_SW         = 6'b100011;  // Store word

    // Estados para instruções tipo J
    localparam STATE_J          = 6'b100110;  // Jump
    localparam STATE_JAL        = 6'b100111;  // Jump and link

    // OPCODES - Códigos de operação das instruções
    localparam OP_TYPE_R        = 6'b000000;  // Instruções tipo R
    localparam OP_ADDI          = 6'b001000;  // Add immediate
    localparam OP_BEQ           = 6'b000100;  // Branch if equal
    localparam OP_BNE           = 6'b000101;  // Branch if not equal
    localparam OP_SLLM          = 6'b001001;  // Shift left logical memory
    localparam OP_LB            = 6'b100000;  // Load byte
    localparam OP_LUI           = 6'b001111;  // Load upper immediate
    localparam OP_LW            = 6'b100011;  // Load word
    localparam OP_SB            = 6'b101000;  // Store byte
    localparam OP_SW            = 6'b101011;  // Store word
    localparam OP_J             = 6'b000010;  // Jump
    localparam OP_JAL           = 6'b000011;  // Jump and link

    // FUNCTION CODES - Códigos de função para instruções tipo R
    localparam FUNCT_ADD        = 6'b100000;  // Soma
    localparam FUNCT_AND        = 6'b100100;  // AND lógico
    localparam FUNCT_DIV        = 6'b011010;  // Divisão
    localparam FUNCT_MULT       = 6'b011000;  // Multiplicação
    localparam FUNCT_JR         = 6'b001000;  // Jump register
    localparam FUNCT_MFHI       = 6'b010000;  // Move from HI
    localparam FUNCT_MFLO       = 6'b010010;  // Move from LO
    localparam FUNCT_SLL        = 6'b000000;  // Shift left logical
    localparam FUNCT_SLT        = 6'b101010;  // Set less than
    localparam FUNCT_SRA        = 6'b000011;  // Shift right arithmetic
    localparam FUNCT_SUB        = 6'b100010;  // Subtração
    localparam FUNCT_XCHG       = 6'b000101;  // Exchange

    // Inicialização do estado
    initial begin
        current_state = STATE_RESET;
    end

    // PROCESSO PRINCIPAL - Máquina de estados
    always @(posedge clk) begin
        // RESET - Inicializa todos os sinais
        if (reset_in == 1'b1) begin
            reset_all_signals();
            current_state = STATE_FETCH;
            counter = 5'b00000;
        end else begin
            // Decodificação do estado atual e chamada da task correspondente
            case (current_state)
                STATE_FETCH: handle_fetch_state();      // Busca instrução da memória
                STATE_DECODE: handle_decode_state();    // Decodifica instrução e prepara operandos
                STATE_OVERFLOW: handle_overflow_state(); // Trata overflow
                STATE_OPCODE404: handle_opcode404_state(); // Trata instrução inválida
                STATE_DIV0: handle_div0_state();        // Trata divisão por zero
                // Estados para instruções tipo R
                STATE_ADD: handle_add_state();
                STATE_AND: handle_and_state();
                STATE_DIV: handle_div_state();
                STATE_MULT: handle_mult_state();
                STATE_JR: handle_jr_state();
                STATE_MFHI: handle_mfhi_state();
                STATE_MFLO: handle_mflo_state();
                STATE_SLL: handle_sll_state();
                STATE_SLT: handle_slt_state();
                STATE_SRA: handle_sra_state();
                STATE_SUB: handle_sub_state();
                STATE_XCHG: handle_xchg_state();
                // Estados para instruções tipo I
                STATE_ADDI: handle_addi_state();
                STATE_BEQ: handle_beq_state();
                STATE_BNE: handle_bne_state();
                STATE_SLLM: handle_sllm_state();
                STATE_LB: handle_lb_state();
                STATE_LUI: handle_lui_state();
                STATE_LW: handle_lw_state();
                STATE_SB: handle_sb_state();
                STATE_SW: handle_sw_state();
                // Estados para instruções tipo J
                STATE_J: handle_j_state();
                STATE_JAL: handle_jal_state();
                default: current_state = STATE_OPCODE404;
            endcase
        end
    end

    // Task para reset de todos os sinais
    task reset_all_signals;
        begin
            mux_register_wr     = 2'b01;
        mux_register_wd     = 3'b000;
            address_rg_load     = 1'b0;
            epc_load            = 1'b0;
            mdr_load            = 1'b0;
            ir_load             = 1'b0;
            hi_load             = 1'b0;
            lo_load             = 1'b0;
            a_load              = 1'b0;
            b_load              = 1'b0;
            ula_out_load        = 1'b0;
            memory_wr           = 1'b0;
            reg_wr              = 1'b1;
            pc_write            = 1'b0;
            is_beq              = 1'b0;
            is_bne              = 1'b0;
            
            // Special Controllers
            ula                 = 3'b000;
            shift               = 3'b000;
            
            // Mux Controllers
            mux_memory_wd       = 1'b0;
            mux_high            = 1'b0;
            mux_low             = 1'b0;
            mux_extend          = 1'b0;
            mux_b               = 1'b0;
            mux_shift_src       = 1'b0;
            mux_shift_amt       = 2'b00;
            mux_a               = 2'b00;
            mux_ula1            = 2'b00;
        mux_ula2            = 2'b00;
            mux_address         = 3'b000;
            
            // Size Controllers
            store_size          = 1'b0;
            load_size           = 2'b00;
            
            // Mult and Div Controllers
            mult_init           = 1'b0;
            div_init            = 1'b0;
        end
    endtask

    // Task para limpar sinais de controle (sem afetar ULA e shift)
    task clear_control_signals;
        begin
            address_rg_load     = 1'b0;
            epc_load            = 1'b0;
            mdr_load            = 1'b0;
            ir_load             = 1'b0;
            hi_load             = 1'b0;
            lo_load             = 1'b0;
            a_load              = 1'b0;
            b_load              = 1'b0;
            ula_out_load        = 1'b0;
            memory_wr           = 1'b0;
            reg_wr              = 1'b0;
            pc_write            = 1'b0;
            is_beq              = 1'b0;
            is_bne              = 1'b0;
            mult_init           = 1'b0;
            div_init            = 1'b0;
            // Não limpa ULA e shift para permitir que cada estado configure seus valores
        end
    endtask

    // TASKS PRINCIPAIS - Implementação dos estados da máquina
    
    // FETCH: Busca instrução da memória e incrementa PC
    task handle_fetch_state;
        begin
            if (counter <= 5'b00010) begin
                // Configura ULA para somar PC + 4
                mux_address         = 3'b000;   // Endereço vem do PC
                mux_ula1            = 2'b00;    // Entrada A = PC
            mux_ula2            = 2'b01;    // Entrada B = 4 (constante)
                ula                 = 3'b001;   // Operação de soma
                address_rg_load     = 1'b1;    // Carrega endereço calculado
                ula_out_load        = 1'b1;    // Salva PC+4
                clear_other_loads();
                memory_wr           = 1'b0;
                reg_wr              = 1'b0;
                pc_write            = 1'b0;
                is_beq              = 1'b0;
                is_bne              = 1'b0;
                mult_init           = 1'b0;
                div_init            = 1'b0;
                
                current_state = STATE_FETCH;
                counter = counter + 5'b00001;
            end else if (counter == 5'b00011) begin
                // Carrega instrução da memória e atualiza PC
                mux_pc              = 2'b10;    // PC = ULA_OUT (PC+4)
                clear_loads_except_ir();
                ir_load             = 1'b1;     // Carrega instrução no IR
                memory_wr           = 1'b0;
                reg_wr              = 1'b0;
                pc_write            = 1'b1;     // Atualiza PC
                is_beq              = 1'b0;
                is_bne              = 1'b0;
                mult_init           = 1'b0;
                div_init            = 1'b0;
                
                current_state = STATE_DECODE;
                counter = 5'b00000;
            end
        end
    endtask

    // DECODE: Decodifica instrução e prepara operandos
    task handle_decode_state;
        begin
            if (counter == 5'b00000) begin
                // Calcula endereço de branch (PC + 4 + offset)
                mux_extend          = 1'b1;     // Extensão com sinal
                mux_ula1            = 2'b00;    // PC atual
                mux_ula2            = 2'b11;    // Imediato estendido
                ula                 = 3'b001;   // Soma para branch
                clear_loads_except_ulaout();
                 ula_out_load        = 1'b1;    // Salva endereço de branch
                memory_wr           = 1'b0;
                reg_wr              = 1'b0;
                pc_write            = 1'b0;
                is_beq              = 1'b0;
                is_bne              = 1'b0;
                mult_init           = 1'b0;
                div_init            = 1'b0;
                
                current_state = STATE_DECODE;
                counter = counter + 5'b00001;
            end else if (counter == 5'b00001) begin
                // Lê registradores fonte da instrução
                mux_a               = 2'b01;    // Registrador RS
                mux_b               = 1'b0;     // Registrador RT
                clear_loads_except_ab();
                a_load              = 1'b1;     // Carrega operando A
                b_load              = 1'b1;     // Carrega operando B
                memory_wr           = 1'b0;
                reg_wr              = 1'b0;
                pc_write            = 1'b0;
                is_beq              = 1'b0;
                is_bne              = 1'b0;
                mult_init           = 1'b0;
                div_init            = 1'b0;
                
                counter = 5'b00000;
                decode_instruction();  // Decodifica e vai para estado específico
            end
        end
    endtask

    // DECODIFICAÇÃO: Determina próximo estado baseado no opcode
    task decode_instruction;
        begin
            case (opcode)
                OP_TYPE_R: begin  // Instruções tipo R - usa campo function
                    case (funct)
                        FUNCT_ADD:  current_state = STATE_ADD;   // Soma
                        FUNCT_AND:  current_state = STATE_AND;   // AND lógico
                        FUNCT_DIV:  current_state = STATE_DIV;   // Divisão
                        FUNCT_MULT: current_state = STATE_MULT;  // Multiplicação
                        FUNCT_JR:   current_state = STATE_JR;    // Jump register
                        FUNCT_MFHI: current_state = STATE_MFHI;  // Move from HI
                        FUNCT_MFLO: current_state = STATE_MFLO;  // Move from LO
                        FUNCT_SLL:  current_state = STATE_SLL;   // Shift left
                        FUNCT_SLT:  current_state = STATE_SLT;   // Set less than
                        FUNCT_SRA:  current_state = STATE_SRA;   // Shift right
                        FUNCT_SUB:  current_state = STATE_SUB;   // Subtração
                        FUNCT_XCHG: current_state = STATE_XCHG;  // Exchange
                        default:    current_state = STATE_OPCODE404;
                    endcase
                end
                // Instruções tipo I - opcode determina operação
                OP_ADDI:    current_state = STATE_ADDI;  // Add immediate
                OP_BEQ:     current_state = STATE_BEQ;   // Branch if equal
                OP_BNE:     current_state = STATE_BNE;   // Branch if not equal
                OP_SLLM:    current_state = STATE_SLLM;  // Shift left memory
                OP_LB:      current_state = STATE_LB;    // Load byte
                OP_LUI:     current_state = STATE_LUI;   // Load upper immediate
                OP_LW:      current_state = STATE_LW;    // Load word
                OP_SB:      current_state = STATE_SB;    // Store byte
                OP_SW:      current_state = STATE_SW;    // Store word
                // Instruções tipo J - jump direto
                OP_J:       current_state = STATE_J;     // Jump
                OP_JAL:     current_state = STATE_JAL;   // Jump and link
                default:    current_state = STATE_OPCODE404;
            endcase
        end
    endtask

    // Tasks auxiliares para limpeza de sinais
    task clear_other_loads;
        begin
            epc_load            = 1'b0;
            mdr_load            = 1'b0;
            ir_load             = 1'b0;
            high_load           = 1'b0;
            low_load            = 1'b0;
            a_load              = 1'b0;
            b_load              = 1'b0;
        end
    endtask

    task clear_loads_except_ir;
        begin
            address_rg_load     = 1'b0;
            epc_load            = 1'b0;
            mdr_load            = 1'b0;
            high_load           = 1'b0;
            low_load            = 1'b0;
            a_load              = 1'b0;
            b_load              = 1'b0;
            ula_out_load        = 1'b0;
        end
    endtask

    task clear_loads_except_ulaout;
        begin
            address_rg_load     = 1'b0;
            epc_load            = 1'b0;
            mdr_load            = 1'b0;
            ir_load             = 1'b0;
            high_load           = 1'b0;
            low_load            = 1'b0;
            a_load              = 1'b0;
            b_load              = 1'b0;
        end
    endtask

    task clear_loads_except_ab;
        begin
            address_rg_load     = 1'b0;
            epc_load            = 1'b0;
            mdr_load            = 1'b0;
            ir_load             = 1'b0;
            high_load           = 1'b0;
            low_load            = 1'b0;
            ula_out_load        = 1'b0;
        end
    endtask

    // Implementação simplificada dos outros estados (mantendo a funcionalidade original)
    task handle_overflow_state;
        begin
            // Implementação do estado de overflow (mantida da versão original)
            if (counter <= 5'b00010) begin
                mux_address = 3'b011;
                clear_control_signals();
                current_state = STATE_OVERFLOW;
                counter = counter + 5'b00001;
            end else if (counter == 5'b00011) begin
                clear_control_signals();
                epc_load = 1'b1;
                mdr_load = 1'b1;
                current_state = STATE_OVERFLOW;
                counter = counter + 5'b00001;
            end else if (counter == 5'b00100) begin
                mux_extend = 1'b0;
                mux_ula1 = 2'b10;
                 mux_ula2 = 2'b10;
                mux_pc = 2'b01;
                ula = 3'b001;
                clear_control_signals();
                pc_write = 1'b1;
                current_state = STATE_FETCH;
                counter = 5'b00000;
            end
        end
    endtask

    task handle_opcode404_state;
        begin
            // Implementação similar ao overflow mas com endereço diferente
            if (counter <= 5'b00010) begin
                mux_address = 3'b010;
                clear_control_signals();
                current_state = STATE_OPCODE404;
                counter = counter + 5'b00001;
            end else if (counter == 5'b00011) begin
                clear_control_signals();
                epc_load = 1'b1;
                mdr_load = 1'b1;
                current_state = STATE_OPCODE404;
                counter = counter + 5'b00001;
            end else if (counter == 5'b00100) begin
                mux_extend = 1'b0;
                mux_ula1 = 2'b10;
                 mux_ula2 = 2'b10;
                mux_pc = 2'b01;
                ula = 3'b001;
                clear_control_signals();
                pc_write = 1'b1;
                current_state = STATE_FETCH;
                counter = 5'b00000;
            end
        end
    endtask

    task handle_div0_state;
        begin
            // Implementação similar aos estados de erro
            if (counter <= 5'b00010) begin
                mux_address = 3'b100;
                clear_control_signals();
                current_state = STATE_DIV0;
                counter = counter + 5'b00001;
            end else if (counter == 5'b00011) begin
                clear_control_signals();
                epc_load = 1'b1;
                mdr_load = 1'b1;
                current_state = STATE_DIV0;
                counter = counter + 5'b00001;
            end else if (counter == 5'b00100) begin
                mux_extend = 1'b0;
                mux_ula1 = 2'b10;
            mux_ula2 = 2'b10;
                mux_pc = 2'b01;
                ula = 3'b001;
                clear_control_signals();
                pc_write = 1'b1;
                current_state = STATE_FETCH;
                counter = 5'b00000;
            end
        end
    endtask

    // INSTRUÇÕES TIPO R - Operações entre registradores
    
    // ADD: Soma dois registradores e armazena resultado
    task handle_add_state;
        begin
            if (counter == 5'b00000) begin
                // Configura ULA para somar A + B
                mux_ula1            = 2'b10;    // Operando A (RS)
                mux_ula2            = 2'b10;    // Operando B (RT)
                ula                 = 3'b001;   // Operação de soma
                clear_loads_except_ulaout();
                 ula_out_load        = 1'b1;    // Salva resultado da soma
                memory_wr           = 1'b0;
                reg_wr              = 1'b0;
                pc_write            = 1'b0;
                is_beq              = 1'b0;
                is_bne              = 1'b0;
                mult_init           = 1'b0;
                div_init            = 1'b0;
                
                current_state = STATE_ADD;
                counter = counter + 5'b00001;
            end else if (counter == 5'b00001) begin
                // Escreve resultado no registrador destino (RD)
                mux_reg_dest        = 2'b01;    // Destino = RD
                mux_reg_data        = 3'b000;   // Dados = ULA_OUT
                clear_other_loads();
                memory_wr           = 1'b0;
                reg_wr              = 1'b1;     // Habilita escrita no registrador
                pc_write            = 1'b0;
                is_beq              = 1'b0;
                is_bne              = 1'b0;
                mult_init           = 1'b0;
                div_init            = 1'b0;
                
                current_state = STATE_FETCH;
                counter = 5'b00000;
            end
        end
    endtask

    task handle_and_state;
        begin
            if (counter == 5'b00000) begin
                mux_ula1 = 2'b01;
                 mux_ula2 = 2'b00;
                ula = 3'b011;
                clear_control_signals();
                ula_out_load = 1'b1;
                current_state = STATE_AND;
                counter = counter + 5'b00001;
            end else if (counter == 5'b00001) begin
                mux_register_wr = 2'b11;
                 mux_register_wd = 3'b010;
                clear_control_signals();
                reg_wr = 1'b1;
                current_state = STATE_FETCH;
                counter = 5'b00000;
            end
        end
    endtask

    // Implementação básica dos demais estados (mantendo funcionalidade)
    task handle_div_state;
        begin
            if (counter == 5'b00000) begin
                if (div_zero) begin
                    current_state = STATE_DIV0;
                    counter = 5'b00000;
                end else begin
                    clear_control_signals();
                    div_init = 1'b1;
                    current_state = STATE_DIV;
                    counter = counter + 5'b00001;
                end
            end else if (div_stop && counter >= 5'b00001) begin
                current_state = STATE_FETCH;
                counter = 5'b00000;
            end else begin
                clear_control_signals();
                current_state = STATE_DIV;
                counter = counter + 5'b00001;
            end
        end
    endtask

    task handle_mult_state;
        begin
            if (counter == 5'b00000) begin
                clear_control_signals();
                mult_init = 1'b1;
                current_state = STATE_MULT;
                counter = counter + 5'b00001;
            end else if (mult_stop && counter >= 5'b00001) begin
                current_state = STATE_FETCH;
                counter = 5'b00000;
            end else begin
                clear_control_signals();
                current_state = STATE_MULT;
                counter = counter + 5'b00001;
            end
        end
    endtask

    task handle_jr_state;
        begin
            mux_pc = 2'b00;
            clear_control_signals();
            pc_write = 1'b1;
            current_state = STATE_FETCH;
            counter = 5'b00000;
        end
    endtask

    task handle_mfhi_state;
        begin
            mux_register_wr = 2'b11;
                 mux_register_wd = 3'b100;
            clear_control_signals();
            reg_wr = 1'b1;
            current_state = STATE_FETCH;
            counter = 5'b00000;
        end
    endtask

    task handle_mflo_state;
        begin
            mux_register_wr = 2'b11;
                 mux_register_wd = 3'b101;
            clear_control_signals();
            reg_wr = 1'b1;
            current_state = STATE_FETCH;
            counter = 5'b00000;
        end
    endtask

    task handle_sll_state;
        begin
            if (counter == 5'b00000) begin
                mux_shift_amt = 2'b00;
                mux_shift_src = 1'b0;
                shift = 3'b001;
                clear_control_signals();
                current_state = STATE_SLL;
                counter = counter + 5'b00001;
            end else if (counter == 5'b00001) begin
                mux_register_wr = 2'b11;
                 mux_register_wd = 3'b110;
                clear_control_signals();
                reg_wr = 1'b1;
                current_state = STATE_FETCH;
                counter = 5'b00000;
            end
        end
    endtask

    task handle_slt_state;
        begin
            if (counter == 5'b00000) begin
                mux_ula1 = 2'b01;
                 mux_ula2 = 2'b00;
                ula = 3'b110;
                clear_control_signals();
                ula_out_load = 1'b1;
                current_state = STATE_SLT;
                counter = counter + 5'b00001;
            end else if (counter == 5'b00001) begin
                mux_register_wr = 2'b11;
                 mux_register_wd = 3'b010;
                clear_control_signals();
                reg_wr = 1'b1;
                current_state = STATE_FETCH;
                counter = 5'b00000;
            end
        end
    endtask

    task handle_sra_state;
        begin
            if (counter == 5'b00000) begin
                mux_shift_amt = 2'b00;
                mux_shift_src = 1'b0;
                shift = 3'b010;
                clear_control_signals();
                current_state = STATE_SRA;
                counter = counter + 5'b00001;
            end else if (counter == 5'b00001) begin
                mux_register_wr = 2'b11;
                 mux_register_wd = 3'b110;
                clear_control_signals();
                reg_wr = 1'b1;
                current_state = STATE_FETCH;
                counter = 5'b00000;
            end
        end
    endtask

    task handle_sub_state;
        begin
            if (counter == 5'b00000) begin
                mux_ula1 = 2'b01;
                 mux_ula2 = 2'b00;
                ula = 3'b010;
                clear_control_signals();
                ula_out_load = 1'b1;
                current_state = STATE_SUB;
                counter = counter + 5'b00001;
            end else if (overflow && counter == 5'b00001) begin
                current_state = STATE_OVERFLOW;
                counter = 5'b00000;
            end else if (counter == 5'b00001) begin
                mux_register_wr = 2'b11;
                mux_register_wd = 3'b010;
                clear_control_signals();
                reg_wr = 1'b1;
                current_state = STATE_FETCH;
                counter = 5'b00000;
            end
        end
    endtask

    task handle_xchg_state;
        begin
            if (counter == 5'b00000) begin
                mux_register_wr = 2'b01;
            mux_register_wd = 3'b001;
                clear_control_signals();
                reg_wr = 1'b1;
                current_state = STATE_XCHG;
                counter = counter + 5'b00001;
            end else if (counter == 5'b00001) begin
                mux_register_wr = 2'b11;
            mux_register_wd = 3'b000;
                clear_control_signals();
                reg_wr = 1'b1;
                current_state = STATE_FETCH;
                counter = 5'b00000;
            end
        end
    endtask

    task handle_addi_state;
        begin
            if (counter == 5'b00000) begin
                mux_ula1 = 2'b01;
                 mux_ula2 = 2'b10;
                mux_extend = 1'b1;
                ula = 3'b001;
                clear_control_signals();
                ula_out_load = 1'b1;
                current_state = STATE_ADDI;
                counter = counter + 5'b00001;
            end else if (overflow && counter == 5'b00001) begin
                current_state = STATE_OVERFLOW;
                counter = 5'b00000;
            end else if (counter == 5'b00001) begin
                mux_register_wr = 2'b00;
                mux_register_wd = 3'b010;
                clear_control_signals();
                reg_wr = 1'b1;
                current_state = STATE_FETCH;
                counter = 5'b00000;
            end
        end
    endtask

    task handle_beq_state;
        begin
            mux_ula1 = 2'b01;
                 mux_ula2 = 2'b00;
            mux_pc = 2'b01;
            clear_control_signals();
            ula = 3'b010;
            is_beq = 1'b1;
            current_state = STATE_FETCH;
            counter = 5'b00000;
        end
    endtask

    task handle_bne_state;
        begin
            mux_ula1 = 2'b01;
                 mux_ula2 = 2'b00;
            mux_pc = 2'b01;
            clear_control_signals();
            ula = 3'b010;
            is_bne = 1'b1;
            current_state = STATE_FETCH;
            counter = 5'b00000;
        end
    endtask

    task handle_sllm_state;
        begin
            if (counter == 5'b00000) begin
                mux_ula1 = 2'b01;
                 mux_ula2 = 2'b10;
                mux_extend = 1'b1;
                ula = 3'b001;
                clear_control_signals();
                ula_out_load = 1'b1;
                current_state = STATE_SLLM;
                counter = counter + 5'b00001;
            end else if (overflow && counter == 5'b00001) begin
                current_state = STATE_OVERFLOW;
                counter = 5'b00000;
            end else if (counter >= 5'b00001 && counter <= 5'b00011) begin
                mux_address = 3'b001;
                clear_control_signals();
                current_state = STATE_SLLM;
                counter = counter + 5'b00001;
            end else if (counter == 5'b00100) begin
                clear_control_signals();
                mdr_load = 1'b1;
                current_state = STATE_SLLM;
                counter = counter + 5'b00001;
            end else if (counter == 5'b00101) begin
                mux_address = 3'b001;
                mux_mem_data = 1'b1;
                store_size = 1'b0;
                clear_control_signals();
                memory_wr = 1'b1;
                current_state = STATE_FETCH;
                counter = 5'b00000;
            end
        end
    endtask

    task handle_lb_state;
        begin
            if (counter == 5'b00000) begin
                mux_ula1 = 2'b01;
                 mux_ula2 = 2'b10;
                mux_extend = 1'b1;
                ula = 3'b001;
                clear_control_signals();
                ula_out_load = 1'b1;
                current_state = STATE_LB;
                counter = counter + 5'b00001;
            end else if (overflow && counter == 5'b00001) begin
                current_state = STATE_OVERFLOW;
                counter = 5'b00000;
            end else if (counter >= 5'b00001 && counter <= 5'b00011) begin
                mux_address = 3'b001;
                clear_control_signals();
                current_state = STATE_LB;
                counter = counter + 5'b00001;
            end else if (counter == 5'b00100) begin
                load_size = 2'b01;
                clear_control_signals();
                mdr_load = 1'b1;
                current_state = STATE_LB;
                counter = counter + 5'b00001;
            end else if (counter == 5'b00101) begin
                mux_register_wr = 2'b00;
                mux_register_wd = 3'b011;
                clear_control_signals();
                reg_wr = 1'b1;
                current_state = STATE_FETCH;
                counter = 5'b00000;
            end
        end
    endtask

    task handle_lui_state;
        begin
            mux_register_wr = 2'b00;
            mux_register_wd = 3'b001;
            clear_control_signals();
            reg_wr = 1'b1;
            current_state = STATE_FETCH;
            counter = 5'b00000;
        end
    endtask

    task handle_lw_state;
        begin
            if (counter == 5'b00000) begin
                // Calcula endereço: base + offset
                mux_extend          = 1'b1;     // Extensão com sinal do imediato
                mux_ula1            = 2'b10;    // Base (RS)
                 mux_ula2            = 2'b11;    // Offset (imediato estendido)
                 ula                 = 3'b001;   // Soma para calcular endereço
                 clear_loads_except_ulaout();
                 ula_out_load        = 1'b1;    // Salva endereço calculado
                memory_wr           = 1'b0;
                reg_wr              = 1'b0;
                pc_write            = 1'b0;
                is_beq              = 1'b0;
                is_bne              = 1'b0;
                mult_init           = 1'b0;
                div_init            = 1'b0;
                
                current_state = STATE_LW;
                counter = counter + 5'b00001;
            end else if (counter == 5'b00001) begin
                // Acessa memória no endereço calculado
                mux_address         = 3'b001;   // Endereço = ULA_OUT
                clear_loads_except_mdr();
                mdr_load            = 1'b1;     // Carrega dados da memória
                memory_wr           = 1'b0;     // Operação de leitura
                reg_wr              = 1'b0;
                pc_write            = 1'b0;
                is_beq              = 1'b0;
                is_bne              = 1'b0;
                mult_init           = 1'b0;
                div_init            = 1'b0;
                
                current_state = STATE_LW;
                counter = counter + 5'b00001;
            end else if (counter == 5'b00010) begin
                // Escreve dados carregados no registrador RT
                mux_reg_dest        = 2'b00;    // Destino = RT
                mux_reg_data        = 3'b001;   // Dados = MDR (memória)
                clear_other_loads();
                memory_wr           = 1'b0;
                reg_wr              = 1'b1;     // Habilita escrita no registrador
                pc_write            = 1'b0;
                is_beq              = 1'b0;
                is_bne              = 1'b0;
                mult_init           = 1'b0;
                div_init            = 1'b0;
                
                current_state = STATE_FETCH;
                counter = 5'b00000;
            end
        end
    endtask

    // SW: Armazena palavra do registrador na memória
    task handle_sw_state;
        begin
            if (counter == 5'b00000) begin
                // Calcula endereço: base + offset
                mux_extend          = 1'b1;     // Extensão com sinal do imediato
                mux_ula1            = 2'b10;    // Base (RS)
                 mux_ula2            = 2'b11;    // Offset (imediato estendido)
                 ula                 = 3'b001;   // Soma para calcular endereço
                 clear_loads_except_ulaout();
                 ula_out_load        = 1'b1;    // Salva endereço calculado
                memory_wr           = 1'b0;
                reg_wr              = 1'b0;
                pc_write            = 1'b0;
                is_beq              = 1'b0;
                is_bne              = 1'b0;
                mult_init           = 1'b0;
                div_init            = 1'b0;
                
                current_state = STATE_SW;
                counter = counter + 5'b00001;
            end else if (counter == 5'b00001) begin
                // Escreve dados do registrador RT na memória
                mux_address         = 3'b001;   // Endereço = ULA_OUT
                mux_mem_data        = 1'b0;     // Dados = registrador B (RT)
                clear_other_loads();
                memory_wr           = 1'b1;     // Operação de escrita
                reg_wr              = 1'b0;
                pc_write            = 1'b0;
                is_beq              = 1'b0;
                is_bne              = 1'b0;
                mult_init           = 1'b0;
                div_init            = 1'b0;
                
                current_state = STATE_FETCH;
                counter = 5'b00000;
            end
        end
    endtask

    task handle_j_state;
        begin
            clear_control_signals();
            mux_pc = 2'b11;
            pc_write = 1'b1;
            current_state = STATE_FETCH;
            counter = 5'b00000;
        end
    endtask

    task handle_jal_state;
        begin
            if (counter == 5'b00000) begin
                // Salva PC+4 no registrador $ra (31) para retorno
                mux_reg_dest        = 2'b10;    // Destino = $ra (registrador 31)
                mux_reg_data        = 3'b000;   // Dados = ULA_OUT (PC+4 do FETCH)
                ula                 = 3'b000;   // ULA não usada neste ciclo
                clear_other_loads();
                memory_wr           = 1'b0;
                reg_wr              = 1'b1;     // Escreve endereço de retorno
                pc_write            = 1'b0;
                is_beq              = 1'b0;
                is_bne              = 1'b0;
                mult_init           = 1'b0;
                div_init            = 1'b0;
                
                current_state = STATE_JAL;
                counter = counter + 5'b00001;
            end else if (counter == 5'b00001) begin
                // Salta para endereço target (26 bits + 4 bits do PC)
                mux_pc              = 2'b11;    // PC = endereço de jump
                clear_control_signals();
                memory_wr           = 1'b0;
                reg_wr              = 1'b0;
                pc_write            = 1'b1;     // Atualiza PC com novo endereço
                is_beq              = 1'b0;
                is_bne              = 1'b0;
                mult_init           = 1'b0;
                div_init            = 1'b0;
                
                current_state = STATE_FETCH;
                counter = 5'b00000;
            end
        end
    endtask

endmodule