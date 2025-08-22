`default_nettype none
`timescale 1ns/1ps

module tt_um_fifo (
    input  wire [7:0] ui_in,    // Switches (8-bit input data)
    output wire [7:0] uo_out,   // LEDs (8-bit read data output)
    input  wire [7:0] uio_in,   // Unused (set to zero)
    output wire [7:0] uio_out,  // Unused
    output wire [7:0] uio_oe,   // Unused
    input  wire       clk,      // 100 MHz system clock
    input  wire       rst_n     // Reset (active low, usually button)
);

    // Internal signals
    wire wclk, rclk;
    wire full, empty;
    reg  winc, rinc;
    wire [7:0] rdata;

    // Clock dividers: generate slow clocks from system clock
    clock_divider #(50_000_000) wclk_div ( // 1 Hz
        .clk(clk),
        .rst_n(rst_n),
        .clk_out(wclk)
    );

    clock_divider #(25_000_000) rclk_div ( // 2 Hz
        .clk(clk),
        .rst_n(rst_n),
        .clk_out(rclk)
    );

    // Simple control: always try to write and read (for demo)
    always @(*) begin
        winc = ~full;   // Write only when not full
        rinc = ~empty;  // Read only when not empty
    end

    // FIFO instance
    fifo #(8,3) myfifo (   // 8-bit data, 8-depth FIFO
        .rdata(rdata),
        .wdata(ui_in),   // input from switches
        .full(full),
        .empty(empty),
        .winc(winc),
        .rinc(rinc),
        .wclk(wclk),
        .rclk(rclk),
        .wrst_n(rst_n),
        .rrst_n(rst_n)
    );

    // Output LEDs show read data
    assign uo_out  = rdata;
    assign uio_out = 8'b0;
    assign uio_oe  = 8'b0;

endmodule
