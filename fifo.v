module fifo #(parameter DATA_WIDTH = 8, ADDR_WIDTH = 4)(
    input wclk, wrst_n, winc,
    input rclk, rrst_n, rinc,
    input [DATA_WIDTH-1:0] wdata,
    output [DATA_WIDTH-1:0] rdata,
    output full, empty
);
    wire [ADDR_WIDTH:0] wptr, rptr;
    wire [ADDR_WIDTH-1:0] waddr, raddr;
    wire [ADDR_WIDTH:0] rptr_sync, wptr_sync;

    fifo_memory #(DATA_WIDTH, ADDR_WIDTH) mem (
        .clk(wclk), .waddr(waddr), .raddr(raddr),
        .wdata(wdata), .wen(winc & ~full), .ren(rinc & ~empty), .rdata(rdata)
    );

    wptr_full #(ADDR_WIDTH) wptr_inst (
        .wclk(wclk), .wrst_n(wrst_n), .winc(winc),
        .rptr_sync(rptr_sync), .full(full),
        .wptr(wptr), .waddr(waddr)
    );

    rptr_empty #(ADDR_WIDTH) rptr_inst (
        .rclk(rclk), .rrst_n(rrst_n), .rinc(rinc),
        .wptr_sync(wptr_sync), .empty(empty),
        .rptr(rptr), .raddr(raddr)
    );

    two_ff_sync #(ADDR_WIDTH) sync_r2w (
        .clk(wclk), .rst_n(wrst_n), .d(rptr), .q(rptr_sync)
    );

    two_ff_sync #(ADDR_WIDTH) sync_w2r (
        .clk(rclk), .rst_n(rrst_n), .d(wptr), .q(wptr_sync)
    );
endmodule
