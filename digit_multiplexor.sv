//------------------------------------------------------------------------------
// Module Name: digit_multiplexor
// Description: This module is a 4-to-1 multiplexer designed to select and 
//              output one of four 4-bit digit inputs based on a 4-bit selector 
//              signal. It is typically used in applications where multiple 
//              digits (such as those representing seconds and minutes) need to 
//              be displayed sequentially on a single display, such as in a 
//              timekeeping or stopwatch circuit.
//
//              The module accepts four 4-bit inputs corresponding to individual 
//              digits of time (seconds and minutes), and a 4-bit selector input 
//              that determines which digit is routed to the output.
//
//              The selector input uses a "one-hot" encoding, meaning that only 
//              one of its bits should be high ('1') at any time to select the 
//              corresponding digit:
//
//              - If `selector` is 4'b0001, `sec_dig1` (seconds digit) is selected.
//              - If `selector` is 4'b0010, `sec_dig2` (tens of seconds) is selected.
//              - If `selector` is 4'b0100, `min_dig1` (minutes digit) is selected.
//              - If `selector` is 4'b1000, `min_dig2` (tens of minutes) is selected.
//              - In all other cases, the output `time_digit` is set to 4'b0000.
//
// Inputs:
//   - sec_dig1 : 4-bit input representing the seconds digit.
//   - sec_dig2 : 4-bit input representing the tens of seconds digit.
//   - min_dig1 : 4-bit input representing the minutes digit.
//   - min_dig2 : 4-bit input representing the tens of minutes digit.
//   - selector : 4-bit one-hot encoded input used to select the digit to output.
//
// Output:
//   - time_digit : 4-bit output that carries the selected digit.
//
// Note: This module assumes that the `selector` signal is one-hot encoded. If
//       multiple bits in `selector` are high simultaneously, the behavior is
//       undefined and will default to outputting 4'b0000.
//------------------------------------------------------------------------------

module digit_multiplexor (
    input  logic [3:0] sec_dig1,
    input  logic [3:0] sec_dig2,
    input  logic [3:0] min_dig1,
    input  logic [3:0] min_dig2,
    input  logic [3:0] selector,
    input  logic [3:0] decimal_point, 
    output logic [3:0] time_digit,
    output logic       dp_in
);

    always_comb begin
        case (selector)
            4'b0001: time_digit = sec_dig1;   // display seconds digit
            4'b0010: time_digit = sec_dig2;   // display tens of seconds digit
            4'b0100: time_digit = min_dig1;   // display minutes digit
            4'b1000: time_digit = min_dig2;   // display tens of minutes digit
            default: time_digit = 4'b0000;    // default case
        endcase
    end

    always_comb begin
        case (selector)
            4'b0001: dp_in = decimal_point[0];   // DP right of seconds digit
            4'b0010: dp_in = decimal_point[1];   // DP right of tens of seconds digit
            4'b0100: dp_in = decimal_point[2];   // DP right of minutes digit
            4'b1000: dp_in = decimal_point[3];   // DP right of tens of minutes digit
            default: dp_in = 0;    // default case (all DP are OFF)
        endcase
    end

endmodule
