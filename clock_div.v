`timescale 1ns / 1ps

module clock_div(
    input clk ,        // Input clock (assumed 100 MHz for this example)
    input reset,         // Synchronous reset
    output reg wclk,   // 50 MHz write clock output
    output reg rclk    // 30 MHz read clock output
);

    reg [2:0] wr_counter = 3'b000;  // Counter for write clock division
    reg [2:0] rd_counter = 3'b000; // Counter for read clock division

    // Generate 50 MHz clock (divide by 1.2)
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            wr_counter <= 3'b000;
            wclk <= 1'b0;
        end else if (wr_counter == 1) begin
            wr_counter <= 3'b000;
            wclk <= ~wclk;
        end else begin
            wr_counter <= wr_counter + 1'b1;
        end
    end

    // Generate 30 MHz clock (approximate divide by 2)
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            rd_counter <= 3'b000;
            rclk <= 1'b0;
        end else if (rd_counter == 2) begin
            rd_counter <= 3'b000;
            rclk <= ~rclk;
        end else begin
            rd_counter <= rd_counter + 1'b1;
        end
    end



endmodule
