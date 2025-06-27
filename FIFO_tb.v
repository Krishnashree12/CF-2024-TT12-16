`timescale 1ns/1ps

module FIFO_tb;

    parameter DSIZE = 8;
    parameter ASIZE = 3;
    parameter DEPTH = 1 << ASIZE;

    reg  [DSIZE-1:0] wdata;
    wire [DSIZE-1:0] rdata;
    wire wfull, rempty;
    reg winc, rinc, wclk, rclk, wrst_n, rrst_n;

    FIFO #(DSIZE, ASIZE) uut (
        .wdata(wdata),
        .rdata(rdata),
        .wfull(wfull),
        .rempty(rempty),
        .winc(winc),
        .rinc(rinc),
        .wclk(wclk),
        .rclk(rclk),
        .wrst_n(wrst_n),
        .rrst_n(rrst_n)
    );

    reg [DSIZE-1:0] expected_data [0:DEPTH+5];
    integer i, seed = 1;
    integer write_index = 0, read_index = 0;

    always #5  wclk = ~wclk;
    always #10 rclk = ~rclk;

    initial begin
        wclk = 0; rclk = 0;
        wrst_n = 0; rrst_n = 0;
        winc = 0; rinc = 0; wdata = 0;

        #20; wrst_n = 1; rrst_n = 1;

        // Test 1: Write up to depth
        $display("----- Test 1: Write then Read -----");
        for (i = 0; i < DEPTH; i = i + 1) begin
            @(posedge wclk);
            if (!wfull) begin
                wdata = $random(seed);
                expected_data[write_index] = wdata;
                write_index = write_index + 1;
                winc = 1;
            end
        end
        @(posedge wclk); winc = 0;

        // Read all values back
        #20;
        for (i = 0; i < DEPTH; i = i + 1) begin
            @(posedge rclk);
            if (!rempty) begin
                rinc = 1;
            end
            @(posedge rclk);
            rinc = 0;
            if (rdata !== expected_data[read_index]) begin
                $display("❌ MISMATCH at %0t: Expected = %h, Got = %h", $time, expected_data[read_index], rdata);
            end else begin
                $display("✅ MATCH at %0t: %h", $time, rdata);
            end
            read_index = read_index + 1;
        end

        // Test 2: FIFO Overflow
        $display("----- Test 2: FIFO Overflow -----");
        for (i = 0; i < DEPTH + 3; i = i + 1) begin
            @(posedge wclk);
            if (!wfull) begin
                wdata = $random(seed);
                winc = 1;
                $display("Writing: %h at %0t", wdata, $time);
            end else begin
                winc = 0;
                $display("❗ Write blocked at %0t (FULL)", $time);
            end
        end
        @(posedge wclk); winc = 0;

        // Test 3: FIFO Underflow
        $display("----- Test 3: FIFO Underflow -----");
        for (i = 0; i < DEPTH + 3; i = i + 1) begin
            @(posedge rclk);
            if (!rempty) begin
                rinc = 1;
                $display("Reading: %h at %0t", rdata, $time);
            end else begin
                rinc = 0;
                $display("❗ Read blocked at %0t (EMPTY)", $time);
            end
            @(posedge rclk); rinc = 0;
        end

        #20;
        $display("✅ Simulation complete.");
        $finish;
    end

endmodule
