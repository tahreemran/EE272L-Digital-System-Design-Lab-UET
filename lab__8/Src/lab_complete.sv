
module synchronizer (
    input  logic clk,
    input  logic async_signal,
    output logic sync_signal
);
    logic q1;

    always_ff @(posedge clk) begin
        q1          <= async_signal;
        sync_signal <= q1;
    end
endmodule



module sample_pulse_gen #(
    parameter SAMPLE_COUNT_MAX = 50000
)(
    input  logic clk,
    output logic sample_pulse
);
    logic [$clog2(SAMPLE_COUNT_MAX)-1:0] count = 0;

    always_ff @(posedge clk) begin
        if (count == SAMPLE_COUNT_MAX - 1) begin
            count        <= 0;
            sample_pulse <= 1'b1;
        end else begin
            count        <= count + 1;
            sample_pulse <= 1'b0;
        end
    end
endmodule


module debouncer #(
    parameter PULSE_COUNT_MAX = 10
)(
    input  logic clk,
    input  logic sample_pulse,
    input  logic sync_out,
    output logic switch_out
);
    logic reset;
    assign reset  = ~sync_out;

    logic enable;
    assign enable = sample_pulse & sync_out;

    logic [$clog2(PULSE_COUNT_MAX+1)-1:0] count = 0;

    always_ff @(posedge clk) begin
        if (reset) begin
            count      <= 0;
            switch_out <= 1'b0;
        end else if (enable && (count < PULSE_COUNT_MAX)) begin
            count      <= count + 1;
        end else if (count == PULSE_COUNT_MAX) begin
            switch_out <= 1'b1;
        end
    end
endmodule



module edge_detector (
    input  logic clk,
    input  logic switch_out,
    output logic edge_pulse
);
    logic sig_out;

    always_ff @(posedge clk) begin
        sig_out    <= switch_out;
        edge_pulse <= switch_out & ~sig_out;
    end
endmodule



module dac #(
    parameter CYCLES_PER_WINDOW = 1024
)(
    input  logic                                 clk,
    input  logic                                 rst,
    input  logic [$clog2(CYCLES_PER_WINDOW)-1:0] code,
    output logic                                 pwm,
    output logic                                 next_sample
);
    logic [$clog2(CYCLES_PER_WINDOW)-1:0] count;

    always_ff @(posedge clk) begin
        if (rst)
            count <= 0;
        else if (count == CYCLES_PER_WINDOW - 1)
            count <= 0;
        else
            count <= count + 1;
    end

    assign pwm         = (count < code);
    assign next_sample = (count == CYCLES_PER_WINDOW - 1);
endmodule



module sq_wave_gen #(
    parameter CYCLES_PER_WINDOW = 1024,
    parameter SAMPLES_PER_HALF  = 111
)(
    input  logic                                 clk,
    input  logic                                 rst,
    input  logic                                 next_sample,
    output logic [$clog2(CYCLES_PER_WINDOW)-1:0] code
);
    logic [$clog2(SAMPLES_PER_HALF)-1:0] sample_count;
    logic                                sq_high;

    always_ff @(posedge clk) begin
        if (rst) begin
            sample_count <= 0;
            sq_high      <= 1'b1;
        end else if (next_sample) begin
            if (sample_count == SAMPLES_PER_HALF - 1) begin
                sample_count <= 0;
                sq_high      <= ~sq_high;
            end else begin
                sample_count <= sample_count + 1;
            end
        end
    end

    
    assign code = sq_high ? 10'd562 : 10'd462;
endmodule


// ================== UPDATED top_btn_parser ==================
module top_btn_parser (
    input  logic clk,
    input  logic rst,
    input  logic async_signal,
    output logic edge_detect_pulse,
    output logic sig_in,
    output logic mod_clk,
    output logic async_sig_out,
    output logic pwm_out
);

    logic sync_out;
    logic sample_pulse;
    logic switch_out;
    logic edge_pulse;
    logic sound_enable;
    logic next_sample;
    logic [9:0] code;
    logic pwm;
    logic dac_rst;

    // 1. Synchronizer
    synchronizer u_sync (
        .clk(clk),
        .async_signal(async_signal),
        .sync_signal(sync_out)
    );

    // 2. FAST sample pulse (was 50000)
    sample_pulse_gen #(
        .SAMPLE_COUNT_MAX (20)
    ) u_spg (
        .clk(clk),
        .sample_pulse(sample_pulse)
    );

    // 3. FAST debouncer (was 10)
    debouncer #(
        .PULSE_COUNT_MAX (3)
    ) u_deb (
        .clk(clk),
        .sample_pulse(sample_pulse),
        .sync_out(sync_out),
        .switch_out(switch_out)
    );

    // 4. Edge detector
    edge_detector u_edge (
        .clk(clk),
        .switch_out(switch_out),
        .edge_pulse(edge_pulse)
    );

    // 5. Toggle FF
    always_ff @(posedge clk) begin
        if (rst)
            sound_enable <= 0;
        else if (edge_pulse)
            sound_enable <= ~sound_enable;
    end

    assign dac_rst = rst | ~sound_enable;

    // 6. FAST square wave (was 1024 & 111)
    sq_wave_gen #(
        .CYCLES_PER_WINDOW (8),
        .SAMPLES_PER_HALF  (4)
    ) u_sqwav (
        .clk(clk),
        .rst(dac_rst),
        .next_sample(next_sample),
        .code(code)
    );

    // 7. FAST DAC (was 1024)
    dac #(
        .CYCLES_PER_WINDOW (8)
    ) u_dac (
        .clk(clk),
        .rst(dac_rst),
        .code(code),
        .pwm(pwm),
        .next_sample(next_sample)
    );

    assign pwm_out = sound_enable ? pwm : 0;

    // Probes
    assign edge_detect_pulse = edge_pulse;
    assign sig_in            = sync_out;
    assign mod_clk           = sample_pulse;
    assign async_sig_out     = async_signal;

endmodule


module a7top (
    input  logic [15:0] switch,
    input  logic [4:0]  push_button,
    input  logic        clk,
    output logic [15:0] led,
    output logic [7:0]  an,
    output logic [6:0]  abcdefg,
    output logic [7:0]  pmod_a
);
    // Safe defaults for unused outputs
    assign led     = 16'h0000;
    assign an      = 8'hFF;     // 7-seg digits off (active-low enable)
    assign abcdefg = 7'h7F;     // all segments off

    // Unused pmod bits driven low
    assign pmod_a[7:5] = 3'b000;

    // Design under test
    top_btn_parser i1 (
        .clk              (clk),
        .rst              (push_button[0]),
        .async_signal     (push_button[1]),
        .edge_detect_pulse(pmod_a[0]),      // probe
        .sig_in           (pmod_a[1]),      // probe
        .mod_clk          (pmod_a[2]),      // probe
        .async_sig_out    (pmod_a[3]),      // probe
        .pwm_out          (pmod_a[4])       // AUDIO -> headphones
    );

endmodule
