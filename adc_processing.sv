// Calculation: This scales FFFFh to 270Fh (i.e. 9999d)
//    mVolts = ave_data/(2^16 - 1) * 9999 = ave_data * 0.152575
//    mVolts ~ ave_data * 1250/2^13 = (ave_data) * 1250 >> 13
// NOTE: The 7-seg display will display in millivolts, 
//       i.e. 9999 is 0.9999 V or 999.9 mV
//  3.300 instead of 0.9999!
//       place the decimal point in the correct place!
//scaled_adc_data <= (ave_data*1250) >> 13; // 1250/(2^13) ~ 0.15257495994506752117
//scaled_adc_data <= (ave_data*79993) >> 19; // 9999/(2^16 - 1) = 0.15257495994506752117
                                             // 0.15257495994506752117 ~ 79993/2^19 (more accurate than previous scaling)
// Perform the calculation with wider intermediate result to avoid 32-bit overflow error

// Since FFFF means we are at 3.300V, we can keep (2^16 -1) as part of above calc., but instead multiply by 3300 (3.300) - add d.p. later.
// So, we get that, V = ave_data/(2^16-1) * 3300 = ave_data * 0.0503547723 ~ (ave_data * 52) >> 10

module adc_processing #(
    parameter int SCALING_FACTOR = 52,          // Default scaling factor changed because for lab 7 we require 3.300V NOT 0.9999V/999.9mV
    parameter int SHIFT_FACTOR   = 10
) (
    input  logic        clk,
    input  logic        reset,
    input  logic        ready,
    input  logic [15:0] data,
    output logic [15:0] scaled_adc_data,
    output logic [15:0] ave_data,
    //output logic        ready_pulse
);
    logic [15:0] ave_data;
    logic        ready_r;
    logic [15:0] scaled_adc_data_pipe;

    // Calculate the bit width for the scaling factor
    localparam int SCALING_FACTOR_WIDTH = $clog2(SCALING_FACTOR) + 1;
    
    // Calculate the intermediate width dynamically based on ave_data (16-bits) and scaling factor
    localparam int INTERMEDIATE_WIDTH = 16 + SCALING_FACTOR_WIDTH;

    // Define the intermediate register with the required bit width, to avoid 32-bit overflow on intermediate calculation 
    logic [INTERMEDIATE_WIDTH-1:0] scaled_adc_data_temp; 

    // Pulser 
    always_ff @(posedge clk)
        if (reset)
            ready_r <= 0;
        else
            ready_r <= ready;
       
    assign ready_pulse = ~ready_r & ready; // generate 1-clk pulse when ready goes high

    averager #(
        .power(8), // 2**(power) samples, default is 2**8 = 256 samples (4^4 = 256 samples, adds 4 bits of ADC resolution)
        .N(16)     // # of bits to take the average of
    ) AVERAGER (
        .reset(reset),
        .clk(clk),
        .EN(ready_pulse),
        .Din(data),
        .Q(ave_data)
    );
    
    always_ff @(posedge clk) begin
        if (reset) begin
            scaled_adc_data <= 0;
            scaled_adc_data_temp <= 0;
            scaled_adc_data_pipe <= 0;
        end
        else if (ready_pulse) begin
            scaled_adc_data_temp <= ave_data * SCALING_FACTOR;            // Use a wider temp register to avoid 32-bit overflow error
            scaled_adc_data_pipe <= scaled_adc_data_temp >> SHIFT_FACTOR; // Shift right by 19 after the multiplication
            scaled_adc_data      <= scaled_adc_data_pipe; // Additional register faciliates pipelining, if needed, for
        end                                               // higher clock frequencies. Costs are an additional register
    end                                                   // and an additional 1 clk cycle latency.    
endmodule