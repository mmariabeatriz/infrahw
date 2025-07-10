module mult (
    input  wire [31:0] multiplicand,    // Input A
    input  wire [31:0] multiplier,      // Input B
    input  wire        clk,
    input  wire        reset,
    input  wire        mult_init,
    
    output wire        mult_stop,
    output reg  [31:0] hi_out,          // Upper 32 bits of result
    output reg  [31:0] lo_out           // Lower 32 bits of result
);
    // Booth's multiplication algorithm registers
    reg [64:0] accumulator;         // Main accumulator (A + Q + Q-1)
    reg [64:0] multiplicand_ext;    // Extended multiplicand
    reg [64:0] complement_2;        // 2's complement of multiplicand
    reg [5:0]  counter;             // Bit counter
    reg [31:0] complement_32;       // 32-bit 2's complement
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
                    if (counter < 6'b100000) begin  // 32 iterations
                        // Booth's algorithm: check last two bits
                        if (accumulator[1] != accumulator[0]) begin
                            if (accumulator[0] == 0) begin  // Subtraction
                                accumulator = accumulator + complement_2;
                            end
                            else begin  // Addition
                                accumulator = accumulator + multiplicand_ext;
                            end
                        end
                        // Arithmetic right shift
                        accumulator = accumulator >>> 1;
                        if (accumulator[63] == 1) begin  // Sign extension
                            accumulator[64] = 1'b1;
                        end
                        counter <= counter + 1;
                    end
                    else begin  // Multiplication complete
                        hi_out = accumulator[64:33];
                        lo_out = accumulator[32:1];
                        mult_running = 0;
                        finished = 1;
                        stop_flag = 1;
                    end
                end
                else begin
                    if (finished == 0) begin
                        // Initialize multiplication
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