module fifo_memory #(parameter DATA_WIDTH = 8, ADDR_WIDTH = 4)(
    input wclk,rclk,
    input [ADDR_WIDTH-1:0] waddr, raddr,
    input [DATA_WIDTH-1:0] wdata,
    input wen, ren,
    output reg [DATA_WIDTH-1:0] rdata
);
    reg [DATA_WIDTH-1:0] mem [(2**ADDR_WIDTH)-1:0];

    always @(posedge wclk) begin
        if (wen && !full) begin
          mem[waddr] <= wdata;
    end
        
    always @(posedge rclk) begin
        if (ren && !empty) 
          rdata <= mem[raddr];
        else 
          rdata <= {WIDTH{1'b0}};
    end
 endmodule
