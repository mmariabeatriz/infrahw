// Unidade de Divisão (DIV) - Realiza divisão de números inteiros com sinal
// Implementa algoritmo de divisão por subtração sucessiva com tratamento de sinais
// Produz quociente (LO) e resto (HI), detecta divisão por zero
module div (
    input  wire [31:0] RegAOut,      // Recebe RS
    input  wire [31:0] RegBOut,      // Recebe RT
    input  wire        clk,
    input  wire        reset,
    input  wire        DivCtrl,      // Ativa DIV
    output reg         DivDone,      // Informa a unidade o término
    output reg         Div0,         // caso ocorra uma divisão por 0
    output reg  [31:0] HI,           // resto
    output reg  [31:0] LO            // quociente
);
    // Registradores internos
    reg        init_done; 
    reg [31:0] aux_A, aux_B;        // Registradores aux
    reg        sign_A, sign_B;      // Sinais dos registradores A e B
    reg [31:0] counter;             // Contador
    reg        div_active;          // Indica divisão ativa
    
    // ULA interna para subtração e comparação
    wire [31:0] alu_result;
    wire        alu_greater_equal;
    
    assign alu_result = aux_A - aux_B;
    assign alu_greater_equal = (aux_A >= aux_B);
    
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            // Reset de todos os registradores
            HI <= 32'b0;
            LO <= 32'b0;
            DivDone <= 1'b0;
            Div0 <= 1'b0;
            init_done <= 1'b0;
            aux_A <= 32'b0;
            aux_B <= 32'b0;
            sign_A <= 1'b0;
            sign_B <= 1'b0;
            counter <= 32'b0;
            div_active <= 1'b0;
        end
        else if (DivCtrl) begin
            if (!init_done) begin
                // Verificar divisão por zero primeiro
                if (RegBOut == 32'b0) begin
                    Div0 <= 1'b1;
                    HI <= 32'hFFFFFFFF;  // Maior valor possível de 32 bits
                    LO <= 32'hFFFFFFFF;  // Maior valor possível de 32 bits
                    DivDone <= 1'b1;
                    init_done <= 1'b0;
                    div_active <= 1'b0;
                end
                else begin
                    // Inicialização dos registradores auxiliares
                    init_done <= 1'b1;
                    div_active <= 1'b1;
                    DivDone <= 1'b0;
                    Div0 <= 1'b0;
                    counter <= 32'b0;
                    
                    // Armazenar sinais e valores absolutos
                    sign_A <= RegAOut[31];
                    sign_B <= RegBOut[31];
                    aux_A <= RegAOut[31] ? (~RegAOut + 1) : RegAOut;  // Valor absoluto de A
                    aux_B <= RegBOut[31] ? (~RegBOut + 1) : RegBOut;  // Valor absoluto de B
                end
            end
            else if (div_active) begin
                // Algoritmo de divisão
                if (alu_greater_equal) begin
                    aux_A <= alu_result;  // A = A - B
                    counter <= counter + 1;  // Incrementar contador
                end
                else begin
                     // Divisão concluída
                     // - A e B negativos: divisão positiva
                     // - Só A ou só B negativo: divisão negativa
                     // - Ambos positivos: divisão positiva
                     if ((sign_A && sign_B) || (!sign_A && !sign_B)) begin
                         // Ambos negativos ou ambos positivos -> resultado positivo
                         LO <= counter;
                     end
                     else begin
                         // Um negativo, outro positivo -> resultado negativo
                         LO <= ~counter + 1;
                     end
                     
                     if (sign_A) begin
                         HI <= ~aux_A + 1;  // Resto negativo
                     end
                     else begin
                         HI <= aux_A;       // Resto positivo
                     end
                     
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
