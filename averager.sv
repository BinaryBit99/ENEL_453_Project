// Enhanced averager with proper type declarations and bit handling



module averager #(
    parameter int power = 8,    // 2^8 = 256 samples
    parameter int N = 8,        // Bit width of input data
    parameter int M = N + power/2  // Output width with extra resolution bits
) (
    input  logic clk,
    input  logic reset,
    input  logic EN,
    input  logic [N-1:0] Din,
    output logic [M-1:0] Q     // Now M bits wide instead of N
);
    // Declare register array and sum with proper widths
    logic [N-1:0] REG_ARRAY [2**power:1];
    logic [power+N-1:0] sum;    // Wide enough to hold full sum
    
    // Take more bits from the sum to get the extra resolution
    assign Q = sum[power+N-1:power/2];  // Changed bit selection for more resolution
    
    always_ff @(posedge clk) begin
        if (reset) begin
            sum <= '0;
            for (int j = 1; j <= 2**power; j++) begin
                REG_ARRAY[j] <= '0;
            end
        end
        else if (EN) begin
            // Update sum and shift register
            sum <= sum + Din - REG_ARRAY[2**power];
            for (int j = 2**power; j > 1; j--) begin
                REG_ARRAY[j] <= REG_ARRAY[j-1];
            end
            REG_ARRAY[1] <= Din;
        end
    end
endmodule


