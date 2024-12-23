`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: Slave
//////////////////////////////////////////////////////////////////////////////////

module Slave(
    input wire rst,              // Reset signal.
    input wire SCLK,             // SPI clock from Master.
    input wire MOSI,             // Master Out, Slave In.
    input wire SS,               // Slave select.
    input wire [7:0] data_tx,    // Input data to transmit by MISO.
    output reg MISO,             // Master In, Slave Out.
    output reg [7:0] data_rx     // Data received from Master.
);
    
    reg [7:0] Tx_Reg;           // Data to MOSI is stored here.
    reg [7:0] Rx_Reg;           // Data received by MISO is stored here.
    reg [3:0] counter;          // To keep count of transmitted bits.

    parameter INIT = 2'b00, LOAD = 2'b01, COMM = 2'b10, FINISH = 2'b11;
    reg [1:0] state;

    always @(posedge SCLK or posedge rst) begin
        if (rst) begin
            counter <= 0;
            MISO    <= 0;
            Tx_Reg  <= 0;
            Rx_Reg  <= 0;
            state   <= INIT;
        end else begin
            case (state)
                INIT: state <= (~SS) ? LOAD : INIT;
                LOAD: state <= COMM;
                COMM: state <= (counter == 4'b1000) ? FINISH : COMM;
                FINISH: state <= INIT;
            endcase
        end
    end

    always @(posedge SCLK) begin
        case (state)
            INIT: counter <= 0;
            LOAD: Tx_Reg <= data_tx;
            COMM: begin
                MISO   <= Tx_Reg[7];
                Rx_Reg <= {Rx_Reg[6:0], MOSI};
                Tx_Reg <= {Tx_Reg[6:0], 1'b0};
                counter <= counter + 1;
            end
            FINISH: data_rx <= Rx_Reg;
        endcase
    end
endmodule

