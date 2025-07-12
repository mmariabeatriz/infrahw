module mult (
    input  wire [31:0] multiplicand,    // Entrada A
    input  wire [31:0] multiplier,      // Entrada B
    input  wire        clk,
    input  wire        reset,
    input  wire        mult_init,
    
    output wire        mult_stop,
    output reg  [31:0] hi_out,          // 32 bits superiores do resultado
    output reg  [31:0] lo_out           // 32 bits inferiores do resultado
);
    // Registradores do algoritmo de multiplicação de Booth
    reg [64:0] accumulator;         // Acumulador principal (A + Q + Q-1)
    reg [64:0] multiplicand_ext;    // Multiplicando estendido
    reg [64:0] complement_2;        // Complemento de 2 do multiplicando
    reg [5:0]  counter;             // Contador de bits
    reg [31:0] complement_32;       // Complemento de 2 de 32 bits
    reg        stop_flag, mult_running, finished;

    assign mult_stop = stop_flag;
    
    always @(posedge clk) begin
        if (reset) begin
            accumulator      = 65'b0;
            multiplicand_ext = 65'b0;
            complement_2     = 65'b0;
            counter          = 6'b0;
            complement_32    = 32'b0;
            mult_running     = 1'b0;
            finished         = 1'b0;
            stop_flag        = 0;
        end
        else begin
            if (mult_init) begin
                if (mult_running) begin
                    if (counter < 6'b100000) begin  // 32 iterações
                        // Algoritmo de Booth: verifica os dois últimos bits
                        if (accumulator[1] != accumulator[0]) begin
                            if (accumulator[0] == 0) begin  // Subtração
                                accumulator = accumulator + complement_2;
                            end
                            else begin  // Adição
                                accumulator = accumulator + multiplicand_ext;
                            end
                        end
                        // Deslocamento aritmético à direita
                        accumulator = accumulator >>> 1;
                        if (accumulator[63] == 1) begin  // Extensão de sinal
                            accumulator[64] = 1'b1;
                        end
                        counter <= counter + 1;
                    end
                    else begin  // Multiplicação completa
                        hi_out = accumulator[64:33];
                        lo_out = accumulator[32:1];
                        mult_running = 0;
                        finished = 1;
                        stop_flag = 1;
                    end
                end
                else begin
                    if (finished == 0) begin
                        // Inicializa multiplicação
                        accumulator = {32'b0, multiplier, 1'b0};
                        multiplicand_ext = {multiplicand[31:0], 33'b0};
                        complement_32 = ~multiplicand + 32'b00000000000000000000000000000001;
                        complement_2 = {complement_32, 33'b0};
                        counter <= 6'b0;
                        mult_running = 1'b1;
                    end
                    else begin
                        finished = 0;
                    end
                end
            end
        end
    end
endmodule