`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: SPI
//////////////////////////////////////////////////////////////////////////////////

module SPI(
    input wire reset,
    input wire ON,
    input wire CLK,
    input wire [7:0] master_in,
    input wire [7:0] slave_in,
    output wire [7:0] master_out,
    output wire [7:0] slave_out
);
    wire MISO;
    wire MOSI;
    wire SS;
    wire SCLK;

    Master M1 (
        .rst(reset),
        .on(ON),
        .clk(CLK),
        .data_tx(master_in),
        .MISO(MISO),
        .SS(SS),
        .MOSI(MOSI),
        .SCLK(SCLK),
        .data_rx(master_out)
    );

    Slave S1 (
        .rst(reset),
        .SCLK(SCLK),
        .MOSI(MOSI),
        .SS(SS),
        .data_tx(slave_in),
        .MISO(MISO),
        .data_rx(slave_out)
    );
endmodule
