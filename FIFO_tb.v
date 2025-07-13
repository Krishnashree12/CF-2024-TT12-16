`timescale 1ns/1ps

module FIFO_tb;

    parameter DSIZE = 8;
    parameter ASIZE = 3;
    parameter DEPTH = 1 << ASIZE;

    reg  [DSIZE-1:0] wdata;
    wire [DSIZE-1:0] rdata;
    wire wfull, rempty;
    reg winc, rinc, wclk, rclk, wrst_n, rrst_n;

    // Instantiate FIFO
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

    integer i;
    integer seed = 1;
    reg [DSIZE-1:0] expected_data [0:DEPTH+5]; // Store expected written data
    integer read_index = 0, write_index = 0;

    // Clock generation
    always #5  wclk = ~wclk;
    always #10 rclk = ~rclk;

    initial begin
        // Initialize
        wclk = 0; rclk = 0;
        wrst_n = 0; rrst_n = 0;
        winc = 0; rinc = 0;
        wdata = 0;

        // Apply reset
        #20;
        wrst_n = 1;
        rrst_n = 1;

        // Test 1: Write < DEPTH values
        $display("----- Test 1: Write then Read -----");
        for (i = 0; i < DEPTH; i = i + 1) begin
            @(posedge wclk);
            if (!wfull) begin
                wdata = $random(seed);
                expected_data[write_index] = wdata;
                write_index = write_index + 1;
                winc = 1;
            end else begin
                winc = 0;
            end
        end
        winc = 0;

        // Wait a bit, then start reading
        #20;
        for (i = 0; i < DEPTH; i = i + 1) begin
            @(posedge rclk);
            if (!rempty) begin
                rinc = 1;
                #1;
                if (rdata !== expected_data[read_index]) begin
                    $display("❌ Mismatch at time %0t: Expected = %h, Got = %h", $time, expected_data[read_index], rdata);
                end else begin
                    $display("✅ Match at time %0t: %h", $time, rdata);
                end
                read_index = read_index + 1;
            end else begin
                rinc = 0;
            end
        end
        rinc = 0;

        // Test 2: Overflow condition
        $display("----- Test 2: FIFO Overflow -----");
        for (i = 0; i < DEPTH + 3; i = i + 1) begin
            @(posedge wclk);
            if (!wfull) begin
                wdata = $random(seed);
                winc = 1;
                $display("Writing: %h", wdata);
            end else begin
                winc = 0;
                $display("🛑 Write blocked at time %0t (FIFO FULL)", $time);
            end
        end
        winc = 0;

        // Test 3: Underflow condition
        $display("----- Test 3: FIFO Underflow -----");
        for (i = 0; i < DEPTH + 3; i = i + 1) begin
            @(posedge rclk);
            if (!rempty) begin
                rinc = 1;
                $display("Reading: %h", rdata);
            end else begin
                rinc = 0;
                $display("⚠️ Read blocked at time %0t (FIFO EMPTY)", $time);
            end
        end
        rinc = 0;

        #20;
        $display("✅ Simulation finished.");
        $finish;
    end

endmodule
