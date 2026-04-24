/*
 * Testbench: dac (PWM Generator as DAC)
 *
 * Berkeley Lab 3 spec:
 *   "Run the testbench in sim/dac_tb.v to verify this functionality -
 *    check the waveform too."
 *   "Note: the testbench sets CYCLES_PER_WINDOW to 8 to make the simulation
 *    easier to debug."
 *
 * Verifies:
 *   - code=0: pwm is 0 for the entire window
 *   - code=3: pwm is 1 for cycles 0-3, 0 for cycles 4-7 (half of 8)
 *   - code=7: pwm is 1 for entire window
 *   - next_sample is high on last cycle of each window
 *
 * Digital Systems Lab - UET Lahore (2026), based on Berkeley EECS150 Lab 3
 */

`timescale 1ns/1ns

module dac_tb;

    // Berkeley: "testbench sets CYCLES_PER_WINDOW to 8"
    localparam CYCLES_PER_WINDOW = 8;
    localparam CLK_PERIOD        = 8;

    logic                               clk;
    logic                               rst;
    logic [$clog2(CYCLES_PER_WINDOW)-1:0] code;
    logic                               pwm_out;
    logic                               next_sample;

    dac #(
        .CYCLES_PER_WINDOW (CYCLES_PER_WINDOW)
    ) dut (
        .clk         (clk),
        .rst         (rst),
        .code        (code),
        .pwm_out     (pwm_out),
        .next_sample (next_sample)
    );

    initial clk = 0;
    always #(CLK_PERIOD/2) clk = ~clk;

    // Count high cycles in one window and check next_sample placement
    task check_window;
        input [$clog2(CYCLES_PER_WINDOW)-1:0] test_code;
        input integer expected_high_cycles;
        input string label;
        integer high_count;
        integer ns_count;
        integer i;
        begin
            code        = test_code;
            high_count  = 0;
            ns_count    = 0;
            // Wait for window start (next_sample just fired, so counter = 0 next)
            @(posedge next_sample);
            @(posedge clk); #1;

            for (i = 0; i < CYCLES_PER_WINDOW; i = i + 1) begin
                if (pwm_out)     high_count++;
                if (next_sample) ns_count++;
                @(posedge clk); #1;
            end

            if (high_count == expected_high_cycles)
                $display("PASS [%s] code=%0d: pwm high for %0d cycles (expected %0d)",
                         label, test_code, high_count, expected_high_cycles);
            else
                $display("FAIL [%s] code=%0d: pwm high for %0d cycles (expected %0d)",
                         label, test_code, high_count, expected_high_cycles);

            if (ns_count == 1)
                $display("PASS [%s]: next_sample occurred exactly once per window", label);
            else
                $display("FAIL [%s]: next_sample occurred %0d times (expected 1)", label, ns_count);
        end
    endtask

    initial begin
        rst  = 1;
        code = 0;
        repeat(3) @(posedge clk);
        rst = 0;
        repeat(2) @(posedge clk);

        // Berkeley examples:
        // code=0   -> 0 cycles high (entire window low)
        // code=3   -> 4 cycles high (cycles 0,1,2,3 -> 4 total for window of 8)
        // code=7   -> 8 cycles high (entire window)

        check_window(0, 0, "code=0 (all low)");
        check_window(3, 4, "code=3 (half window, 8-cycle window)");
        check_window(7, 8, "code=7 (all high)");

        $display("\nDAC testbench complete. Check waveform for visual verification.");
        $finish;
    end

endmodule
