`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/08/2024 12:15:00 PM
// Design Name: 
// Module Name: compare_one
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

module compare_one (
    input  logic clk,                // System clock
    input  logic reset,              // Active-high reset
    input  logic V_compare_state1,   // Comparator output (1 when V_analog_in > V_DAC1, 0 otherwise)
    output logic [7:0] V_analog_in   // 8-bit scaled voltage value proportional to V_analog_in
);

    parameter int N = 16;            // Bit width for counter and `voltage_compare1`
    parameter int MAX_VALUE_8BIT = 255;  // Max value for 8-bit output (corresponding to 3.3V)

    logic [N-1:0] duty_cycle_counter; // Counter for duty cycle measurement
    logic [N-1:0] voltage_compare1;   // Captured duty cycle value proportional to V_analog_in
    logic prev_compare_state1;        // Previous state of V_compare_state1 for edge detection

    // Edge detection and duty cycle capture process
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            duty_cycle_counter <= 0;
            voltage_compare1 <= 0;
            prev_compare_state1 <= 0;
        end else begin
            // Edge detection on V_compare_state1
            if (V_compare_state1 && !prev_compare_state1) begin
                // Rising edge detected: reset the duty cycle counter
                duty_cycle_counter <= 0;
            end else if (!V_compare_state1 && prev_compare_state1) begin
                // Falling edge detected: capture the duty cycle
                voltage_compare1 <= duty_cycle_counter;
            end
            
            // Increment the duty cycle counter during the high state of V_compare_state1
            if (V_compare_state1) begin
                duty_cycle_counter <= duty_cycle_counter + 1;
            end

            // Update previous state of V_compare_state1 for edge detection
            prev_compare_state1 <= V_compare_state1;
        end
    end

    // Scale `voltage_compare1` to an 8-bit output (proportional to 0 - 3.3V)
    always_comb begin
        V_analog_in = (voltage_compare1 * MAX_VALUE_8BIT) >> (N - 8);
    end
   

endmodule


