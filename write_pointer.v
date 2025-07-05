`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: krishnahsree
// 
// Create Date: 12.06.2025 17:51:01
// Design Name: 
// Module Name: wptr_handler
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


module wptr_handler_non2n #(
   parameter FIFO_DEPTH = 520 ,
   parameter PTR_WIDTH = 10,
   parameter MEM_SIZE=(1<<PTR_WIDTH),
   parameter START_ADDR=(MEM_SIZE/2)-(FIFO_DEPTH/2),
   parameter END_ADDR=(MEM_SIZE/2)+(FIFO_DEPTH/2)-1
 )(
   input wclk,wrst_n,w_en,full,
   output reg [PTR_WIDTH-1:0] wptr
 );
   always@(posedge wclk or negedge wrst_n) begin
     if(!wrst_n)
       wptr<=START_ADDR;
     else if(w_en && !full) begin
       if(wptr==END_ADDR)
         wptr<=START_ADDR;
       else
         wptr<=wptr+1;
       end
     end   
endmodule
