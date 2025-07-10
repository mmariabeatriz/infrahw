module control_unit (
    // INPUT PORTS
    input wire          clk,
    input wire          reset_in,
    input wire [5:0]    opcode,
    input wire [15:0]   immediate,
    input wire          overflow,
    input wire          zero_div,
    input wire          mult_stop,
    input wire          div_stop,
    input wire          div_zero,

    // OUTPUT PORTS
    // Muxs (até 2 entradas)
    output reg          mux_wd_memory,
    output reg          mux_high,
    output reg          mux_low,
    output reg          mux_extend,
    output reg          mux_b,
    output reg          mux_shift_src,
    output reg [1:0]    mux_shift_amt,

    // Muxs (até 4 entradas)
    output reg [1:0]    mux_a,               // 3 entradas
    output reg [1:0]    mux_alu1,            // 3 entradas
    output reg [1:0]    mux_alu2,            // 4 entradas
    output reg [1:0]    mux_pc,              // 4 entradas
    output reg [1:0]    mux_wr_registers,    // 4 entradas

    // Muxs (até 8 entradas)
    output reg [2:0]    mux_address,         // 5 entradas
    output reg [2:0]    mux_wd_registers,    // 7 entradas

    // Registers
    output reg          address_rg_load,
    output reg          epc_load,
    output reg          mdr_load,
    output reg          ir_load,
    output reg          high_load,
    output reg          low_load,
    output reg          a_load,
    output reg          b_load,
    output reg          alu_out_load,

    // Write and Read Controllers
    output reg          store_size,
    output reg [1:0]    load_size,
    output reg          memory_wr,
    output reg          reg_wr,

    // Controlador Controllers
    output reg          pc_write,
    output reg          is_beq,              // Antigo PCWriteCond
    output reg          is_bne,

    // Special Controllers
    output reg [2:0]    ula,
    output reg [2:0]    shift,

    // Mult Controller
    output reg          mult_init,
    // Div Controller
    output reg          div_init
);

    // VARIABLES
    reg [5:0] current_state;    // 6 bits para representar o estado atual
    reg [4:0] counter;          // 5 bits para representar o clk atual em um dado estado
    wire [5:0] funct;
    assign funct = immediate[5:0];

    // STATE PARAMETERS
    localparam STATE_RESET      = 6'b000000;
    localparam STATE_FETCH      = 6'b000001;
    localparam STATE_DECODE     = 6'b000010;
    localparam STATE_OVERFLOW   = 6'b000011;
    localparam STATE_OPCODE404  = 6'b000100;
    localparam STATE_DIV0       = 6'b000101;

    localparam STATE_ADD        = 6'b000110;
    localparam STATE_AND        = 6'b000111;
    localparam STATE_DIV        = 6'b001000;
    localparam STATE_MULT       = 6'b001001;
    localparam STATE_JR         = 6'b001010;
    localparam STATE_MFHI       = 6'b001011;
    localparam STATE_MFLO       = 6'b001100;
    localparam STATE_SLL        = 6'b001101;
    localparam STATE_SLT        = 6'b001110;
    localparam STATE_SRA        = 6'b001111;
    localparam STATE_SUB        = 6'b010001;
    localparam STATE_XCHG       = 6'b010010;

    localparam STATE_ADDI       = 6'b010011;
    localparam STATE_BEQ        = 6'b010100;
    localparam STATE_BNE        = 6'b010101;
    localparam STATE_SLLM       = 6'b010110;
    localparam STATE_LB         = 6'b010111;
    localparam STATE_LUI        = 6'b011000;
    localparam STATE_LW         = 6'b011001;
    localparam STATE_SB         = 6'b011010;
    localparam STATE_SW         = 6'b011011;

    localparam STATE_J          = 6'b011110;
    localparam STATE_JAL        = 6'b011111;

    // Opcodes (instruction type)
    localparam OP_TYPE_R        = 6'b000000;
    localparam OP_ADDI          = 6'b001000;
    localparam OP_BEQ           = 6'b000100;
    localparam OP_BNE           = 6'b000101;
    localparam OP_SLLM          = 6'b001001;
    localparam OP_LB            = 6'b100000;
    localparam OP_LUI           = 6'b001111;
    localparam OP_LW            = 6'b100011;
    localparam OP_SB            = 6'b101000;
    localparam OP_SW            = 6'b101011;
    localparam OP_J             = 6'b000010;
    localparam OP_JAL           = 6'b000011;

    // Funct of type R
    localparam FUNCT_ADD        = 6'b100000;
    localparam FUNCT_AND        = 6'b100100;
    localparam FUNCT_DIV        = 6'b011010;
    localparam FUNCT_MULT       = 6'b011000;
    localparam FUNCT_JR         = 6'b001000;
    localparam FUNCT_MFHI       = 6'b010000;
    localparam FUNCT_MFLO       = 6'b010010;
    localparam FUNCT_SLL        = 6'b000000;
    localparam FUNCT_SLT        = 6'b101010;
    localparam FUNCT_SRA        = 6'b000011;
    localparam FUNCT_SUB        = 6'b100010;
    localparam FUNCT_XCHG       = 6'b000101;

    // Inicialização
    initial begin
        current_state = STATE_RESET;
    end

    // Processo principal
    always @(posedge clk) begin
        // RESET
        if (reset_in == 1'b1) begin
            reset_all_signals();
            current_state = STATE_FETCH;
            counter = 5'b00000;
        end else begin
            case (current_state)
                STATE_FETCH: handle_fetch_state();
                STATE_DECODE: handle_decode_state();
                STATE_OVERFLOW: handle_overflow_state();
                STATE_OPCODE404: handle_opcode404_state();
                STATE_DIV0: handle_div0_state();
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
                STATE_ADDI: handle_addi_state();
                STATE_BEQ: handle_beq_state();
                STATE_BNE: handle_bne_state();
                STATE_SLLM: handle_sllm_state();
                STATE_LB: handle_lb_state();
                STATE_LUI: handle_lui_state();
                STATE_LW: handle_lw_state();
                STATE_SB: handle_sb_state();
                STATE_SW: handle_sw_state();
                STATE_J: handle_j_state();
                STATE_JAL: handle_jal_state();
                default: current_state = STATE_OPCODE404;
            endcase
        end
    end

    // Task para reset de todos os sinais
    task reset_all_signals;
        begin
            mux_wr_registers    = 2'b01;
            mux_wd_registers    = 3'b000;
            address_rg_load     = 1'b0;
            epc_load            = 1'b0;
            mdr_load            = 1'b0;
            ir_load             = 1'b0;
            high_load           = 1'b0;
            low_load            = 1'b0;
            a_load              = 1'b0;
            b_load              = 1'b0;
            alu_out_load        = 1'b0;
            memory_wr           = 1'b0;
            reg_wr              = 1'b1;
            pc_write            = 1'b0;
            is_beq              = 1'b0;
            is_bne              = 1'b0;
            
            // Special Controllers
            ula                 = 3'b000;
            shift               = 3'b000;
            
            // Mux Controllers
            mux_wd_memory       = 1'b0;
            mux_high            = 1'b0;
            mux_low             = 1'b0;
            mux_extend          = 1'b0;
            mux_b               = 1'b0;
            mux_shift_src       = 1'b0;
            mux_shift_amt       = 2'b00;
            mux_a               = 2'b00;
            mux_alu1            = 2'b00;
            mux_alu2            = 2'b00;
            mux_pc              = 2'b00;
            mux_address         = 3'b000;
            
            // Size Controllers
            store_size          = 1'b0;
            load_size           = 2'b00;
            
            // Mult and Div Controllers
            mult_init           = 1'b0;
            div_init            = 1'b0;
        end
    endtask

    // Task para limpar sinais de controle
    task clear_control_signals;
        begin
            address_rg_load     = 1'b0;
            epc_load            = 1'b0;
            mdr_load            = 1'b0;
            ir_load             = 1'b0;
            high_load           = 1'b0;
            low_load            = 1'b0;
            a_load              = 1'b0;
            b_load              = 1'b0;
            alu_out_load        = 1'b0;
            memory_wr           = 1'b0;
            reg_wr              = 1'b0;
            pc_write            = 1'b0;
            is_beq              = 1'b0;
            is_bne              = 1'b0;
            mult_init           = 1'b0;
            div_init            = 1'b0;
        end
    endtask

    // Tasks para cada estado
    task handle_fetch_state;
        begin
            if (counter <= 5'b00010) begin
                mux_address         = 3'b000;
                mux_alu1            = 2'b00;
                mux_alu2            = 2'b01;
                ula                 = 3'b001;
                address_rg_load     = 1'b1;
                alu_out_load        = 1'b1;
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
                mux_pc              = 2'b10;
                clear_loads_except_ir();
                ir_load             = 1'b1;
                memory_wr           = 1'b0;
                reg_wr              = 1'b0;
                pc_write            = 1'b1;
                is_beq              = 1'b0;
                is_bne              = 1'b0;
                mult_init           = 1'b0;
                div_init            = 1'b0;
                
                current_state = STATE_DECODE;
                counter = 5'b00000;
            end
        end
    endtask

    task handle_decode_state;
        begin
            if (counter == 5'b00000) begin
                mux_extend          = 1'b1;
                mux_alu1            = 2'b00;
                mux_alu2            = 2'b11;
                ula                 = 3'b001;
                clear_loads_except_aluout();
                alu_out_load        = 1'b1;
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
                mux_a               = 2'b01;
                mux_b               = 1'b0;
                clear_loads_except_ab();
                a_load              = 1'b1;
                b_load              = 1'b1;
                memory_wr           = 1'b0;
                reg_wr              = 1'b0;
                pc_write            = 1'b0;
                is_beq              = 1'b0;
                is_bne              = 1'b0;
                mult_init           = 1'b0;
                div_init            = 1'b0;
                
                counter = 5'b00000;
                decode_instruction();
            end
        end
    endtask

    task decode_instruction;
        begin
            case (opcode)
                OP_TYPE_R: begin
                    case (funct)
                        FUNCT_ADD:  current_state = STATE_ADD;
                        FUNCT_AND:  current_state = STATE_AND;
                        FUNCT_DIV:  current_state = STATE_DIV;
                        FUNCT_MULT: current_state = STATE_MULT;
                        FUNCT_JR:   current_state = STATE_JR;
                        FUNCT_MFHI: current_state = STATE_MFHI;
                        FUNCT_MFLO: current_state = STATE_MFLO;
                        FUNCT_SLL:  current_state = STATE_SLL;
                        FUNCT_SLT:  current_state = STATE_SLT;
                        FUNCT_SRA:  current_state = STATE_SRA;
                        FUNCT_SUB:  current_state = STATE_SUB;
                        FUNCT_XCHG: current_state = STATE_XCHG;
                        default:    current_state = STATE_OPCODE404;
                    endcase
                end
                OP_ADDI:    current_state = STATE_ADDI;
                OP_BEQ:     current_state = STATE_BEQ;
                OP_BNE:     current_state = STATE_BNE;
                OP_SLLM:    current_state = STATE_SLLM;
                OP_LB:      current_state = STATE_LB;
                OP_LUI:     current_state = STATE_LUI;
                OP_LW:      current_state = STATE_LW;
                OP_SB:      current_state = STATE_SB;
                OP_SW:      current_state = STATE_SW;
                OP_J:       current_state = STATE_J;
                OP_JAL:     current_state = STATE_JAL;
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
            alu_out_load        = 1'b0;
        end
    endtask

    task clear_loads_except_aluout;
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
            alu_out_load        = 1'b0;
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
                mux_alu1 = 2'b10;
                mux_alu2 = 2'b10;
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
                mux_alu1 = 2'b10;
                mux_alu2 = 2'b10;
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
                mux_alu1 = 2'b10;
                mux_alu2 = 2'b10;
                mux_pc = 2'b01;
                ula = 3'b001;
                clear_control_signals();
                pc_write = 1'b1;
                current_state = STATE_FETCH;
                counter = 5'b00000;
            end
        end
    endtask

    task handle_add_state;
        begin
            if (counter == 5'b00000) begin
                mux_alu1 = 2'b01;
                mux_alu2 = 2'b00;
                ula = 3'b001;
                clear_control_signals();
                alu_out_load = 1'b1;
                current_state = STATE_ADD;
                counter = counter + 5'b00001;
            end else if (overflow && counter == 5'b00001) begin
                current_state = STATE_OVERFLOW;
                counter = 5'b00000;
            end else if (counter == 5'b00001) begin
                mux_wr_registers = 2'b11;
                mux_wd_registers = 3'b010;
                clear_control_signals();
                reg_wr = 1'b1;
                current_state = STATE_FETCH;
                counter = 5'b00000;
            end
        end
    endtask

    task handle_and_state;
        begin
            if (counter == 5'b00000) begin
                mux_alu1 = 2'b01;
                mux_alu2 = 2'b00;
                ula = 3'b011;
                clear_control_signals();
                alu_out_load = 1'b1;
                current_state = STATE_AND;
                counter = counter + 5'b00001;
            end else if (counter == 5'b00001) begin
                mux_wr_registers = 2'b11;
                mux_wd_registers = 3'b010;
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
            mux_wr_registers = 2'b11;
            mux_wd_registers = 3'b100;
            clear_control_signals();
            reg_wr = 1'b1;
            current_state = STATE_FETCH;
            counter = 5'b00000;
        end
    endtask

    task handle_mflo_state;
        begin
            mux_wr_registers = 2'b11;
            mux_wd_registers = 3'b101;
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
                mux_wr_registers = 2'b11;
                mux_wd_registers = 3'b110;
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
                mux_alu1 = 2'b01;
                mux_alu2 = 2'b00;
                ula = 3'b110;
                clear_control_signals();
                alu_out_load = 1'b1;
                current_state = STATE_SLT;
                counter = counter + 5'b00001;
            end else if (counter == 5'b00001) begin
                mux_wr_registers = 2'b11;
                mux_wd_registers = 3'b010;
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
                mux_wr_registers = 2'b11;
                mux_wd_registers = 3'b110;
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
                mux_alu1 = 2'b01;
                mux_alu2 = 2'b00;
                ula = 3'b010;
                clear_control_signals();
                alu_out_load = 1'b1;
                current_state = STATE_SUB;
                counter = counter + 5'b00001;
            end else if (overflow && counter == 5'b00001) begin
                current_state = STATE_OVERFLOW;
                counter = 5'b00000;
            end else if (counter == 5'b00001) begin
                mux_wr_registers = 2'b11;
                mux_wd_registers = 3'b010;
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
                mux_wr_registers = 2'b01;
                mux_wd_registers = 3'b001;
                clear_control_signals();
                reg_wr = 1'b1;
                current_state = STATE_XCHG;
                counter = counter + 5'b00001;
            end else if (counter == 5'b00001) begin
                mux_wr_registers = 2'b11;
                mux_wd_registers = 3'b000;
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
                mux_alu1 = 2'b01;
                mux_alu2 = 2'b10;
                mux_extend = 1'b1;
                ula = 3'b001;
                clear_control_signals();
                alu_out_load = 1'b1;
                current_state = STATE_ADDI;
                counter = counter + 5'b00001;
            end else if (overflow && counter == 5'b00001) begin
                current_state = STATE_OVERFLOW;
                counter = 5'b00000;
            end else if (counter == 5'b00001) begin
                mux_wr_registers = 2'b00;
                mux_wd_registers = 3'b010;
                clear_control_signals();
                reg_wr = 1'b1;
                current_state = STATE_FETCH;
                counter = 5'b00000;
            end
        end
    endtask

    task handle_beq_state;
        begin
            mux_alu1 = 2'b01;
            mux_alu2 = 2'b00;
            mux_pc = 2'b01;
            ula = 3'b010;
            clear_control_signals();
            is_beq = 1'b1;
            current_state = STATE_FETCH;
            counter = 5'b00000;
        end
    endtask

    task handle_bne_state;
        begin
            mux_alu1 = 2'b01;
            mux_alu2 = 2'b00;
            mux_pc = 2'b01;
            ula = 3'b010;
            clear_control_signals();
            is_bne = 1'b1;
            current_state = STATE_FETCH;
            counter = 5'b00000;
        end
    endtask

    task handle_sllm_state;
        begin
            if (counter == 5'b00000) begin
                mux_alu1 = 2'b01;
                mux_alu2 = 2'b10;
                mux_extend = 1'b1;
                ula = 3'b001;
                clear_control_signals();
                alu_out_load = 1'b1;
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
                mux_wd_memory = 1'b1;
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
                mux_alu1 = 2'b01;
                mux_alu2 = 2'b10;
                mux_extend = 1'b1;
                ula = 3'b001;
                clear_control_signals();
                alu_out_load = 1'b1;
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
                mux_wr_registers = 2'b00;
                mux_wd_registers = 3'b011;
                clear_control_signals();
                reg_wr = 1'b1;
                current_state = STATE_FETCH;
                counter = 5'b00000;
            end
        end
    endtask

    task handle_lui_state;
        begin
            mux_wr_registers = 2'b00;
            mux_wd_registers = 3'b001;
            clear_control_signals();
            reg_wr = 1'b1;
            current_state = STATE_FETCH;
            counter = 5'b00000;
        end
    endtask

    task handle_lw_state;
        begin
            if (counter == 5'b00000) begin
                mux_alu1 = 2'b01;
                mux_alu2 = 2'b10;
                mux_extend = 1'b1;
                ula = 3'b001;
                clear_control_signals();
                alu_out_load = 1'b1;
                current_state = STATE_LW;
                counter = counter + 5'b00001;
            end else if (overflow && counter == 5'b00001) begin
                current_state = STATE_OVERFLOW;
                counter = 5'b00000;
            end else if (counter >= 5'b00001 && counter <= 5'b00011) begin
                mux_address = 3'b001;
                clear_control_signals();
                current_state = STATE_LW;
                counter = counter + 5'b00001;
            end else if (counter == 5'b00100) begin
                load_size = 2'b00;
                clear_control_signals();
                mdr_load = 1'b1;
                current_state = STATE_LW;
                counter = counter + 5'b00001;
            end else if (counter == 5'b00101) begin
                mux_wr_registers = 2'b00;
                mux_wd_registers = 3'b011;
                clear_control_signals();
                reg_wr = 1'b1;
                current_state = STATE_FETCH;
                counter = 5'b00000;
            end
        end
    endtask

    task handle_sb_state;
        begin
            if (counter == 5'b00000) begin
                mux_alu1 = 2'b01;
                mux_alu2 = 2'b10;
                mux_extend = 1'b1;
                ula = 3'b001;
                clear_control_signals();
                alu_out_load = 1'b1;
                current_state = STATE_SB;
                counter = counter + 5'b00001;
            end else if (overflow && counter == 5'b00001) begin
                current_state = STATE_OVERFLOW;
                counter = 5'b00000;
            end else if (counter == 5'b00001) begin
                mux_address = 3'b001;
                mux_wd_memory = 1'b0;
                store_size = 1'b1;
                clear_control_signals();
                memory_wr = 1'b1;
                current_state = STATE_FETCH;
                counter = 5'b00000;
            end
        end
    endtask

    task handle_sw_state;
        begin
            if (counter == 5'b00000) begin
                mux_alu1 = 2'b01;
                mux_alu2 = 2'b10;
                mux_extend = 1'b1;
                ula = 3'b001;
                clear_control_signals();
                alu_out_load = 1'b1;
                current_state = STATE_SW;
                counter = counter + 5'b00001;
            end else if (overflow && counter == 5'b00001) begin
                current_state = STATE_OVERFLOW;
                counter = 5'b00000;
            end else if (counter == 5'b00001) begin
                mux_address = 3'b001;
                mux_wd_memory = 1'b0;
                clear_control_signals();
                memory_wr = 1'b1;
                current_state = STATE_FETCH;
                counter = 5'b00000;
            end
        end
    endtask

    task handle_j_state;
        begin
            mux_pc = 2'b11;
            clear_control_signals();
            pc_write = 1'b1;
            current_state = STATE_FETCH;
            counter = 5'b00000;
        end
    endtask

    task handle_jal_state;
        begin
            if (counter == 5'b00000) begin
                mux_alu1 = 2'b00;
                mux_alu2 = 2'b00;
                ula = 3'b000;
                clear_control_signals();
                alu_out_load = 1'b1;
                current_state = STATE_JAL;
                counter = counter + 5'b00001;
            end else if (counter == 5'b00001) begin
                mux_pc = 2'b11;
                mux_wd_registers = 3'b010;
                mux_wr_registers = 2'b10;
                clear_control_signals();
                reg_wr = 1'b1;
                pc_write = 1'b1;
                current_state = STATE_FETCH;
                counter = 5'b00000;
            end
        end
    endtask

endmodule