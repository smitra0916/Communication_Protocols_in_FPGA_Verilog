module UART_Tx_tb;
    reg clk;
    reg reset;
    reg [7:0] data_in;
    reg start;
    wire Tx;

    UART_Tx uut (
        .clk(clk),
        .reset(reset),
        .data_in(data_in),
        .start(start),
        .Tx(Tx)
    );

    initial begin
        clk = 0;
        reset = 1;
        data_in = 8'hA5;
        start = 0;
        #10 reset = 0;
        #20 start = 1;
        #10 start = 0;
    end

    always #5 clk = ~clk;

endmodule
