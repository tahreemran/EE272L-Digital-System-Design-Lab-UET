/*
 * Button Parser Module
 * Chains: synchronizer → debouncer → edge_detector
 *
 * Berkeley Lab 3 spec:
 *   "Look at src/button_parser.v which combines the synchronizer,
 *    debouncer, and edge detector in a chain."
 *
 * The chain solves three problems:
 *   1. Synchronizer  - brings async button signal into clock domain safely
 *   2. Debouncer     - filters mechanical bounce; only passes stable signal
 *   3. Edge Detector - converts stable press into single 1-cycle pulse
 *
 * Parameters:
 *   WIDTH         - Number of button signals
 *   SAMPLE_CNT_MAX - Debouncer sample rate (65000 per lab spec)
 *   PULSE_CNT_MAX  - Debouncer saturation count (200 per lab spec)
 *
 * Digital Systems Lab - UET Lahore (2026), based on Berkeley EECS150 Lab 3
 */

module button_parser
#(
    parameter WIDTH          = 1,
    parameter SAMPLE_CNT_MAX = 65000,
    parameter PULSE_CNT_MAX  = 200
)
(
    input  logic             clk,
    input  logic [WIDTH-1:0] button_in,   // Raw async button inputs
    output logic [WIDTH-1:0] button_pulse // Clean single-cycle pulse per press
);

    // Stage 1: Synchronize async button signals into clock domain
    logic [WIDTH-1:0] sync_out;

    synchronizer #(
        .WIDTH (WIDTH)
    ) sync_inst (
        .clk      (clk),
        .async_in (button_in),
        .sync_out (sync_out)
    );

    // Stage 2: Debounce - filter mechanical bounce using saturating counter
    logic [WIDTH-1:0] debounced;

    debouncer #(
        .WIDTH          (WIDTH),
        .SAMPLE_CNT_MAX (SAMPLE_CNT_MAX),
        .PULSE_CNT_MAX  (PULSE_CNT_MAX)
    ) deb_inst (
        .clk              (clk),
        .signal_in        (sync_out),
        .debounced_signal (debounced)
    );

    // Stage 3: Edge detect - one pulse per button press, regardless of hold time
    edge_detector #(
        .WIDTH (WIDTH)
    ) edge_inst (
        .clk       (clk),
        .signal_in (debounced),
        .pulse_out (button_pulse)
    );

endmodule
