`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/22/2024 10:19:51 PM
// Design Name: 
// Module Name: binary_regular_filter
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

// A bit motive for why this module/filter was created was to engage in the practice of 'reusability' for the AVERAGED and SCALED modules!

// Instead of adding FOUR extra modules in total for R2R and PWM successive for their averaging and scaling, we can just make use of what we have so far and just implement this filter!

module binary_regular_filter(                       // This 'filter' selects between either REGULAR or SUCCESSIVE for the RAW output values that feed into the AVERAGED and SCALED modules.
    input logic [7:0] V_analog_in_r2r,              // R2R REGULAR
    input logic [7:0] comparator_result,            // PWM REGULAR
    input logic [7:0] r2r_successive_out,           // R2R SUCCESSIVE
    input logic [7:0] captured_pwm_successive,      // PWM SUCCESSIVE
    
    input logic fourth_select,                      // SELECTs used for the logic.
    input logic third_select,
    input logic second_select,
    input logic first_select,
    input logic down_button,
    
    output logic [7:0] R2R_output,                  // Either SUCCESIVE or REGULAR outputs for the below two outputs.
    output logic [7:0] PWM_output
    );
    
    logic [7:0] R2R_output;
    logic [7:0] PWM_output;
    
    logic r2r_reg_enable;
    logic r2r_successive_enable;
    
    logic pwm_reg_enable;
    logic pwm_successive_enable;
    
    assign r2r_reg_enable = (fourth_select & third_select & ~second_select) | (fourth_select & third_select & first_select);
    assign r2r_successive_enable = (fourth_select & ~third_select & first_select) | (down_button);
    
    assign pwm_reg_enable = (~fourth_select & third_select & ~second_select) | (~fourth_select & third_select & first_select);
    assign pwm_successive_enable = (fourth_select & second_select & ~first_select) | (fourth_select & ~third_select & ~first_select) | (fourth_select & third_select & second_select & ~first_select);
    
    always_comb begin
        if (r2r_reg_enable)
            R2R_output = V_analog_in_r2r;
        else if (r2r_successive_enable)
            R2R_output = r2r_successive_out;
        else                                        // IMPORTANT: This else block was necessary to prevent inferred latches!
            R2R_output = 8'h00;
    end
    
    always_comb begin
        if (pwm_reg_enable)
            PWM_output = comparator_result;
        else if (pwm_successive_enable)
            PWM_output = captured_pwm_successive;
        else
            PWM_output = 8'h00;
    end
    
    
    
endmodule
