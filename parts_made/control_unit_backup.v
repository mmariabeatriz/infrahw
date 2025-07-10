//mexi p cacete nesse código, deixei oq tava funcionando salvo pq vai que

module control_unit_backup (

//INPUT PORTS
input wire          clk,
input wire          Reset_In,
input wire [5:0]    Opcode,
input wire [15:0]   IMMEDIATE,
input wire          Overflow,
input wire          Zero_Div,
input wire          MultStop,
input wire          DivStop,
input wire          DivZero,

//OUTPUT PORTS
//Muxs (até 2 entradas)
output reg          Mux_WD_Memory,
output reg          Mux_High,
output reg          Mux_Low,
output reg          Mux_Extend,
output reg          Mux_B,
output reg          Mux_Shift_Src,
output reg [1:0]    Mux_Shift_Amt,

//Muxs (até 4 entradas)
output reg [1:0]    Mux_A,               //3 entradas
output reg [1:0]    Mux_ALU1,            //3 entradas
output reg [1:0]    Mux_ALU2,            //4 entradas
output reg [1:0]    Mux_PC,              //4 entradas
output reg [1:0]    Mux_WR_Registers,    //4 entradas

//Muxs (até 8 entradas)
output reg [2:0]    Mux_Address,         //5 entradas
output reg [2:0]    Mux_WD_Registers,    //7 entradas

//Registers
output reg          Adress_RG_Load,
output reg          EPC_Load,
output reg          MDR_Load,
output reg          IR_Load,
output reg          High_Load,
output reg          Low_Load,
output reg          A_Load,
output reg          B_Load,
output reg          ALUOut_Load,

//Write and Read Controllers
output reg          Store_Size,
output reg [1:0]    Load_Size,
output reg          Memory_WR,
output reg          Reg_WR,

//Controlador Controllers
output reg          PCWrite,
output reg          IsBEQ,              //Antigo PCWriteCond
output reg          IsBNE,

//Special Controllers
output reg [2:0]    ULA,
output reg [2:0]    Shift,

//Mult Controller
output reg          MultInit,
//Div Controller
output reg          DivInit

);

//VARIABLES

reg [5:0] states; //(6 bits para representar o estado atual)
reg [4:0] counter; //(5 bit para representar o clk atual em um dado estado)
wire [5:0] Funct;
assign Funct = IMMEDIATE[5:0];

//STATE PARAMETERS

parameter State_Reset       =       6'b000000;
parameter State_Fetch       =       6'b000001;
parameter State_Decode      =       6'b000010;
parameter State_Overflow    =       6'b000011;
parameter State_Opcode404   =       6'b000100;
parameter State_Div0        =       6'b000101;

parameter State_Add         =       6'b000110;
parameter State_And         =       6'b000111;
parameter State_Div         =       6'b001000;
parameter State_Mult        =       6'b001001;
parameter State_Jr          =       6'b001010;
parameter State_Mfhi        =       6'b001011;
parameter State_Mflo        =       6'b001100;
parameter State_Sll         =       6'b001101;
parameter State_Slt         =       6'b001110;
parameter State_Sra         =       6'b001111;
parameter State_Sub         =       6'b010001;
parameter State_Xchg        =       6'b010010;

parameter State_Addi        =       6'b010011;
parameter State_Beq         =       6'b010100;
parameter State_Bne         =       6'b010101;
parameter State_Sllm        =       6'b010110;
parameter State_Lb          =       6'b010111;
parameter State_Lui         =       6'b011000;
parameter State_Lw          =       6'b011001;
parameter State_Sb          =       6'b011010;
parameter State_Sw          =       6'b011011;

parameter State_J           =       6'b011110;
parameter State_Jal         =       6'b011111;

//Opcodes (istruction type)
parameter Op_Type_r         =       6'b000000;
parameter Op_Addi           =       6'b001000;
parameter Op_Beq            =       6'b000100;
parameter Op_Bne            =       6'b000101;
parameter Op_Sllm           =       6'b001001;
parameter Op_Lb             =       6'b100000;
parameter Op_Lui            =       6'b001111;
parameter Op_Lw             =       6'b100011;
parameter Op_Sb             =       6'b101000;
parameter Op_Sw             =       6'b101011;
parameter Op_J              =       6'b000010;
parameter Op_Jal            =       6'b000011;

//Funct of type R
parameter Funct_Add         =       6'b100000;
parameter Funct_And         =       6'b100100;
parameter Funct_Div         =       6'b011010;
parameter Funct_Mult        =       6'b011000;
parameter Funct_Jr          =       6'b001000;
parameter Funct_Mfhi        =       6'b010000;
parameter Funct_Mflo        =       6'b010010; 
parameter Funct_Sll         =       6'b000000;
parameter Funct_Slt         =       6'b101010;
parameter Funct_Sra         =       6'b000011;
parameter Funct_Sub         =       6'b100010;
parameter Funct_Xchg        =       6'b000101;

initial begin
    //Mux_WR_Registers    =   2'b01;
    //Mux_WD_Registers    =   3'b000;
    //Reg_WR              =   1'b1;
    states                =   State_Reset;
    //counter             =   5'b00000;
end

