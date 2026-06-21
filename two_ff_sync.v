`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 19.07.2025 11:15:47
// Design Name: 
// Module Name: two_ff_sync
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
module two_ff_sync #(parameter PTR_WIDTH = 4)(
    input clk, rst_n,
    input [PTR_WIDTH:0] d,
    output reg [PTR_WIDTH:0] q
);
    reg [PTR_WIDTH:0] sync1;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            sync1 <= 0;
            q     <= 0;
        end else begin
            sync1 <= d;
            q     <= sync1;
        end
    end
endmodule
