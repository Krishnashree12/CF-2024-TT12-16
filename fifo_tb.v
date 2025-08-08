module fifo_tb;
    parameter DATA_WIDTH = 8, ADDR_WIDTH = 4;

    reg wclk, wrst_n, rclk, rrst_n, winc, rinc;
    reg [DATA_WIDTH-1:0] wdata;
    wire [DATA_WIDTH-1:0] rdata;
    wire full, empty;

    fifo #(DATA_WIDTH, ADDR_WIDTH) dut (
        .wclk(wclk), .wrst_n(wrst_n), .winc(winc),
        .rclk(rclk), .rrst_n(rrst_n), .rinc(rinc),
        .wdata(wdata), .rdata(rdata),
        .full(full), .empty(empty)
    );

    // Clock generation
    initial begin
        wclk = 0; forever #5 wclk = ~wclk;
    end

    initial begin
        rclk = 0; forever #7 rclk = ~rclk;
    end

    initial begin
        wrst_n = 0; rrst_n = 0; winc = 0; rinc = 0; wdata = 0;
        #15 wrst_n = 1; rrst_n = 1;

        // Write 10 values
        repeat (10) begin
            @(posedge wclk);
            if (!full) begin
                winc = 1; wdata = $random;
            end else begin
                winc = 0;
            end
        end

        winc = 0;

        // Read 10 values
        repeat (10) begin
            @(posedge rclk);
            if (!empty)
                rinc = 1;
            else
                rinc = 0;
        end

        rinc = 0;
        #100 $finish;
    end
endmodule
