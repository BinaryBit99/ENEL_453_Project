`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/13/2024 10:30:15 PM
// Design Name: 
// Module Name: comparator
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


// Comparator module below functions to 'capture' the falling edge of the duty cycle output from comparator for PWM RAMP

// For the purpose of reusability, we used this module also for R2R!

// Essentially, right when the analog input test voltage intersects with the ramp, for the time thereafter the comparator output voltage will be a zero. Thus, we detect WHEN the comparator output will be zero; the 8 bit binary value corresponding to this matches the PWM RAW input.

module comparator
    #(
        parameter int WIDTH = 8
    )
    (
        input  logic clk,
        input  logic reset,
        input  logic comparator_output,
        input  logic [WIDTH-1:0] current_duty_cycle,
        output logic [WIDTH-1:0] captured_duty_cycle
    );
    
    // Synchronization registers
    logic comp_sync1, comp_sync2;
    logic comparator_output_prev;
    
    // Noise filtering counter
    logic [3:0] stable_counter;
    logic [WIDTH-1:0] temp_capture;
    
    always_ff @(posedge clk) begin
        if (reset) begin
            comp_sync1 <= 1'b1;
            comp_sync2 <= 1'b1;
            comparator_output_prev <= 1'b1;
            captured_duty_cycle <= '0;
            stable_counter <= '0;
        end else begin
            // Two-stage synchronization
            comp_sync1 <= comparator_output;
            comp_sync2 <= comp_sync1;
            comparator_output_prev <= comp_sync2;
            
            // Falling edge detection with noise filtering
            if (comparator_output_prev && !comp_sync2) begin
                temp_capture <= current_duty_cycle;
                stable_counter <= 4'hF; // Start stability check
            end else if (stable_counter > 0) begin
                stable_counter <= stable_counter - 1;
                if (stable_counter == 1) begin
                    captured_duty_cycle <= temp_capture;
                end
            end
        end
    end
endmodule
