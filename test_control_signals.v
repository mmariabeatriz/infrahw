module test_control_signals;
    reg clk;
    reg reset;
    reg [31:0] instruction;
    reg zero_flag;
    reg overflow;
    reg div_zero;
    
    // Control signals outputs
    wire [5:0] opcode;
    wire [4:0] rs, rt, rd, shamt;
    wire [5:0] funct;
    wire [15:0] immediate;
    wire [25:0] address;
    wire [3:0] alu_control;
    wire alu_zero, alu_overflow;
    wire reg_dst, jump, branch, mem_read, mem_to_reg;
    wire [3:0] alu_op;
    wire mem_write, alu_src, reg_write;
    wire [1:0] load_size_control, store_size_control;
    wire pc_write, pc_write_cond;
    wire [1:0] pc_source;
    wire [1:0] shift_amt_selector;
    wire [4:0] current_state;
    
    // Instantiate control unit
    control_unit uut (
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
        .current_state(current_state)
    );
    
    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    
    // Test sequence
    initial begin
        $dumpfile("test_control_signals.vcd");
        $dumpvars(0, test_control_signals);
        
        // Initialize
        reset = 1;
        instruction = 32'h00000000;
        zero_flag = 0;
        overflow = 0;
        div_zero = 0;
        
        // Reset
        #10 reset = 0;
        
        // Test ADD instruction (R-type): add $t0, $t1, $t2
        // opcode=000000, rs=01001, rt=01010, rd=01000, shamt=00000, funct=100000
        #10 instruction = 32'b000000_01001_01010_01000_00000_100000;
        
        // Wait for instruction to be processed
        #30;
        
        // Test SLL instruction (R-type): sll $t0, $t1, 2
        // opcode=000000, rs=00000, rt=01001, rd=01000, shamt=00010, funct=000000
        instruction = 32'b000000_00000_01001_01000_00010_000000;
        
        // Wait for instruction to be processed
        #30;
        
        // Test ADDI instruction (I-type): addi $t0, $t1, 100
        // opcode=001000, rs=01001, rt=01000, immediate=0000000001100100
        instruction = 32'b001000_01001_01000_0000000001100100;
        
        // Wait for instruction to be processed
        #30;
        
        $display("Test completed");
        $finish;
    end
    
    // Monitor signals
    always @(posedge clk) begin
        $display("Time=%0t State=%d Instruction=%h", $time, current_state, instruction);
        $display("  reg_dst=%b alu_op=%b reg_write=%b alu_src=%b", reg_dst, alu_op, reg_write, alu_src);
        $display("  shift_amt_selector=%b mem_read=%b mem_write=%b", shift_amt_selector, mem_read, mem_write);
        $display("");
    end
    
endmodule