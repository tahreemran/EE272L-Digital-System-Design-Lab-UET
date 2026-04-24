/*
 * Testbench: sq_wave_gen
 *
 * Berkeley Lab 3 spec:
 *   "We have provided a simple testbench in sim/sq_wave_gen_tb.v which pulls
 *    about 1 second worth of samples (125e6 / 1024 = 122070) from your
 *    sq_wave_gen module and writes them to a file in sim/codes.txt."
 *
 *   "You can run a script to convert this text file to an audio file:
 *    cd lab3 && ../scripts/audio_from_sim sim/codes.txt"
 *
 *   Verifies:
 *   - code is always either 562 (high) or 462 (low)
 *   - Toggle happens approximately every 139 samples
 *   - next_sample correctly drives code updates
 *
 * Digital Systems Lab - UET Lahore (2026), based on Berkeley EECS150 Lab 3
 */

`timescale 1ns/1ns

module sq_wave_gen_tb;

    // Berkeley: 125e6 / 1024 = 122070 samples per second
    localparam TOTAL_SAMPLES = 122070;
    localparam CLK_PERIOD    = 8;   // 125 MHz
    localparam CYCLES_PER_WINDOW = 1024;

    // Reduce for faster simulation - set to small number while debugging
    // Change to TOTAL_SAMPLES to generate full codes.txt for audio check
    localparam SIM_SAMPLES = 500;  // ~4 half-periods visible for fast sim

    logic       clk;
    logic       rst;
    logic       next_sample;
    logic [9:0] code;

    // Generate next_sample every CYCLES_PER_WINDOW clock cycles
    // (mimics what the DAC would produce)
    logic [$clog2(CYCLES_PER_WINDOW)-1:0] window_ctr;

    always_ff @(posedge clk) begin
        if (rst)
            window_ctr <= 0;
        else if (window_ctr >= CYCLES_PER_WINDOW - 1)
            window_ctr <= 0;
        else
            window_ctr <= window_ctr + 1;
    end

    assign next_sample = (window_ctr == CYCLES_PER_WINDOW - 1);

    sq_wave_gen dut (
        .clk         (clk),
        .rst         (rst),
        .next_sample (next_sample),
        .code        (code)
    );

    initial clk = 0;
    always #(CLK_PERIOD/2) clk = ~clk;

    // File handle for codes.txt (Berkeley uses this to generate audio)
    integer fd;
    integer sample_count;
    integer invalid_codes;
    integer prev_code;
    integer toggle_count;
    integer samples_since_toggle;

    initial begin
        rst           = 1;
        sample_count  = 0;
        invalid_codes = 0;
        toggle_count  = 0;
        samples_since_toggle = 0;

        repeat(3) @(posedge clk);
        rst = 0;

        // Open output file (Berkeley: sim/codes.txt)
        fd = $fopen("sim/codes.txt", "w");
        if (fd == 0) begin
            $display("WARNING: Could not open sim/codes.txt - running without file output");
        end

        prev_code = -1;

        $display("Running sq_wave_gen for %0d samples...", SIM_SAMPLES);

        // Pull SIM_SAMPLES samples
        repeat (SIM_SAMPLES * CYCLES_PER_WINDOW) begin
            @(posedge clk); #1;
            if (next_sample) begin
                sample_count++;

                // Write to codes.txt for audio generation
                if (fd != 0)
                    $fwrite(fd, "%0d\n", code);

                // Verify code is always 562 or 462
                if (code !== 10'd562 && code !== 10'd462) begin
                    $display("FAIL at sample %0d: invalid code=%0d (expected 562 or 462)",
                             sample_count, code);
                    invalid_codes++;
                end

                // Detect toggle
                if (prev_code != -1 && code != prev_code) begin
                    toggle_count++;
                    if (samples_since_toggle > 0)
                        $display("Toggle #%0d at sample %0d (after %0d samples, expected ~139)",
                                 toggle_count, sample_count, samples_since_toggle);
                    samples_since_toggle = 0;
                end else begin
                    samples_since_toggle++;
                end
                prev_code = code;
            end
        end

        if (fd != 0) $fclose(fd);

        $display("\n--- sq_wave_gen Results ---");
        $display("Total samples pulled : %0d", sample_count);
        $display("Toggle count         : %0d", toggle_count);
        $display("Invalid codes        : %0d", invalid_codes);

        if (invalid_codes == 0)
            $display("PASS: All codes were 562 or 462");
        else
            $display("FAIL: %0d invalid code(s) found", invalid_codes);

        if (toggle_count > 0)
            $display("Average samples per half-period: ~%0d (expected 139)",
                     sample_count / toggle_count);

        $display("\nTo generate audio: cd lab7 && python3 scripts/audio_from_sim sim/codes.txt");
        $finish;
    end

endmodule
