module baud_gen #(
    parameter CLK_FREQ   = 50_000_000,
    parameter BAUD_RATE  = 115_200,
    parameter OVERSAMPLE = 16 
) (
    input  wire clk,
    input  wire rst_n,
    output reg  baud_tick,
    output reg  baud_tick_x16
);

    
    localparam integer DIV_BAUD     = (CLK_FREQ / BAUD_RATE);
    localparam integer DIV_BAUD_X16 = (CLK_FREQ / (BAUD_RATE * OVERSAMPLE));
    localparam integer CNT_BAUD_W     = $clog2(DIV_BAUD + 1);
    localparam integer CNT_BAUD_X16_W = $clog2(DIV_BAUD_X16 + 1);

    reg [CNT_BAUD_W-1:0] cnt_baud;
    reg [CNT_BAUD_X16_W-1:0] cnt_baud_x16;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cnt_baud  <= 0;
            baud_tick <= 1'b0;
        end else begin
            if (cnt_baud == DIV_BAUD - 1) begin
                cnt_baud  <= 0;
                baud_tick <= 1'b1;
            end else begin
                cnt_baud  <= cnt_baud + 1'b1;
                baud_tick <= 1'b0;
            end
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cnt_baud_x16  <= 0;
            baud_tick_x16 <= 1'b0;
        end else begin
            if (cnt_baud_x16 == DIV_BAUD_X16 - 1) begin
                cnt_baud_x16  <= 0;
                baud_tick_x16 <= 1'b1;
            end else begin
                cnt_baud_x16  <= cnt_baud_x16 + 1'b1;
                baud_tick_x16 <= 1'b0;
            end
        end
    end

endmodule