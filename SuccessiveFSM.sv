`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// AUTHOR: Evan Barker
// 
// Create Date: 11/20/2024 02:26:07 PM
// Design Name: 
// Module Name: SuccessiveFSM
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
////////////////////////////////////////////////////////////////////////////////////


module SuccessiveFSM #(
    parameter WIDTH = 8
)(
    input  logic clk,
    input  logic reset,
    input  logic enable,
    input  logic comparator,
    output logic [WIDTH-1:0] next_approximation,
    output logic [WIDTH-1:0] digitized_successive,
    output logic done
    //output logic converting,
    //output logic [2:0] all_states
    //output logic [WIDTH-1:0] test_value,     
   // output logic [3:0] bit_position,         
    //output logic comp_input 
);
    typedef enum logic [2:0] {
        BASELINE   = 3'b001,
        CONVERTING = 3'b010,
        READY      = 3'b100
    } state_type;
    
    state_type state, next_state;
    logic [WIDTH-1:0] approximation_reg, next_approximation;
    logic [3:0] bit_counter, next_bit_counter;
    logic [WIDTH-1:0] digitized_reg;
    logic converting;
    // Counter for 50 clock cycles
    logic [12:0] delay_counter;
    
    assign comp_input = comparator;
    assign bit_position = bit_counter;
    //ssign test_value = approximation_reg;
    //assign all_states = state;
    
    // Simple 50-cycle counter
    always_ff @(posedge clk) begin
        if (reset) begin
            delay_counter <= 0;
        end else begin
            if (delay_counter == 4999)  // Count 0 to 49 = 50 cycles
                delay_counter <= 0;
            else
                delay_counter <= delay_counter + 1;
        end
    end
    
    // Sequential logic - only update when counter hits 49
    always_ff @(posedge clk) begin
        if (reset) begin
            state <= BASELINE;
            approximation_reg <= 8'b0000_0000;
            bit_counter <= 4'b1000;
            digitized_reg <= 8'b0000_0000;
        end else if (delay_counter == 4999) begin  // Update every 50 cycles
            state <= next_state;
            approximation_reg <= next_approximation;
            bit_counter <= next_bit_counter;
            
            if (state == READY) begin
                digitized_reg <= approximation_reg;
            end
        end
    end

    assign digitized_successive = digitized_reg;
    
    // Combinational logic remains the same
    always_comb begin
        next_state = state;
        next_approximation = approximation_reg;
        next_bit_counter = bit_counter;
        converting = 0;
        done = 0;
        
        case (state)
            BASELINE: begin
                if (enable) begin
                    next_state = CONVERTING;
                    next_approximation = 8'b1000_0000;
                    next_bit_counter = WIDTH;
                end
            end
            
            CONVERTING: begin
                converting = 1;
                
                if (bit_counter == 0) begin
                    next_state = READY;
                end else begin
                    if (!comp_input) begin
                        next_approximation = approximation_reg & ~(8'b00000001 << (bit_counter - 1));
                    end
                    
                    if (bit_counter > 1) begin
                        next_approximation = next_approximation | (8'b00000001 << (bit_counter - 2));
                    end 
                    
                    next_bit_counter = bit_counter - 1;
                end
            end
            
            READY: begin
                done = 1;
                next_state = BASELINE;
                next_bit_counter = WIDTH;
            end
            
            default: next_state = BASELINE;
        endcase    
        
        if (reset) begin
            next_state = BASELINE;
            next_approximation = '0;
            next_bit_counter = WIDTH;
        end
        if (!enable && state != BASELINE) begin
            next_state = BASELINE;
        end 
    end
    
endmodule
  
    
    
    
   