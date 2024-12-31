module buzzer_pwm #(
    parameter int CLOCK_FREQ = 100_000_000, // System clock frequency in Hz
    parameter int BUZZER_FREQ = 1000        // Desired buzzer frequency in Hz
) (
    input  logic clk,    // Clock input
    input  logic reset,  // Active-high reset
    input  logic enable, // Active-high enable
    output logic pwm_out // PWM signal output for buzzer
);

    // Downcounter parameters
    localparam int PERIOD = CLOCK_FREQ / BUZZER_FREQ / 2; // Calculate the period for half the buzzer frequency

    logic zero;  // Signal to indicate when the counter reaches zero

    // Instantiate the downcounter to generate the desired frequency
    downcounter #(
        .PERIOD(PERIOD)
    ) downcounter_inst (
        .clk(clk),
        .reset(reset),
        .enable(enable),
        .zero(zero) // Pulses at the desired frequency
    );

    // Toggle pwm_out on each zero pulse
    always_ff @(posedge clk) begin
        if (reset)
            pwm_out <= 0;
        else if (zero)
            pwm_out <= ~pwm_out; // Toggle the PWM output
    end

endmodule
