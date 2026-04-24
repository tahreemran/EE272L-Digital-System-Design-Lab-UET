/*
 * Edge Detector Module
 * Parameterized-width rising edge detector.
 * Converts a low-to-high transition into exactly ONE clock-cycle-wide pulse.
 *
 * Berkeley Lab 3 spec:
 *   "We want to convert the low-to-high transition of a button press to a
 *    1 clock cycle wide pulse that the rest of our design can use."
 *   "The edge detector testbench tests that your edge_detector outputs a
 *    1 cycle wide pulse when its corresponding input transitions from 0 to 1."
 *
 * Digital Systems Lab - UET Lahore (2026), based on Berkeley EECS150 Lab 3
 */

module edge_detector
#(
    parameter WIDTH = 1
)
(
    input  logic             clk,
    input  logic [WIDTH-1:0] signal_in,   // Synchronized input signal(s)
    output logic [WIDTH-1:0] pulse_out    // 1-cycle pulse on rising edge
);

    // Register previous value
    logic [WIDTH-1:0] prev;

    always_ff @(posedge clk) begin
        prev <= signal_in;
    end

    // Rising edge detected: current=1, previous=0
    assign pulse_out = signal_in & ~prev;

endmodule
