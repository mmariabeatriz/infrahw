module cpu (

    input wire clk,
    input wire reset

);

    //Control Wires  (mux)
    wire            Mux_WD_Memory_selector;
    wire            Mux_High_selector;
    wire            Mux_Low_selector;
    wire            Mux_Extend_selector;
    wire            Mux_B_selector;
    wire            Mux_Shift_Src_selector;
    wire [1:0]      Mux_Shift_Amt_selector;
    wire[1:0]       Mux_A_selector;
    wire[1:0]       Mux_ALU1_selector; 
    wire[1:0]       Mux_ALU2_selector;  
    wire[1:0]       Mux_PC_selector;
    wire[1:0]       Mux_WR_Registers_selector;
    wire[2:0]       Mux_Address_selector;  
    wire[2:0]       Mux_WD_Registers_selector;

    //Control Wires  (Registers)
    wire            PC_Load;
    wire            Address_RG_Load;
    wire            EPC_Load;
    wire            MDR_Load;
    wire            IR_Load;
    wire            High_Load;
    wire            Low_Load;
    wire            A_Load;
    wire            B_Load;
    wire            ALUOut_Load;

    //Control Useless
    wire            NEGATIVE;
    wire            EQUAL;



    //Control Wires  (Outros)
    wire            Store_Size_selector;
    wire [1:0]      Load_Size_selector;
    wire [2:0]      ALU_selector;
    wire [2:0]      Shift_selector;
    wire            Memory_WR;
    wire            Reg_WR;
    wire            PCWrite;
    wire            IsBEQ;              
    wire            IsBNE;
    
    wire            GT;
    wire            ZERO;
    wire            OVERFLOW;
    wire            LESS;

    //Control Wires (Mult)
    wire            MultInit;
    wire            MultStop;

    //Control Wires (Div)
    wire            DivInit;
    wire            DivStop;
    wire            DivZero;

    //Data Wires (Registradores)
    wire [31:0]     PC_Out; 
    wire [31:0]     Address_RG_Out;
    wire [31:0]     EPC_Out;
    wire [31:0]     MDR_Out;
    wire [31:0]     IR_Out;
    wire [31:0]     High_Out;
    wire [31:0]     Low_Out;
    wire [31:0]     A_Out;
    wire [31:0]     B_Out;
    wire [31:0]     ALUOut_Out;

    //Data Wires (Mux)
    wire [31:0]     Mux_PC_Out;
    wire [31:0]     Mux_Address_Out;  
    wire [31:0]     Mux_WD_Memory_Out;
    wire [4:0]      Mux_WR_Registers_Out;
    wire [31:0]     Mux_WD_Registers_Out;
    wire [31:0]     Mux_High_Out;
    wire [31:0]     Mux_Low_Out;
    wire [15:0]     Mux_Extend_Out;
    wire [31:0]     Mux_A_Out;
    wire [31:0]     Mux_B_Out;
    wire [31:0]     Mux_Shift_Src_Out;
    wire [4:0]      Mux_Shift_Amt_Out;
    wire [31:0]     Mux_ALU1_Out; 
    wire [31:0]     Mux_ALU2_Out;  

    //Data Wires (Outros)
    wire [31:0]     Store_Size_Out;
    wire [31:0]     Memory_Out;
    wire [5:0]      OPCODE;
    wire [4:0]      RS;
    wire [4:0]      RT;
    wire [15:0]     IMMEDIATE;
    wire [15:0]     Load_Size_OutDown;
    wire [31:0]     Load_Size_OutUp;
    wire [31:0]     Concat_28to32_Out;
    wire [25:0]     Concat_26to28_Out;
    wire [31:0]     RegDesloc_Out;
    wire [31:0]     Sign_Extend1_32_Out;
    wire [31:0]     Read_Data1_Out;
    wire [31:0]     Read_Data2_Out;
    wire [31:0]     Mult_High_Out;
    wire [31:0]     Div_High_Out;
    wire [31:0]     Mult_Low_Out;
    wire [31:0]     Div_Low_Out;
    wire [31:0]     Sign_Extend16_32_Out;
    wire [31:0]     Sl_32_32_Out;
    wire [27:0]     Sl_26_28_Out;
    wire [31:0]     ALU_Result;
    wire [31:0]     Sl_16_32_Out;

    Registrador PC_(
        clk,
        reset,
        PC_Load,
        Mux_PC_Out,
        PC_Out
    );

    mux_IorD mux_address_(
        Mux_Address_selector,
        PC_Out,
        ALUOut_Out,
        Mux_Address_Out
    );

    mux_writeDataMem mux_wd_MEM_(
        Mux_WD_Memory_selector,
        B_Out,
        Store_Size_Out,
        Mux_WD_Memory_Out
    );

    ss store_size_(
        Store_Size_selector,
        MDR_Out,
        B_Out,
        Store_Size_Out
    );

    Registrador address_RG_(
        clk,
        reset,
        Address_RG_Load,
        PC_Out,
        Address_RG_Out
    );

    Memoria MEM_(
        Mux_Address_Out,
        clk,
        Memory_WR,
        Mux_WD_Memory_Out,
        Memory_Out
    );

    Registrador mdr_(
        clk,
        reset,
        MDR_Load,
        Memory_Out,
        MDR_Out
    );

    Registrador EPC_(
        clk,
        reset,
        EPC_Load,
        Address_RG_Out,
        EPC_Out
    );

    Instr_Reg IR_(
        clk,
        reset,
        IR_Load,
        Memory_Out,
        OPCODE,
        RS,
        RT,
        IMMEDIATE
    );


    ls load_size_(

        Load_Size_selector,
        MDR_Out,
        Load_Size_OutDown,
        Load_Size_OutUp
    );

    concat_26to28 concat_26to28_(

       RT,
       RS,
       IMMEDIATE,
       Concat_26to28_Out

    );

    mux_regDst mux_wr_reg_(
       
       Mux_WR_Registers_selector,
       RT,
       IMMEDIATE,
       Mux_WR_Registers_Out

    );

    mux_memToReg mux_wd_reg_(

       Mux_WD_Registers_selector,
       Load_Size_OutUp,
       ALUOut_Out,
       Low_Out,
       High_Out,
       RegDesloc_Out,
       Sign_Extend1_32_Out,
       Sl_16_32_Out,
       Mux_WD_Registers_Out
       

    );


    Registrador high_(

        clk,
        reset,
        High_Load,
        Mux_High_Out,
        High_Out

    );

    Registrador low_(

        clk,
        reset,
        Low_Load,
        Mux_Low_Out,
        Low_Out

    );

    Banco_reg registers_(

        clk,
        reset,
        Reg_WR,
        RS,
        RT,
        Mux_WR_Registers_Out,
        Mux_WD_Registers_Out,
        Read_Data1_Out,
        Read_Data2_Out

    );

    mux_High mux_high_(
        
        Mux_High_selector,
        Mult_High_Out,
        Div_High_Out,
        Mux_High_Out

    );

    mux_Low mux_low_(

        Mux_Low_selector,
        Mult_Low_Out,
        Div_Low_Out,
        Mux_Low_Out

    );

    mux_Extend mux_extend_(

        Mux_Extend_selector,
        Load_Size_OutDown,
        IMMEDIATE,
        Mux_Extend_Out

    );

    sl_16_32 sl_16_32_(

        IMMEDIATE,
        Sl_16_32_Out

    );
    controller controller_(

       GT,
       ZERO,
       PCWrite,
       IsBEQ,
       IsBNE,

       PC_Load

    );

    mux_A mux_a_(

       Mux_A_selector,
       Memory_Out,
       Read_Data1_Out,
       Read_Data2_Out,
       Mux_A_Out

    );

    mux_B mux_b_(

        Mux_B_selector,
        Read_Data2_Out,
        Memory_Out,
        Mux_B_Out

    );

    RegDesloc reg_desloc_(
  
        clk,
        reset,
        Shift_selector,
        Mux_Shift_Amt_Out,
        Mux_Shift_Src_Out,
        RegDesloc_Out

    );

    mult mult_(   
        A_Out,
        B_Out,
        clk,
        reset,
        MultInit,
        MultStop,
        Mult_High_Out,
        Mult_Low_Out
    );
        

    div div_(
        A_Out,
        B_Out,
        clk,
        DivInit,
        DivStop,
        reset,
        DivZero,
        Div_High_Out,
        Div_Low_Out

    );

    se sign_extend_(

        Mux_Extend_Out,
        Sign_Extend16_32_Out

    );

    Registrador A_(

        clk,
        reset,
        A_Load,
        Mux_A_Out,
        A_Out

    );

     Registrador B_(

        clk,
        reset,
        B_Load,
        Mux_B_Out,
        B_Out

    );

    mux_Shift_Src mux_shift_src_(

        Mux_Shift_Src_selector,
        A_Out,
        B_Out,
        Mux_Shift_Src_Out

    );

    mux_Shift_Amt mux_shift_amt_(
        Mux_Shift_Amt_selector,
        B_Out,
        IMMEDIATE,
        MDR_Out,
        Mux_Shift_Amt_Out
    );

    sl_32_32 sl_32_32_(

        Sign_Extend16_32_Out,
        Sl_32_32_Out

    );

    sl_26_28 sl_26_28_(

        Concat_26to28_Out,
        Sl_26_28_Out

    );

    mux_ALUSrcA Mux_ALU1_(

        Mux_ALU1_selector,
        PC_Out,
        A_Out,
        Mux_ALU1_Out

    );

    mux_ALUSrcB Mux_ALU2_(

        .seletor(Mux_ALU2_selector),
        .Reg_B_info(B_Out),
        .sigEx(Sign_Extend16_32_Out),
        .sigLef(Sl_32_32_Out),
        .mux_alusrcb_out(Mux_ALU2_Out)

    );

    concat_28to32 concat_28to32_(

        .PC_out(PC_Out),
        .SL_out(Sl_26_28_Out),
        .conc_out(Concat_28to32_Out)

    );

    ula32 ALU_(

        Mux_ALU1_Out,
        Mux_ALU2_Out,
        ALU_selector,
        ALU_Result,
        OVERFLOW,
        NEGATIVE,
        ZERO,
        EQUAL,
        GT,
        LESS

    );


    se_1_32 sign_extend1_32_(

        LESS,
        Sign_Extend1_32_Out

    );

    Registrador ALUOut_(

        clk,
        reset,
        ALUOut_Load,
        ALU_Result,
        ALUOut_Out

    );

    mux_PC_Src mux_PC_(

        Mux_PC_selector,
        EPC_Out,
        ALU_Result,
        ALUOut_Out,
        Concat_28to32_Out,
        Mux_PC_Out

    );

    control_unit unid_control_(

        clk,
        reset,
        OPCODE,
        IMMEDIATE,
        OVERFLOW,
        Zero_Div,
        MultStop,
        DivStop,
        DivZero,

        Mux_WD_Memory_selector,
        Mux_High_selector,
        Mux_Low_selector,
        Mux_Extend_selector,
        Mux_B_selector,
        Mux_Shift_Src_selector,
        Mux_Shift_Amt_selector,

        Mux_A_selector,              
        Mux_ALU1_selector,            
        Mux_ALU2_selector,            
        Mux_PC_selector,              
        Mux_WR_Registers_selector,    

        Mux_Address_selector,         
        Mux_WD_Registers_selector,    

        Address_RG_Load,
        EPC_Load,
        MDR_Load,
        IR_Load,
        High_Load,
        Low_Load,
        A_Load,
        B_Load,
        ALUOut_Load,

        Store_Size_selector,
        Load_Size_selector,
        Memory_WR,
        Reg_WR,

        PCWrite,
        IsBEQ,              
        IsBNE,

        ALU_selector,
        Shift_selector,
        
        MultInit,

        DivInit
    );

endmodule
