module tb_UART_RX();

parameter word_size = 8, half_word = word_size/2;

reg read_not_ready_in, sample_clk, rst_b, serial_in;
wire read_not_ready_out, error1, error2;
wire [word_size-1:0] rx_datareg;

UART_RX uut(
    .serial_in(serial_in),
    .read_not_ready_in(read_not_ready_in),
    .read_not_ready_out(read_not_ready_out),
    .error1(error1),
    .error2(error2),
    .sample_clk(sample_clk),
    .rst_b(rst_b),
    .rx_datareg(rx_datareg));

always
    #1 sample_clk = ~sample_clk;

initial begin
    $dumpfile("rx_signal_dump.vcd");
    $dumpvars(0, tb_UART_RX);
end

initial begin
    rst_b=0;
    sample_clk = 0;
    serial_in = 0;
    read_not_ready_in = 0;

    #2 rst_b = 1;
    serial_in = 1;

    #8 rst_b = 0;
    #10 rst_b = 1;

    #10 serial_in = 0;
    #16 serial_in = 1;
    #16 serial_in = 0;
    #10 $finish;
end
endmodule



