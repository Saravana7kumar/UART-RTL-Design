module uart_rx #( parameter OVERSAMPLE = 16) (
    input wire clk,
    input wire rst_n,
    input wire baud_tick_x16,
    input wire rx_serial, 
    output reg [7:0] rx_data,
    output reg rx_valid,
    output reg rx_error 
);
     localparam [1:0]
        S_IDLE  = 2'd0,
        S_START = 2'd1,
        S_DATA  = 2'd2,
        S_STOP  = 2'd3;
 
   
    reg rx_sync_0, rx_sync_1;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            rx_sync_0 <= 1'b1;
            rx_sync_1 <= 1'b1;
        end else begin
            rx_sync_0 <= rx_serial;
            rx_sync_1 <= rx_sync_0;
        end
    end
 
    reg [1:0] state;
    reg [$clog2(OVERSAMPLE)-1:0] os_cnt; 
    reg [2:0] bit_idx;
    reg [7:0] shift_reg;
 
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state     <= S_IDLE;
            os_cnt    <= 0;
            bit_idx   <= 3'd0;
            shift_reg <= 8'h00;
            rx_data   <= 8'h00;
            rx_valid  <= 1'b0;
            rx_error  <= 1'b0;
        end else begin
            rx_valid <= 1'b0; 
 
            if (baud_tick_x16) begin
                case (state)
                    S_IDLE: begin
                        os_cnt <= 0;
                   
                        if (rx_sync_1 == 1'b0) begin
                            state <= S_START;
                        end
                    end
 
                    S_START: begin
                        if (os_cnt == (OVERSAMPLE/2 - 1)) begin
                            if (rx_sync_1 == 1'b0) begin
                                os_cnt  <= 0;
                                bit_idx <= 3'd0;
                                state   <= S_DATA;
                            end else begin
                                state <= S_IDLE;
                            end
                        end else begin
                            os_cnt <= os_cnt + 1'b1;
                        end
                    end
 
                    S_DATA: begin
                        if (os_cnt == OVERSAMPLE - 1) begin
                            os_cnt <= 0;
                            shift_reg[bit_idx] <= rx_sync_1;
                            if (bit_idx == 3'd7) begin
                                state <= S_STOP;
                            end else begin
                                bit_idx <= bit_idx + 1'b1;
                            end
                        end else begin
                            os_cnt <= os_cnt + 1'b1;
                        end
                    end
 
                    S_STOP: begin
                        if (os_cnt == OVERSAMPLE - 1) begin
                            os_cnt   <= 0;
                            rx_data  <= shift_reg;
                            rx_valid <= 1'b1;
                            rx_error <= ~rx_sync_1;
                            state    <= S_IDLE;
                        end else begin
                            os_cnt <= os_cnt + 1'b1;
                        end
                    end
 
                    default: state <= S_IDLE;
                endcase
            end
        end
    end
 
endmodule