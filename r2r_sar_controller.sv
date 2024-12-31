`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/20/2024 02:50:41 PM
// Design Name: 
// Module Name: r2r_sar_controller
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

// R2R SAR ADC Controller with One-Hot Encoded FSM
module r2r_sar_controller #(
    parameter WIDTH = 8
)(
    input  logic clk,
    input  logic reset,
    input  logic enable,
    input  logic R2R_duty_in,
    output logic [WIDTH-1:0] current_value_internal,
    output logic [WIDTH-1:0] captured_R2R_value,
    output logic done
);
    logic converting;
    logic comparator_sync;
    logic [WIDTH-1:0] current_R2R_value;
    
    // Two-stage synchronizer for comparator input with reset
//    logic comp_sync1;
//    always_ff @(posedge clk) begin
//        if (reset) begin
//            comp_sync1 <= 0;
//            comparator_sync <= 0;
//        end else begin
//            comp_sync1 <= R2R_duty_in;
//            comparator_sync <= comp_sync1;
//        end
//    end
    
    // Instantiate base SAR ADC
    SuccessiveFSM #(
        .WIDTH(WIDTH)
    ) SuccessiveFSM (
        .clk(clk),
        .reset(reset),
        .enable(enable),
        .comparator(R2R_duty_in),
        .digitized_successive(current_R2R_value),
        .next_approximation(current_value_internal),
        .done(done)
        //.converting(converting)
    );
    
    // Mealy-style output logic
    // Replace combinational block with sequential for captured value
    always_ff @(posedge clk) begin
        if (reset) begin
            captured_R2R_value <= '0;
        end else if (done) begin
            captured_R2R_value <= current_R2R_value;
        end
    end
    
    // Pure combinational assignment for current value
    //assign current_R2R_value = current_value_internal;
    
endmodule
