//*******************************************************************************
// Module: seven_segment_display_subsystem
//
// Description:
// This module integrates the digit_multiplexor, seven_segment_digit_selector, 
// and seven_segment_decoder into a single subsystem to drive a 4-digit 
// 7-segment display. It is designed to interface with a top-level module like 
// lab_1b_top_level and enables hierarchical design.
//
// Inputs:
// - clk: Clock input
// - reset: Active-high synchronous reset
// - sec_dig1, sec_dig2, min_dig1, min_dig2: 4-bit BCD digit inputs
//
// Outputs:
// - CA, CB, CC, CD, CE, CF, CG, DP: Individual segment controls (active-low)
// - AN1, AN2, AN3, AN4: Anode controls for the 4 digits (active-low)
//
// Internal Signals:
// - digit_select: One-hot encoded output for digit selection
// - digit_to_display: 4-bit BCD value to display on the current digit
// - in_DP: Control signal for the decimal point
//
//*******************************************************************************

module seven_segment_display_subsystem (
    //input  logic     swtich_to_reg,
    input  logic        clk,
    input  logic        hex_bin,
    //input  logic [7:0] V_analog_in,
    input  logic        reset,
    input  logic        first_select,   // selects inputted for allzero logic
    input  logic        second_select,
    input  logic        third_select,
    input  logic        fourth_select,
    input  logic [15:0]       mux_in,
//    input  logic [3:0]  sec_dig1, // seconds digit (units)
//    input  logic [3:0]  sec_dig2, // tens of seconds
//    input  logic [3:0]  min_dig1, // minutes digit (units)
//    input  logic [3:0]  min_dig2, // tens of minutes
    input  logic [3:0] decimal_point, 
    output logic        CA, CB, CC, CD, CE, CF, CG, DP, // segment outputs (active-low)
    output logic        AN1, AN2, AN3, AN4 // anode outputs for digit selection (active-low)
);

    // Internal signals
    logic switch_all_zeros;
    logic [3:0] digit_to_display;
    //logic [15:0] V_analog_in_ext;
    logic int_result;
    logic [3:0] digit_select;
    logic [3:0] an_outputs;
    logic       in_DP, out_DP;
    logic [15:0] dec_out;
    logic [3:0] select_in_bus;
    logic [15:0] into_seven_seg;           // HEX OR DEC OUTPUT (FROM MUX) based on hex_bin select.
    
    assign select_in_bus = {fourth_select, third_select, second_select, first_select};
    
    assign into_seven_seg = (hex_bin || select_in_bus == 4'b0010) ? mux_in : dec_out;
    
    
    assign switch_all_zeros = (~fourth_select & ~third_select & ~second_select & first_select);

    assign int_result = reset | switch_all_zeros;
    
    //assign V_analog_in_ext = {8'b0, V_analog_in}; // Concatenate 8 zeros to the upper 8 bits
        
    // Instantiate digit multiplexor
    digit_multiplexor DIGIT_MUX (
        .sec_dig1(  into_seven_seg[3:0]),  // input for seconds digit (units)
        .sec_dig2(  into_seven_seg[7:4]),  // input for tens of seconds digit
        .min_dig1(  into_seven_seg[11:8]),  // input for minutes digit (units)
        .min_dig2(  into_seven_seg[15:12]),  // input for tens of minutes digit
        .selector(  digit_select), // one-hot selector for the digit
        .decimal_point(decimal_point),
        .time_digit(digit_to_display),  // 4-bit digit output to display
        .dp_in(in_DP) // output
    );

    // Instantiate digit selector
    seven_segment_digit_selector DIGIT_SELECTOR (
        .clk(         clk),         // Clock input
        .reset(       int_result),       // Reset input (active-high)
        .digit_select(digit_select), // Output: one-hot encoded digit select
        .an_outputs(  an_outputs)   // Output: active-low anode controls
    );
    
    bin_to_bcd DEFAULT_DEC (
        .clk(clk),
        .reset(reset),
        .bin_in(mux_in),
        .bcd_out(dec_out)
    );
        

    // Instantiate seven segment decoder
    seven_segment_decoder SEG_DECODER (
        .data( digit_to_display), // Input: 4-bit BCD digit to display
        .dp_in( in_DP),           // Input: Decimal point control
        .CA( CA), .CB( CB), .CC( CC), .CD( CD), .CE( CE), .CF( CF), .CG( CG), // Segment outputs (active-low)
        .DP( out_DP)              // Decimal point output (active-low)
    );

    // Connect anodes
    assign AN1 = an_outputs[0];
    assign AN2 = an_outputs[1];
    assign AN3 = an_outputs[2];
    assign AN4 = an_outputs[3];

    // Control the decimal point: You can modify `in_DP` assignment as per the design
    //assign in_DP = 0;  // No decimal point by default, modify as needed
    assign DP = out_DP;  // Pass the decimal point signal from the decoder

endmodule
