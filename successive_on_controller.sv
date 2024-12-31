`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/20/2024 04:00:01 PM
// Design Name: 
// Module Name: successive_on_controller
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

// Module contains combinational logic for the enables for successive R2R and PWM depending upon the four selects and the down button.

module successive_on_controller(        // Logical controller designed to engage in abstraction for successive controllers.
    input logic fourth_select,
    input logic third_select,
    input logic second_select,
    input logic first_select,
    input down_button,                  // Extra button because we have 17 options with successive added.
    
    output logic enable_pwm_successive,
    output logic enable_r2r_successive
    );
    logic enable_pwm_successive;
    logic enable_r2r_successive;
    
    // Logic below controls the successive enables for R2R and PWM.
    
    assign enable_pwm_successive = (fourth_select & second_select & ~first_select) | (fourth_select & ~third_select & ~first_select) | (fourth_select & third_select & second_select & ~first_select);
    assign enable_r2r_successive = (fourth_select & ~third_select & first_select) | (down_button);

    
endmodule
