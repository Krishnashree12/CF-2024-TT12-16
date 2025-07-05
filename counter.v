`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: krishnashree
// 
// Create Date: 02.07.2025 16:44:05
// Design Name: 
// Module Name: entry_counter_non2n
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


module entry_counter_non2n #(
   parameter FIFO_DEPTH = 520 ,
   parameter PTR_WIDTH = 10
 )(
   input wclk,wrst_n,w_en,rclk,rrst_n,r_en,
   output reg full,empty,
   output reg [PTR_WIDTH-1:0] count
 );
   always@(posedge wclk or negedge wrst_n) begin
     if(!wrst_n)
       count<=0;
     else if(w_en && !full && !(r_en &&!empty))
       count<=count+1;
     else if(w_en && !full && (r_en &&!empty))
       count<=count;
     else if(!(w_en && !full) && (r_en &&!empty))
       count<=count-1;
     end
     
   always@(posedge wclk or negedge wrst_n) begin
     if(!wrst_n) //!a that means a=0
       full<=0;
     else
       full<=(count== FIFO_DEPTH);
     end
   always@(posedge rclk or negedge rrst_n) begin
     if(!rrst_n)
       empty<=1;
     else
       empty <=(count==0);
     end
endmodule
