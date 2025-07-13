module control_unit(
    input clk,
    input reset,
    input [31:0] instruction,
    input zero_flag,
    input overflow,
    input div_zero,
    
    // Instruction fields
    output reg [5:0] opcode,
    output reg [4:0] rs,
    output reg [4:0] rt,
    output reg [4:0] rd,
    output reg [4:0] shamt,
    output reg [5:0] funct,
    output reg [15:0] immediate,
    output reg [25:0] address,
    
    // ALU controls
    output reg [3:0] alu_control,
    output reg alu_zero,
    output reg alu_overflow,
    
    // Control signals
    output reg reg_dst,
    output reg jump,
    output reg branch,
    output reg mem_read,
    output reg mem_to_reg,
    output reg [3:0] alu_op,
    output reg mem_write,
    output reg alu_src,
    output reg reg_write,
    
    // Load/Store size controls
    output reg [1:0] load_size_control,
    output reg [1:0] store_size_control,
    
    // PC controls
    output reg pc_write,
    output reg pc_write_cond,
    output reg [1:0] pc_source,
    
    // Shift amount control
    output reg [1:0] shift_amt_selector,
    
    // State output
    output [4:0] current_state
);

    // VARIABLES
    reg [4:0] state;     // 5 bits para representar o estado atual
    reg [4:0] counter;   // 5 bits para representar o clk atual em um dado estado
    
    // Instruction field extraction
    always @(*) begin
        opcode = instruction[31:26];
        rs = instruction[25:21];
        rt = instruction[20:16];
        rd = instruction[15:11];
        shamt = instruction[10:6];
        funct = instruction[5:0];
        immediate = instruction[15:0];
        address = instruction[25:0];
    end
    
    // Assign current state to output
    assign current_state = state;

    // STATE PARAMETERS
    parameter ST_RESET          = 5'b00000;
    parameter ST_FETCH          = 5'b00001;
    parameter ST_DECODE         = 5'b00010;
    parameter ST_ADD            = 5'b00011;
    parameter ST_AND            = 5'b00100;
    parameter ST_DIV            = 5'b00101;
    parameter ST_MULT           = 5'b00110;
    parameter ST_JR             = 5'b00111;
    parameter ST_MFHI           = 5'b01000;
    parameter ST_MFLO           = 5'b01001;
    parameter ST_SLL            = 5'b01010;
    parameter ST_SLT            = 5'b01011;
    parameter ST_SRA            = 5'b01100;
    parameter ST_SUB            = 5'b01101;
    parameter ST_XCHG           = 5'b01110;
    parameter ST_ADDI           = 5'b01111;
    parameter ST_BEQ            = 5'b10000;
    parameter ST_BNE            = 5'b10001;
    parameter ST_SLLM           = 5'b10010;
    parameter ST_LB             = 5'b10011;
    parameter ST_LUI            = 5'b10100;
    parameter ST_LW             = 5'b10101;
    parameter ST_SB             = 5'b10110;
    parameter ST_SW             = 5'b10111;
    parameter ST_J              = 5'b11000;
    parameter ST_JAL            = 5'b11001;
    parameter ST_OVERFLOW       = 5'b11010;
    parameter ST_OPCODE404      = 5'b11011;
    parameter ST_DIV0           = 5'b11100;

    // Opcodes (instruction type)
    parameter OP_TYPE_R = 6'b000000;
    parameter OP_ADDI   = 6'b001000;
    parameter OP_BEQ    = 6'b000100;
    parameter OP_BNE    = 6'b000101;
    parameter OP_SLLM   = 6'b000001;
    parameter OP_LB     = 6'b100000;
    parameter OP_LUI    = 6'b001111;
    parameter OP_LW     = 6'b100011;
    parameter OP_SB     = 6'b101000;
    parameter OP_SW     = 6'b101011;
    parameter OP_J      = 6'b000010;
    parameter OP_JAL    = 6'b000011;

    // Function codes for R-type instructions
    parameter FUNCT_ADD  = 6'b100000;
    parameter FUNCT_AND  = 6'b100100;
    parameter FUNCT_DIV  = 6'b011010;
    parameter FUNCT_MULT = 6'b011000;
    parameter FUNCT_JR   = 6'b001000;
    parameter FUNCT_MFHI = 6'b010000;
    parameter FUNCT_MFLO = 6'b010010;
    parameter FUNCT_SLL  = 6'b000000;
    parameter FUNCT_SLT  = 6'b101010;
    parameter FUNCT_SRA  = 6'b000011;
    parameter FUNCT_SUB  = 6'b100010;
    parameter FUNCT_XCHG = 6'b000101;

    // Inicialização
    initial begin
        state = ST_RESET;
    end

    // Main state machine
    always @(posedge clk) begin
        if (reset) begin
            state = ST_RESET;
            counter = 5'b00000;
        end else begin
            case (state)
                ST_RESET: handle_reset_state();
                ST_FETCH: handle_fetch_state();
                ST_DECODE: handle_decode_state();
                ST_OVERFLOW: handle_overflow_state();
                ST_OPCODE404: handle_opcode404_state();
                ST_DIV0: handle_div0_state();
                ST_ADD: handle_add_state();
                ST_AND: handle_and_state();
                ST_DIV: handle_div_state();
                ST_MULT: handle_mult_state();
                ST_JR: handle_jr_state();
                ST_MFHI: handle_mfhi_state();
                ST_MFLO: handle_mflo_state();
                ST_SLL: handle_sll_state();
                ST_SLT: handle_slt_state();
                ST_SRA: handle_sra_state();
                ST_SUB: handle_sub_state();
                ST_XCHG: handle_xchg_state();
                ST_ADDI: handle_addi_state();
                ST_BEQ: handle_beq_state();
                ST_BNE: handle_bne_state();
                ST_SLLM: handle_sllm_state();
                ST_LB: handle_lb_state();
                ST_LUI: handle_lui_state();
                ST_LW: handle_lw_state();
                ST_SB: handle_sb_state();
                ST_SW: handle_sw_state();
                ST_J: handle_j_state();
                ST_JAL: handle_jal_state();
                default: state = ST_OPCODE404;
            endcase
        end
    end

    // TASKS
    task reset_control_signals;
        begin
            // Control signals
            reg_dst = 1'b0;
            jump = 1'b0;
            branch = 1'b0;
            mem_read = 1'b0;
            mem_to_reg = 1'b0;
            alu_op = 4'b0000;
            mem_write = 1'b0;
            alu_src = 1'b0;
            reg_write = 1'b0;
            
            // Load/Store size controls
            load_size_control = 2'b00;
            store_size_control = 2'b00;
            
            // PC controls
            pc_write = 1'b0;
            pc_write_cond = 1'b0;
            pc_source = 2'b00;
            
            // Shift amount control
            shift_amt_selector = 2'b00;
            
            // ALU controls
            alu_control = 4'b0000;
            alu_zero = 1'b0;
            alu_overflow = 1'b0;
        end
    endtask

    // Tasks para cada estado
    task handle_reset_state;
        begin
            reset_control_signals();
            state = ST_FETCH;
            counter = 5'b00000;
        end
    endtask

    task handle_fetch_state;
        begin
            // Reset todos os sinais de controle no FETCH
            reset_control_signals();
            
            // Configurar sinais específicos do FETCH
            mem_read = 1'b1;
            pc_write = 1'b1;
            pc_source = 2'b00; // PC + 4
            
            state = ST_DECODE;
            counter = 5'b00000;
        end
    endtask

    task handle_decode_state;
        begin
            counter = 5'b00000;
            decode_instruction();
        end
    endtask

    task decode_instruction;
        begin
            case (opcode)
                OP_TYPE_R: begin
                    case (funct)
                        FUNCT_ADD:  state = ST_ADD;
                        FUNCT_AND:  state = ST_AND;
                        FUNCT_DIV:  state = ST_DIV;
                        FUNCT_MULT: state = ST_MULT;
                        FUNCT_JR:   state = ST_JR;
                        FUNCT_MFHI: state = ST_MFHI;
                        FUNCT_MFLO: state = ST_MFLO;
                        FUNCT_SLL:  state = ST_SLL;
                        FUNCT_SLT:  state = ST_SLT;
                        FUNCT_SRA:  state = ST_SRA;
                        FUNCT_SUB:  state = ST_SUB;
                        FUNCT_XCHG: state = ST_XCHG;
                        default:    state = ST_OPCODE404;
                    endcase
                end
                OP_ADDI:    state = ST_ADDI;
                OP_BEQ:     state = ST_BEQ;
                OP_BNE:     state = ST_BNE;
                OP_SLLM:    state = ST_SLLM;
                OP_LB:      state = ST_LB;
                OP_LUI:     state = ST_LUI;
                OP_LW:      state = ST_LW;
                OP_SB:      state = ST_SB;
                OP_SW:      state = ST_SW;
                OP_J:       state = ST_J;
                OP_JAL:     state = ST_JAL;
                default:    state = ST_OPCODE404;
            endcase
        end
    endtask

    // R-type instruction tasks
    task handle_add_state;
        begin
            reg_dst = 1'b1;
            alu_src = 1'b0; // Use register
            alu_op = 4'b0010; // ADD
            alu_control = 4'b0010; // ADD
            reg_write = 1'b1;
            if (overflow) state = ST_OVERFLOW;
            else state = ST_FETCH;
        end
    endtask

    task handle_and_state;
        begin
            reg_dst = 1'b1;
            alu_src = 1'b0; // Use register
            alu_op = 4'b0001; // AND
            alu_control = 4'b0001; // AND
            reg_write = 1'b1;
            state = ST_FETCH;
        end
    endtask

    task handle_div_state;
        begin
            alu_src = 1'b0; // Use register
            alu_op = 4'b1001; // DIV
            alu_control = 4'b1001; // DIV
            if (div_zero) state = ST_DIV0;
            else state = ST_FETCH;
        end
    endtask

    task handle_mult_state;
        begin
            alu_src = 1'b0; // Use register
            alu_op = 4'b1010; // MULT
            alu_control = 4'b1010; // MULT
            state = ST_FETCH;
        end
    endtask

    task handle_jr_state;
        begin
            pc_write = 1'b1;
            pc_source = 2'b10; // Register
            state = ST_FETCH;
        end
    endtask

    task handle_mfhi_state;
        begin
            reg_dst = 1'b1;
            alu_src = 1'b0; // Use register
            alu_op = 4'b1100; // MFHI
            alu_control = 4'b1100; // MFHI
            reg_write = 1'b1;
            state = ST_FETCH;
        end
    endtask

    task handle_mflo_state;
        begin
            reg_dst = 1'b1;
            alu_src = 1'b0; // Use register
            alu_op = 4'b1101; // MFLO
            alu_control = 4'b1101; // MFLO
            reg_write = 1'b1;
            state = ST_FETCH;
        end
    endtask

    task handle_sll_state;
        begin
            reg_dst = 1'b1;
            alu_src = 1'b0; // Use register
            alu_op = 4'b0100; // SLL
            alu_control = 4'b0100; // SLL
            reg_write = 1'b1;
            shift_amt_selector = 2'b11; // Use shamt from instruction
            state = ST_FETCH;
        end
    endtask

    task handle_slt_state;
        begin
            reg_dst = 1'b1;
            alu_src = 1'b0; // Use register
            alu_op = 4'b0111; // SLT
            alu_control = 4'b0111; // SLT
            reg_write = 1'b1;
            state = ST_FETCH;
        end
    endtask

    task handle_sra_state;
        begin
            reg_dst = 1'b1;
            alu_src = 1'b0; // Use register
            alu_op = 4'b0101; // SRA
            alu_control = 4'b0101; // SRA
            reg_write = 1'b1;
            shift_amt_selector = 2'b11; // Use shamt from instruction
            state = ST_FETCH;
        end
    endtask

    task handle_sub_state;
        begin
            reg_dst = 1'b1;
            alu_src = 1'b0; // Use register
            alu_op = 4'b0110; // SUB
            alu_control = 4'b0110; // SUB
            reg_write = 1'b1;
            if (overflow) state = ST_OVERFLOW;
            else state = ST_FETCH;
        end
    endtask

    task handle_xchg_state;
        begin
            reg_dst = 1'b1;
            alu_src = 1'b0; // Use register
            alu_op = 4'b1011; // XCHG
            alu_control = 4'b1011; // XCHG
            reg_write = 1'b1;
            state = ST_FETCH;
        end
    endtask

    // I-type instruction tasks
    task handle_addi_state;
        begin
            alu_src = 1'b1; // Immediate
            alu_op = 4'b0010; // ADD
            reg_write = 1'b1;
            if (overflow) state = ST_OVERFLOW;
            else state = ST_FETCH;
        end
    endtask

    task handle_beq_state;
        begin
            branch = 1'b1;
            alu_op = 4'b0110; // SUB for comparison
            pc_write_cond = 1'b1;
            pc_source = 2'b01; // Branch target
            state = ST_FETCH;
        end
    endtask

    task handle_bne_state;
        begin
            branch = 1'b1;
            alu_op = 4'b0110; // SUB for comparison
            pc_write_cond = 1'b1;
            pc_source = 2'b01; // Branch target
            state = ST_FETCH;
        end
    endtask

    task handle_sllm_state;
        begin
            alu_src = 1'b1; // Immediate
            alu_op = 4'b0100; // SLL
            reg_write = 1'b1;
            state = ST_FETCH;
        end
    endtask

    task handle_lb_state;
        begin
            alu_src = 1'b1; // Immediate
            alu_op = 4'b0010; // ADD for address calculation
            mem_read = 1'b1;
            mem_to_reg = 1'b1;
            reg_write = 1'b1;
            load_size_control = 2'b00; // Load byte - 1 byte
            state = ST_FETCH;
        end
    endtask

    task handle_lui_state;
        begin
            alu_src = 1'b1; // Immediate
            alu_op = 4'b1000; // LUI
            reg_write = 1'b1;
            state = ST_FETCH;
        end
    endtask

    task handle_lw_state;
        begin
            alu_src = 1'b1; // Immediate
            alu_op = 4'b0010; // ADD for address calculation
            mem_read = 1'b1;
            mem_to_reg = 1'b1;
            reg_write = 1'b1;
            load_size_control = 2'b10; // Load word - 4 bytes
            state = ST_FETCH;
        end
    endtask

    task handle_sb_state;
        begin
            alu_src = 1'b1; // Immediate
            alu_op = 4'b0010; // ADD for address calculation
            mem_write = 1'b1;
            store_size_control = 2'b00; // Store byte - 1 byte
            state = ST_FETCH;
        end
    endtask

    task handle_sw_state;
        begin
            alu_src = 1'b1; // Immediate
            alu_op = 4'b0010; // ADD for address calculation
            mem_write = 1'b1;
            store_size_control = 2'b10; // Store word - 4 bytes
            state = ST_FETCH;
        end
    endtask

    // J-type instruction tasks
    task handle_j_state;
        begin
            jump = 1'b1;
            pc_write = 1'b1;
            pc_source = 2'b11; // Jump target
            state = ST_FETCH;
        end
    endtask

    task handle_jal_state;
        begin
            jump = 1'b1;
            pc_write = 1'b1;
            pc_source = 2'b11; // Jump target
            reg_write = 1'b1; // Write return address to $ra
            state = ST_FETCH;
        end
    endtask

    // Exception handling tasks
    task handle_overflow_state;
        begin
            pc_write = 1'b1;
            pc_source = 2'b11; // Exception handler address
            state = ST_FETCH;
        end
    endtask

    task handle_opcode404_state;
        begin
            pc_write = 1'b1;
            pc_source = 2'b11; // Exception handler address
            state = ST_FETCH;
        end
    endtask

    task handle_div0_state;
        begin
            pc_write = 1'b1;
            pc_source = 2'b11; // Exception handler address
            state = ST_FETCH;
        end
    endtask

endmodule