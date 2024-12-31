// This module was written by Claude 3.5 Sonnet, through several debugging
// iterations with Denis Onen.
// For ENEL 453, you do not have to know the double dabble algorithm used in 
// this module. However, you should know how to manually convert binary to
// BCD, and BCD to binary (i.e. on paper).
//////////////////////////////////////////////////////////////////////////////////

// Claude 3rd attempt, works!!
///////////////////////////////////////////////////////////////////////////////
// Module Name: bin_to_bcd
// 
// Description:
// This module converts a 16-bit binary input to a 16-bit BCD (Binary-Coded Decimal) output.
// It uses the Double Dabble algorithm to perform the conversion over 17 clock cycles.
// The module can handle binary inputs up to 9999 (decimal). For inputs greater than 9999,
// it outputs an error code (0xEEEE) to indicate overflow.
//
// Inputs:
//   - bin_in  : 16-bit binary input to be converted
//   - clk     : System clock
//   - reset   : Active-high synchronous reset
//
// Outputs:
//   - bcd_out : 16-bit BCD output (4 digits, 4 bits each)
//
// Internal Signals:
//   - scratch     : 32-bit register used for the Double Dabble algorithm
//   - clkcnt      : 5-bit counter to track the conversion process (0-17)
//   - ready       : Indicates when the conversion is complete and output is valid
//   - overflow_error: Indicates when the input exceeds 9999
//
// Operation:
//   1. On reset, all registers are cleared and the module is set to ready state.
//   2. When a new binary input is received, the conversion process begins:
//      - The input is loaded into the least significant 16 bits of the scratch register.
//      - Over the next 16 clock cycles, the Double Dabble algorithm is applied.
//      - On the 17th cycle, the final BCD result is latched to the output.
//   3. If the input exceeds 9999, an error code (0xEEEE) is immediately output.
//
// Note: This module requires 17 clock cycles to complete a conversion for valid inputs.
//       The 'ready' signal can be used to determine when the output is valid.
///////////////////////////////////////////////////////////////////////////////
module bin_to_bcd(
    input  logic [15:0] bin_in,
    output logic [15:0] bcd_out,
    input  logic clk,
    input  logic reset
);

    logic [31:0] scratch, next_scratch;
    logic [4:0]  clkcnt, next_clkcnt;
    logic        ready, next_ready,overflow_error;
    logic [15:0] next_bcd_out;

    always_ff @(posedge clk) begin
        if (reset) begin
            scratch <= '0;
            bcd_out <= '0;
            ready   <= 1'b1;
            clkcnt  <= '0;
        end else begin
            scratch <= next_scratch;
            bcd_out <= next_bcd_out;
            ready   <= next_ready;
            clkcnt  <= next_clkcnt;
        end
    end

    always_comb begin
        next_scratch = scratch;
        next_bcd_out = bcd_out;
        next_ready   = ready;
        next_clkcnt  = clkcnt;

        if (bin_in > 9999) begin
            next_bcd_out = 16'hEEEE;
            overflow_error = 1;
            next_ready   = 1'b0;
            next_clkcnt  = '0;
            next_scratch = '0;
        end else begin
            overflow_error = 0;
            case (clkcnt)
                5'd0: begin
                    next_scratch = {16'b0, bin_in};
                    next_clkcnt = clkcnt + 1;
                    next_ready = 1'b0;
                end
                 5'd1, 5'd2, 5'd3, 5'd4, 5'd5, 5'd6, 5'd7, 5'd8, 5'd9, 5'd10, 5'd11, 5'd12, 5'd13, 5'd14, 5'd15, 5'd16: begin
                    // Add 3 to columns >= 5
                    if (next_scratch[31:28] >= 5) next_scratch[31:28] = next_scratch[31:28] + 3;
                    if (next_scratch[27:24] >= 5) next_scratch[27:24] = next_scratch[27:24] + 3;
                    if (next_scratch[23:20] >= 5) next_scratch[23:20] = next_scratch[23:20] + 3;
                    if (next_scratch[19:16] >= 5) next_scratch[19:16] = next_scratch[19:16] + 3;
                    
                    // Shift left
                    next_scratch = {next_scratch[30:0], 1'b0};
                    next_clkcnt = clkcnt + 1;
                end
                5'd17: begin
                    next_bcd_out = next_scratch[31:16];
                    next_ready = 1'b1;
                    next_clkcnt = '0;
                end
                default: begin
                    next_clkcnt = '0;
                end
            endcase
        end
    end

endmodule
