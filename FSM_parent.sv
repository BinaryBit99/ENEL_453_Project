`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/06/2024 11:47:22 AM
// Design Name: 
// Module Name: FSM_parent
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


module FSM_parent(
    input  logic clk,
    input  logic reset,
    
    input  logic first_select,      // LOGICAL SELECTS
    input  logic second_select,
    input  logic third_select,
    input  logic fourth_select,
    input  down_button,
   
    output logic triangle_en,       // OUTPUTS: 1 enable ON when either r2r_enable is true OR pwm_enable is true (either). Feeds into downcounter/pwm_inst.
    output logic r2r_enable,
    output logic pwm_enable
    );
    // Intermediate signals:
    logic pwm_enable;
    logic r2r_enable;
    logic triangle_en;
    logic first_mode_select;
    logic second_mode_select;
    logic [1:0] mode_select;
    
    // input logic for selects that dictate mode_select values (R2R or PWM).
    
    assign first_mode_select = (fourth_select & third_select & ~second_select) | (fourth_select & first_select) | (down_button);
    assign second_mode_select = (~fourth_select & third_select & first_select) | (~fourth_select & third_select & ~second_select) | (fourth_select & ~third_select & ~first_select) | (fourth_select & third_select & second_select & ~first_select);
    assign mode_select = {first_mode_select, second_mode_select};
    
    output_mode_fsm FSM (
        .clk(clk),
        .reset(reset),
        .mode_select(mode_select),
        .pwm_enable(pwm_enable), 
        .r2r_enable(r2r_enable)     
    );
    
    assign triangle_en = pwm_enable | r2r_enable;
endmodule
