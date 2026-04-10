module uart_clock_generator #(
    parameter DIV_WIDTH = 8   //sample_clk scale down factor 
)(
    input  wire        sys_clk,
    input  wire        rst_b,
    input  wire [2:0]  sel_baud_rate,

    output wire clk,
    output wire sample_clk
);


    reg [DIV_WIDTH-1:0] div256_cnt;

    always @(posedge sys_clk or negedge rst_b) begin
        if (!rst_b)
            div256_cnt <= 0;
        else
            div256_cnt <= div256_cnt + 1;
    end

    // These represent different baud rates
    wire tap0 = div256_cnt[0];
    wire tap1 = div256_cnt[1];
    wire tap2 = div256_cnt[2];
    wire tap3 = div256_cnt[3];
    wire tap4 = div256_cnt[4];
    wire tap5 = div256_cnt[5];
    wire tap6 = div256_cnt[6];
    wire tap7 = div256_cnt[7];

    reg mux_clk;

    always @(*) begin
        case (sel_baud_rate)
            3'd0: mux_clk = tap0;
            3'd1: mux_clk = tap1;
            3'd2: mux_clk = tap2;
            3'd3: mux_clk = tap3;
            3'd4: mux_clk = tap4;
            3'd5: mux_clk = tap5;
            3'd6: mux_clk = tap6;
            3'd7: mux_clk = tap7;
            default: mux_clk = tap3;
        endcase
    end

    assign sample_clk = mux_clk;

    reg [2:0] div8_cnt;

    always @(posedge sample_clk or negedge rst_b) begin
        if (!rst_b)
            div8_cnt <= 0;
        else
            div8_cnt <= div8_cnt + 1;
    end

    // MSB gives divide-by-8 clock
    assign clk = div8_cnt[2];

endmodule
