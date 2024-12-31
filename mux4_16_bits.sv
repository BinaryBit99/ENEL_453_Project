
module menu_FSM (
    input  logic        clk,
    input  logic        rst,
    input  logic        first_select,
    input  logic        second_select,
    input  logic        third_select,
    input  logic        fourth_select,
    input  logic        down_button_select,
    input  logic [15:0] scaled_adc_data,  
    input  logic [15:0] ave_xadc,  
    input  logic [15:0] xadc_raw, 
    input  logic [7:0]  pwm_raw,  
    input  logic [11:0] reg_switches_in,
    input  logic [7:0]  r2r_raw,
    input  logic [11:0] pwm_avg,
    input  logic [15:0] pwm_scaled,
    input  logic [11:0] r2r_avg,
    input  logic [15:0] r2r_scaled,
    input  logic [7:0]  pwm_successive_raw,
    input  logic [7:0]  r2r_successive_raw_in,
    output logic [15:0] mux_out,
    output logic [3:0]  decimal_point
);

    // State enumeration for all possible combinations
    typedef enum logic [4:0] {
        STATE_0000 = 5'd0,  // reg_switches
        STATE_0010 = 5'd1,  // in1
        STATE_0011 = 5'd2,  // in2
        STATE_0100 = 5'd3,  // in7
        STATE_0101 = 5'd4,  // analog_pwm_avg
        STATE_0110 = 5'd5,  // in0
        STATE_0111 = 5'd6,  // analog_pwm
        STATE_1000 = 5'd7,  // pwm_successive
        STATE_1001 = 5'd8,  // r2r_successive_raw
        STATE_1010 = 5'd9,  // in7
        STATE_1011 = 5'd10, // analog_r2r_avg
        STATE_1100 = 5'd11, // analog_r2r_raw
        STATE_1101 = 5'd12, // analog_r2r_avg
        STATE_1110 = 5'd13, // analog_pwm_avg
        STATE_1111 = 5'd14  // in9
    } state_t;

    state_t current_state, next_state;
    logic [3:0] select_inputs;
    
    // Zero-extend all the smaller inputs
    logic [15:0] analog_pwm;
    logic [15:0] reg_switches;
    logic [15:0] analog_r2r_raw;
    logic [15:0] analog_pwm_avg;
    logic [15:0] analog_r2r_avg;
    logic [15:0] pwm_successive;
    logic [15:0] r2r_successive_raw;
    
    // Input processing
    assign select_inputs = {fourth_select, third_select, second_select, first_select};
    
    // Signal extensions
    assign pwm_successive = {{8{1'b0}}, pwm_successive_raw};
    assign analog_pwm = {{8{1'b0}}, pwm_raw};     
    assign analog_pwm_avg = {{4{1'b0}}, pwm_avg};
    assign reg_switches = {{4{1'b0}}, reg_switches_in};    
    assign analog_r2r_avg = {{4{1'b0}}, r2r_avg};
    assign analog_r2r_raw = {{8{1'b0}}, r2r_raw}; 
    assign r2r_successive_raw = {{8{1'b0}}, r2r_successive_raw_in};

    // State register
    always_ff @(posedge clk) begin
        if (rst)
            current_state <= STATE_0000;
        else
            current_state <= next_state;
    end

    // Next state logic based on select inputs
    always_comb begin
        // Default: maintain current state
        next_state = current_state;
        
        // State transitions based on select inputs
        case (select_inputs)
            4'b0000: next_state = STATE_0000;
            4'b0010: next_state = STATE_0010;
            4'b0011: next_state = STATE_0011;
            4'b0100: next_state = STATE_0100;
            4'b0101: next_state = STATE_0101;
            4'b0110: next_state = STATE_0110;
            4'b0111: next_state = STATE_0111;
            4'b1000: next_state = STATE_1000;
            4'b1001: next_state = STATE_1001;
            4'b1010: next_state = STATE_1010;
            4'b1011: next_state = STATE_1011;
            4'b1100: next_state = STATE_1100;
            4'b1101: next_state = STATE_1101;
            4'b1110: next_state = STATE_1110;
            4'b1111: next_state = STATE_1111;
            default: next_state = current_state;
        endcase
        
        // Special case for down_button_select
        if (down_button_select)
            next_state = STATE_1111; // Maps to in9 output
    end

    // Output logic based on current state
    // IMPORTANT NOTE: The REASON why we have cases where the selects are the same is because successive/regular PWM/R2R are SHARING the same averager/scaling modules
    // Remember, the reason why we did this was to ensure we maintained a practice of reusability; we used binary_reg_filter as a means of processing the successive/regular PWM/R2R through the averaged/scaled modules.
    // If still confused, start from top level, and follow schematic.
    
    always_comb begin
        // Default outputs
        mux_out = 16'h0000;
        decimal_point = 4'b0000;
        
        case (current_state)
            STATE_0000: begin
                mux_out = reg_switches;
                decimal_point = 4'b0000;
            end
            STATE_0010: begin
                mux_out = ave_xadc;             // Averaged, but not scaled, XADC value.
                decimal_point = 4'b0000;
            end
            STATE_0011: begin   
                mux_out = xadc_raw;             // Raw (not averaged nor scaled) XADC value.
                decimal_point = 4'b0000;
            end
            STATE_0100: begin
                mux_out = pwm_scaled;
                decimal_point = 4'b1000;
            end
            STATE_0101: begin
                mux_out = analog_pwm_avg;
                decimal_point = 4'b0000;
            end
            STATE_0110: begin
                mux_out = scaled_adc_data;      // Averaged & Scaled XADC value.
                decimal_point = 4'b1000;
            end
            STATE_0111: begin
                mux_out = analog_pwm;
                decimal_point = 4'b0000;
            end
            STATE_1000: begin
                mux_out = pwm_successive;
                decimal_point = 4'b0000;
            end
            STATE_1001: begin
                mux_out = r2r_successive_raw;
                decimal_point = 4'b0000;
            end
            STATE_1010: begin
                mux_out = pwm_scaled;
                decimal_point = 4'b1000;
            end
            STATE_1011: begin
                mux_out = analog_r2r_avg;
                decimal_point = 4'b0000;
            end
            STATE_1100: begin
                mux_out = analog_r2r_raw;
                decimal_point = 4'b0000;
            end
            STATE_1101: begin
                mux_out = analog_r2r_avg;
                decimal_point = 4'b0000;
            end
            STATE_1110: begin
                mux_out = analog_pwm_avg;
                decimal_point = 4'b0000;
            end
            STATE_1111: begin
                mux_out = r2r_scaled;
                decimal_point = 4'b1000;
            end
            default: begin                      // NO inferred latches thanks to this default statement.
                mux_out = 16'h0000;
                decimal_point = 4'b0000;
            end
        endcase
    end

endmodule