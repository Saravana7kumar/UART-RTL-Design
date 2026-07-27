`timescale 1ns/1ps
module uart_tb;
    localparam CLK_FREQ  = 800_000;
    localparam BAUD_RATE = 100_000;
    localparam CLK_FREQ_SIM  = 1_600_000;
    localparam BAUD_RATE_SIM = 100_000;
    localparam CLK_PERIOD = 1_000_000_000 / CLK_FREQ_SIM; 
    reg clk;
    reg rst_n;
    reg [7:0] tx_data;
    reg tx_valid;
    wire tx_ready;
    wire tx_busy;
    wire [7:0] rx_data;
    wire rx_valid;
    wire rx_error;
    wire uart_line;
    integer i;
    integer errors;
    reg [7:0] test_bytes [0:4];

    initial clk = 1'b0;
    always #(CLK_PERIOD/2) clk = ~clk;

    uart_top #(
        .CLK_FREQ  (CLK_FREQ_SIM),
        .BAUD_RATE (BAUD_RATE_SIM)
    ) dut (
        .clk (clk),
        .rst_n (rst_n),
        .tx_data (tx_data),
        .tx_valid (tx_valid),
        .tx_ready (tx_ready),
        .tx_busy (tx_busy),
        .rx_data (rx_data),
        .rx_valid (rx_valid),
        .rx_error (rx_error),
        .uart_txd (uart_line),
        .uart_rxd (uart_line)
    );

    task send_byte(input [7:0] data);
        begin
            @(posedge clk);
            wait (tx_ready == 1'b1);
            tx_data  = data;
            tx_valid = 1'b1;
            @(posedge clk);
            tx_valid = 1'b0;
        end
    endtask

    initial begin
        test_bytes[0] = 8'h55;
        test_bytes[1] = 8'hA5;
        test_bytes[2] = 8'h00;
        test_bytes[3] = 8'hFF;
        test_bytes[4] = 8'h3C;

        errors   = 0;
        tx_data  = 8'h00;
        tx_valid = 1'b0;
        rst_n    = 1'b0;

        repeat (5) @(posedge clk);
        rst_n = 1'b1;
        repeat (5) @(posedge clk);

        for (i = 0; i <= 4; i = i + 1) begin
            send_byte(test_bytes[i]);
            wait (rx_valid == 1'b1);
            @(posedge clk);
            if (rx_data !== test_bytes[i]) begin
                $display("[FAIL] byte %0d: expected 0x%02h, got 0x%02h", i, test_bytes[i], rx_data);
                errors = errors + 1;
            end else begin
                $display("[PASS] byte %0d: 0x%02h received correctly", i, rx_data);
            end
            if (rx_error) begin
                $display("[FAIL] byte %0d: framing error flagged", i);
                errors = errors + 1;
            end
            repeat (20) @(posedge clk);
        end

        if (errors == 0)
            $display("\n*** ALL TESTS PASSED ***\n");
        else
            $display("\n*** %0d TEST(S) FAILED ***\n", errors);

        $finish;
    end
    
    initial begin
        #200000;
        $display("[TIMEOUT] Simulation did not finish in time");
        $finish;
    end
    
    initial begin
        $dumpfile("uart_tb.vcd");
        $dumpvars(0, uart_tb);
    end

endmodule