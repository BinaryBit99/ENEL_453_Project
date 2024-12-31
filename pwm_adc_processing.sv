`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/10/2024 09:56:19 PM
// Design Name: 
// Module Name: pwm_adc_processing
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

// Code works below

module pwm_adc_processing #(
    parameter int SCALING_FACTOR = 3400,         // Direct voltage scaling
    parameter int SHIFT_FACTOR   = 8,           // Adjusted to prevent premature clamping
    parameter int INPUT_BITS     = 8,           
    parameter int AVERAGE_POWER  = 8            
) (
    input  logic                    clk,
    input  logic                    reset,
    input  logic [7:0]             pwm_in,     
    output logic [15:0]            scaled_adc_data,
    output logic [11:0]            ave_data,
    output logic                    conversion_done
);
    // Internal signals
    logic [7:0] ramp_counter;     
    logic       ready_pulse;       
    
    // Ensure enough width for multiplication
    localparam int SCALE_WIDTH = 24; // Wide enough for multiplication
    logic [SCALE_WIDTH-1:0] scaled_temp;
    logic [11:0] averaged_value;

    // Timing control
    always_ff @(posedge clk) begin
        if (reset)
            ramp_counter <= '0;
        else
            ramp_counter <= ramp_counter + 1'b1;
    end

    always_ff @(posedge clk) begin
        if (reset)
            ready_pulse <= 1'b0;
        else
            ready_pulse <= (ramp_counter == 8'hFF);
    end

    // Averager instance
    averager #(
        .power(AVERAGE_POWER),  
        .N(INPUT_BITS),        
        .M(INPUT_BITS + AVERAGE_POWER/2)  
    ) AVERAGER (
        .reset(reset),
        .clk(clk),
        .EN(ready_pulse),
        .Din(pwm_in),
        .Q(averaged_value)
    );

    assign ave_data = averaged_value;
    
    // Pre-scaling normalization
    logic [11:0] normalized_value;
    always_comb begin
        // Map input range (0-4095) to (0-255)
        normalized_value = averaged_value >> 4;
    end

    // Scaling pipeline with adjusted range
    always_ff @(posedge clk) begin
        if (reset) begin
            scaled_adc_data <= '0;
            scaled_temp <= '0;
            conversion_done <= 1'b0;
        end
        else if (ready_pulse) begin
            // Scale normalized value to voltage range
            scaled_temp <= normalized_value * SCALING_FACTOR;
            
            if ((scaled_temp >> SHIFT_FACTOR) > 16'd3300) begin
                scaled_adc_data <= 16'd3300;
            end else begin
                scaled_adc_data <= scaled_temp >> SHIFT_FACTOR;
            end
            
            conversion_done <= 1'b1;
        end
        else begin
            conversion_done <= 1'b0;
        end
    end
endmodule



