module uart_top #(
    parameter CLK_FREQ  = 50_000_000,
    parameter BAUD_RATE = 115_200
) (
    input  wire       clk,
    input  wire       rst_n,

    // TX-side user interface
    input wire [7:0] tx_data,
    input wire tx_valid,
    output wire tx_ready,
    output wire tx_busy,

    // RX-side user interface
    output wire [7:0] rx_data,
    output wire rx_valid,
    output wire rx_error,

    // Physical UART pins
    output wire uart_txd,
    input  wire uart_rxd
);

    wire baud_tick;
    wire baud_tick_x16;

    baud_gen #(
        .CLK_FREQ (CLK_FREQ),
        .BAUD_RATE (BAUD_RATE),
        .OVERSAMPLE (16)
    ) u_baud_gen (
        .clk (clk),
        .rst_n (rst_n),
        .baud_tick (baud_tick),
        .baud_tick_x16 (baud_tick_x16)
    );

    uart_tx u_uart_tx (
        .clk (clk),
        .rst_n (rst_n),
        .baud_tick (baud_tick),
        .tx_data (tx_data),
        .tx_valid (tx_valid),
        .tx_ready (tx_ready),
        .tx_serial (uart_txd),
        .tx_busy (tx_busy)
    );

    uart_rx #(
        .OVERSAMPLE (16)
    ) u_uart_rx (
        .clk (clk),
        .rst_n (rst_n),
        .baud_tick_x16 (baud_tick_x16),
        .rx_serial (uart_rxd),
        .rx_data (rx_data),
        .rx_valid (rx_valid),
        .rx_error (rx_error)
    );

endmodule