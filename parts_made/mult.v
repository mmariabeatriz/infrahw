// Unidade de Multiplicação (MULT) - Realiza multiplicação de números inteiros com sinal
// Implementa algoritmo de Booth para multiplicação eficiente
// Produz resultado de 64 bits: parte alta (HI) e parte baixa (LO)
module mult (
    input  wire [31:0] RegAOut,         // Recebe RS
    input  wire [31:0] RegBOut,         // Recebe RT
    input  wire        clk,
    input  wire        reset,
    input  wire        MultCtrl,        // Início da multiplicação
    
    output reg         MultDone,        // Fim do MULT
    output reg  [31:0] HI,              // Armazena os 32 bits mais significativos
    output reg  [31:0] LO               // Armazena os 32 bits menos significativos
);
    // Registradores internos conforme especificação
    reg        Initialize;
    reg [6:0]  Counter;
    reg [64:0] A_Multiplicand_ComparePos;    // Registrador p/ SRA
    reg [64:0] Multiplier;                   // Recebe o multiplicador de RT
    reg [31:0] NegativeBTemp;                // Armazena o multiplicador negativo
    reg [64:0] Temp;                         // Recebe NegativeBTemp com 65 bits
    reg        mult_active;                  // Indica se multiplicação está ativa
    
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            // Reset de todos os registradores
            HI <= 32'b0;
            LO <= 32'b0;
            MultDone <= 1'b0;
            Initialize <= 1'b1;
            Counter <= 7'b0;
            A_Multiplicand_ComparePos <= 65'b0;
            Multiplier <= 65'b0;
            NegativeBTemp <= 32'b0;
            Temp <= 65'b0;
            mult_active <= 1'b0;
        end
        else if (MultCtrl && Initialize) begin
            // Primeiro ciclo: inicialização dos registradores internos
            Initialize <= 1'b0;
            mult_active <= 1'b1;
            MultDone <= 1'b0;
            Counter <= 7'b0;
            
            // Inicializar registradores conforme algoritmo de Booth correto
            A_Multiplicand_ComparePos[64:33] <= 32'b0;              // Registrador A inicializado com 0
            A_Multiplicand_ComparePos[32:1] <= RegBOut;             // Multiplicador de RT
            A_Multiplicand_ComparePos[0] <= 1'b0;                   // Bit extra para comparação
            
            Multiplier <= {33'b0, RegAOut};                        // Multiplicando de RS
            NegativeBTemp <= (~RegAOut) + 32'd1;                   // Multiplicando negativo
            Temp <= {33'b0, (~RegAOut) + 32'd1};                   // Temp com multiplicando negativo
        end
        else if (mult_active) begin
                if (Counter < 7'd32) begin
                    // Booth: comparar os dois bits menos significativos
                     case (A_Multiplicand_ComparePos[1:0])
                         2'b10: begin
                             // 10: subtrair multiplicando e fazer shift
                             A_Multiplicand_ComparePos <= $signed({A_Multiplicand_ComparePos[64:33] - RegAOut, A_Multiplicand_ComparePos[32:0]}) >>> 1;
                         end
                         2'b01: begin
                             // 01: somar multiplicando e fazer shift
                             A_Multiplicand_ComparePos <= $signed({A_Multiplicand_ComparePos[64:33] + RegAOut, A_Multiplicand_ComparePos[32:0]}) >>> 1;
                         end
                         default: begin
                             // 00 ou 11: apenas fazer shift aritmético
                             A_Multiplicand_ComparePos <= $signed(A_Multiplicand_ComparePos) >>> 1;
                         end
                     endcase
                    
                    Counter <= Counter + 1;
                end
                else begin
                    HI <= A_Multiplicand_ComparePos[64:33];
                    LO <= A_Multiplicand_ComparePos[32:1];
                    MultDone <= 1'b1;
                    mult_active <= 1'b0;
                    Initialize <= 1'b1;
                end
        end
    end
endmodule