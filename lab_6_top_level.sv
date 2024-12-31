module top_level (
    input  logic   clk,                     // White space and comments used consistently throughout code.
    input  logic   reset,                   // Input/Output names changed according to their functionality.
    input  logic   [11:0] switches_inputs,
    
    input  logic   hex_bin,                 // Logic input to convert between BCD/hex ; note that by default things will be displayed in BCD (see inside seven segment module).
    
    input  logic first_select,              // 4 total selects below enable for 2^4 = 16 options; note that the selects are gray coded to optimize timing between sub-modes (e.g., R2R avg -> R2R avg & scaling)
    input  logic second_select,             // NOTE: Karnaugh maps were used to determine the effecient combinational logic needed to 'encode' these selects
    input  logic third_select,
    input  logic fourth_select,
    
    input          vauxp15,                 // XADC inputs
    input          vauxn15,
    
    input          PWM_duty_in,
    input logic    r2r_binary_scaled_enable,
    input          R2R_duty_in,
    
    output logic   CA, CB, CC, CD, CE, CF, CG, DP,  // These control which panel is ON for each digit.
    output logic   AN1, AN2, AN3, AN4,       // These control the current four each of four digits in seven seg.
    output logic [15:0] led,                // Simple LEDs; these are used for successive output.
    
    output logic   pwm_waveform_out,         // PWM waveform output
    output logic [7:0] R2R_waveform_out     // R2R waveform output
);
    // Internal signal declarations
    
    logic [2:0] mode_select;
    logic [7:0] for_seven_seg;
    logic pwm_out;
    logic [7:0] R2R_out;
    logic [15:0] led;
    logic        ready;
    logic [7:0]       V_analog_in;
    logic [7:0]     V_analog_in_r2r;
    logic [15:0] data;
   
    logic [15:0] scaled_adc_data;
    
    logic [7:0] r2r_comparator_result;
    logic [11:0] r2r_avg_data;
    logic [15:0] r2r_scaled_data;
   
    logic [15:0] ave_xadc;
    logic [15:0] pwm_scaled_data;
    logic [11:0] pwm_ave_data;
    logic [6:0]  daddr_in;
    logic [7:0] duty_cycle;
    
    
    logic        enable;
    logic        eos_out;
    logic       zero;
    logic [7:0] r2r_successive_out;
    logic        busy_out;
    logic        ready_pulse;
    logic [15:0] bcd_value, mux_out;
    logic [7:0] comparator_result;
    logic [7:0] pwm_successive_out;
    logic r2r_enable; //buzzer_enable;
    logic pwm_enable;
    logic pwm_out_internal;
    logic pwm_out_int;
    logic [7:0] current_reference;
    logic enable_pwm_successive;
    logic enable_r2r_successive;
    logic [7:0] R2R_out_internal;
    //logic [1:0] buzzer_mode;  // New signal for buzzer mode control
    logic triangle_en;
    logic [7:0] current_R2R_value;
    logic [7:0] captured_pwm_successive;
    
    logic [7:0] R2R_output;
    logic [7:0] PWM_output;
    // Constants
    localparam CHANNEL_ADDR = 7'h1f;
    
    
    assign mode_select = {third_select, fourth_select}; // iterative test
    
    assign led[7:0] = captured_pwm_successive;
    
    
    
    assign led[10] = pwm_waveform_out;
    assign led[9] = PWM_duty_in;
    
   
    
    
    successive_on_controller SUCCESSIVE_ENABLED (
        .fourth_select(fourth_select),
        .third_select(third_select),
        .second_select(second_select),
        .down_button(r2r_binary_scaled_enable),
        .first_select(first_select),
        .enable_pwm_successive(enable_pwm_successive),
        .enable_r2r_successive(enable_r2r_successive)
    );
    
    pwm_sar_controller PWM_successive_controller (
        .clk(clk),
        .reset(reset),
        //.converting(converting),
        .enable(enable_pwm_successive),
        //.for_seven_seg(for_seven_seg),
        .PWM_duty_in(PWM_duty_in),
        //.all_states(all_states),
        .current_duty_cycle(current_reference),
        //.bit_counter(bit_counter),
        .captured_duty_cycle(captured_pwm_successive)
        //.done(1'b0)
    );
    
   
    
    binary_regular_filter BINARY_REG_FILTER (
        .fourth_select(fourth_select),
        .third_select(third_select),
        .second_select(second_select),
        .first_select(first_select),
        .V_analog_in_r2r(V_analog_in_r2r),
        .comparator_result(comparator_result),
        .r2r_successive_out(r2r_successive_out),
        .captured_pwm_successive(captured_pwm_successive),
        .down_button(r2r_binary_scaled_enable),
        .R2R_output(R2R_output),
        .PWM_output(PWM_output)
    );
    
    r2r_sar_controller R2R_successive_controller (
        .clk(clk),
        .reset(reset),
        .enable(enable_r2r_successive), // leave as 0 for now, deal with logic later.
        .R2R_duty_in(R2R_duty_in),
        .current_value_internal(current_R2R_value),
        .captured_R2R_value(r2r_successive_out),
        .done(1'b0)
   );
     
    comparator COMPARATOR (
        .clk(clk),
        .reset(reset),
        .comparator_output(PWM_duty_in),
        .current_duty_cycle(R2R_out_internal),
        .captured_duty_cycle(comparator_result)
    );
    
    comparator COMPARATOR_R2R (
        .clk(clk),
        .reset(reset),
        .comparator_output(R2R_duty_in),
        .current_duty_cycle(R2R_out_internal),
        .captured_duty_cycle(V_analog_in_r2r)
    );
    
    // XADC Instantiation
    xadc_wiz_0 XADC_INST (
        .di_in(16'h0000),
        .daddr_in(CHANNEL_ADDR),
        .den_in(enable),
        .dwe_in(1'b0),
        .drdy_out(ready),
        .do_out(data),
        .dclk_in(clk),
        .reset_in(reset),
        .vp_in(1'b0),
        .vn_in(1'b0),
        .vauxp15(vauxp15),
        .vauxn15(vauxn15),
        .channel_out(),
        .eoc_out(enable),
        .alarm_out(),
        .eos_out(eos_out),
        .busy_out(busy_out)
    );
    

    // Instantiate the FSM
    FSM_parent parent (
        .clk(clk),
        .reset(reset),
        .first_select(first_select),
        .second_select(second_select),
        .third_select(third_select),
        .down_button(r2r_binary_scaled_enable),
        .fourth_select(fourth_select),   
        .triangle_en(triangle_en),
        .pwm_enable(pwm_enable),
        .r2r_enable(r2r_enable)
    );

   

    r2r_processing R2R_PROC (
        .clk(clk),
        .reset(reset),
        .data(R2R_output),
        .ave_data(r2r_avg_data),
        .scaled_r2r_data(r2r_scaled_data)
    );
    
    // PWM ADC instance (internally timed)
    pwm_adc_processing PWM_ADC (
        .clk(clk),
        .reset(reset),
        .pwm_in(PWM_output),
        .ave_data(pwm_ave_data),
        .scaled_adc_data(pwm_scaled_data),
        .conversion_done()         // Connect if needed
    );


    r2r_pwm_waveform_enable ALL_THREE_MUX (
        .r2r_enable(r2r_enable),
        .pwm_out_internal(pwm_out_internal),
        .pwm_enable(pwm_enable),
        .R2R_out_internal(R2R_out_internal),
        .scaled_adc_data(scaled_adc_data),
        //.led(led[15:0]),
        .pwm_out(pwm_waveform_out),
        .R2R_out(R2R_waveform_out)
    );
    
 
    // Rest of your existing module instantiations
    adc_processing ADC_PROC (
        .clk(clk),
        .reset(reset),
        .ready(ready),
        .data(data),
        .ave_data(ave_xadc),
        .scaled_adc_data(scaled_adc_data)
        //.ready_pulse(ready_pulse)
    );
    
    
    logic [3:0] decimal_pt;
    
    menu_FSM menu_module (
        .scaled_adc_data(scaled_adc_data),        // Avg. + Scaled XADC
        .ave_xadc(ave_xadc),                    // Avg. XADC
        .xadc_raw(data[15:4]),                  // XADC raw
        .pwm_raw(comparator_result),            // PWM raw
        .reg_switches_in(switches_inputs),      // switches
        .r2r_raw(V_analog_in_r2r),                  // r2r raw
        .pwm_avg(pwm_ave_data),                 // pwm avg. data
        .pwm_scaled(pwm_scaled_data),          // pwm scaled
        .r2r_avg(r2r_avg_data),
        .r2r_scaled(r2r_scaled_data),
        .pwm_successive_raw(captured_pwm_successive), //binary approximation start:
        .r2r_successive_raw_in(r2r_successive_out),
        
        .clk(clk),
        .rst(reset),
        
        .first_select(first_select),        // LOGICAL selects to CHOOSE what passes through to seven segment module (i.e., what selects between say, scaled_adc_data or ave_xadc, etc.)
        .second_select(second_select),
        .third_select(third_select),
        .fourth_select(fourth_select),
        .down_button_select(r2r_binary_scaled_enable),
        
        .mux_out(mux_out),                  // This will get outputted to the seven segment module.
        .decimal_point(decimal_pt)
    );
  
    seven_segment_display_subsystem SEVEN_SEGMENT_DISPLAY (
        .clk(clk), 
        .hex_bin(hex_bin),
   
        .first_select(first_select),            // The selects feed in here in order to aid with the logic of making the segment all zeros.
        .second_select(second_select),
        .third_select(third_select),
        .fourth_select(fourth_select),
        
        .reset(reset), 
        .mux_in(mux_out),

        .decimal_point(decimal_pt),
        .CA(CA), .CB(CB), .CC(CC), .CD(CD), 
        .CE(CE), .CF(CF), .CG(CG), .DP(DP), 
        .AN1(AN1), .AN2(AN2), .AN3(AN3), .AN4(AN4)
    );
        
    waveform_generator #(
        .WIDTH(8),
        .CLOCK_FREQ(200_000_000),           // 200MHz clock (5% bonus)
        .WAVE_FREQ(100)                         // Frequency set to 100 Hz to ensure averager module outputs good values.
    ) waveform_generator (
        .clk(clk),
        .reset(reset),
        .enable(triangle_en),
        .current_reference(current_reference), //digitized reference feeding in
        .first_select(first_select),            // selects for combinational logic
        .second_select(second_select),
        .third_select(third_select),
        .fourth_select(fourth_select),
        .r2r_binary_scaled_enable(r2r_binary_scaled_enable),
        .current_reference_r2r(current_R2R_value),
        .pwm_out(pwm_out_internal),
        .R2R_out(R2R_out_internal)
    );
    
    
endmodule