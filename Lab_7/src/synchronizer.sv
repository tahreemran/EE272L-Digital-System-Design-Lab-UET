/*
 * Synchronizer Module
 * Parameterized-width two flip-flop synchronizer.
 * Safely brings asynchronous signals into the synchronous clock domain.
 *
 * Berkeley Lab 3 spec:
 *   "For synchronizing one bit, it is a pair of flip-flops connected serially.
 *    This module is parameterized by a WIDTH parameter which controls the
 *    number of one-bit signals to synchronize."
 *
 * Digital Systems Lab - UET Lahore (2026), based on Berkeley EECS150 Lab 3
 */

module synchronizer
#(
    parameter WIDTH = 1
)
(
    input  logic             clk,
    input  logic [WIDTH-1:0] async_in,   // Asynchronous input(s)
    output logic [WIDTH-1:0] sync_out    // Synchronized output(s)
);

    // First stage flip-flop(s)
    logic [WIDTH-1:0] ff1;

    always_ff @(posedge clk) begin
        ff1      <= async_in;
        sync_out <= ff1;
    end

endmodule
