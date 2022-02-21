`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/11/28 19:44:26
// Design Name: 
// Module Name: sdram_top
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module sdram_top(
  input clk,
  input rst_n,
  input wr_clk,
  input rd_clk,
  input ping_pong_en,
  input [23:0] sdram_wr_addr_max,
  input [23:0] sdram_wr_addr_min,
  input [23:0] sdram_rd_addr_max,
  input [23:0] sdram_rd_addr_min,
  input [15:0] w_data_in,
  input wr_en,
  input rd_en,
  output [15:0] r_data_out,
  input [9:0] br_length,
  input rd_valid,
  output init_done,
  output sdram_clk,
  output sdram_cke,
  output sdram_cs_n,
  output sdram_ras_n,
  output sdram_cas_n,
  inout [15:0] sdram_data,
  output sdram_we_n,
  output [1:0] sdram_dqm,
  output [1:0] sdram_bank,
  output [12:0] sdram_addr
    );
  wire clk_out1;
  wire clk_out2;
  wire wr_ack;
  wire rd_ack;
  wire wr_req;
  wire rd_req;
  wire [15:0] wdata;
  wire [15:0] rdata;
  wire [9:0] wr_data_count;
  wire [9:0] rd_data_count;
  wire [23:0] sdram_wr_addr;
  wire [23:0] sdram_rd_addr;

wr_fifo u_wr_fifo (
  .rst(~rst_n),                      // input wire rst
  .wr_clk(wr_clk),                // input wire wr_clk
  .rd_clk(clk_out1),                // input wire rd_clk
  .din(w_data_in),                      // input wire [15 : 0] din
  .wr_en(wr_en),                  // input wire wr_en
  .rd_en(wr_ack),                  // input wire rd_en
  .dout(wdata),                    // output wire [15 : 0] dout
  .full(),                    // output wire full
  .empty(),                  // output wire empty
  .rd_data_count(rd_data_count),  // output wire [9 : 0] rd_data_count
  .wr_data_count(),  // output wire [9 : 0] wr_data_count
  .wr_rst_busy(),      // output wire wr_rst_busy
  .rd_rst_busy()      // output wire rd_rst_busy
);

wr_fifo u_rd_fifo (
  .rst(~rst_n),                      // input wire rst
  .wr_clk(clk_out1),                // input wire wr_clk
  .rd_clk(rd_clk),                // input wire rd_clk
  .din(rdata),                      // input wire [15 : 0] din
  .wr_en(rd_ack),                  // input wire wr_en
  .rd_en(rd_en),                  // input wire rd_en
  .dout(r_data_out),                    // output wire [15 : 0] dout
  .full(),                    // output wire full
  .empty(),                  // output wire empty
  .rd_data_count(),  // output wire [9 : 0] rd_data_count
  .wr_data_count(wr_data_count),  // output wire [9 : 0] wr_data_count
  .wr_rst_busy(),      // output wire wr_rst_busy
  .rd_rst_busy()      // output wire rd_rst_busy
);

sdram_ctrl U_SDRAM_CTRL_0
(  .clk           ( clk_out1      ),
   .rst_n         ( rst_n         ),
   .wr_sys_addr   ( sdram_wr_addr ),
   .rd_sys_addr   ( sdram_rd_addr ),
   .br_length     ( br_length     ),
   .wr_req        ( wr_req        ),
   .rd_req        ( rd_req        ),
   .wdata         ( wdata         ),
   .rdata         ( rdata         ), 
   .init_done     ( init_done     ),
   .wr_ack        ( wr_ack        ),
   .rd_ack        ( rd_ack        ),
   .sdrma_ref_clk ( ),
   .sdram_cke     ( sdram_cke     ),
   .sdram_cs_n    ( sdram_cs_n    ),
   .sdram_ras_n   ( sdram_ras_n   ),
   .sdram_cas_n   ( sdram_cas_n   ),
   .sdram_we_n    ( sdram_we_n    ),
   .sdram_dqm     ( sdram_dqm     ),
   .sdram_bank    ( sdram_bank    ),
   .sdram_addr    ( sdram_addr    ),
   .sdram_data    ( sdram_data    ));

fifo_ctrl U_FIFO_CTRL_0
(  .clk               ( clk               ),
   .rst_n             ( rst_n && init_done),
   .ping_pong_en      ( ping_pong_en      ),
   .br_length         ( br_length         ),
   .sdram_wr_addr_max ( sdram_wr_addr_max ),
   .sdram_wr_addr_min ( sdram_wr_addr_min ),
   .sdram_rd_addr_max ( sdram_rd_addr_max ),
   .sdram_rd_addr_min ( sdram_rd_addr_min ),
   .wr_data_count     ( rd_data_count     ),
   .rd_data_count     ( wr_data_count     ),
   .wr_ack            ( wr_ack            ),
   .rd_ack            ( rd_ack            ),
   .rd_valid          ( rd_valid          ),
   .wr_req            ( wr_req            ),
   .rd_req            ( rd_req            ),
   .sdram_wr_addr     ( sdram_wr_addr     ),
   .sdram_rd_addr     ( sdram_rd_addr     ));

  sdram_pll u_instance_name
   (
    // Clock out ports
    .clk_out1(clk_out1),     // output clk_out1
    .clk_out2(clk_out2),     // output clk_out2
    // Status and control signals
    .reset(~rst_n), // input reset
    .locked(),       // output locked
   // Clock in ports
    .clk_in1(clk));

  assign sdram_clk = clk_out2;
endmodule
