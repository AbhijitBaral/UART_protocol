module UART_top #(parameter word_size = 8) (
    input read_not_ready_in,
          RX,
          read_en,

          sys_clk,
          rst_b,

          byte_ready,
          load_tx_datareg,
          t_byte,

    input [2:0] sel_baud_rate,

    output error1,
           error2,
           read_not_ready_out,
           TX,

    inout [word_size-1:0] data_bus
);

wire clock, sample_clk;
wire [word_size - 1:0] internal_rx_data;

UART_RX receiver(
    .serial_in(RX),
    .read_not_ready_in(read_not_ready_in),
    .read_not_ready_out(read_not_ready_out),
    .error1(error1),
    .error2(error2),
    .sample_clk(sample_clk),
    .rst_b(rst_b),
    .rx_datareg(internal_rx_data));

//tri state buffer
assign data_bus = (read_en)?internal_rx_data:{word_size{1'bz}};

UART_TX transmitter(
    .byte_ready(byte_ready),
    .load_tx_datareg(load_tx_datareg),
    .t_byte(t_byte),
    .serial_out(TX),
    .clk(clock),
    .rst_b(rst_b),
    .data_bus(data_bus)); 

uart_clock_generator clk_gen(
    .sys_clk(sys_clk),
    .rst_b(rst_b),
    .sel_baud_rate(sel_baud_rate),
    .clk(clock),
    .sample_clk(sample_clk));

endmodule
