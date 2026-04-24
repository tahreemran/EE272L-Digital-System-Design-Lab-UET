/*
 * DAC Module (PWM Generator as Digital-to-Analog Converter)
 *
 * Berkeley Lab 3 spec:
 *   "Let's make the pulse window 1024 cycles of the 125 MHz clock.
 *    This gives us 10 bits of resolution, and gives a PWM frequency of
 *    125MHz / 1024 = 122 kHz which is much greater than the filter cutoff."
 *
 *   "Implement the circuit in src/dac.v to drive the pwm output based on the
 *    code input. Assuming clock cycles are 0-indexed, the code is the clock
 *    cycle (up to and including) in the pulse window during which the pwm
 *    output should be high."
 *
 *   "code = 0 is an edge case where pwm should be 0 for the entire
 *    pulse window of 1024 cycles."
 *
 *   Examples:
 *     code = 0   -> pwm = 0 for all 1024 cycles
 *     code = 511 -> pwm = 1 for cycles 0-511, 0 for cycles 512-1023
 *     code = 1023-> pwm = 1 for entire pulse window
 *
 *   "The DAC should also output a signal called next_sample to tell the
 *    outside world that it can safely change the code before another pulse
 *    window begins. next_sample should be 1 on the final cycle of the
 *    pulse window."
 *
 * Parameters:
 *   CYCLES_PER_WINDOW - Pulse window size (default 1024, set to 8 in testbench)
 *
 * Digital Systems Lab - UET Lahore (2026), based on Berkeley EECS150 Lab 3
 */

module dac
#(
    parameter CYCLES_PER_WINDOW = 1024
)
(
    input  logic                          clk,
    input  logic                          rst,
    input  logic [$clog2(CYCLES_PER_WINDOW)-1:0] code,  // PWM code (10 bits for 1024)
    output logic                          pwm_out,       // PWM output to audio
    output logic                          next_sample    // High on last cycle of window
);

    localparam CTR_BITS = $clog2(CYCLES_PER_WINDOW);

    logic [CTR_BITS-1:0] counter;

    // Counter: 0 to CYCLES_PER_WINDOW-1
    always_ff @(posedge clk) begin
        if (rst) begin
            counter <= 0;
        end else begin
            if (counter >= CYCLES_PER_WINDOW - 1)
                counter <= 0;
            else
                counter <= counter + 1;
        end
    end

    // next_sample: high on the LAST cycle of the pulse window
    assign next_sample = (counter == CYCLES_PER_WINDOW - 1);

    // pwm_out:
    //   code = 0   -> always 0 (special case)
    //   code > 0   -> high while counter <= code-1 (i.e., for 'code' cycles)
    // Berkeley: "code is the clock cycle up to and including in which pwm is high"
    // So pwm is high for cycles 0..code (inclusive), meaning counter <= code
    // BUT code=0 is special: pwm=0 entire window.
    assign pwm_out = (code != 0) && (counter <= code);

endmodule
