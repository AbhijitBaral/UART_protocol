module tb_UART_tx();

reg load_tx_datareg, byte_ready, t_byte, clk, rst_b;
reg [7:0] data_bus;
wire serial_out;

UART_TX uut(.data_bus(data_bus),
            .load_tx_datareg(load_tx_datareg),
            .byte_ready(byte_ready),
            .t_byte(t_byte),
            .rst_b(rst_b), 
            .clk(clk)
);

always #5 clk = ~clk;

initial begin
    $dumpfile("signal_dump.vcd");
    $dumpvars(0, tb_UART_tx);
end

initial begin
    clk = 0;
    #5 rst_b = 0;
    data_bus[7:0] = 8'ha7;
    #5 rst_b = 1;
       load_tx_datareg = 0;
    #10 load_tx_datareg = 1; 
    #10 load_tx_datareg = 0; 
    #10 byte_ready = 1;
    #10 byte_ready = 0;
    #30 t_byte = 1;
    #5 data_bus = 8'h1a;
    #5 t_byte = 0;
       load_tx_datareg = 1;
    #10 load_tx_datareg = 0;
    #20 load_tx_datareg = 1;
    #5 data_bus = 8'hb4;
    #5 load_tx_datareg = 0;
    #80 $finish;
end
endmodule
