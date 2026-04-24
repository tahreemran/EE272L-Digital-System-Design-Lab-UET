/*
 * Debouncer Module
 * Parameterized-width debouncer for button inputs.
 *
 * Berkeley Lab 3 spec:
 *   "The debouncer module should consist of:
 *    - Sample Pulse Generator: outputs a 1 every SAMPLE_CNT_MAX clock cycles
 *    - Saturating Counter: counts up to and including PULSE_CNT_MAX (and saturates)
 *
 *   Circuit behavior:
 *    - All counters start at 0
 *    - If sample pulse emits 1 on a clock edge AND input signal is 1 ->
 *      increment saturating counter; else reset it to 0
 *    - Once saturating counter reaches PULSE_CNT_MAX, hold indefinitely
 *      until sampled input signal becomes 0
 *    - debounced_signal = (saturating_counter == PULSE_CNT_MAX)
 *
 *   Note: input to debouncer is the OUTPUT of the synchronizer.
 *   You can use the same sample pulse generator for all input signals,
 *   but have a SEPARATE saturating counter per input signal."
 *
 * Parameters:
 *   WIDTH         - Number of button signals to debounce
 *   SAMPLE_CNT_MAX - How many clock cycles between samples (default 65000)
 *   PULSE_CNT_MAX  - How many samples high before output goes high (default 200)
 *
 * Digital Systems Lab - UET Lahore (2026), based on Berkeley EECS150 Lab 3
 */

module debouncer
#(
    parameter WIDTH         = 1,
    parameter SAMPLE_CNT_MAX = 65000,
    parameter PULSE_CNT_MAX  = 200
)
(
    input  logic             clk,
    input  logic [WIDTH-1:0] signal_in,        // From synchronizer output
    output logic [WIDTH-1:0] debounced_signal  // Clean, stable button signal
);

    // -----------------------------------------------------------------------
    // Sample Pulse Generator
    // Counts up to SAMPLE_CNT_MAX and emits a 1-cycle pulse
    // -----------------------------------------------------------------------
    localparam SAMPLE_CTR_BITS = $clog2(SAMPLE_CNT_MAX + 1);

    logic [SAMPLE_CTR_BITS-1:0] sample_counter;
    logic                        sample_pulse;

    always_ff @(posedge clk) begin
        if (sample_counter >= SAMPLE_CNT_MAX - 1) begin
            sample_counter <= 0;
        end else begin
            sample_counter <= sample_counter + 1;
        end
    end

    assign sample_pulse = (sample_counter == SAMPLE_CNT_MAX - 1);

    // -----------------------------------------------------------------------
    // Saturating Counter (one per input bit)
    // -----------------------------------------------------------------------
    localparam PULSE_CTR_BITS = $clog2(PULSE_CNT_MAX + 1);

    logic [PULSE_CTR_BITS-1:0] pulse_counter [WIDTH-1:0];

    genvar i;
    generate
        for (i = 0; i < WIDTH; i = i + 1) begin : sat_counters
            always_ff @(posedge clk) begin
                if (sample_pulse) begin
                    if (signal_in[i]) begin
                        // Input is high: increment, saturate at PULSE_CNT_MAX
                        if (pulse_counter[i] < PULSE_CNT_MAX)
                            pulse_counter[i] <= pulse_counter[i] + 1;
                    end else begin
                        // Input is low: reset counter
                        pulse_counter[i] <= 0;
                    end
                end
            end

            // Output: 1 only when counter has reached PULSE_CNT_MAX
            assign debounced_signal[i] = (pulse_counter[i] == PULSE_CNT_MAX);
        end
    endgenerate

endmodule
