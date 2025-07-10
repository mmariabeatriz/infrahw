module test_control_signals;
    // Sinais de entrada
    reg clk, Reset_In;
    reg [5:0] Opcode;
    reg [15:0] IMMEDIATE;
    reg Overflow, Zero_Div, MultStop, DivStop, DivZero;
    
    // Sinais de saída
    wire [2:0] Mux_Address, Mux_WD_Registers, ULA, Shift;
    wire [1:0] Mux_A, Mux_ALU1, Mux_ALU2, Mux_PC, Mux_WR_Registers, Load_Size;
    wire Mux_WD_Memory, Mux_High, Mux_Low, Mux_Extend, Mux_B, Mux_Shift_Src;
wire [1:0] Mux_Shift_Amt;
    wire Adress_RG_Load, EPC_Load, MDR_Load, IR_Load;
    wire High_Load, Low_Load, A_Load, B_Load, ALUOut_Load;
    wire Store_Size, Memory_WR, Reg_WR, PCWrite, IsBEQ, IsBNE;
    wire MultInit, DivInit;
    
    // Instância do controlador
    Unid_Control uut (
        .clk(clk),
        .Reset_In(Reset_In),
        .Opcode(Opcode),
        .IMMEDIATE(IMMEDIATE),
        .Overflow(Overflow),
        .Zero_Div(Zero_Div),
        .MultStop(MultStop),
        .DivStop(DivStop),
        .DivZero(DivZero),
        .Mux_Address(Mux_Address),
        .Mux_WD_Registers(Mux_WD_Registers),
        .ULA(ULA),
        .Mux_PC(Mux_PC),
        .Mux_WR_Registers(Mux_WR_Registers),
        .Mux_ALU1(Mux_ALU1),
        .Mux_ALU2(Mux_ALU2),
        .Mux_A(Mux_A),
        .Mux_Extend(Mux_Extend),
        .Mux_B(Mux_B),
        .Mux_WD_Memory(Mux_WD_Memory),
        .Mux_High(Mux_High),
        .Mux_Low(Mux_Low),
        .Mux_Shift_Src(Mux_Shift_Src),
        .Mux_Shift_Amt(Mux_Shift_Amt),
        .Adress_RG_Load(Adress_RG_Load),
        .EPC_Load(EPC_Load),
        .MDR_Load(MDR_Load),
        .IR_Load(IR_Load),
        .High_Load(High_Load),
        .Low_Load(Low_Load),
        .A_Load(A_Load),
        .B_Load(B_Load),
        .ALUOut_Load(ALUOut_Load),
        .Store_Size(Store_Size),
        .Load_Size(Load_Size),
        .Memory_WR(Memory_WR),
        .Reg_WR(Reg_WR),
        .PCWrite(PCWrite),
        .IsBEQ(IsBEQ),
        .IsBNE(IsBNE),
        .Shift(Shift),
        .MultInit(MultInit),
        .DivInit(DivInit)
    );
    
    // Geração do clock
    always #5 clk = ~clk;
    
    initial begin
        // Configuração inicial
        clk = 0;
        Reset_In = 1;
        Overflow = 0;
        Zero_Div = 0;
        MultStop = 0;
        DivStop = 0;
        DivZero = 0;
        
        // Configuração do arquivo VCD
        $dumpfile("test.vcd");
        $dumpvars(0, test_control_signals);
        
        $display("=== TESTE DE SINAIS DE CONTROLE ===");
        
        // Reset
        #10 Reset_In = 0;
        
        // Teste ADD (R-type)
        $display("\nTeste ADD:");
        Opcode = 6'b000000; // R-type
        IMMEDIATE = 16'h1020; // Funct = 100000 (ADD)
        #50;
        $display("Estado: %b, ULA: %b, Reg_WR: %b", uut.states, ULA, Reg_WR);
        
        // Reset
        Reset_In = 1;
        #10 Reset_In = 0;
        
        // Teste AND (R-type)
        $display("\nTeste AND:");
        Opcode = 6'b000000; // R-type
        IMMEDIATE = 16'h1024; // Funct = 100100 (AND)
        #50;
        $display("Estado: %b, ULA: %b, Reg_WR: %b", uut.states, ULA, Reg_WR);
        
        // Reset
        Reset_In = 1;
        #10 Reset_In = 0;
        
        // Teste SUB (R-type)
        $display("\nTeste SUB:");
        Opcode = 6'b000000; // R-type
        IMMEDIATE = 16'h1022; // Funct = 100010 (SUB)
        #50;
        $display("Estado: %b, ULA: %b, Reg_WR: %b", uut.states, ULA, Reg_WR);
        
        // Reset
        Reset_In = 1;
        #10 Reset_In = 0;
        
        // Teste XCHG (R-type)
        $display("\nTeste XCHG:");
        Opcode = 6'b000000; // R-type
        IMMEDIATE = 16'h1005; // Funct = 000101 (XCHG)
        #50;
        $display("Estado: %b, ULA: %b, Reg_WR: %b", uut.states, ULA, Reg_WR);
        
        // Reset
        Reset_In = 1;
        #10 Reset_In = 0;
        
        // Teste ADDI (I-type)
        $display("\nTeste ADDI:");
        Opcode = 6'b001000; // ADDI
        IMMEDIATE = 16'h0005;
        #50;
        $display("Estado: %b, ULA: %b, Reg_WR: %b, Mux_Extend: %b", uut.states, ULA, Reg_WR, Mux_Extend);
        
        // Reset
        Reset_In = 1;
        #10 Reset_In = 0;
        
        // Teste BEQ (I-type)
        $display("\nTeste BEQ:");
        Opcode = 6'b000100; // BEQ
        IMMEDIATE = 16'h0002;
        Zero_Div = 1; // Simula condição verdadeira
        #50;
        $display("Estado: %b, IsBEQ: %b, PCWrite: %b, Mux_PC: %b", uut.states, IsBEQ, PCWrite, Mux_PC);
        
        // Reset
        Reset_In = 1;
        Zero_Div = 0;
        #10 Reset_In = 0;
        
        // Teste BNE (I-type)
        $display("\nTeste BNE:");
        Opcode = 6'b000101; // BNE
        IMMEDIATE = 16'h0002;
        #50;
        $display("Estado: %b, IsBNE: %b, PCWrite: %b, Mux_PC: %b", uut.states, IsBNE, PCWrite, Mux_PC);
        
        // Reset
        Reset_In = 1;
        #10 Reset_In = 0;
        
        // Teste LW (I-type)
        $display("\nTeste LW:");
        Opcode = 6'b100011; // LW
        IMMEDIATE = 16'h0004;
        #50;
        $display("Estado: %b, Memory_WR: %b, MDR_Load: %b, Reg_WR: %b", uut.states, Memory_WR, MDR_Load, Reg_WR);
        
        // Reset
        Reset_In = 1;
        #10 Reset_In = 0;
        
        // Teste SW (I-type)
        $display("\nTeste SW:");
        Opcode = 6'b101011; // SW
        IMMEDIATE = 16'h0004;
        #50;
        $display("Estado: %b, Memory_WR: %b, Mux_Address: %b", uut.states, Memory_WR, Mux_Address);
        
        // Reset
        Reset_In = 1;
        #10 Reset_In = 0;
        
        // Teste J (J-type)
        $display("\nTeste J:");
        Opcode = 6'b000010; // J
        IMMEDIATE = 16'h1000;
        #50;
        $display("Estado: %b, PCWrite: %b, Mux_PC: %b", uut.states, PCWrite, Mux_PC);
        
        // Reset
        Reset_In = 1;
        #10 Reset_In = 0;
        
        // Teste JAL (J-type)
        $display("\nTeste JAL:");
        Opcode = 6'b000011; // JAL
        IMMEDIATE = 16'h2000;
        #50;
        $display("Estado: %b, PCWrite: %b, Mux_PC: %b, Mux_WR_Registers: %b, Reg_WR: %b", uut.states, PCWrite, Mux_PC, Mux_WR_Registers, Reg_WR);
        
        // Reset
        Reset_In = 1;
        #10 Reset_In = 0;
        
        // Teste SLLM (I-type)
        $display("\nTeste SLLM:");
        Opcode = 6'b001001; // SLLM
        IMMEDIATE = 16'h0004;
        #50;
        $display("Estado: %b, Memory_WR: %b, Mux_Address: %b, Store_Size: %b", uut.states, Memory_WR, Mux_Address, Store_Size);
        
        $display("\n=== TESTE CONCLUÍDO ===");
        $finish;
    end
    
endmodule