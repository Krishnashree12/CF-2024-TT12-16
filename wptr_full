
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 19.07.2025 10:51:52
// Design Name: 
// Module Name: wptr_full
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
module wptr_full #(parameter ADDR_WIDTH = 4)(
    input wclk, wrst_n, winc,
    input [ADDR_WIDTH:0] rptr_sync,
    output reg full,
    output [ADDR_WIDTH:0] wptr,
    output [ADDR_WIDTH:0] waddr
);
    reg [ADDR_WIDTH:0] wbin;
    wire [ADDR_WIDTH:0] wgray;
    wire [ADDR_WIDTH:0] wbin_next, wgray_next;

    assign wbin_next = wbin + (winc & ~full);
    assign wgray_next = (wbin_next >> 1) ^ wbin_next;

    always @(posedge wclk or negedge wrst_n) begin
        if (!wrst_n)
            wbin <= 0;
        else
            wbin <= wbin_next;
    end

    assign waddr = wbin[ADDR_WIDTH-1:0];
    assign wptr  = wgray_next;

    always @(posedge wclk or negedge wrst_n) begin
        if (!wrst_n)
            full <= 1'b0;
        else
            full <= (wgray_next == {~rptr_sync[ADDR_WIDTH:ADDR_WIDTH-1], rptr_sync[ADDR_WIDTH-2:0]});
    end
endmodule
