`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: krishnashree
// 
// Create Date: 04.07.2025 18:00:39
// Design Name: 
// Module Name: async_fifo_non2n
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
module async_fifo_non2n #(
    parameter DATA_WIDTH = 8,
    parameter FIFO_DEPTH = 520,
    parameter PTR_WIDTH = 10,
    parameter MEM_SIZE = (1 << PTR_WIDTH),
    parameter START_ADDR = (MEM_SIZE/2) - (FIFO_DEPTH/2),
    parameter END_ADDR   = (MEM_SIZE/2) + (FIFO_DEPTH/2) - 1,
    parameter COUNT_WIDTH = 10
)(
    // Write interface
    input wclk,
    input wrst_n,
    input w_en,
    input [DATA_WIDTH-1:0] wdata,
    output full,

    // Read interface
    input rclk,
    input rrst_n,
    input r_en,
    output [DATA_WIDTH-1:0] rdata,
    output empty
);

    // Internal signals
    wire [PTR_WIDTH-1:0] wptr, rptr;
    wire [PTR_WIDTH-1:0] waddr, raddr;
    wire [COUNT_WIDTH-1:0] count;

    // Write pointer handler
    wptr_handler_non2n #(
        .FIFO_DEPTH(FIFO_DEPTH),
        .PTR_WIDTH(PTR_WIDTH),
        .MEM_SIZE(MEM_SIZE),
        .START_ADDR(START_ADDR),
        .END_ADDR(END_ADDR)
    ) wptr_inst (
        .wclk(wclk),
        .wrst_n(wrst_n),
        .w_en(w_en),
        .full(full),
        .wptr(wptr)
    );
    assign waddr = wptr;

    // Read pointer handler
    rptr_handler_non2n #(
        .FIFO_DEPTH(FIFO_DEPTH),
        .PTR_WIDTH(PTR_WIDTH),
        .MEM_SIZE(MEM_SIZE),
        .START_ADDR(START_ADDR),
        .END_ADDR(END_ADDR)
    ) rptr_inst (
        .rclk(rclk),
        .rrst_n(rrst_n),
        .r_en(r_en),
        .empty(empty),
        .rptr(rptr)
    );
    assign raddr = rptr;

    // Entry counter for full/empty detection
    entry_counter_non2n #(
        .FIFO_DEPTH(FIFO_DEPTH),
        .COUNT_WIDTH(COUNT_WIDTH)
    ) counter_inst (
        .wclk(wclk),
        .wrst_n(wrst_n),
        .rclk(rclk),
        .rrst_n(rrst_n),
        .w_en(w_en),
        .r_en(r_en),
        .full(full),
        .empty(empty),
        .count(count)
    );

    // FIFO memory
    fifo_mem_non2n #(
        .DATA_WIDTH(DATA_WIDTH),
        .PTR_WIDTH(PTR_WIDTH),
        .MEM_SIZE(MEM_SIZE)
    ) mem_inst (
        .wclk(wclk),
        .w_en(w_en),
        .waddr(waddr),
        .wdata(wdata),
        .rclk(rclk),
        .r_en(r_en),
        .raddr(raddr),
        .rdata(rdata)
    );

endmodule

