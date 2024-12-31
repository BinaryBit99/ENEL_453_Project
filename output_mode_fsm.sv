module output_mode_fsm (
    input  logic clk,
    input  logic reset,
    input  logic [1:0] mode_select,  // Two-bit input for mode selection
    output logic pwm_enable,
    output logic r2r_enable
);
    typedef enum logic [1:0] {
        OFF_MODE = 2'b00,
        PWM_MODE = 2'b01,
        R2R_MODE = 2'b10
    } statetype;

    statetype current_state, next_state;

    // State register
    always_ff @(posedge clk or posedge reset) begin
        if (reset)
            current_state <= OFF_MODE;
        else
            current_state <= next_state;
    end

    // Next state logic
    always_comb begin
        next_state = statetype'(mode_select);  // Directly use mode_select as the next state
    end

    // Output logic
    always_comb begin
        pwm_enable = 0;
        r2r_enable = 0;
        case (current_state)
            PWM_MODE:    pwm_enable = 1;
            R2R_MODE:    r2r_enable = 1;
            OFF_MODE:    ; // All outputs remain 0
        endcase
    end
endmodule