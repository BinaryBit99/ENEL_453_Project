`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/06/2024 02:58:21 PM
// Design Name: 
// Module Name: all_three_muxes
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


module r2r_pwm_waveform_enable(
    input  logic pwm_out_internal,
    input  logic [7:0] R2R_out_internal,
    input  logic [15:0] scaled_adc_data,
    input  logic r2r_enable,
    //input  logic [15:0] led,
    input  logic pwm_enable,
    //input  logic [7:0] R2R_out,
    //output logic [15:0] led,
    output logic pwm_out, //buzzer_out,
    output logic [7:0] R2R_out

    );
    //logic [15:0] led;
  
    
    //assign led = pwm_out_internal ? scaled_adc_data : '0;
    
    always_comb begin
        pwm_out = pwm_enable ? pwm_out_internal : '0;
        R2R_out = r2r_enable ? R2R_out_internal : '0;
    end
endmodule
