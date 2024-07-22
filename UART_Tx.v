module UART_Tx(
    input wire clk,
    input wire reset,
    input wire [7:0] data_in,
    input wire start,
    output reg Tx
);
    // Calculate the baud rate divisor
    localparam BAUD_RATE_DIV = CLK_FREQ / BAUD_RATE;

    reg [3:0] state;
    reg [7:0] shift_reg;
    reg [3:0] bit_count;
    reg [15:0] baud_count;
    
    parameter CLK_FREQ = 50000000; // System clock frequency
    parameter BAUD_RATE = 9600;  // Desired baud rate
    parameter IDLE = 4'd0;
    parameter START = 4'd1;
    parameter DATA = 4'd2;
    parameter STOP = 4'd3;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= IDLE;
            Tx <= 1'b1;
            bit_count <= 4'd0;
            baud_count <= 16'd0;
        end else begin
            case (state)
                IDLE: begin
                    if (start) begin
                        state <= START;
                        shift_reg <= data_in;
                        baud_count <= 16'd0;
                        bit_count <= 4'd0;
                    end
                end
                START: begin
                    if (baud_count == BAUD_RATE_DIV) begin
                        baud_count <= 16'd0;
                        Tx <= 1'b0;
                        state <= DATA;
                    end else begin
                        baud_count <= baud_count + 1;
                    end
                end
                DATA: begin
                    if (baud_count == BAUD_RATE_DIV) begin
                        baud_count <= 16'd0;
                        Tx <= shift_reg[0];
                        shift_reg <= shift_reg >> 1;
                        bit_count <= bit_count + 1;
                        if (bit_count == 4'd7) state <= STOP;
                    end else begin
                        baud_count <= baud_count + 1;
                    end
                end
                STOP: begin
                    if (baud_count == BAUD_RATE_DIV) begin
                        baud_count <= 16'd0;
                        Tx <= 1'b1;
                        state <= IDLE;
                    end else begin
                        baud_count <= baud_count + 1;
                    end
                end
            endcase
        end
    end
endmodule
