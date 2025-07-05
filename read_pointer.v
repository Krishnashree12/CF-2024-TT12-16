`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02.07.2025 16:33:18
// Design Name: 
// Module Name: rptr_handler_non2n
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


module rptr_handler_non2n #(
   parameter FIFO_DEPTH = 520 ,
   parameter PTR_WIDTH = 10,
   parameter MEM_SIZE=(1<<PTR_WIDTH),
   parameter START_ADDR=(MEM_SIZE/2)-(FIFO_DEPTH/2),
   parameter END_ADDR=(MEM_SIZE/2)+(FIFO_DEPTH/2)-1
 )(
   input rclk,rrst_n,r_en,empty,
   output reg [PTR_WIDTH-1:0] rptr
 );
   always@(posedge rclk or negedge rrst_n) begin
     if(!rrst_n)
       rptr<=START_ADDR;
     else if(r_en && !empty) begin
       if(rptr==END_ADDR)
         rptr<=START_ADDR;
       else
         rptr<=rptr+1;
       end
     end   
endmodule
