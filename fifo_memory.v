module fifo_memory #(parameter DATA_WIDTH = 8, ADDR_WIDTH = 4)(
    input clk,
    input [ADDR_WIDTH-1:0] waddr, raddr,
    input [DATA_WIDTH-1:0] wdata,
    input wen, ren,
    output reg [DATA_WIDTH-1:0] rdata
);
    reg [DATA_WIDTH-1:0] mem [(2**ADDR_WIDTH)-1:0];

    always @(posedge clk) begin
        if (wen)
            mem[waddr] <= wdata;
        if (ren)
            rdata <= mem[raddr];
    end
endmodule
