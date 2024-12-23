`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: Master
// Project Name: SPI PROTOCOL IMPLEMENTATION  
//////////////////////////////////////////////////////////////////////////////////

module Master (
    input wire rst,           // Reset signal.
    input wire on,            // Transmission start signal.
    input wire clk,           // System clock.
    input wire [7:0] data_tx, // Input data to transmit by MOSI.
    input wire MISO,          // Master In, Slave Out.
    output reg SS,            // Slave select.
    output reg MOSI,          // Master Out, Slave In.
    output wire SCLK,         // SPI clock to Slave.
    output reg [7:0] data_rx  // Data received from Slave.
);
    
    reg [7:0] Tx_Reg;        // Data to MOSI is stored here.
    reg [7:0] Rx_Reg;        // Data received by MISO is stored here.
    reg [3:0] counter;       // To keep count of transmitted bits.
    wire spi_clk;
    
    clock_divider clk_div (
        .clk(clk),
        .reset(rst),
        .spi_clk(spi_clk)
     );
     assign SCLK = spi_clk;
     
    parameter INIT = 2'b00, LOAD = 2'b01, COMM = 2'b10, FINISH = 2'b11;
    reg [1:0] state;

    always @(posedge spi_clk or posedge rst) begin
        if (rst) begin
            counter <= 4'b0000;
            MOSI    <= 0;
            Tx_Reg  <= 0;
            Rx_Reg  <= 0;
            SS      <= 1;
            state   <= INIT;
        end else begin
            case (state)
                INIT: state <= (on == 1'b1) ? LOAD : INIT;
                LOAD: state <= COMM;
                COMM: state <= (counter == 4'b1000) ? FINISH : COMM;
                FINISH: state <= INIT;
            endcase
        end
    end

    always @(posedge spi_clk) begin
        case (state)
            INIT: begin
                SS <= 0;
            end
            LOAD: begin
               //SS      <= 0;
                Tx_Reg  <= data_tx;
                counter <= 4'b0000;
            end
            COMM: begin
                 MOSI   <= Tx_Reg[7];
                 Rx_Reg <= {Rx_Reg[6:0], MISO};
                 Tx_Reg <= {Tx_Reg[6:0], 1'b0};
                 counter <= counter + 1;
            end
            FINISH: begin
                data_rx <= Rx_Reg;
                SS      <= 1;
            end
        endcase
    end
endmodule