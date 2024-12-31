// Sawtooth PWM Generator Module
// Generates a sawtooth waveform using PWM by adjusting the duty cycle.



// Sawtooth PWM and R2R Generator Module
// Generates a sawtooth waveform using PWM by adjusting the duty cycle.
module waveform_generator
    #(
        parameter int WIDTH = 8,                   // Bit width for duty_cycle
        parameter int CLOCK_FREQ = 200_000_000,    // System clock frequency in Hz      UPDATE: Adjusted to 200MHz from 100MHz as part of 5% bonus.
        parameter real WAVE_FREQ = 1.0             // Desired sawtooth wave frequency in Hz
    )
    (
        input  logic clk,      // System clock (100 MHz)
        input  logic reset,    // Active-high reset
        input  logic enable,   // Active-high enable
        input  logic first_select,
        input  logic second_select,
        input  logic third_select,
        input  logic fourth_select,
        input  logic [7:0] current_reference,
        input  logic [7:0] current_reference_r2r,
        input  r2r_binary_scaled_enable,
        output logic pwm_out,  // PWM output signal
        output logic [WIDTH-1:0] R2R_out // R2R ladder output
    );
    // Calculate maximum duty cycle value based on WIDTH
    localparam int MAX_DUTY_CYCLE = (2 ** WIDTH) - 1;  // 255 for WIDTH = 8
    // Total steps for duty_cycle (only up)
    localparam int TOTAL_STEPS = MAX_DUTY_CYCLE + 1;   // 256 steps for sawtooth
    // Calculate downcounter PERIOD to achieve desired wave frequency
    localparam int DOWNCOUNTER_PERIOD = integer'(CLOCK_FREQ / (WAVE_FREQ * TOTAL_STEPS));
    // Ensure DOWNCOUNTER_PERIOD is positive
    initial begin
        if (DOWNCOUNTER_PERIOD <= 0) begin
            $error("DOWNCOUNTER_PERIOD must be positive. Adjust CLOCK_FREQ or WAVE_FREQ.");
        end
    end
    // Internal signals
    logic zero;                   // Output from downcounter (enables duty_cycle update)
    logic r2r_binary_select;
    logic [WIDTH-1:0] R2R_out_int;
    logic pwm_reg_select;
    logic [WIDTH-1:0] duty_cycle; // Duty cycle value for PWM
    logic pwm_binary_select;
    assign R2R_out_int = duty_cycle; // R2R ladder resistor circuit automatically generates the analog voltage
    logic [WIDTH-1:0] mux_out;
    assign pwm_binary_select = (fourth_select & ~third_select & ~first_select) | (fourth_select & second_select & ~first_select);
    assign r2r_binary_select = (fourth_select & ~third_select & first_select) | (r2r_binary_scaled_enable);
    assign pwm_reg_select = (third_select & ~second_select) | (third_select & first_select);
    
    assign mux_out = pwm_binary_select ? current_reference : R2R_out_int;
    
    assign R2R_out = r2r_binary_select ? current_reference_r2r : R2R_out_int;
    
    //assign mux_out = pwm_binary_select ? current_reference : R2R_out;
    // Instantiate downcounter module
    downcounter #(
        .PERIOD(DOWNCOUNTER_PERIOD)  // Set downcounter period based on calculations
    ) downcounter_inst (
        .clk(clk),
        .reset(reset),
        .enable(enable),  // Use the enable input
        .zero(zero)       // Pulses high every DOWNCOUNTER_PERIOD clock cycles
    );
    // Duty cycle counter logic for sawtooth wave
    always_ff @(posedge clk) begin
        if (reset) begin
            duty_cycle <= 0;    // Initialize duty_cycle to 0 on reset
        end else if (enable) begin
            if (zero) begin
                if (duty_cycle == MAX_DUTY_CYCLE) begin
                    duty_cycle <= 0;  // Reset to 0 when reaching peak
                end else begin
                    duty_cycle <= duty_cycle + 1; // Keep counting up
                end
            end
        end else begin
            duty_cycle <= 0;    // Reset duty_cycle when enable is low
        end
    end
    // Instantiate PWM module
    pwm #(
        .WIDTH(WIDTH)
    ) pwm_inst (
        .clk(clk),
        .reset(reset),
        .enable(enable),    // Use the enable input
        .duty_cycle(mux_out),
        .pwm_out(pwm_out)   // Output PWM signal
    );
endmodule
