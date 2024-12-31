`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/13/2024 01:36:44 PM
// Design Name: 
// Module Name: comparator_capture
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


module comparator_capture(
    input logic [7:0] duty_cycle,
    input logic clk,
    input logic V_compare_state1,
    output logic ready_pulse,
    output logic [7:0] PWM_RAW

    );
    
    logic comparator_sync_0, comparator_sync_1;
    logic comparator_prev_state;
    assign ready_pulse = ~V_compare_state1;
    
    always_ff @(posedge clk) begin
        comparator_sync_0 <= V_compare_state1;
        comparator_sync_1 <= comparator_sync_0;
        
        comparator_prev_state <= comparator_sync_1;
        
        if (comparator_prev_state && !comparator_sync_1) begin
            PWM_RAW <= duty_cycle;
            end
    end
endmodule
