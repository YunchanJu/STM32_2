`timescale 1ns/1ps
module tb_uart_led;
    localparam N=16;
    reg clk=0,rst=1,rx=1;
    always #5 clk=~clk;
    wire tx,led,overrun,framing_error;
    wire [7:0] echo;
    wire echo_valid,echo_error;
    integer echoes=0;
    reg [7:0] expected[0:8];
    uart_led #(.CLKS_PER_BIT(N)) dut(clk,rst,rx,tx,led,overrun,framing_error);
    uart_rx #(.CPB(N)) monitor(clk,rst,tx,echo,echo_valid,echo_error);
    task bit_time(input bit b);
        begin rx=b;repeat(N) @(negedge clk);end
    endtask
    task send_byte(input reg [7:0] b,input bit want_led);
        integer i;
        begin
            @(negedge clk);bit_time(0);
            for(i=0;i<8;i=i+1) bit_time(b[i]);
            bit_time(1);
            repeat(4) @(negedge clk);
            if(led!==want_led) $fatal(1,"LED command %h",b);
        end
    endtask
    always @(posedge clk) if(echo_valid) begin
        if(echo!==expected[echoes]) $fatal(1,"echo %0d got %h",echoes,echo);
        echoes=echoes+1;
    end
    initial begin
        expected[0]="1";expected[1]="1";expected[2]="2";
        expected[3]="2";expected[4]="0";expected[5]="A";
        expected[6]="a";expected[7]=8'h01;expected[8]="1";
        repeat(4) @(negedge clk);rst=0;
        send_byte("1",1);send_byte("1",1);send_byte("2",0);
        send_byte("2",1);send_byte("0",0);send_byte("A",0);
        send_byte("a",0);send_byte(8'h01,0);send_byte("1",1);
        wait(echoes==9);repeat(4) @(negedge clk);
        if(overrun||framing_error||echo_error) $fatal(1,"UART error");
        $display("PASS UART: nine echoed bytes, repeated set/toggle, invalid command, ASCII distinction");$finish;
    end
    initial begin #1000000;$fatal(1,"timeout");end
endmodule
