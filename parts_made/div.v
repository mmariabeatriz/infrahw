module div (
    input  wire [31:0] dividend,     // value_A
    input  wire [31:0] divisor_in,   // value_B
    input  wire        clk,
    input  wire        div_init,
    input  wire        div_stop,
    input  wire        reset,
    output wire        div_zero,
    output wire [31:0] hi_out,       // remainder
    output wire [31:0] lo_out        // quotient
);
    // Division algorithm:
    // Shift divisor right and compare with current dividend
    // If divisor is larger, shift 0 as next quotient bit
    // If divisor is smaller, subtract and shift 1 as next quotient bit
    
    reg        div_running, finished, stop_flag, error_div_zero;
    reg [31:0] remainder, divisor_reg;
    reg [31:0] dividend_reg, quotient;
    reg [5:0]  current_bit;
    reg [5:0]  counter;

    assign hi_out   = remainder;
    assign lo_out   = quotient;
    assign div_stop = stop_flag;
    assign div_zero = error_div_zero;
    always @ (posedge clk) begin
        if (div_zero) begin
            error_div_zero = 0;
        end
        else if (div_stop) begin
            stop_flag = 0;
        end
        else if (reset) begin
            remainder     = 32'b0;
            divisor_reg   = 32'b0;
            dividend_reg  = 32'b0;
            quotient      = 32'b0;
            current_bit   = 5'b0;
            counter       = 5'b0;
            finished      = 0;
            div_running   = 0;
            stop_flag     = 0;
        end
        else if (div_init) begin
            if (div_running) begin
                if (current_bit != 6'b111111) begin  // -1 (all bits processed)
                    remainder = {remainder[30:0], dividend_reg[current_bit]};
                    if (remainder >= divisor_reg) begin
                        remainder = remainder - divisor_reg;
                        quotient = {quotient[30:0], 1'b1};
                    end
                    else begin
                        quotient = {quotient[30:0], 1'b0};
                    end
                    current_bit <= current_bit - 1'b1;
                    counter <= counter + 1'b1;
                end
                else begin
                    div_running = 0;
                    finished = 1;
                    stop_flag = 1;
                end
            end
            else begin
                if (finished == 0) begin
                    if (divisor_in == 32'b0) begin
                        error_div_zero = 1;
                    end
                    else begin
                        dividend_reg = dividend;
                        divisor_reg  = divisor_in;
                        current_bit  = 5'b11111;  // 31
                        div_running  = 1;
                    end
                end
                else begin
                    finished = 0;
                end
            end
        end
    end
endmodule
