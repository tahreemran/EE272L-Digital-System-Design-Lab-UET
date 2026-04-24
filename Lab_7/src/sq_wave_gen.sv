/*
 * Square Wave Generator
 *
 * Berkeley Lab 3 spec:
 *   "Write a square wave sample generator in src/sq_wave_gen.v which takes
 *    a 125 MHz clock and the next_sample signal from the DAC, and outputs
 *    the code for it to play."
 *
 *   "next_sample indicates when the sq_wave_gen module should emit a new
 *    sample of the 440 Hz square wave. When next_sample is high, you should
 *    emit the next sample of the square wave on the code output on the NEXT
 *    rising clock edge. When next_sample is low, you should FREEZE the state
 *    of your module since the outside world isn't requesting a new sample."
 *
 *   "The square wave generator should output the codes for a 440 Hz square wave."
 *
 *   "Note: 125e6 / 1024 / 440 / 2 = 138.7 ~ 139"
 *     - 125e6 clock cycles/second
 *     - 1024  clock cycles/pulse window
 *     - 440   square cycles/second
 *     - 2     value partitions/square cycle (high half + low half)
 *   -> Toggle the square wave every 139 samples
 *
 *   "When the square wave is HIGH, code should be 562.
 *    When the square wave is LOW,  code should be 462.
 *    Avoid using the full code range 0-1023 to keep the volume low."
 *
 * Parameters:
 *   SAMPLES_PER_HALF_PERIOD - How many next_sample pulses per toggle (default 139)
 *
 * Digital Systems Lab - UET Lahore (2026), based on Berkeley EECS150 Lab 3
 */

module sq_wave_gen
#(
    parameter SAMPLES_PER_HALF_PERIOD = 139  // 125e6 / 1024 / 440 / 2 ≈ 139
)
(
    input  logic        clk,
    input  logic        rst,
    input  logic        next_sample,        // From DAC: request next sample
    output logic [9:0]  code                // To DAC: 10-bit PWM code
);

    localparam CODE_HIGH = 10'd562;   // Square wave high level (keeps volume safe)
    localparam CODE_LOW  = 10'd462;   // Square wave low level

    localparam CTR_BITS = $clog2(SAMPLES_PER_HALF_PERIOD + 1);

    // Tracks current square wave phase (high or low)
    logic sq_high;

    // Counts how many samples have elapsed in the current half-period
    logic [CTR_BITS-1:0] sample_count;

    always_ff @(posedge clk) begin
        if (rst) begin
            sq_high      <= 1'b1;         // Start high
            sample_count <= 0;
            code         <= CODE_HIGH;
        end else if (next_sample) begin
            // A new sample is being requested — advance state
            if (sample_count >= SAMPLES_PER_HALF_PERIOD - 1) begin
                // Half-period elapsed: toggle the square wave
                sample_count <= 0;
                sq_high      <= ~sq_high;
                code         <= sq_high ? CODE_LOW : CODE_HIGH;
                // Note: sq_high is CURRENT value before toggle, so:
                // if currently high -> going low -> emit CODE_LOW next
                // if currently low  -> going high -> emit CODE_HIGH next
            end else begin
                // Still within half-period: keep same code, just count
                sample_count <= sample_count + 1;
                code         <= sq_high ? CODE_HIGH : CODE_LOW;
            end
        end
        // If next_sample is low: freeze — no state change
    end

endmodule
