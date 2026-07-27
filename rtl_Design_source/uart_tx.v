module uart_tx (
    input wire clk,
    input wire rst_n,     
    input wire baud_tick, 
    input wire [7:0] tx_data,
    input wire tx_valid,
    output reg tx_ready,
    output reg tx_serial,
    output reg tx_busy 
);

    localparam [2:0]
        S_IDLE  = 3'd0,
        S_START = 3'd1,
        S_DATA  = 3'd2,
        S_STOP  = 3'd3;

    reg [2:0] state;
    reg [7:0] shift_reg;
    reg [2:0] bit_idx;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state     <= S_IDLE;
            shift_reg <= 8'h00;
            bit_idx   <= 3'd0;
            tx_serial <= 1'b1;  
            tx_ready  <= 1'b1;
            tx_busy   <= 1'b0;
        end else begin
            case (state)
                S_IDLE: begin
                    tx_serial <= 1'b1;
                    tx_busy   <= 1'b0;
                    tx_ready  <= 1'b1;
                    if (tx_valid) begin
                        shift_reg <= tx_data;
                        tx_ready  <= 1'b0;
                        tx_busy   <= 1'b1;
                        state     <= S_START;
                    end
                end

                S_START: begin
                    
                    if (baud_tick) begin
                        tx_serial <= 1'b0;
                        bit_idx   <= 3'd0;
                        state     <= S_DATA;
                    end
                end

                S_DATA: begin
                    if (baud_tick) begin
                        tx_serial <= shift_reg[bit_idx];
                        if (bit_idx == 3'd7) begin
                            state <= S_STOP;
                        end else begin
                            bit_idx <= bit_idx + 1'b1;
                        end
                    end
                end

                S_STOP: begin
                    if (baud_tick) begin
                        tx_serial <= 1'b1; 
                        state     <= S_IDLE;
                    end
                end

                default: state <= S_IDLE;
            endcase
        end
    end

endmodule