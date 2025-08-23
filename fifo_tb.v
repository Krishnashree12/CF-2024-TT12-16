`timescale 1ns/1ps

module fifo_tb();

    parameter DSIZE = 8;      // Data bus size
    parameter ASIZE = 4;      // Address bus size
    parameter DEPTH = 1 << ASIZE;

    reg  [3:0] wdata;
    wire [3:0] rdata;
    reg              winc, rinc;
    reg              clk, rst_n;
    wire full,empty;
    
        // Clock divider signals
    wire wclk;
    wire rclk;
    // Instantiate FIFO DUT
    clk_div clk_div ( 
        .clk(clk),
        .rst_n(~rst_n),
        .wclk(wclk),
        .rclk(rclk)
    );

     fifo #(DSIZE, ASIZE) dut ( 
        .rdata(rdata), 
        .wdata(wdata),
        .full(full),
        .empty(empty),
        .winc(winc), 
        .rinc(rinc), 
        .wclk(wclk), 
        .rclk(rclk), 
        .rst_n(rst_n)
    );
    integer i;
    integer seed = 1;

    // Clock generation
    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        // Initialization
        rst_n = 0;
        winc = 0;
        rinc = 0;
        wdata = 0;

        // Apply Reset
        $display("Applying Reset...");
        #40;  
        rst_n = 1;
        $display("Reset Released at %0t", $time);

        //--------------------------
        // TEST 1: Write 8 values
        //--------------------------
        $display("----- Write Test -----");
        for (i = 0; i < 8; i = i + 1) begin
            wdata = $random(seed) % 16;
            winc = 1;
            rinc = 0;
            #10;           // one write pulse
            winc = 0;
            #10;
            $display("Wrote: %02x at %0t", wdata, $time);
        end

        //---------------------------
        // TEST 2: Read them back
        //---------------------------
        $display("----- Read Test -----");
        winc = 0; // no writes during readback
        for (i = 0; i < 8; i = i + 1) begin
            rinc = 1;
            #10;
            rinc = 0;
            #10;
            if (!empty)
                $display("Read : %02x at %0t (empty=%0b, full=%0b)", rdata, $time, empty, full);
            else
                $display("Read blocked at %0t (EMPTY)", $time);
        end

        //---------------------------
        // TEST 3: FIFO Overflow
        //---------------------------
        $display("----- FIFO Overflow Test -----");
        rinc = 0;
        for (i = 0; i < DEPTH + 3; i = i + 1) begin
            wdata = $random(seed) % 256;
            winc = 1;
            #10;
            if (full)
                $display("Write blocked at %0t (FULL)", $time);
            else
                $display("Written: %02x at %0t", wdata, $time);
            winc = 0;
            #10;
        end

        //-----------------------------
        // TEST 4: FIFO Underflow
        //-----------------------------
        $display("----- FIFO Underflow Test -----");
        winc = 0;
        for (i = 0; i < DEPTH + 3; i = i + 1) begin
            rinc = 1;
            #10;
            if (empty)
                $display("Read blocked at %0t (EMPTY)", $time);
            else
                $display("Read: %02x at %0t (empty=%0b)", rdata, $time, empty);
            rinc = 0;
            #10;
        end

        $display("Simulation Finished.");
        $finish;
    end

endmodule