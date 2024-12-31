///////////////////////////////////////////////////////////////////////////////
// Module Name: seven_segment_digit_selector
// 
// Description:
// This module implements a digit selector for a 4-digit 7-segment display.
// It generates a rotating selection signal at approximately 763 Hz,
// allowing for time-multiplexed control of the 4 digits.
//
// Inputs:
//   - clk   : System clock (assumed to be 100 MHz)
//   - reset : Active-high synchronous reset
//
// Outputs:
//   - digit_select : 4-bit output indicating the currently selected digit (one-hot encoded)
//   - an_outputs   : 4-bit active-low output for directly driving 7-segment display anodes
//
// Internal Signals:
//   - count : 17-bit counter used to generate a ~763 Hz clock signal
//   - q     : 4-bit register storing the current digit selection state
//   - d     : Next state for the digit selection register
//
// Operation:
//   1. A 17-bit counter divides the 100 MHz clock to create a ~763 Hz signal.
//   2. On each ~763 Hz clock tick, the digit selection rotates:
//      1000 -> 0100 -> 0010 -> 0001 -> 1000 (repeat)
//   3. The digit_select output directly reflects the current selection state.
//   4. The an_outputs is the inverted digit_select, suitable for driving active-low anodes.
//
// Reset Behavior:
//   On reset, the counter is cleared and the digit selection is set to 1111.
//   This ensures a known state and allows the module to start its rotation from a defined point.
//
// Note: The actual update frequency may vary slightly from 763 Hz due to the binary division.
///////////////////////////////////////////////////////////////////////////////

module seven_segment_digit_selector (
    input logic        clk,
    input logic        reset,
    output logic [3:0] digit_select,
    output logic [3:0] an_outputs
);

    logic [3:0] d, q;
    logic [16:0] count;

    // 1 kHz clock process (100 MHz / 2^17 = 762.9 Hz)
    always_ff @(posedge clk) begin
        if (reset) begin
            count <= 17'b0;
        end else begin
            count <= count + 1;
        end
    end

    // DFFs process
    always_ff @(posedge clk) begin
        if (reset) begin
            // Reset state values for q
            q <= 4'b1111;
        end else if (count == 17'b0) begin
            // Propagate signals through the DFF
            if (q[0] && q[1]) begin
                q <= 4'b1000;
            end else begin
                q <= d;
            end
        end
    end

    // Connect the DFFs into a chain/loop
    assign d[0] = q[3];
    assign d[1] = q[0];
    assign d[2] = q[1];
    assign d[3] = q[2];

    // Output assignments
    assign digit_select = q;

    // Copying q to the LED anodes, invert because active low
    assign an_outputs = ~q;

endmodule
