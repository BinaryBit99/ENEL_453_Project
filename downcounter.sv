
module downcounter #(
    parameter int PERIOD = 1000  // Number to count down from, must be positive
) (
    input  logic clk,    // Clock input
    input  logic reset,  // Active-high reset
    input  logic enable, // Active-high enable
    output logic zero    // Pulses high for one clock cycle when counter reaches zero
);

    // Calculate the number of bits needed to represent PERIOD
    localparam int COUNT_WIDTH = $clog2(PERIOD);

    logic [COUNT_WIDTH-1:0] count;

    always_ff @(posedge clk) begin
        if (reset) begin
            count <= PERIOD - 1;
            zero  <= 0;
        end else if (enable) begin
            if (count == 0) begin
                count <= PERIOD - 1;
                zero  <= 1;
            end else begin
                count <= count - 1;
                zero  <= 0;
            end
        end else
            zero <= 0;
    end

endmodule