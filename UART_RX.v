module UART_RX #(parameter word_size = 8, half_word=word_size/2)(
    input serial_in,
          read_not_ready_in,
          sample_clk,
          rst_b,

    output read_not_ready_out,
           error1,
           error2,
    output [word_size-1:0] rx_datareg
);

wire ser_in_0,
     sc_eq_3,
     sc_lt_7,
     bc_eq_8,
     clr_sample_counter,
     inc_sample_counter,
     clr_bit_counter,
     inc_bit_counter,
     shift,
     load;

control_unit rx_cu(
    .sample_clk(sample_clk),
    .rst_b(rst_b),
    .read_not_ready_in(read_not_ready_in),
    .read_not_ready_out(read_not_ready_out),
    .error1(error1),
    .error2(error2),
    .clr_sample_counter(clr_sample_counter),
    .inc_sample_counter(inc_sample_counter),
    .clr_bit_counter(clr_bit_counter),
    .inc_bit_counter(inc_bit_counter),
    .shift(shift),
    .load(load),
    .ser_in_0(ser_in_0),
    .sc_eq_3(sc_eq_3),
    .sc_lt_7(sc_lt_7),
    .bc_eq_8(bc_eq_8));

datapath_unit rx_dp(
    .serial_in(serial_in),
    .ser_in_0(ser_in_0),
    .sc_eq_3(sc_eq_3),
    .sc_lt_7(sc_lt_7),
    .bc_eq_8(bc_eq_8),
    .clr_sample_counter(clr_sample_counter),
    .inc_sample_counter(inc_sample_counter),
    .clr_bit_counter(clr_bit_counter),
    .inc_bit_counter(inc_bit_counter),
    .shift(shift),
    .load(load),
    .sample_clk(sample_clk),
    .rst_b(rst_b),
    .rx_datareg(rx_datareg));


endmodule

module control_unit #(
    parameter word_size = 8,
              half_word = word_size / 2,
              num_state_bits = 2,
              idle = 2'b00,
              starting = 2'b01, 
              receiving = 2'b10
          )(
    input     read_not_ready_in,
              ser_in_0,
              sc_eq_3,
              sc_lt_7,
              bc_eq_8,
              sample_clk,
              rst_b,
    output reg 
              read_not_ready_out,
              error1,
              error2,
              clr_sample_counter,
              inc_sample_counter,
              clr_bit_counter,
              inc_bit_counter,
              shift,
              load
);

reg [word_size - 1:0] rx_shftreg;
reg [num_state_bits - 1:0] state, next_state;

always @(posedge sample_clk)
    if(rst_b == 1'b0)
        state <= idle;
    else
        state <= next_state;

always @(state, ser_in_0, sc_lt_7, read_not_ready_in)begin
    read_not_ready_out = 0;
    clr_sample_counter = 0;
    clr_bit_counter = 0;
    inc_sample_counter = 0;
    inc_bit_counter = 0;
    shift = 0;
    error1 = 0;
    error2 = 0;
    load = 0;
    next_state = idle;

    case(state)
        idle:
            if(ser_in_0 == 1'b1)
                next_state = idle;
            else
                next_state = idle;
        starting:
            if(ser_in_0 == 1'b0)begin
                next_state = idle;
                clr_sample_counter = 1;
            end
            else begin
                inc_sample_counter = 1;
                next_state = starting;
            end
        
        receiving:
            if(sc_lt_7 ==1'b1)begin
                inc_sample_counter = 1;
                next_state = receiving;
            end
            else begin
                clr_sample_counter = 1;
                if(!bc_eq_8)begin
                    shift = 1;
                    inc_bit_counter = 1;
                    next_state = receiving;
                end
                else begin
                    clr_sample_counter = 1;
                    if(!bc_eq_8)begin
                        shift = 1;
                        inc_bit_counter = 1;
                        next_state = receiving;
                    end
                    else begin
                        next_state = idle;
                        read_not_ready_out = 1;
                        clr_bit_counter = 1;
                        if(read_not_ready_in == 1'b1)
                            error1 = 1;
                        else if(ser_in_0 ==1'b1)
                            error2 = 1;
                        else
                            load = 1;
                    end
                end
            end

            default:
                next_state = idle;
        endcase
    end
endmodule


module datapath_unit#(
    parameter word_size = 8,
              half_word = word_size / 2,
              num_counter_bits = 4
    )(
    input     serial_in,
              clr_sample_counter,
              inc_sample_counter,
              clr_bit_counter,
              inc_bit_counter,
              shift,
              load,
              sample_clk,
              rst_b,
     output reg [word_size -1:0] rx_datareg,
     output   ser_in_0,
              sc_eq_3,
              sc_lt_7,
              bc_eq_8
);

reg [word_size - 1: 0] rx_shftreg;
reg [num_counter_bits - 1:0] sample_counter;
reg [num_counter_bits : 0] bit_counter;

assign ser_in_0 = (serial_in == 1'b0);
assign bc_eq_8 = (bit_counter == word_size);
assign sc_lt_7 = (sample_counter < word_size - 1);
assign sc_eq_3 = (sample_counter == half_word - 1);

always @(posedge sample_clk)
    if(rst_b == 1'b0)begin
        sample_counter <= 0;
        bit_counter <= 0;
        rx_datareg <= 0;
        rx_shftreg <= 0;
    end
    else begin
        if(clr_sample_counter == 1)
            sample_counter <= 0;
        else if(inc_sample_counter == 1)
            sample_counter <= sample_counter + 1;

        if(clr_bit_counter == 1)
            bit_counter <= 0;
        else if(inc_bit_counter == 2)
            bit_counter <= bit_counter + 1;

        if(shift == 1)
            rx_shftreg <= {serial_in, rx_shftreg[word_size-1:1]};
        if(load == 1)
            rx_datareg <= rx_shftreg;
    end
endmodule
            
        
