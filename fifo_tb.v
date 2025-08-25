`timescale 1ns/1ps

module fifo_tb;
  // Parameters
  parameter DSIZE = 4;
  parameter ASIZE = 3;
  localparam DEPTH = 1 << ASIZE;
  // Signals
  reg               clk;   // main simulation clock (100 MHz)
  reg               rst_n;
  wire              wclk, rclk;
  reg               winc, rinc;
  reg  [DSIZE-1:0]  wdata;
  wire [DSIZE-1:0]  rdata;
  wire              full, empty;
  
  // DUT instantiation
  fifo #(.DSIZE(DSIZE), .ASIZE(ASIZE)) dut (
      .clk  (clk),    
      .rst_n  (rst_n),
      .wclk    (wclk),
      .rclk    (rclk),
      .winc    (winc),
      .rinc    (rinc),
      .wdata   (wdata),
      .rdata   (rdata),
      .full   (full),
      .empty  (empty)
  );

  // Main clock generation (100 MHz)
  initial begin
      clk = 0;
      forever #5 clk = ~clk; // 10 ns period
  end

  // Reset sequence
  initial begin
      rst_n = 0;
      winc   = 0;
      rinc   = 0;
      wdata  = 0;
      #50;             // hold reset
      rst_n = 1;      // release write reset
  end

  // Write process (1-cycle pulse)
  initial begin
      @(posedge rst_n); // wait until write reset deasserted
      forever begin
          @(posedge wclk);
          if (!full) begin
              wdata <= wdata + 1;
              winc  <= 1;
          end else
              winc  <= 0;
          @(posedge wclk); // pulse only one cycle
          winc <= 0;
      end
  end

  // Read process (1-cycle pulse)
  initial begin
      @(posedge rst_n); // wait until read reset deasserted
      #30;              // wait so FIFO fills
      forever begin
          @(posedge rclk);
          if (!empty)
              rinc <= 1;
          else
              rinc <= 0;
          @(posedge rclk); // pulse only one cycle
          rinc <= 0;
      end
  end

  // Monitor FIFO transactions
  initial begin
      $display("Time\twdata\trdata\twfull\trempty");
      $monitor("%0t\t%0h\t%0h\t%b\t%b", $time, wdata, rdata, full, empty);
  end

  // Stop simulation
  initial begin
      #3000;
      $finish;
  end
  
endmodule
