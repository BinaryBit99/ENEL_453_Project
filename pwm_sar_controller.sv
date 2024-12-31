`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/20/2024 02:49:58 PM
// Design Name: 
// Module Name: pwm_sar_controller
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

// Controller below 'controls' PWM SAR routing - The PWM_duty_in is continuously fed into this module such that continuous comparisons in SuccessiveFSM occurs.
// The 'meat' of the logic for successive is embedded in the SuccessiveFSM file.

module pwm_sar_controller #(
    parameter WIDTH = 8
)(
    input  logic clk,                               // Input signals.
    input  logic reset,
    input  logic enable,
    input  logic PWM_duty_in,                       // This comes from comparator (either will be 1 or 0; 1 if analog input test > reference duty voltage, else a 0)
    output logic [WIDTH-1:0] current_duty_cycle,    // This is the intermediate reference voltage that is used for the approximation algorithm (1000_0000 -> 0100_0000 -> 0110_0000 -> ETC.); We do NOT use this for the seven segment output, because they are strictly intermediate values.
    output logic [WIDTH-1:0] captured_duty_cycle    // THIS is the value we use for the seven segement display as it is the 'ready' state digital reference voltage coming from SuccessiveFSM!
);
    
    logic [WIDTH-1:0] current_value_internal;       // Intermediate signals.
    logic [WIDTH-1:0] for_seven_seg;
    logic done;
  
    // Instantiate SAR ADC
    SuccessiveFSM #(            
        .WIDTH(WIDTH)
    ) SuccessiveFSM (
        .clk(clk),
        .reset(reset),      
        .enable(enable),
        .comparator(PWM_duty_in),
        .next_approximation(current_value_internal),
        .digitized_successive(for_seven_seg),
        .done(done)     
    );
    
    // Added a sync below to allow for more stable output values going into seven segment display.
    always_ff @(posedge clk) begin
        if (reset) begin
            captured_duty_cycle <= '0;
        end else if (done) begin
            captured_duty_cycle <= for_seven_seg;
        end
    end
    
    // Pure combinational assignment for current value
    assign current_duty_cycle = current_value_internal;
    
endmodule

