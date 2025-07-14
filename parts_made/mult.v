`timescale 1ns / 1ps

// Multiplicador com Algoritmo de Booth - VERSÃO CORRIGIDA
// Realiza multiplicação de dois números de 32 bits com sinal
// Produz resultado de 64 bits em 32 ciclos
module mult(
    input wire clk,
    input wire [31:0] A,        // Multiplicando (RS)
    input wire [31:0] B,        // Multiplicador (RT)
    input wire mult_ctrl,       // Sinal para iniciar multiplicação
    
    output reg [31:0] HI,       // 32 bits mais significativos
    output reg [31:0] LO,       // 32 bits menos significativos
    output reg stop             // Sinal indicando término da multiplicação
);

    // Estados da máquina de multiplicação
    parameter IDLE = 2'b00;
    parameter MULTIPLY = 2'b01;
    parameter DONE = 2'b10;
    
    // Registradores internos
    reg [1:0] state;
    reg [32:0] accumulator;     // Acumulador (33 bits com sinal)
    reg [31:0] multiplier;      // Multiplicador (Q)
    reg q_minus1;               // Bit Q-1
    reg [31:0] multiplicand;    // M (multiplicando)
    reg [5:0] count;            // Contador de ciclos
    
    // Sinais para operações
    wire [1:0] booth_bits;      // Q0 e Q-1 para decisão
    wire [32:0] add_result;     // Resultado de accumulator + multiplicand
    wire [32:0] sub_result;     // Resultado de accumulator - multiplicand
    
    // Atribuições
    assign booth_bits = {multiplier[0], q_minus1};
    assign add_result = accumulator + {multiplicand[31], multiplicand}; // Extensão de sinal
    assign sub_result = accumulator - {multiplicand[31], multiplicand}; // Extensão de sinal
    
    always @(posedge clk) begin
        if (!mult_ctrl) begin
            // Reset completo
            state <= IDLE;
            accumulator <= 33'b0;
            multiplier <= 32'b0;
            q_minus1 <= 1'b0;
            multiplicand <= 32'b0;
            count <= 6'b0;
            HI <= 32'b0;
            LO <= 32'b0;
            stop <= 1'b0;
        end
        else begin
            case (state)
                IDLE: begin
                    stop <= 1'b0;
                    if (mult_ctrl) begin
                        // Inicialização
                        accumulator <= 33'b0;          // A = 0
                        multiplier <= B;               // Q = multiplicador
                        q_minus1 <= 1'b0;            // Q-1 = 0
                        multiplicand <= A;            // M = multiplicando
                        count <= 6'b0;
                        state <= MULTIPLY;
                    end
                end
                
                MULTIPLY: begin
                    if (count < 32) begin
                        // Algoritmo de Booth seguido de shift
                        case (booth_bits)
                            2'b01: begin
                                // Adicionar M e fazer shift
                                accumulator <= {add_result[32], add_result[32:1]};
                                {multiplier, q_minus1} <= {add_result[0], multiplier};
                            end
                            2'b10: begin
                                // Subtrair M e fazer shift
                                accumulator <= {sub_result[32], sub_result[32:1]};
                                {multiplier, q_minus1} <= {sub_result[0], multiplier};
                            end
                            default: begin
                                // Apenas shift (2'b00, 2'b11)
                                accumulator <= {accumulator[32], accumulator[32:1]};
                                {multiplier, q_minus1} <= {accumulator[0], multiplier};
                            end
                        endcase
                        
                        count <= count + 1;
                    end
                    else begin
                        // Multiplicação concluída
                        HI <= accumulator[31:0];   // 32 bits superiores
                        LO <= multiplier;          // 32 bits inferiores
                        state <= DONE;
                    end
                end
                
                DONE: begin
                    stop <= 1'b1;
                    if (!mult_ctrl) begin
                        state <= IDLE;
                    end
                end
                
                default: state <= IDLE;
            endcase
        end
    end

endmodule