`timescale 1ns/1ps

module tb_uart_clock_generator;

    parameter CLK_PERIOD = 20; // 50 MHz → 20 ns

    reg sys_clk;
    reg rst_b;
    reg [2:0] sel_baud_rate;

    wire clk;         // baud clock
    wire sample_clk;  // 8× baud

    uart_clock_generator dut (
        .sys_clk(sys_clk),
        .rst_b(rst_b),
        .sel_baud_rate(sel_baud_rate),
        .clk(clk),
        .sample_clk(sample_clk)
    );
    
    initial begin
        $dumpfile("clk_generator_signal_dump.vcd");
        $dumpvars(0, tb_uart_clock_generator);
    end

    initial begin
        sys_clk = 0;
        forever #(CLK_PERIOD/2) sys_clk = ~sys_clk;
    end

    initial begin
        rst_b = 0;
        #100;
        rst_b = 1;
    end

    integer clk_edges;
    integer sample_edges;

    initial begin
        clk_edges = 0;
        sample_edges = 0;
    end

    always @(posedge clk)
        clk_edges = clk_edges + 1;

    always @(posedge sample_clk)
        sample_edges = sample_edges + 1;

    integer i;

    initial begin
        wait(rst_b);

        for (i = 0; i < 8; i = i + 1) begin
            sel_baud_rate = i;

            // reset counters
            clk_edges = 0;
            sample_edges = 0;

            // observe for some time
            #(100000);

            $display("SEL=%0d | clk_edges=%0d | sample_edges=%0d",
                     i, clk_edges, sample_edges);

            // -------------------------------------------------
            // Check relationship: sample_clk ≈ 8 × clk
            // -------------------------------------------------
            if (sample_edges < (clk_edges * 7) ||
                sample_edges > (clk_edges * 9)) begin
                $display("ERROR: Oversampling ratio incorrect for sel=%0d", i);
            end else begin
                $display("PASS: Oversampling ratio OK for sel=%0d", i);
            end

            $display("--------------------------------------");
        end

        $finish;
    end

endmodule
