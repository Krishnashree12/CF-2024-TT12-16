
module clock_divider #(parameter DIV = 50_000_000)( // default: 100 MHz / (2*50M) = 1 Hz
    input  wire clk,      // input 100 MHz system clock (from Basys-3)
    input  wire rst_n,    // active low reset
    output reg  clk_out   // divided clock
);
    reg [31:0] counter;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            counter <= 0;
            clk_out <= 0;
        end else begin
            if (counter == DIV-1) begin
                counter <= 0;
                clk_out <= ~clk_out; // toggle
            end else begin
                counter <= counter + 1;
            end
        end
    end
endmodule
