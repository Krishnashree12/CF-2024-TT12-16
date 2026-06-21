`timescale 1ns/1ps

module fifo_tb();

    parameter DSIZE = 8;      // Data bus size
    parameter ASIZE = 3;      // Address bus size
    parameter DEPTH = 1 << ASIZE; // Depth of the FIFO memory

    reg  [DSIZE-1:0] wdata;   // Input data
    wire [DSIZE-1:0] rdata;   // Output data
    wire full, empty;         // FIFO status signals
    reg winc, rinc, wclk, rclk, wrst_n, rrst_n; 

    // Instantiate FIFO DUT
    fifo #(DSIZE, ASIZE) dut ( 
        .rdata(rdata), 
        .wdata(wdata),
        .full(full),
        .empty(empty),
        .winc(winc), 
        .rinc(rinc), 
        .wclk(wclk), 
        .rclk(rclk), 
        .wrst_n(wrst_n), 
        .rrst_n(rrst_n)
    );

    integer i;
    integer seed = 1;

    // Write and Read clocks
    always #5  wclk = ~wclk;   // faster write clock
    always #10 rclk = ~rclk;   // slower read clock

    initial begin
        // Initialize signals
        wclk = 0; 
        rclk = 0;
        wrst_n = 0; 
        rrst_n = 0;
        winc = 0;
        rinc = 0;
        wdata = 0;

        // Apply Reset
        $display("Applying Reset...");
        #40; 
        wrst_n = 1; 
        rrst_n = 1;
        $display("Reset Released at %0t", $time);

        //-----------------------------------------------------
        // TEST 1: Write some data and then read it back
        //-----------------------------------------------------
        $display("----- Test 1: Write then Read -----");

        // Phase A: Write 8 values
        rinc = 0;
        for (i = 0; i < 8; i = i + 1) begin
            wdata = $random(seed) % 256;
            winc = 1;
            #10;  // one write cycle
            winc = 0;
            #10;
            $display("Wrote: %02x at %0t", wdata, $time);
        end

        // Phase B: Read them back
        winc = 0;
        rinc = 1;
        for (i = 0; i < 8; i = i + 1) begin
            #20; // wait for read cycle
            if (!empty)
                $display("Read: %02x at %0t", rdata, $time);
            else
                $display("Read blocked at %0t (EMPTY)", $time);
        end

        //-----------------------------------------------------
        // TEST 2: FIFO Overflow
        //-----------------------------------------------------
        $display("----- Test 2: FIFO Overflow -----");
        rinc = 0;  // disable reads
        winc = 1;
        for (i = 0; i < DEPTH + 3; i = i + 1) begin
            wdata = $random(seed) % 256;
            #10;
            if (full)
                $display("Write blocked at %0t (FULL)", $time);
            else
                $display("Writing: %02x at %0t", wdata, $time);
        end
        winc = 0;

        //-----------------------------------------------------
        // TEST 3: FIFO Underflow
        //-----------------------------------------------------
        $display("----- Test 3: FIFO Underflow -----");
        winc = 0; // disable writes
        rinc = 1;
        for (i = 0; i < DEPTH + 3; i = i + 1) begin
            #20;
            if (empty)
                $display("Read blocked at %0t (EMPTY)", $time);
            else
                $display("Reading: %02x at %0t", rdata, $time);
        end
        rinc = 0;

        //-----------------------------------------------------
        $display("Simulation Finished.");
        $finish;
    end

endmodule
