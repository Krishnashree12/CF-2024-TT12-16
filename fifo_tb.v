`timescale 1ns/1ps

module fifo_tb();

    parameter DSIZE = 8; // Data bus size
    parameter ASIZE = 3; // Address bus size
    parameter DEPTH = 1 << ASIZE; // Depth of the FIFO memory

    reg [DSIZE-1:0] wdata;   // Input data
    wire [DSIZE-1:0] rdata;  // Output data
    wire full, empty;      // Write full and read empty signals
    reg winc, rinc, wclk, rclk, wrst_n, rrst_n; // Write and read signals

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

    integer i=0;
    integer seed = 1;

    // Read and write clock in loop
    always #5 wclk = ~wclk;    // faster writing
    always #10 rclk = ~rclk;   // slower reading
    
    initial begin
        // Initialize all signals
        wclk = 0;
        rclk = 0;
        wrst_n = 1;     // Active low reset
        rrst_n = 1;     // Active low reset
        winc = 0;
        rinc = 0;
        wdata = 0;

        // Reset the FIFO
        #40 wrst_n = 0; rrst_n = 0;
        #40 wrst_n = 1; rrst_n = 1;

        // TEST CASE 1: Write data and read it back
        $display("----- Test 1: Write then Read -----");
        rinc = 1;
        for (i = 0; i < 10; i = i + 1) begin
            wdata = $random(seed) % 256;
            winc = 1;
            #10;
            winc = 0;
            #10;
            $display("? MATCH at %0t: %02x", $time, rdata);
        end

        // TEST CASE 2: Write data to make FIFO full and try to write more data
        $display("----- Test 2: FIFO Overflow -----");
        rinc = 0;
        winc = 1;
        for (i = 0; i < DEPTH + 3; i = i + 1) begin
            wdata = $random(seed) % 256;
            #10;
             if (full)
                $display("? Write blocked at %0t (FULL)", $time);
             else
                $display("Writing: %02x at %0t", wdata, $time);
        end

        // TEST CASE 3: Read data from empty FIFO and try to read more data
        $display("----- Test 3: FIFO Underflow -----");
        winc = 0;
        rinc = 1;
        for (i = 0; i < DEPTH + 3; i = i + 1) begin
            #20;
            if (empty)
                $display("? Read blocked at %0t (EMPTY)", $time);
            else
                $display("Reading: %02x at %0t", rdata, $time);
        end

        $finish;
    end

endmodule
