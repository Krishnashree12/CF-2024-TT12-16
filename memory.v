`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: krishnashree
// 
// Create Date: 03.07.2025 10:04:10
// Design Name: 
// Module Name: fifo_mem_non2n
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


module fifo_mem_non2n#(
   parameter DATA_WIDTH=8,
   parameter PTR_WIDTH=10,
   parameter MEM_SIZE=(1<<PTR_WIDTH)
 )(
   input wclk,w_en,rclk,r_en,
   input [PTR_WIDTH-1:0] waddr,
   input [PTR_WIDTH-1:0] raddr,
   input [DATA_WIDTH-1:0] wdata,
   output reg [DATA_WIDTH-1:0] rdata
);
  reg [DATA_WIDTH-1:0] mem [0:MEM_SIZE-1];
  always@(posedge wclk) begin
    if(w_en)
      mem[waddr] <=wdata;
    end
  always@(posedge rclk) begin
      if(r_en)
        rdata <= mem[raddr];
      end
endmodule
