module pwm #( 
    parameter int WIDTH = 8
) (
    input  logic             clk,
    input  logic             reset,
    input  logic             enable,
    input  logic [WIDTH-1:0] duty_cycle,
    output logic             pwm_out
);

    logic [WIDTH-1:0] counter;

    always_ff @(posedge clk) begin
        if (reset)
            counter <= 0;
        else if (enable)
            counter <= counter + 1;
    end

    always_comb begin
        if (!enable)
            pwm_out = 1'b0;  // Output low when not enabled
        else if (duty_cycle == {WIDTH{1'b1}})
            pwm_out = 1'b1;
        else if (counter < duty_cycle)
            pwm_out = 1'b1;
        else 
            pwm_out = 1'b0; 
    end

endmodule
