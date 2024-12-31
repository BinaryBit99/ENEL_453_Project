`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/14/2024 02:24:32 PM
// Design Name: 
// Module Name: xadc_averager
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module xadc_averager #(
    parameter int power = 8,    // 2^8 = 256 samples
    parameter int N = 8         // Bit width of input data
) (
    input  logic clk,
    input  logic reset,
    input  logic EN,
    input  logic [N-1:0] Din,
    output logic [N-1:0] Q
);
    // Declare register array and sum with proper widths
    logic [N-1:0] REG_ARRAY [2**power:1];
    logic [power+N-1:0] sum;    // Wide enough to hold full sum
    
    // Average by taking upper bits of sum
    assign Q = sum[power+N-1:power];
    
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

