`timescale 1ns/1ps
// Rewritten preparation implementation, 2026-10-26. UART 9600 baud 8N1.
module uart_led #(parameter CLKS_PER_BIT=5208)(
    input wire clk_50mhz, rst_p, rx,
    output wire tx, output reg led,
    output reg overrun, output wire framing_error
);
    wire [7:0] received;
    wire received_valid, tx_busy;
    reg pending, send;
    reg [7:0] pending_byte, send_byte;
    uart_rx #(.CPB(CLKS_PER_BIT)) receiver(
        clk_50mhz,rst_p,rx,received,received_valid,framing_error);
    uart_tx #(.CPB(CLKS_PER_BIT)) transmitter(
        clk_50mhz,rst_p,send,send_byte,tx,tx_busy);
    always @(posedge clk_50mhz) begin
        if(rst_p) begin
            led<=0; pending<=0; send<=0; overrun<=0;
            pending_byte<=0; send_byte<=0;
        end else begin
            send<=0;
            if(pending && !tx_busy && !send) begin
                send_byte<=pending_byte; send<=1; pending<=0;
            end
            if(received_valid) begin
                case(received)
                    8'h30: led<=0;       // ASCII '0'
                    8'h31: led<=1;       // ASCII '1'
                    8'h32: led<=~led;    // ASCII '2'
                    default: led<=led;
                endcase
                // One-byte output buffer. Echo each received byte to the PC.
                if(!pending || (!tx_busy && !send)) begin
                    pending_byte<=received; pending<=1;
                end else overrun<=1;
            end
        end
    end
endmodule

module uart_rx #(parameter CPB=5208)(
    input wire clk,rst,rx,
    output reg [7:0] data,
    output reg valid,error
);
    (* ASYNC_REG="TRUE" *) reg meta=1, sync=1;
    reg [1:0] state;
    reg [31:0] count;
    reg [2:0] bit_no;
    reg [7:0] shift;
    always @(posedge clk) begin
        meta<=rx; sync<=meta;
        if(rst) begin
            state<=0;count<=0;bit_no<=0;shift<=0;data<=0;valid<=0;error<=0;
        end else begin
            valid<=0; error<=0;
            case(state)
                0: if(!sync) begin state<=1; count<=0; end
                1: if(count==(CPB/2)-1) begin
                    count<=0;
                    if(!sync) begin state<=2;bit_no<=0;end
                    else state<=0;
                end else count<=count+1;
                2: if(count==CPB-1) begin
                    count<=0; shift[bit_no]<=sync;
                    if(bit_no==7) state<=3; else bit_no<=bit_no+1'b1;
                end else count<=count+1;
                3: if(count==CPB-1) begin
                    count<=0;state<=0;
                    if(sync) begin data<=shift;valid<=1;end
                    else error<=1;
                end else count<=count+1;
                default: state<=0;
            endcase
        end
    end
endmodule

module uart_tx #(parameter CPB=5208)(
    input wire clk,rst,start,
    input wire [7:0] data,
    output wire tx, output reg busy
);
    reg [9:0] frame;
    reg [31:0] count;
    reg [3:0] bit_no;
    assign tx=busy ? frame[0] : 1'b1;
    always @(posedge clk) begin
        if(rst) begin busy<=0;frame<=10'h3ff;count<=0;bit_no<=0;end
        else if(!busy) begin
            if(start) begin frame<={1'b1,data,1'b0};busy<=1;count<=0;bit_no<=0;end
        end else if(count==CPB-1) begin
            count<=0;frame<={1'b1,frame[9:1]};
            if(bit_no==9) begin busy<=0;bit_no<=0;end
            else bit_no<=bit_no+1'b1;
        end else count<=count+1;
    end
endmodule
