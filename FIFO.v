module FIFO #(parameter DSIZE = 8, ASIZE = 3) (
    output [DSIZE-1:0] rdata,
    input  [DSIZE-1:0] wdata,
    output             wfull,
    output             rempty,
    input              winc,
    input              rinc,
    input              wclk,
    input              rclk,
    input              wrst_n,
    input              rrst_n
);

    localparam DEPTH = 1 << ASIZE;

    // Memory
    reg [DSIZE-1:0] mem [0:DEPTH-1];

    // Write pointer and read pointer (binary and gray)
    reg [ASIZE:0] wptr_bin, rptr_bin;
    reg [ASIZE:0] wptr_gray, rptr_gray;

    // Synced pointers in opposite domains
    reg [ASIZE:0] rptr_gray_sync1, rptr_gray_sync2;
    reg [ASIZE:0] wptr_gray_sync1, wptr_gray_sync2;

    // Assign output data
    assign rdata = mem[rptr_bin[ASIZE-1:0]];

    // Empty and Full logic
    assign rempty = (rptr_gray == wptr_gray_sync2);
    assign wfull  = (wptr_gray == {~rptr_gray_sync2[ASIZE:ASIZE-1], rptr_gray_sync2[ASIZE-2:0]});

    // Gray code conversion functions
    function [ASIZE:0] bin2gray;
        input [ASIZE:0] bin;
        bin2gray = bin ^ (bin >> 1);
    endfunction

    function [ASIZE:0] gray2bin;
        input [ASIZE:0] gray;
        integer i;
        begin
            gray2bin[ASIZE] = gray[ASIZE];
            for (i = ASIZE-1; i >= 0; i = i - 1)
                gray2bin[i] = gray2bin[i+1] ^ gray[i];
        end
    endfunction

    // Write logic
    always @(posedge wclk or negedge wrst_n) begin
        if (!wrst_n) begin
            wptr_bin <= 0;
            wptr_gray <= 0;
        end else if (winc && !wfull) begin
            mem[wptr_bin[ASIZE-1:0]] <= wdata;
            wptr_bin <= wptr_bin + 1;
            wptr_gray <= bin2gray(wptr_bin + 1);
        end
    end

    // Read logic
    always @(posedge rclk or negedge rrst_n) begin
        if (!rrst_n) begin
            rptr_bin <= 0;
            rptr_gray <= 0;
        end else if (rinc && !rempty) begin
            rptr_bin <= rptr_bin + 1;
            rptr_gray <= bin2gray(rptr_bin + 1);
        end
    end

    // Synchronize read pointer into write clock domain
    always @(posedge wclk or negedge wrst_n) begin
        if (!wrst_n) begin
            rptr_gray_sync1 <= 0;
            rptr_gray_sync2 <= 0;
        end else begin
            rptr_gray_sync1 <= rptr_gray;
            rptr_gray_sync2 <= rptr_gray_sync1;
        end
    end

    // Synchronize write pointer into read clock domain
    always @(posedge rclk or negedge rrst_n) begin
        if (!rrst_n) begin
            wptr_gray_sync1 <= 0;
            wptr_gray_sync2 <= 0;
        end else begin
            wptr_gray_sync1 <= wptr_gray;
            wptr_gray_sync2 <= wptr_gray_sync1;
        end
    end

endmodule
