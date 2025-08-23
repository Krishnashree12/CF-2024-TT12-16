module fifo_memory #(parameter DATA_WIDTH = 8, ADDR_WIDTH = 4)(
    input wire wclk, rclk,
    input wire [ADDR_WIDTH-1:0] waddr, raddr,
    input wire [3:0] wdata,
    input wire wen, ren,
    output reg [3:0] rdata
);
    reg [3:0] mem [(2**ADDR_WIDTH)-1:0];

    always @(posedge wclk) begin
        if (wen) begin
            mem[waddr] <= wdata;
        end
    end

    always @(posedge rclk) begin
        if (ren) begin
          rdata <= mem[raddr];
        end else begin
          rdata <= {ADDR_WIDTH{1'b0}};
       end
    end

endmodule
