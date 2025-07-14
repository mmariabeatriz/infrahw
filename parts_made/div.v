// Unidade de Divisão (DIV) - Realiza divisão de números inteiros com sinal
// Implementa divisão por subtração sucessiva
// Produz quociente (LO) e resto (HI)
module div (
    input  wire [31:0] RegAOut,         // Dividendo (RS)
    input  wire [31:0] RegBOut,         // Divisor (RT)
    input  wire        clk,
    input  wire        reset,
    input  wire        DivCtrl,        // Início da divisão
    
    output reg         DivDone,        // Fim da divisão
    output reg         Div0,           // Divisão por zero
    output reg  [31:0] HI,             // Resto
    output reg  [31:0] LO              // Quociente
);
    // Registradores internos
    reg [31:0] dividend;        // Dividendo (valor absoluto)
    reg [31:0] divisor;         // Divisor (valor absoluto)
    reg [31:0] quotient;        // Quociente temporário
    reg [31:0] remainder;       // Resto temporário
    reg        sign_result;     // Sinal do resultado
    reg        sign_remainder;  // Sinal do resto
    reg        div_active;      // Divisão ativa
    reg        init_done;       // Inicialização concluída
    
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            // Reset de todos os registradores
            HI <= 32'b0;
            LO <= 32'b0;
            DivDone <= 1'b0;
            Div0 <= 1'b0;
            dividend <= 32'b0;
            divisor <= 32'b0;
            quotient <= 32'b0;
            remainder <= 32'b0;
            sign_result <= 1'b0;
            sign_remainder <= 1'b0;
            div_active <= 1'b0;
            init_done <= 1'b0;
        end
        else if (DivCtrl) begin
            if (!init_done) begin
                // Verificar divisão por zero
                if (RegBOut == 32'b0) begin
                    Div0 <= 1'b1;
                    HI <= 32'b0;  // Resto indefinido
                    LO <= 32'b0;  // Quociente indefinido
                    DivDone <= 1'b1;
                    init_done <= 1'b0;
                    div_active <= 1'b0;
                end
                else begin
                    // Inicialização para divisão
                    init_done <= 1'b1;
                    div_active <= 1'b1;
                    DivDone <= 1'b0;
                    Div0 <= 1'b0;
                    
                    // Determinar sinais
                    sign_result <= RegAOut[31] ^ RegBOut[31];  // XOR para sinal do quociente
                    sign_remainder <= RegAOut[31];             // Resto tem sinal do dividendo
                    
                    // Valores absolutos
                    dividend <= RegAOut[31] ? (~RegAOut + 1) : RegAOut;
                    divisor <= RegBOut[31] ? (~RegBOut + 1) : RegBOut;
                    quotient <= 32'b0;
                    remainder <= 32'b0;
                end
            end
            else if (div_active) begin
                // Algoritmo de subtração sucessiva simples
                if (dividend >= divisor) begin
                    dividend <= dividend - divisor;
                    quotient <= quotient + 1;
                end
                else begin
                    // Divisão concluída
                    remainder <= dividend;
                    
                    // Aplicar sinais
                    LO <= sign_result ? (~quotient + 1) : quotient;
                    HI <= sign_remainder ? (~dividend + 1) : dividend;
                    
                    DivDone <= 1'b1;
                    div_active <= 1'b0;
                    init_done <= 1'b0;
                end
            end
        end
        else begin
            // DivCtrl desativado -> resetar flags
            init_done <= 1'b0;
            div_active <= 1'b0;
            if (DivDone) begin
                DivDone <= 1'b0;
            end
            if (Div0) begin
                Div0 <= 1'b0;
            end
        end
    end
endmodule
