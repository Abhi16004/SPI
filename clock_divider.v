`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: clock_divider
//////////////////////////////////////////////////////////////////////////////////

module clock_divider(
    input wire clk,
    input wire reset,
    output reg spi_clk
);
    reg [1:0] counter;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            counter <= 0;
            spi_clk <= 0;
        end else if (counter == 3) begin
            counter <= 0;
            spi_clk <= ~spi_clk;
        end else begin
            counter <= counter + 1;
        end
    end
endmodule