always @(posedge clk) begin
    //RESET
    if ((Reset_In == 1'b1)) begin
        Mux_WR_Registers    =   2'b01;       ////
        Mux_WD_Registers    =   3'b000;      ////
        Adress_RG_Load      =   1'b0;
        EPC_Load            =   1'b0;
        MDR_Load            =   1'b0;
        IR_Load             =   1'b0;
        High_Load           =   1'b0;
        Low_Load            =   1'b0;
        A_Load              =   1'b0;
        B_Load              =   1'b0;
        ALUOut_Load         =   1'b0;
        Memory_WR           =   1'b0;
        Reg_WR              =   1'b1;        ////
        PCWrite             =   1'b0;
        IsBEQ               =   1'b0;
        IsBNE               =   1'b0;
        
        //Special Controllers
        ULA                 =   3'b000;
        Shift               =   3'b000;
        
        //Mux Controllers
        Mux_WD_Memory       =   1'b0;
        Mux_High            =   1'b0;
        Mux_Low             =   1'b0;
        Mux_Extend          =   1'b0;
        Mux_B               =   1'b0;
        Mux_Shift_Src       =   1'b0;
        Mux_Shift_Amt       =   2'b00;
        Mux_A               =   2'b00;
        Mux_ALU1            =   2'b00;
        Mux_ALU2            =   2'b00;
        Mux_PC              =   2'b00;
        Mux_Address         =   3'b000;
        
        //Size Controllers
        Store_Size          =   1'b0;
        Load_Size           =   2'b00;
        
        //Mult and Div Controllers
        MultInit            =   1'b0;
        DivInit             =   1'b0;

        //next state
        states = State_Fetch;
        counter = 5'b00000;
    end else begin
        case (states) //descobrir qual estado se esta para tornar o output adequado
            //FETCH
            State_Fetch: begin
                if (counter == 5'b00000 || counter == 5'b00001 || counter == 5'b00010) begin
                    Mux_Address         =   3'b000; ////
                    Mux_ALU1            =   2'b00; ////
                    Mux_ALU2            =   2'b01; ////
                    ULA                 =   3'b001; ////
                    Adress_RG_Load      =   1'b1; ////
                    EPC_Load            =   1'b0;
                    MDR_Load            =   1'b0;
                    IR_Load             =   1'b0;
                    High_Load           =   1'b0;
                    Low_Load            =   1'b0;
                    A_Load              =   1'b0;
                    B_Load              =   1'b0;
                    ALUOut_Load         =   1'b1; ////
                    Memory_WR           =   1'b0;
                    Reg_WR              =   1'b0;
                    PCWrite             =   1'b0;
                    IsBEQ               =   1'b0;
                    IsBNE               =   1'b0;
                    
                    MultInit            =   1'b0;
                    DivInit             =   1'b0;

                    //next state
                    states = State_Fetch;
                    counter = counter + 5'b00001;
                end else if (counter == 5'b00011) begin
                    Mux_PC              =   2'b10; ////
                    Adress_RG_Load      =   1'b0;
                    EPC_Load            =   1'b0;
                    MDR_Load            =   1'b0;
                    IR_Load             =   1'b1; ////
                    High_Load           =   1'b0;
                    Low_Load            =   1'b0;
                    A_Load              =   1'b0;
                    B_Load              =   1'b0;
                    ALUOut_Load         =   1'b0;
                    Memory_WR           =   1'b0;
                    Reg_WR              =   1'b0;
                    PCWrite             =   1'b1; ////
                    IsBEQ               =   1'b0;
                    IsBNE               =   1'b0;
                    
                    MultInit            =   1'b0;
                    DivInit             =   1'b0;

                    //next state
                    states = State_Decode;
                    counter = 5'b00000;
                    end
            end 

            //DECODE
            State_Decode: begin
                if (counter == 5'b00000) begin
                    Mux_Extend          =   1'b1; ////
                    Mux_ALU1            =   2'b00; ////
                    Mux_ALU2            =   2'b11; ////
                    ULA                 =   3'b001; ////
                    Adress_RG_Load      =   1'b0;
                    EPC_Load            =   1'b0;
                    MDR_Load            =   1'b0;
                    IR_Load             =   1'b0;
                    High_Load           =   1'b0;
                    Low_Load            =   1'b0;
                    A_Load              =   1'b0;
                    B_Load              =   1'b0;
                    ALUOut_Load         =   1'b1; ////
                    Memory_WR           =   1'b0;
                    Reg_WR              =   1'b0;
                    PCWrite             =   1'b0;
                    IsBEQ               =   1'b0;
                    IsBNE               =   1'b0;
                    
                    MultInit            =   1'b0;
                    DivInit             =   1'b0;

                    //next state
                    states = State_Decode;
                    counter = counter + 5'b00001;
                end else if (counter == 5'b00001) begin
                    Mux_A               =   2'b01; ////
                    Mux_B               =   1'b0; ////
                    Adress_RG_Load      =   1'b0;
                    EPC_Load            =   1'b0;
                    MDR_Load            =   1'b0;
                    IR_Load             =   1'b0;
                    High_Load           =   1'b0;
                    Low_Load            =   1'b0;
                    A_Load              =   1'b1; ////
                    B_Load              =   1'b1; ////
                    ALUOut_Load         =   1'b0;
                    Memory_WR           =   1'b0;
                    Reg_WR              =   1'b0;
                    PCWrite             =   1'b0;
                    IsBEQ               =   1'b0;
                    IsBNE               =   1'b0;
                    
                    MultInit            =   1'b0;
                    DivInit             =   1'b0;

                    //next state
                    counter = 5'b00000;
                    case (Opcode) //Analisando Opcode da operacao atual para definir o proximo estado
                        //OP Tipo R
                        Op_Type_r: begin
                            case (Funct) //Analisando campo Funct do tipo R
                                //Funct ADD
                                Funct_Add: begin
                                    states = State_Add;
                                end

                                //Funct AND
                                Funct_And: begin
                                    states = State_And;
                                end

                                //Funct DIV
                                Funct_Div: begin
                                    states = State_Div;
                                end

                                //Funct MULT
                                Funct_Mult: begin
                                    states = State_Mult;
                                end

                                //Funct JR
                                Funct_Jr: begin
                                    states = State_Jr;
                                end

                                //Funct MFHI
                                Funct_Mfhi: begin
                                    states = State_Mfhi;
                                end

                                //Funct MFLO
                                Funct_Mflo: begin
                                    states = State_Mflo;
                                end

                                //Funct SLL
                                Funct_Sll: begin
                                    states = State_Sll;
                                end

                                //Funct SLT
                                Funct_Slt: begin
                                    states = State_Slt;
                                end

                                //Funct SRA
                                Funct_Sra: begin
                                    states = State_Sra;
                                end



                                //Funct SUB
                                Funct_Sub: begin
                                    states = State_Sub;
                                end

                                //Funct XCHG
                                Funct_Xchg: begin
                                    states = State_Xchg;
                                end

                                default: //erro de opcode
                                    states = State_Opcode404;
                            endcase
                        end

                        //Op ADDI
                        Op_Addi: begin
                            states = State_Addi;
                        end

                        //Op BEQ
                        Op_Beq: begin
                            states = State_Beq;
                        end

                        //Op BNE
                        Op_Bne: begin
                            states = State_Bne;
                        end

                        //Op SLLM
                        Op_Sllm: begin
                            states = State_Sllm;
                        end

                        //Op LB
                        Op_Lb: begin
                            states = State_Lb;
                        end

                        //Op LUI
                        Op_Lui: begin
                            states = State_Lui;
                        end

                        //Op LW
                        Op_Lw: begin
                            states = State_Lw;
                        end

                        //Op SB
                        Op_Sb: begin
                            states = State_Sb;
                        end

                        //Op SW
                        Op_Sw: begin
                            states = State_Sw;
                        end

                        //Op J
                        Op_J: begin
                            states = State_J;
                        end

                        //Op JAL
                        Op_Jal: begin
                            states = State_Jal;
                        end

                        default:
                            states = State_Opcode404;
                    endcase
                end
            end

            //OVERFLOW
            State_Overflow: begin
                if (counter == 5'b00000 || counter == 5'b00001 || counter == 5'b00010) begin
                    Mux_Address         =   3'b011; ////
                    Adress_RG_Load      =   1'b0;
                    EPC_Load            =   1'b0;
                    MDR_Load            =   1'b0;
                    IR_Load             =   1'b0;
                    High_Load           =   1'b0;
                    Low_Load            =   1'b0;
                    A_Load              =   1'b0;
                    B_Load              =   1'b0;
                    ALUOut_Load         =   1'b0;
                    Memory_WR           =   1'b0;
                    Reg_WR              =   1'b0;
                    PCWrite             =   1'b0;
                    IsBEQ               =   1'b0;
                    IsBNE               =   1'b0;
                    
                    MultInit            =   1'b0;
                    DivInit             =   1'b0;

                    //next state
                    states = State_Overflow;
                    counter = counter + 5'b00001;
                end else if (counter == 5'b00011) begin
                    Adress_RG_Load      =   1'b0;
                    EPC_Load            =   1'b1; ////
                    MDR_Load            =   1'b1; ////
                    IR_Load             =   1'b0;
                    High_Load           =   1'b0;
                    Low_Load            =   1'b0;
                    A_Load              =   1'b0;
                    B_Load              =   1'b0;
                    ALUOut_Load         =   1'b0;
                    Memory_WR           =   1'b0;
                    Reg_WR              =   1'b0;
                    PCWrite             =   1'b0;
                    IsBEQ               =   1'b0;
                    IsBNE               =   1'b0;
                    
                    MultInit            =   1'b0;
                    DivInit             =   1'b0;

                    //next state
                    states = State_Overflow;
                    counter = counter + 5'b00001;
                end else if (counter == 5'b00100) begin
                    Mux_Extend          =   1'b0; ////
                    Mux_ALU1            =   2'b10; ////
                    Mux_ALU2            =   2'b10; ////
                    Mux_PC              =   2'b01; ////
                    ULA                 =   3'b001; ////
                    Adress_RG_Load      =   1'b0;
                    EPC_Load            =   1'b0;
                    MDR_Load            =   1'b0;
                    IR_Load             =   1'b0;
                    High_Load           =   1'b0;
                    Low_Load            =   1'b0;
                    A_Load              =   1'b0;
                    B_Load              =   1'b0;
                    ALUOut_Load         =   1'b0;
                    Memory_WR           =   1'b0;
                    Reg_WR              =   1'b0;
                    PCWrite             =   1'b1; ////
                    IsBEQ               =   1'b0;
                    IsBNE               =   1'b0;
                    
                    MultInit            =   1'b0;
                    DivInit             =   1'b0;

                    //next state
                    states = State_Fetch;
                    counter = 5'b00000;
                end
            end

            //OPCODE INEXISTENTE
            State_Opcode404: begin
                if (counter == 5'b00000 || counter == 5'b00001 || counter == 5'b00010) begin
                    Mux_Address         =   3'b010; ////
                    Adress_RG_Load      =   1'b0;
                    EPC_Load            =   1'b0;
                    MDR_Load            =   1'b0;
                    IR_Load             =   1'b0;
                    High_Load           =   1'b0;
                    Low_Load            =   1'b0;
                    A_Load              =   1'b0;
                    B_Load              =   1'b0;
                    ALUOut_Load         =   1'b0;
                    Memory_WR           =   1'b0;
                    Reg_WR              =   1'b0;
                    PCWrite             =   1'b0;
                    IsBEQ               =   1'b0;
                    IsBNE               =   1'b0;
                    
                    MultInit            =   1'b0;
                    DivInit             =   1'b0;

                    //next state
                    states = State_Opcode404;
                    counter = counter + 5'b00001;
                end else if (counter == 5'b00011) begin
                    Adress_RG_Load      =   1'b0;
                    EPC_Load            =   1'b1; ////
                    MDR_Load            =   1'b1; ////
                    IR_Load             =   1'b0;
                    High_Load           =   1'b0;
                    Low_Load            =   1'b0;
                    A_Load              =   1'b0;
                    B_Load              =   1'b0;
                    ALUOut_Load         =   1'b0;
                    Memory_WR           =   1'b0;
                    Reg_WR              =   1'b0;
                    PCWrite             =   1'b0;
                    IsBEQ               =   1'b0;
                    IsBNE               =   1'b0;
                    
                    MultInit            =   1'b0;
                    DivInit             =   1'b0;

                    //next state
                    states = State_Opcode404;
                    counter = counter + 5'b00001;
                end else if (counter == 5'b00100) begin
                    Mux_Extend          =   1'b0; ////
                    Mux_ALU1            =   2'b10; ////
                    Mux_ALU2            =   2'b10; ////
                    Mux_PC              =   2'b01; ////
                    ULA                 =   3'b001; ////
                    Adress_RG_Load      =   1'b0;
                    EPC_Load            =   1'b0;
                    MDR_Load            =   1'b0;
                    IR_Load             =   1'b0;
                    High_Load           =   1'b0;
                    Low_Load            =   1'b0;
                    A_Load              =   1'b0;
                    B_Load              =   1'b0;
                    ALUOut_Load         =   1'b0;
                    Memory_WR           =   1'b0;
                    Reg_WR              =   1'b0;
                    PCWrite             =   1'b1; ////
                    IsBEQ               =   1'b0;
                    IsBNE               =   1'b0;
                    
                    MultInit            =   1'b0;
                    DivInit             =   1'b0;

                    //next state
                    states = State_Fetch;
                    counter = 5'b00000;
                end
            end

            //DIVISAO POR 0
            State_Div0: begin
                if (counter == 5'b00000 || counter == 5'b00001 || counter == 5'b00010) begin
                    Mux_Address         =   3'b100; ////
                    Adress_RG_Load      =   1'b0;
                    EPC_Load            =   1'b0;
                    MDR_Load            =   1'b0;
                    IR_Load             =   1'b0;
                    High_Load           =   1'b0;
                    Low_Load            =   1'b0;
                    A_Load              =   1'b0;
                    B_Load              =   1'b0;
                    ALUOut_Load         =   1'b0;
                    Memory_WR           =   1'b0;
                    Reg_WR              =   1'b0;
                    PCWrite             =   1'b0;
                    IsBEQ               =   1'b0;
                    IsBNE               =   1'b0;
                    
                    MultInit            =   1'b0;
                    DivInit             =   1'b0;

                    //next state
                    states = State_Div0;
                    counter = counter + 5'b00001;
                end else if (counter == 5'b00011) begin
                    Adress_RG_Load      =   1'b0;
                    EPC_Load            =   1'b1; ////
                    MDR_Load            =   1'b1; ////
                    IR_Load             =   1'b0;
                    High_Load           =   1'b0;
                    Low_Load            =   1'b0;
                    A_Load              =   1'b0;
                    B_Load              =   1'b0;
                    ALUOut_Load         =   1'b0;
                    Memory_WR           =   1'b0;
                    Reg_WR              =   1'b0;
                    PCWrite             =   1'b0;
                    IsBEQ               =   1'b0;
                    IsBNE               =   1'b0;
                    
                    MultInit            =   1'b0;
                    DivInit             =   1'b0;

                    //next state
                    states = State_Div0;
                    counter = counter + 5'b00001;
                end else if (counter == 5'b00100) begin
                    Mux_Extend          =   1'b0; ////
                    Mux_ALU1            =   2'b10; ////
                    Mux_ALU2            =   2'b10; ////
                    Mux_PC              =   2'b01; ////
                    ULA                 =   3'b001; ////
                    Adress_RG_Load      =   1'b0;
                    EPC_Load            =   1'b0;
                    MDR_Load            =   1'b0;
                    IR_Load             =   1'b0;
                    High_Load           =   1'b0;
                    Low_Load            =   1'b0;
                    A_Load              =   1'b0;
                    B_Load              =   1'b0;
                    ALUOut_Load         =   1'b0;
                    Memory_WR           =   1'b0;
                    Reg_WR              =   1'b0;
                    PCWrite             =   1'b1; ////
                    IsBEQ               =   1'b0;
                    IsBNE               =   1'b0;
                    
                    MultInit            =   1'b0;
                    DivInit             =   1'b0;

                    //next state
                    states = State_Fetch;
                    counter = 5'b00000;
                end
            end
            
            //ADD 
            State_Add: begin
                if (counter == 5'b00000) begin
                    Mux_ALU1            =   2'b01; ////
                    Mux_ALU2            =   2'b00; ////
                    ULA                 =   3'b001; ////
                    Adress_RG_Load      =   1'b0;
                    EPC_Load            =   1'b0;
                    MDR_Load            =   1'b0;
                    IR_Load             =   1'b0;
                    High_Load           =   1'b0;
                    Low_Load            =   1'b0;
                    A_Load              =   1'b0;
                    B_Load              =   1'b0;
                    ALUOut_Load         =   1'b1; ////
                    Memory_WR           =   1'b0;
                    Reg_WR              =   1'b0;
                    PCWrite             =   1'b0;
                    IsBEQ               =   1'b0;
                    IsBNE               =   1'b0;
                    
                    MultInit            =   1'b0;
                    DivInit             =   1'b0;
                    
                    //next state
                    states = State_Add;
                    counter = counter + 5'b00001;
                end else if (Overflow && counter == 5'b00001) begin
                    //Erro de overflow so deve ser analisado apos o calculo
                    states = State_Overflow;
                    counter = 5'b00000;
                end else if (counter == 5'b00001) begin
                    Mux_WR_Registers    =   2'b11; ////
                    Mux_WD_Registers    =   3'b010; ////
                    Adress_RG_Load      =   1'b0;
                    EPC_Load            =   1'b0;
                    MDR_Load            =   1'b0;
                    IR_Load             =   1'b0;
                    High_Load           =   1'b0;
                    Low_Load            =   1'b0;
                    A_Load              =   1'b0;
                    B_Load              =   1'b0;
                    ALUOut_Load         =   1'b0;
                    Memory_WR           =   1'b0;
                    Reg_WR              =   1'b1; ////
                    PCWrite             =   1'b0;
                    IsBEQ               =   1'b0;
                    IsBNE               =   1'b0;
                    
                    MultInit            =   1'b0;
                    DivInit             =   1'b0;

                    //next state
                    states = State_Fetch;
                    counter = 5'b00000;
                end
            end

            //AND
            State_And: begin
                if (counter == 5'b00000) begin
                    Mux_ALU1            =   2'b01; ////
                    Mux_ALU2            =   2'b00; ////
                    ULA                 =   3'b011; ////
                    Adress_RG_Load      =   1'b0;
                    EPC_Load            =   1'b0;
                    MDR_Load            =   1'b0;
                    IR_Load             =   1'b0;
                    High_Load           =   1'b0;
                    Low_Load            =   1'b0;
                    A_Load              =   1'b0;
                    B_Load              =   1'b0;
                    ALUOut_Load         =   1'b1; ////
                    Memory_WR           =   1'b0;
                    Reg_WR              =   1'b0;
                    PCWrite             =   1'b0;
                    IsBEQ               =   1'b0;
                    IsBNE               =   1'b0;
                    
                    MultInit            =   1'b0;
                    DivInit             =   1'b0;

                    //next state
                    states = State_And;
                    counter = counter + 5'b00001;
                end else if (counter == 5'b00001) begin
                    Mux_WR_Registers    =   2'b11; ////
                    Mux_WD_Registers    =   3'b010; ////
                    Adress_RG_Load      =   1'b0;
                    EPC_Load            =   1'b0;
                    MDR_Load            =   1'b0;
                    IR_Load             =   1'b0;
                    High_Load           =   1'b0;
                    Low_Load            =   1'b0;
                    A_Load              =   1'b0;
                    B_Load              =   1'b0;
                    ALUOut_Load         =   1'b0;
                    Memory_WR           =   1'b0;
                    Reg_WR              =   1'b1; ////
                    PCWrite             =   1'b0;
                    IsBEQ               =   1'b0;
                    IsBNE               =   1'b0;
                    
                    MultInit            =   1'b0;
                    DivInit             =   1'b0;

                    //next state
                    states = State_Fetch;
                    counter = 5'b00000;
                end
            end

            //DIV
            State_Div: begin
                Mux_ALU1            =   2'b00;
                Mux_ALU2            =   2'b00;
                ULA                 =   3'b000;
                Mux_PC              =   2'b00;
                Adress_RG_Load      =   1'b0;
                EPC_Load            =   1'b0;
                MDR_Load            =   1'b0;
                IR_Load             =   1'b0;
                High_Load           =   1'b0;
                Low_Load            =   1'b0;
                A_Load              =   1'b0;
                B_Load              =   1'b0;
                ALUOut_Load         =   1'b0; 
                Memory_WR           =   1'b0;
                Reg_WR              =   1'b0;
                PCWrite             =   1'b0;
                IsBEQ               =   1'b0;
                IsBNE               =   1'b0;
                
                MultInit            =   1'b0;
                DivInit             =   1'b1;
                //inserir if divzero
                if(!DivZero)begin
                    DivInit             =   1'b0;
                    states = State_Div0;
                end
                else if(!DivStop)begin
                    states = State_Div;
                end
                else begin
                    Mux_High            =   1'b1;
                    Mux_Low             =   1'b1;
                    High_Load           =   1'b1;
                    Low_Load            =   1'b1;
                    DivInit             =   1'b0;
                    states              =   State_Fetch;
                end
            end

            //MULT
            State_Mult: begin
                Mux_ALU1            =   2'b00;
                Mux_ALU2            =   2'b00;
                ULA                 =   3'b000;
                Mux_PC              =   2'b00;
                Adress_RG_Load      =   1'b0;
                EPC_Load            =   1'b0;
                MDR_Load            =   1'b0;
                IR_Load             =   1'b0;
                High_Load           =   1'b0;
                Low_Load            =   1'b0;
                A_Load              =   1'b0;
                B_Load              =   1'b0;
                ALUOut_Load         =   1'b0; 
                Memory_WR           =   1'b0;
                Reg_WR              =   1'b0;
                PCWrite             =   1'b0;
                IsBEQ               =   1'b0;
                IsBNE               =   1'b0;
                
                MultInit            =   1'b1;
                DivInit             =   1'b0;

                states = State_Mult;

                if (!MultStop)begin
                    states = State_Mult;
                end
                else begin
                    Mux_High            =   1'b0;
                    Mux_Low             =   1'b0;
                    High_Load           =   1'b1;
                    Low_Load            =   1'b1;
                    MultInit            =   1'b0;
                    states              =   State_Fetch;
                end
            end
            
            //JR
            State_Jr: begin
                if (counter == 5'b00000) begin
                    Mux_ALU1            =   2'b01; ////
                    Mux_ALU2            =   2'b00; ////
                    ULA                 =   3'b000; ////
                    Mux_PC              =   2'b01; ////
                    Adress_RG_Load      =   1'b0;
                    EPC_Load            =   1'b0;
                    MDR_Load            =   1'b0;
                    IR_Load             =   1'b0;
                    High_Load           =   1'b0;
                    Low_Load            =   1'b0;
                    A_Load              =   1'b0;
                    B_Load              =   1'b0;
                    ALUOut_Load         =   1'b0; 
                    Memory_WR           =   1'b0;
                    Reg_WR              =   1'b0;
                    PCWrite             =   1'b1; ////
                    IsBEQ               =   1'b0;
                    IsBNE               =   1'b0;
                    
                    MultInit            =   1'b0;
                    DivInit             =   1'b0;

                    //next state
                    states = State_Fetch;
                    counter = 5'b00000;
                end 
            end

            //MFHI
            State_Mfhi: begin
                if (counter == 5'b00000) begin
                    Mux_WR_Registers    =   2'b11; ////
                    Mux_WD_Registers    =   3'b100; ////
                    Adress_RG_Load      =   1'b0;
                    EPC_Load            =   1'b0;
                    MDR_Load            =   1'b0;
                    IR_Load             =   1'b0;
                    High_Load           =   1'b0;
                    Low_Load            =   1'b0;
                    A_Load              =   1'b0;
                    B_Load              =   1'b0;
                    ALUOut_Load         =   1'b0;
                    Memory_WR           =   1'b0;
                    Reg_WR              =   1'b1; ////
                    PCWrite             =   1'b0;
                    IsBEQ               =   1'b0;
                    IsBNE               =   1'b0;
                    
                    MultInit            =   1'b0;
                    DivInit             =   1'b0;

                    //next state
                    states = State_Fetch;
                    counter = 5'b00000;
                end
            end

            //MFLO
            State_Mflo: begin
                if (counter == 5'b00000) begin
                    Mux_WR_Registers    =   2'b11; ////
                    Mux_WD_Registers    =   3'b011; ////
                    Adress_RG_Load      =   1'b0;
                    EPC_Load            =   1'b0;
                    MDR_Load            =   1'b0;
                    IR_Load             =   1'b0;
                    High_Load           =   1'b0;
                    Low_Load            =   1'b0;
                    A_Load              =   1'b0;
                    B_Load              =   1'b0;
                    ALUOut_Load         =   1'b0;
                    Memory_WR           =   1'b0;
                    Reg_WR              =   1'b1; ////
                    PCWrite             =   1'b0;
                    IsBEQ               =   1'b0;
                    IsBNE               =   1'b0;
                    
                    MultInit            =   1'b0;
                    DivInit             =   1'b0;

                    //next state
                    states = State_Fetch;
                    counter = 5'b00000;
                end
            end

            //SLL
            State_Sll: begin
                if (counter == 5'b00000) begin
                    Mux_Shift_Src       =   1'b1; ////
                    Mux_Shift_Amt       =   2'b01; ////
                    Shift               =   3'b001; ////
                    Adress_RG_Load      =   1'b0;
                    EPC_Load            =   1'b0;
                    MDR_Load            =   1'b0;
                    IR_Load             =   1'b0;
                    High_Load           =   1'b0;
                    Low_Load            =   1'b0;
                    A_Load              =   1'b0;
                    B_Load              =   1'b0;
                    ALUOut_Load         =   1'b0;
                    Memory_WR           =   1'b0;
                    Reg_WR              =   1'b0;
                    PCWrite             =   1'b0;
                    IsBEQ               =   1'b0;
                    IsBNE               =   1'b0;

                    MultInit            =   1'b0;
                    DivInit             =   1'b0;

                    //next state
                    states = State_Sll;
                    counter = counter + 5'b00001;
                end else if (counter == 5'b00001) begin
                    Mux_WR_Registers    =   2'b11; ////
                    Mux_WD_Registers    =   3'b101; ////
                    Shift               =   3'b010; ////
                    Adress_RG_Load      =   1'b0;
                    EPC_Load            =   1'b0;
                    MDR_Load            =   1'b0;
                    IR_Load             =   1'b0;
                    High_Load           =   1'b0;
                    Low_Load            =   1'b0;
                    A_Load              =   1'b0;
                    B_Load              =   1'b0;
                    ALUOut_Load         =   1'b0;
                    Memory_WR           =   1'b0;
                    Reg_WR              =   1'b0; ////
                    PCWrite             =   1'b0;
                    IsBEQ               =   1'b0;
                    IsBNE               =   1'b0;
                    
                    MultInit            =   1'b0;
                    DivInit             =   1'b0;

                    //next state
                    states = State_Sll;
                    counter = counter + 5'b00001;
                end else if (counter == 5'b00010) begin
                    Shift               =   3'b000; ////
                    Adress_RG_Load      =   1'b0;
                    EPC_Load            =   1'b0;
                    MDR_Load            =   1'b0;
                    IR_Load             =   1'b0;
                    High_Load           =   1'b0;
                    Low_Load            =   1'b0;
                    A_Load              =   1'b0;
                    B_Load              =   1'b0;
                    ALUOut_Load         =   1'b0;
                    Memory_WR           =   1'b0;
                    Reg_WR              =   1'b1;
                    PCWrite             =   1'b0;
                    IsBEQ               =   1'b0;
                    IsBNE               =   1'b0;
                    
                    MultInit            =   1'b0;
                    DivInit             =   1'b0;

                    //next state
                    states = State_Fetch;
                    counter = 5'b00000;
                end
            end

            //SLLV


            //SLT
            State_Slt: begin
                if (counter == 5'b00000) begin
                    Mux_ALU1            =   2'b01; ////
                    Mux_ALU2            =   2'b00; ////
                    ULA                 =   3'b111; ////
                    Adress_RG_Load      =   1'b0;
                    EPC_Load            =   1'b0;
                    MDR_Load            =   1'b0;
                    IR_Load             =   1'b0;
                    High_Load           =   1'b0;
                    Low_Load            =   1'b0;
                    A_Load              =   1'b0;
                    B_Load              =   1'b0;
                    ALUOut_Load         =   1'b0;
                    Memory_WR           =   1'b0;
                    Reg_WR              =   1'b0;
                    PCWrite             =   1'b0;
                    IsBEQ               =   1'b0;
                    IsBNE               =   1'b0;
                    
                    MultInit            =   1'b0;
                    DivInit             =   1'b0;

                    //next state
                    states = State_Slt;
                    counter = counter + 5'b00001;
                end else if (counter == 5'b00001) begin
                    Mux_WR_Registers    =   2'b11; ////
                    Mux_WD_Registers    =   3'b110; ////
                    Adress_RG_Load      =   1'b0;
                    EPC_Load            =   1'b0;
                    MDR_Load            =   1'b0;
                    IR_Load             =   1'b0;
                    High_Load           =   1'b0;
                    Low_Load            =   1'b0;
                    A_Load              =   1'b0;
                    B_Load              =   1'b0;
                    ALUOut_Load         =   1'b0;
                    Memory_WR           =   1'b0;
                    Reg_WR              =   1'b1; ////
                    PCWrite             =   1'b0;
                    IsBEQ               =   1'b0;
                    IsBNE               =   1'b0;
                    
                    MultInit            =   1'b0;
                    DivInit             =   1'b0;

                    //next state
                    states = State_Fetch;
                    counter = 5'b00000;
                end
            end

            //SRA
            State_Sra: begin
                if (counter == 5'b00000) begin
                    Mux_Shift_Src       =   1'b1; ////
                    Mux_Shift_Amt       =   2'b01; ////
                    Shift               =   3'b001; ////
                    Adress_RG_Load      =   1'b0;
                    EPC_Load            =   1'b0;
                    MDR_Load            =   1'b0;
                    IR_Load             =   1'b0;
                    High_Load           =   1'b0;
                    Low_Load            =   1'b0;
                    A_Load              =   1'b0;
                    B_Load              =   1'b0;
                    ALUOut_Load         =   1'b0;
                    Memory_WR           =   1'b0;
                    Reg_WR              =   1'b0;
                    PCWrite             =   1'b0;
                    IsBEQ               =   1'b0;
                    IsBNE               =   1'b0;
                    
                    MultInit            =   1'b0;
                    DivInit             =   1'b0;

                    //next state
                    states = State_Sra;
                    counter = counter + 5'b00001;
                end else if (counter == 5'b00001) begin
                    Mux_WR_Registers    =   2'b11; ////
                    Mux_WD_Registers    =   3'b101; ////
                    Shift               =   3'b100; ////
                    Adress_RG_Load      =   1'b0;
                    EPC_Load            =   1'b0;
                    MDR_Load            =   1'b0;
                    IR_Load             =   1'b0;
                    High_Load           =   1'b0;
                    Low_Load            =   1'b0;
                    A_Load              =   1'b0;
                    B_Load              =   1'b0;
                    ALUOut_Load         =   1'b0;
                    Memory_WR           =   1'b0;
                    Reg_WR              =   1'b0;
                    PCWrite             =   1'b0;
                    IsBEQ               =   1'b0;
                    IsBNE               =   1'b0;
                    
                    MultInit            =   1'b0;
                    DivInit             =   1'b0;

                    //next state
                    states = State_Sra;
                    counter = counter + 5'b00001;
                end else if (counter == 5'b00010) begin
                    Shift               =   3'b000; ////
                    Adress_RG_Load      =   1'b0;
                    EPC_Load            =   1'b0;
                    MDR_Load            =   1'b0;
                    IR_Load             =   1'b0;
                    High_Load           =   1'b0;
                    Low_Load            =   1'b0;
                    A_Load              =   1'b0;
                    B_Load              =   1'b0;
                    ALUOut_Load         =   1'b0;
                    Memory_WR           =   1'b0;
                    Reg_WR              =   1'b1; ////
                    PCWrite             =   1'b0;
                    IsBEQ               =   1'b0;
                    IsBNE               =   1'b0;
                    
                    MultInit            =   1'b0;
                    DivInit             =   1'b0;

                    //next state
                    states = State_Fetch;
                    counter = 5'b00000;
                end
            end
            
            //SRAV




            //SUB
            State_Sub: begin
                if (counter == 5'b00000) begin
                    Mux_ALU1            =   2'b01; ////
                    Mux_ALU2            =   2'b00; ////
                    ULA                 =   3'b010; ////
                    Adress_RG_Load      =   1'b0;
                    EPC_Load            =   1'b0;
                    MDR_Load            =   1'b0;
                    IR_Load             =   1'b0;
                    High_Load           =   1'b0;
                    Low_Load            =   1'b0;
                    A_Load              =   1'b0;
                    B_Load              =   1'b0;
                    ALUOut_Load         =   1'b1; ////
                    Memory_WR           =   1'b0;
                    Reg_WR              =   1'b0;
                    PCWrite             =   1'b0;
                    IsBEQ               =   1'b0;
                    IsBNE               =   1'b0;
                    
                    MultInit            =   1'b0;
                    DivInit             =   1'b0;

                    //next state
                    states = State_Sub;
                    counter = counter + 5'b00001;
                end else if (Overflow && counter == 5'b00001) begin
                    //Erro de overflow so deve ser analisado apos o calculo
                    states = State_Overflow;
                    counter = 5'b00000;
                end else if (counter == 5'b00001) begin
                    Mux_WR_Registers    =   2'b11; ////
                    Mux_WD_Registers    =   3'b010; ////
                    Adress_RG_Load      =   1'b0;
                    EPC_Load            =   1'b0;
                    MDR_Load            =   1'b0;
                    IR_Load             =   1'b0;
                    High_Load           =   1'b0;
                    Low_Load            =   1'b0;
                    A_Load              =   1'b0;
                    B_Load              =   1'b0;
                    ALUOut_Load         =   1'b0;
                    Memory_WR           =   1'b0;
                    Reg_WR              =   1'b1; ////
                    PCWrite             =   1'b0;
                    IsBEQ               =   1'b0;
                    IsBNE               =   1'b0;
                    
                    MultInit            =   1'b0;
                    DivInit             =   1'b0;

                    //next state
                    states = State_Fetch;
                    counter = 5'b00000;
                end
            end

            //XCHG - Exchange registers rs and rt
            State_Xchg: begin
                if (counter == 5'b00000) begin
                    // First step: Load rs value into A register
                    Mux_A               =   2'b01; ////
                    Adress_RG_Load      =   1'b0;
                    EPC_Load            =   1'b0;
                    MDR_Load            =   1'b0;
                    IR_Load             =   1'b0;
                    High_Load           =   1'b0;
                    Low_Load            =   1'b0;
                    A_Load              =   1'b1; ////
                    B_Load              =   1'b0;
                    ALUOut_Load         =   1'b0;
                    Memory_WR           =   1'b0;
                    Reg_WR              =   1'b0;
                    PCWrite             =   1'b0;
                    IsBEQ               =   1'b0;
                    IsBNE               =   1'b0;
                    
                    MultInit            =   1'b0;
                    DivInit             =   1'b0;

                    //next state
                    states = State_Xchg;
                    counter = counter + 5'b00001;
                end else if (counter == 5'b00001) begin
                    // Second step: Load rt value into B register
                    Mux_B               =   1'b0; ////
                    Adress_RG_Load      =   1'b0;
                    EPC_Load            =   1'b0;
                    MDR_Load            =   1'b0;
                    IR_Load             =   1'b0;
                    High_Load           =   1'b0;
                    Low_Load            =   1'b0;
                    A_Load              =   1'b0;
                    B_Load              =   1'b1; ////
                    ALUOut_Load         =   1'b0;
                    Memory_WR           =   1'b0;
                    Reg_WR              =   1'b0;
                    PCWrite             =   1'b0;
                    IsBEQ               =   1'b0;
                    IsBNE               =   1'b0;
                    
                    MultInit            =   1'b0;
                    DivInit             =   1'b0;

                    //next state
                    states = State_Xchg;
                    counter = counter + 5'b00001;
                end else if (counter == 5'b00010) begin
                    // Third step: Write A (original rs) to rt register
                    Mux_WR_Registers    =   2'b01; ////
                    Mux_WD_Registers    =   3'b100; ////
                    Adress_RG_Load      =   1'b0;
                    EPC_Load            =   1'b0;
                    MDR_Load            =   1'b0;
                    IR_Load             =   1'b0;
                    High_Load           =   1'b0;
                    Low_Load            =   1'b0;
                    A_Load              =   1'b0;
                    B_Load              =   1'b0;
                    ALUOut_Load         =   1'b0;
                    Memory_WR           =   1'b0;
                    Reg_WR              =   1'b1; ////
                    PCWrite             =   1'b0;
                    IsBEQ               =   1'b0;
                    IsBNE               =   1'b0;
                    
                    MultInit            =   1'b0;
                    DivInit             =   1'b0;

                    //next state
                    states = State_Xchg;
                    counter = counter + 5'b00001;
                end else if (counter == 5'b00011) begin
                    // Fourth step: Write B (original rt) to rs register
                    Mux_WR_Registers    =   2'b10; ////
                    Mux_WD_Registers    =   3'b101; ////
                    Adress_RG_Load      =   1'b0;
                    EPC_Load            =   1'b0;
                    MDR_Load            =   1'b0;
                    IR_Load             =   1'b0;
                    High_Load           =   1'b0;
                    Low_Load            =   1'b0;
                    A_Load              =   1'b0;
                    B_Load              =   1'b0;
                    ALUOut_Load         =   1'b0;
                    Memory_WR           =   1'b0;
                    Reg_WR              =   1'b1; ////
                    PCWrite             =   1'b0;
                    IsBEQ               =   1'b0;
                    IsBNE               =   1'b0;
                    
                    MultInit            =   1'b0;
                    DivInit             =   1'b0;

                    //next state
                    states = State_Fetch;
                    counter = 5'b00000;
                end
            end



            //ADDI
            State_Addi: begin
                if (counter == 5'b00000) begin
                    Mux_ALU1            =   2'b01; ////
                    Mux_ALU2            =   2'b10; ////
                    Mux_Extend          =   1'b1; ////
                    ULA                 =   3'b001; ////
                    Adress_RG_Load      =   1'b0;
                    EPC_Load            =   1'b0;
                    MDR_Load            =   1'b0;
                    IR_Load             =   1'b0;
                    High_Load           =   1'b0;
                    Low_Load            =   1'b0;
                    A_Load              =   1'b0;
                    B_Load              =   1'b0;
                    ALUOut_Load         =   1'b1; ////
                    Memory_WR           =   1'b0;
                    Reg_WR              =   1'b0;
                    PCWrite             =   1'b0;
                    IsBEQ               =   1'b0;
                    IsBNE               =   1'b0;
                    
                    MultInit            =   1'b0;
                    DivInit             =   1'b0;

                    //next state
                    states = State_Addi;
                    counter = counter + 5'b00001;
                end else if (Overflow && counter == 5'b00001) begin
                    //Erro de overflow so deve ser analisado apos o calculo
                    states = State_Overflow;
                    counter = 5'b00000;
                end else if (counter == 5'b00001) begin
                    Mux_WR_Registers    =   2'b00; ////
                    Mux_WD_Registers    =   3'b010; ////
                    Adress_RG_Load      =   1'b0;
                    EPC_Load            =   1'b0;
                    MDR_Load            =   1'b0;
                    IR_Load             =   1'b0;
                    High_Load           =   1'b0;
                    Low_Load            =   1'b0;
                    A_Load              =   1'b0;
                    B_Load              =   1'b0;
                    ALUOut_Load         =   1'b0;
                    Memory_WR           =   1'b0;
                    Reg_WR              =   1'b1; ////
                    PCWrite             =   1'b0;
                    IsBEQ               =   1'b0;
                    IsBNE               =   1'b0;
                    
                    MultInit            =   1'b0;
                    DivInit             =   1'b0;
                    //next state
                    states = State_Fetch;
                    counter = 5'b00000;
                end
            end



            //BEQ
            State_Beq: begin
                if (counter == 5'b00000) begin
                    Mux_ALU1            =   2'b01; ////
                    Mux_ALU2            =   2'b00; ////
                    Mux_PC              =   2'b10; ////
                    ULA                 =   3'b010; ////
                    Adress_RG_Load      =   1'b0;
                    EPC_Load            =   1'b0;
                    MDR_Load            =   1'b0;
                    IR_Load             =   1'b0;
                    High_Load           =   1'b0;
                    Low_Load            =   1'b0;
                    A_Load              =   1'b0;
                    B_Load              =   1'b0;
                    ALUOut_Load         =   1'b0;
                    Memory_WR           =   1'b0;
                    Reg_WR              =   1'b0;
                    PCWrite             =   1'b0;
                    IsBEQ               =   1'b1; ////
                    IsBNE               =   1'b0;
                    
                    MultInit            =   1'b0;
                    DivInit             =   1'b0;

                    //next state
                    states = State_Fetch;
                    counter = 5'b00000;
                end
            end

            //BNE
            State_Bne: begin
                if (counter == 5'b00000) begin
                    Mux_ALU1            =   2'b01; ////
                    Mux_ALU2            =   2'b00; ////
                    Mux_PC              =   2'b10; ////
                    ULA                 =   3'b010; ////
                    Adress_RG_Load      =   1'b0;
                    EPC_Load            =   1'b0;
                    MDR_Load            =   1'b0;
                    IR_Load             =   1'b0;
                    High_Load           =   1'b0;
                    Low_Load            =   1'b0;
                    A_Load              =   1'b0;
                    B_Load              =   1'b0;
                    ALUOut_Load         =   1'b0;
                    Memory_WR           =   1'b0;
                    Reg_WR              =   1'b0;
                    PCWrite             =   1'b0;
                    IsBEQ               =   1'b0;
                    IsBNE               =   1'b1; ////
                    
                    MultInit            =   1'b0;
                    DivInit             =   1'b0;

                    //next state
                    states = State_Fetch;
                    counter = 5'b00000;
                end
            end

            //BLE


            //LB
            State_Lb: begin
                if (counter == 5'b00000) begin
                    Mux_ALU1            =   2'b01; ////
                    Mux_ALU2            =   2'b10; ////
                    Mux_Extend          =   1'b1; ////
                    ULA                 =   3'b001; ////
                    Adress_RG_Load      =   1'b0;
                    EPC_Load            =   1'b0;
                    MDR_Load            =   1'b0;
                    IR_Load             =   1'b0;
                    High_Load           =   1'b0;
                    Low_Load            =   1'b0;
                    A_Load              =   1'b0;
                    B_Load              =   1'b0;
                    ALUOut_Load         =   1'b1; ////
                    Memory_WR           =   1'b0;
                    Reg_WR              =   1'b0;
                    PCWrite             =   1'b0;
                    IsBEQ               =   1'b0;
                    IsBNE               =   1'b0;
                    
                    MultInit            =   1'b0;
                    DivInit             =   1'b0;

                    //next state
                    states = State_Lb;
                    counter = counter + 5'b00001;
                end else if (Overflow && counter == 5'b00001) begin
                    //Erro de overflow so deve ser analisado apos o calculo
                    states = State_Overflow;
                    counter = 5'b00000;
                end else if (counter == 5'b00001 || counter == 5'b00010 || counter == 5'b00011) begin
                    Mux_Address         =   3'b001; ////
                    Adress_RG_Load      =   1'b0;
                    EPC_Load            =   1'b0;
                    MDR_Load            =   1'b0;
                    IR_Load             =   1'b0;
                    High_Load           =   1'b0;
                    Low_Load            =   1'b0;
                    A_Load              =   1'b0;
                    B_Load              =   1'b0;
                    ALUOut_Load         =   1'b0;
                    Memory_WR           =   1'b0;
                    Reg_WR              =   1'b0;
                    PCWrite             =   1'b0;
                    IsBEQ               =   1'b0;
                    IsBNE               =   1'b0;
                    
                    MultInit            =   1'b0;
                    DivInit             =   1'b0;

                    //next state
                    states = State_Lb;
                    counter = counter + 5'b00001;
                end else if (counter == 5'b00100) begin
                    Adress_RG_Load      =   1'b0;
                    EPC_Load            =   1'b0;
                    MDR_Load            =   1'b1; ////
                    IR_Load             =   1'b0;
                    High_Load           =   1'b0;
                    Low_Load            =   1'b0;
                    A_Load              =   1'b0;
                    B_Load              =   1'b0;
                    ALUOut_Load         =   1'b0;
                    Memory_WR           =   1'b0;
                    Reg_WR              =   1'b0;
                    PCWrite             =   1'b0;
                    IsBEQ               =   1'b0;
                    IsBNE               =   1'b0;
                    
                    MultInit            =   1'b0;
                    DivInit             =   1'b0;

                    //next state
                    states = State_Lb;
                    counter = counter + 5'b00001;
                end else if (counter == 5'b00101) begin
                    Load_Size           =   2'b00; ////
                    Mux_WR_Registers    =   2'b00; ////
                    Mux_WD_Registers    =   3'b001; ////
                    Adress_RG_Load      =   1'b0;
                    EPC_Load            =   1'b0;
                    MDR_Load            =   1'b0;
                    IR_Load             =   1'b0;
                    High_Load           =   1'b0;
                    Low_Load            =   1'b0;
                    A_Load              =   1'b0;
                    B_Load              =   1'b0;
                    ALUOut_Load         =   1'b0;
                    Memory_WR           =   1'b0;
                    Reg_WR              =   1'b1; ////
                    PCWrite             =   1'b0;
                    IsBEQ               =   1'b0;
                    IsBNE               =   1'b0;
                    
                    MultInit            =   1'b0;
                    DivInit             =   1'b0;

                    //next state
                    states = State_Fetch;
                    counter = 5'b00000;
                end
            end



            //LUI
            State_Lui: begin
                if (counter == 5'b00000) begin
                    Mux_WR_Registers    =   2'b00; ////
                    Mux_WD_Registers    =   3'b111; ////
                    Adress_RG_Load      =   1'b0;
                    EPC_Load            =   1'b0;
                    MDR_Load            =   1'b0;
                    IR_Load             =   1'b0;
                    High_Load           =   1'b0;
                    Low_Load            =   1'b0;
                    A_Load              =   1'b0;
                    B_Load              =   1'b0;
                    ALUOut_Load         =   1'b0;
                    Memory_WR           =   1'b0;
                    Reg_WR              =   1'b1; ////
                    PCWrite             =   1'b0;
                    IsBEQ               =   1'b0;
                    IsBNE               =   1'b0;
                    
                    MultInit            =   1'b0;
                    DivInit             =   1'b0;

                    //next state
                    states = State_Fetch;
                    counter = 5'b00000;
                end
            end

            //LW
            State_Lw: begin
                if (counter == 5'b00000) begin
                    Mux_ALU1            =   2'b01; ////
                    Mux_ALU2            =   2'b10; ////
                    Mux_Extend          =   1'b1; ////
                    ULA                 =   3'b001; ////
                    Adress_RG_Load      =   1'b0;
                    EPC_Load            =   1'b0;
                    MDR_Load            =   1'b0;
                    IR_Load             =   1'b0;
                    High_Load           =   1'b0;
                    Low_Load            =   1'b0;
                    A_Load              =   1'b0;
                    B_Load              =   1'b0;
                    ALUOut_Load         =   1'b1; ////
                    Memory_WR           =   1'b0;
                    Reg_WR              =   1'b0;
                    PCWrite             =   1'b0;
                    IsBEQ               =   1'b0;
                    IsBNE               =   1'b0;
                    
                    MultInit            =   1'b0;
                    DivInit             =   1'b0;

                    //next state
                    states = State_Lw;
                    counter = counter + 5'b00001;
                end else if (Overflow && counter == 5'b00001) begin
                    //Erro de overflow so deve ser analisado apos o calculo
                    states = State_Overflow;
                    counter = 5'b00000;
                end else if (counter == 5'b00001 || counter == 5'b00010 || counter == 5'b00011) begin
                    Mux_Address         =   3'b001; ////
                    Adress_RG_Load      =   1'b0;
                    EPC_Load            =   1'b0;
                    MDR_Load            =   1'b0;
                    IR_Load             =   1'b0;
                    High_Load           =   1'b0;
                    Low_Load            =   1'b0;
                    A_Load              =   1'b0;
                    B_Load              =   1'b0;
                    ALUOut_Load         =   1'b0;
                    Memory_WR           =   1'b0;
                    Reg_WR              =   1'b0;
                    PCWrite             =   1'b0;
                    IsBEQ               =   1'b0;
                    IsBNE               =   1'b0;
                    
                    MultInit            =   1'b0;
                    DivInit             =   1'b0;

                    //next state
                    states = State_Lw;
                    counter = counter + 5'b00001;
                end else if (counter == 5'b00100) begin
                    Adress_RG_Load      =   1'b0;
                    EPC_Load            =   1'b0;
                    MDR_Load            =   1'b1; ////
                    IR_Load             =   1'b0;
                    High_Load           =   1'b0;
                    Low_Load            =   1'b0;
                    A_Load              =   1'b0;
                    B_Load              =   1'b0;
                    ALUOut_Load         =   1'b0;
                    Memory_WR           =   1'b0;
                    Reg_WR              =   1'b0;
                    PCWrite             =   1'b0;
                    IsBEQ               =   1'b0;
                    IsBNE               =   1'b0;
                    
                    MultInit            =   1'b0;
                    DivInit             =   1'b0;

                    //next state
                    states = State_Lw;
                    counter = counter + 5'b00001;
                end else if (counter == 5'b00101) begin
                    Load_Size           =   2'b10; ////
                    Mux_WR_Registers    =   2'b00; ////
                    Mux_WD_Registers    =   3'b001; ////
                    Adress_RG_Load      =   1'b0;
                    EPC_Load            =   1'b0;
                    MDR_Load            =   1'b0;
                    IR_Load             =   1'b0;
                    High_Load           =   1'b0;
                    Low_Load            =   1'b0;
                    A_Load              =   1'b0;
                    B_Load              =   1'b0;
                    ALUOut_Load         =   1'b0;
                    Memory_WR           =   1'b0;
                    Reg_WR              =   1'b1; ////
                    PCWrite             =   1'b0;
                    IsBEQ               =   1'b0;
                    IsBNE               =   1'b0;
                    
                    MultInit            =   1'b0;
                    DivInit             =   1'b0;

                    //next state
                    states = State_Fetch;
                    counter = 5'b00000;
                end
            end

            //SB
            State_Sb: begin
                if (counter == 5'b00000) begin
                    Mux_ALU1            =   2'b01; ////
                    Mux_ALU2            =   2'b10; ////
                    Mux_Extend          =   1'b1; ////
                    ULA                 =   3'b001; ////
                    Adress_RG_Load      =   1'b0;
                    EPC_Load            =   1'b0;
                    MDR_Load            =   1'b0;
                    IR_Load             =   1'b0;
                    High_Load           =   1'b0;
                    Low_Load            =   1'b0;
                    A_Load              =   1'b0;
                    B_Load              =   1'b0;
                    ALUOut_Load         =   1'b1; ////
                    Memory_WR           =   1'b0;
                    Reg_WR              =   1'b0;
                    PCWrite             =   1'b0;
                    IsBEQ               =   1'b0;
                    IsBNE               =   1'b0;
                    
                    MultInit            =   1'b0;
                    DivInit             =   1'b0;

                    //next state
                    states = State_Sb;
                    counter = counter + 5'b00001;
                end else if (Overflow && counter == 5'b00001) begin
                    //Erro de overflow so deve ser analisado apos o calculo
                    states = State_Overflow;
                    counter = 5'b00000;
                end else if (counter == 5'b00001 || counter == 5'b00010 || counter == 5'b00011) begin
                    Mux_Address         =   3'b001; ////
                    Adress_RG_Load      =   1'b0;
                    EPC_Load            =   1'b0;
                    MDR_Load            =   1'b0;
                    IR_Load             =   1'b0;
                    High_Load           =   1'b0;
                    Low_Load            =   1'b0;
                    A_Load              =   1'b0;
                    B_Load              =   1'b0;
                    ALUOut_Load         =   1'b0;
                    Memory_WR           =   1'b0;
                    Reg_WR              =   1'b0;
                    PCWrite             =   1'b0;
                    IsBEQ               =   1'b0;
                    IsBNE               =   1'b0;
                    
                    MultInit            =   1'b0;
                    DivInit             =   1'b0;

                    //next state
                    states = State_Sb;
                    counter = counter + 5'b00001;
                end else if (counter == 5'b00100) begin
                    Adress_RG_Load      =   1'b0;
                    EPC_Load            =   1'b0;
                    MDR_Load            =   1'b1; ////
                    IR_Load             =   1'b0;
                    High_Load           =   1'b0;
                    Low_Load            =   1'b0;
                    A_Load              =   1'b0;
                    B_Load              =   1'b0;
                    ALUOut_Load         =   1'b0;
                    Memory_WR           =   1'b0;
                    Reg_WR              =   1'b0;
                    PCWrite             =   1'b0;
                    IsBEQ               =   1'b0;
                    IsBNE               =   1'b0;
                    
                    MultInit            =   1'b0;
                    DivInit             =   1'b0;

                    //next state
                    states = State_Sb;
                    counter = counter + 5'b00001;
                end else if (counter == 5'b00101) begin
                    Mux_Address         =   3'b001; ////
                    Mux_WD_Memory       =   1'b1; ////
                    Store_Size          =   1'b0; ////
                    Adress_RG_Load      =   1'b0;
                    EPC_Load            =   1'b0;
                    MDR_Load            =   1'b0;
                    IR_Load             =   1'b0;
                    High_Load           =   1'b0;
                    Low_Load            =   1'b0;
                    A_Load              =   1'b0;
                    B_Load              =   1'b0;
                    ALUOut_Load         =   1'b0;
                    Memory_WR           =   1'b1; ////
                    Reg_WR              =   1'b0;
                    PCWrite             =   1'b0;
                    IsBEQ               =   1'b0;
                    IsBNE               =   1'b0;
                    
                    MultInit            =   1'b0;
                    DivInit             =   1'b0;

                    //next state
                    states = State_Fetch;
                    counter = 5'b00000;
                end
            end





            //SW
            State_Sw: begin
                if (counter == 5'b00000) begin
                    Mux_ALU1            =   2'b01; ////
                    Mux_ALU2            =   2'b10; ////
                    Mux_Extend          =   1'b1; ////
                    ULA                 =   3'b001; ////
                    Adress_RG_Load      =   1'b0;
                    EPC_Load            =   1'b0;
                    MDR_Load            =   1'b0;
                    IR_Load             =   1'b0;
                    High_Load           =   1'b0;
                    Low_Load            =   1'b0;
                    A_Load              =   1'b0;
                    B_Load              =   1'b0;
                    ALUOut_Load         =   1'b1; ////
                    Memory_WR           =   1'b0;
                    Reg_WR              =   1'b0;
                    PCWrite             =   1'b0;
                    IsBEQ               =   1'b0;
                    IsBNE               =   1'b0;
                    
                    MultInit            =   1'b0;
                    DivInit             =   1'b0;

                    //next state
                    states = State_Sw;
                    counter = counter + 5'b00001;
                end else if (Overflow && counter == 5'b00001) begin
                    //Erro de overflow so deve ser analisado apos o calculo
                    states = State_Overflow;
                    counter = 5'b00000;
                end else if (counter == 5'b00001) begin
                    Mux_Address         =   3'b001; ////
                    Mux_WD_Memory       =   1'b0; ////                    
                    Adress_RG_Load      =   1'b0;
                    EPC_Load            =   1'b0;
                    MDR_Load            =   1'b0;
                    IR_Load             =   1'b0;
                    High_Load           =   1'b0;
                    Low_Load            =   1'b0;
                    A_Load              =   1'b0;
                    B_Load              =   1'b0;
                    ALUOut_Load         =   1'b0;
                    Memory_WR           =   1'b1; ////
                    Reg_WR              =   1'b0;
                    PCWrite             =   1'b0;
                    IsBEQ               =   1'b0;
                    IsBNE               =   1'b0;
                    
                    MultInit            =   1'b0;
                    DivInit             =   1'b0;

                    //next state
                    states = State_Fetch;
                    counter = 5'b00000;
                end
            end

            //SLLM
            State_Sllm: begin
                if (counter == 5'b00000) begin
                    Mux_ALU1            =   2'b01; ////
                    Mux_ALU2            =   2'b10; ////
                    Mux_Extend          =   1'b1; ////
                    ULA                 =   3'b001; ////
                    Adress_RG_Load      =   1'b0;
                    EPC_Load            =   1'b0;
                    MDR_Load            =   1'b0;
                    IR_Load             =   1'b0;
                    High_Load           =   1'b0;
                    Low_Load            =   1'b0;
                    A_Load              =   1'b0;
                    B_Load              =   1'b0;
                    ALUOut_Load         =   1'b1; ////
                    Memory_WR           =   1'b0;
                    Reg_WR              =   1'b0;
                    PCWrite             =   1'b0;
                    IsBEQ               =   1'b0;
                    IsBNE               =   1'b0;
                    
                    MultInit            =   1'b0;
                    DivInit             =   1'b0;

                    //next state
                    states = State_Sllm;
                    counter = counter + 5'b00001;
                end else if (Overflow && counter == 5'b00001) begin
                    //Erro de overflow so deve ser analisado apos o calculo
                    states = State_Overflow;
                    counter = 5'b00000;
                end else if (counter == 5'b00001 || counter == 5'b00010 || counter == 5'b00011) begin
                    Mux_Address         =   3'b001; ////
                    Adress_RG_Load      =   1'b0;
                    EPC_Load            =   1'b0;
                    MDR_Load            =   1'b0;
                    IR_Load             =   1'b0;
                    High_Load           =   1'b0;
                    Low_Load            =   1'b0;
                    A_Load              =   1'b0;
                    B_Load              =   1'b0;
                    ALUOut_Load         =   1'b0;
                    Memory_WR           =   1'b0;
                    Reg_WR              =   1'b0;
                    PCWrite             =   1'b0;
                    IsBEQ               =   1'b0;
                    IsBNE               =   1'b0;
                    
                    MultInit            =   1'b0;
                    DivInit             =   1'b0;

                    //next state
                    states = State_Sllm;
                    counter = counter + 5'b00001;
                end else if (counter == 5'b00100) begin
                    Adress_RG_Load      =   1'b0;
                    EPC_Load            =   1'b0;
                    MDR_Load            =   1'b1; ////
                    IR_Load             =   1'b0;
                    High_Load           =   1'b0;
                    Low_Load            =   1'b0;
                    A_Load              =   1'b0;
                    B_Load              =   1'b0;
                    ALUOut_Load         =   1'b0;
                    Memory_WR           =   1'b0;
                    Reg_WR              =   1'b0;
                    PCWrite             =   1'b0;
                    IsBEQ               =   1'b0;
                    IsBNE               =   1'b0;
                    
                    MultInit            =   1'b0;
                    DivInit             =   1'b0;

                    //next state
                    states = State_Sllm;
                    counter = counter + 5'b00001;
                end else if (counter == 5'b00101) begin
                    Mux_Address         =   3'b001; ////
                    Mux_WD_Memory       =   1'b1; ////
                    Store_Size          =   1'b0; ////
                    Adress_RG_Load      =   1'b0;
                    EPC_Load            =   1'b0;
                    MDR_Load            =   1'b0;
                    IR_Load             =   1'b0;
                    High_Load           =   1'b0;
                    Low_Load            =   1'b0;
                    A_Load              =   1'b0;
                    B_Load              =   1'b0;
                    ALUOut_Load         =   1'b0;
                    Memory_WR           =   1'b1; ////
                    Reg_WR              =   1'b0;
                    PCWrite             =   1'b0;
                    IsBEQ               =   1'b0;
                    IsBNE               =   1'b0;
                    
                    MultInit            =   1'b0;
                    DivInit             =   1'b0;

                    //next state
                    states = State_Fetch;
                    counter = 5'b00000;
                end
            end

            //J
            State_J: begin
                if (counter == 5'b00000) begin
                    Mux_PC              =   2'b11; ////
                    Adress_RG_Load      =   1'b0;
                    EPC_Load            =   1'b0;
                    MDR_Load            =   1'b0;
                    IR_Load             =   1'b0; 
                    High_Load           =   1'b0;
                    Low_Load            =   1'b0;
                    A_Load              =   1'b0;
                    B_Load              =   1'b0;
                    ALUOut_Load         =   1'b0;
                    Memory_WR           =   1'b0;
                    Reg_WR              =   1'b0;
                    PCWrite             =   1'b1; ////
                    IsBEQ               =   1'b0;
                    IsBNE               =   1'b0;
                    
                    MultInit            =   1'b0;
                    DivInit             =   1'b0;

                    //next state
                    states = State_Fetch;
                    counter = 5'b00000;
                end
            end
            
            //JAL
            State_Jal: begin
                if (counter == 5'b00000) begin
                    Mux_ALU1            =   2'b00; ////
                    Mux_ALU2            =   2'b00; ////
                    ULA                 =   3'b000;  ////
                    Adress_RG_Load      =   1'b0;
                    EPC_Load            =   1'b0;
                    MDR_Load            =   1'b0;
                    IR_Load             =   1'b0; 
                    High_Load           =   1'b0;
                    Low_Load            =   1'b0;
                    A_Load              =   1'b0;
                    B_Load              =   1'b0;
                    ALUOut_Load         =   1'b1;  ////
                    Memory_WR           =   1'b0;
                    Reg_WR              =   1'b0;
                    PCWrite             =   1'b0;
                    IsBEQ               =   1'b0;
                    IsBNE               =   1'b0;
                    
                    MultInit            =   1'b0;
                    DivInit             =   1'b0;

                    //next state
                    states = State_Jal;
                    counter = counter + 5'b00001;
                end else if (counter == 5'b00001) begin
                    Mux_PC              =   2'b11; ////
                    Mux_WD_Registers    =   3'b010; ////
                    Mux_WR_Registers    =   2'b10; ////
                    Adress_RG_Load      =   1'b0;
                    EPC_Load            =   1'b0;
                    MDR_Load            =   1'b0;
                    IR_Load             =   1'b0; 
                    High_Load           =   1'b0;
                    Low_Load            =   1'b0;
                    A_Load              =   1'b0;
                    B_Load              =   1'b0;
                    ALUOut_Load         =   1'b0;
                    Memory_WR           =   1'b0;
                    Reg_WR              =   1'b1; ////
                    PCWrite             =   1'b1; ////
                    IsBEQ               =   1'b0;
                    IsBNE               =   1'b0;
                    
                    MultInit            =   1'b0;
                    DivInit             =   1'b0;

                    //next state
                    states = State_Fetch;
                    counter = 5'b00000;
                end
            end
        endcase

    end
    
end

endmodule
