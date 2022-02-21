`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/11/30 22:06:23
// Design Name: 
// Module Name: SEN_TOP
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
`define sobel_en
`define canny_en

module ISP_TOP(
  input clk_wr,
  input clk_rd,
  input clk_fpga,
  input rst_n,
  input ping_pong_en,
  input [23:0] sdram_wr_addr_max,
  input [23:0] sdram_wr_addr_min,
  input [23:0] sdram_rd_addr_max,
  input [23:0] sdram_rd_addr_min,
  input rd_valid,
  input [9:0] br_length,
  output H_SYNC,
  output V_SYNC,
  output BLANK,
  output [15:0] display_data
    );

  wire i_HSYNC;
  wire i_VSYNC;
  wire i_BLANK;
  wire i_HSYNC_grey;
  wire i_VSYNC_grey;
  wire i_BLANK_grey;
  wire i_HSYNC_sobel;
  wire i_VSYNC_sobel;
  wire i_BLANK_sobel;
  wire [7:0] Y0_grey;
  wire [15:0] display_data_grey;
  wire [15:0] i_display_data;
  wire data_req;
  wire [15:0] r_data_out;
  wire init_done;
  wire          sdram_clk;
  wire          sdram_cke;
  wire          sdram_cs_n;
  wire          sdram_ras_n;
  wire          sdram_cas_n;
  wire          sdram_we_n;
  wire   [1:0]  sdram_dqm;
  wire   [1:0]  sdram_bank;
  wire   [12:0] sdram_addr;

  wire   [15:0] sdram_data;
  wire   [15:0] w_data_in;
  wire          wr_en;
  reg [15:0] data_src_mem[0:307199];
  reg  [18:0] data_src_addr;
  wire   [14:0] canny_in;

  always @(posedge clk_wr or negedge rst_n) begin
      if(!rst_n || !init_done) begin
        data_src_addr <= 18'b0;
      end
      else if (data_src_addr == 307199) begin
        data_src_addr <= 18'b0;
      end
      else begin
        data_src_addr <= data_src_addr + 1'b1;
      end
  end
  assign wr_en = init_done;
  assign w_data_in = data_src_mem[data_src_addr];
sdram_top U_SDRAM_TOP_0
(  .clk               ( clk_fpga          ),
   .rst_n             ( rst_n             ),
   .wr_clk            ( clk_wr            ),
   .rd_clk            ( clk_rd            ),
   .ping_pong_en      ( ping_pong_en      ),
   .sdram_wr_addr_max ( sdram_wr_addr_max ),
   .sdram_wr_addr_min ( sdram_wr_addr_min ),
   .sdram_rd_addr_max ( sdram_rd_addr_max ),
   .sdram_rd_addr_min ( sdram_rd_addr_min ),
   .w_data_in         ( w_data_in         ),
   .wr_en             ( wr_en             ),
   .rd_en             ( data_req          ),
   .r_data_out        ( r_data_out        ),
   .br_length         ( br_length         ),
   .rd_valid          ( rd_valid          ),
   .init_done         ( init_done         ),
   .sdram_clk         ( sdram_clk         ),
   .sdram_cke         ( sdram_cke         ),
   .sdram_cs_n        ( sdram_cs_n        ),
   .sdram_ras_n       ( sdram_ras_n       ),
   .sdram_cas_n       ( sdram_cas_n       ),
   .sdram_we_n        ( sdram_we_n        ),
   .sdram_dqm         (          ),
   .sdram_bank        ( sdram_bank        ),
   .sdram_addr        ( sdram_addr        ),
   .sdram_data        ( sdram_data        ));

sdram_model_plus U_SDRAM_MODEL_PLUS_0
(  .Addr      ( sdram_addr      ),
   .Ba        ( sdram_bank        ),
   .Clk       ( sdram_clk       ),
   .Cke       ( sdram_cke       ),
   .Cs_n      ( sdram_cs_n      ),
   .Ras_n     ( sdram_ras_n     ),
   .Cas_n     ( sdram_cas_n     ),
   .We_n      ( sdram_we_n      ),
   .Dqm       ( 2'b00       ),
   .Debug     ( 1'b1     ),
   .Dq        ( sdram_data        ));

VGA_CTRL u_VGA_CTRL(
  .clk(clk_rd),
  .rst_n(rst_n && init_done),
  .H_SYNC(i_HSYNC),
  .V_SYNC(i_VSYNC),
  .BLANK(i_BLANK),
  .i_data(r_data_out),
  .data(i_display_data),
  .data_req(data_req)
  );

RGB2YUV U_RGB2YUV_0
(  .clk            ( clk_rd            ),
   .rst_n          ( rst_n && init_done),
   .i_HSYNC        ( i_HSYNC        ),
   .i_VSYNC        ( i_VSYNC        ),
   .i_BLANK        ( i_BLANK        ),
   .i_display_data ( i_display_data ),
   .Y0             ( Y0_grey),
   .H_SYNC         ( i_HSYNC_grey         ),
   .V_SYNC         ( i_VSYNC_grey         ),
   .BLANK          ( i_BLANK_grey          ),
   .display_data   ( display_data_grey   ));
`ifdef emboss_en
EMBOSS U_EMBOSS_0
(  .clk          ( clk_rd          ),
   .shreshold    ( 150    ),
   .rst_n        ( rst_n && init_done        ),
   .i_HSYNC      ( i_HSYNC_grey      ),
   .i_VSYNC      ( i_VSYNC_grey      ),
   .i_BLANK      ( i_BLANK_grey      ),
   .i_Y0         ( Y0_grey         ),
   .H_SYNC       ( H_SYNC       ),
   .V_SYNC       ( V_SYNC       ),
   .BLANK        ( BLANK        ),
   .display_data ( display_data ));
`endif

`ifdef log_en
LOG U_LOG_0
(  .clk          ( clk_rd          ),
   .rst_n        ( rst_n && init_done        ),
   .i_HSYNC      ( i_HSYNC_grey      ),
   .i_VSYNC      ( i_VSYNC_grey      ),
   .i_BLANK      ( i_BLANK_grey      ),
   .i_Y0         ( Y0_grey         ),
   .H_SYNC       ( H_SYNC       ),
   .V_SYNC       ( V_SYNC       ),
   .BLANK        ( BLANK        ),
   .display_data ( display_data ));
`endif

`ifdef histogram_en
HISTOGRAM U_HISTOGRAM_0
(  .clk          ( clk_rd          ),
   .rst_n        ( rst_n && init_done        ),
   .i_HSYNC      ( i_HSYNC_grey      ),
   .i_VSYNC      ( i_VSYNC_grey      ),
   .i_BLANK      ( i_BLANK_grey      ),
   .i_Y0         ( Y0_grey         ),
   .H_SYNC       ( H_SYNC       ),
   .V_SYNC       ( V_SYNC       ),
   .BLANK        ( BLANK        ),
   .display_data ( display_data ));
`endif

`ifdef histogram_eq_en
HISTOGRAM_EQ U_HISTOGRAM_EQ_0
(  .clk          ( clk_rd          ),
   .rst_n        ( rst_n && init_done        ),
   .i_HSYNC      ( i_HSYNC_grey      ),
   .i_VSYNC      ( i_VSYNC_grey      ),
   .i_BLANK      ( i_BLANK_grey      ),
   .i_Y0         ( Y0_grey         ),
   .H_SYNC       ( H_SYNC       ),
   .V_SYNC       ( V_SYNC       ),
   .BLANK        ( BLANK        ),
   .display_data ( display_data ));
`endif

`ifdef median_filter_en
median_filter U_MEDIAN_FILTER_0
(  .clk          ( clk_rd          ),
   .rst_n        ( rst_n && init_done        ),
   .i_HSYNC      ( i_HSYNC_grey      ),
   .i_VSYNC      ( i_VSYNC_grey      ),
   .i_BLANK      ( i_BLANK_grey      ),
   .i_Y0         ( Y0_grey         ),
   .H_SYNC       ( H_SYNC       ),
   .V_SYNC       ( V_SYNC       ),
   .BLANK        ( BLANK        ),
   .display_data ( display_data ));
`endif

`ifdef gaussian_filter_en
gaussian_filter U_GAUSSIAN_FILTER_0
(  .clk          ( clk_rd          ),
   .rst_n        ( rst_n && init_done        ),
   .i_HSYNC      ( i_HSYNC_grey      ),
   .i_VSYNC      ( i_VSYNC_grey      ),
   .i_BLANK      ( i_BLANK_grey      ),
   .i_Y0         ( Y0_grey         ),
   .H_SYNC       ( H_SYNC       ),
   .V_SYNC       ( V_SYNC       ),
   .BLANK        ( BLANK        ),
   .display_data ( display_data ));
`endif

`ifdef sobel_en
sobel U_SOBEL_0
(  .clk          ( clk_rd          ),
   .rst_n        ( rst_n && init_done        ),
   .i_HSYNC      ( i_HSYNC_grey      ),
   .i_VSYNC      ( i_VSYNC_grey      ),
   .i_BLANK      ( i_BLANK_grey      ),
   .i_Y0         ( Y0_grey         ),
   .thresh_min   ( 60 )          ,
   .thresh_max   ( 120 )          ,
   .H_SYNC       ( i_HSYNC_sobel       ),
   .V_SYNC       ( i_VSYNC_sobel       ),
   .BLANK        ( i_BLANK_sobel        ),
   .canny_in     (canny_in)
`ifndef canny_en
  ,
   .display_data ( display_data )
`endif
);

`ifdef canny_en
canny U_CANNY_0
(  .clk          ( clk_rd          ),
   .rst_n        ( rst_n && init_done        ),
   .i_HSYNC      ( i_HSYNC_sobel      ),
   .i_VSYNC      ( i_VSYNC_sobel      ),
   .i_BLANK      ( i_BLANK_sobel      ),
   .canny_in     ( canny_in     ),
   .H_SYNC       ( H_SYNC       ),
   .V_SYNC       ( V_SYNC       ),
   .BLANK        ( BLANK        ),
   .display_data ( display_data ));
`endif
`endif

`ifdef color_log_en
COLOR_LOG U_COLOR_LOG_0
(  .clk            ( clk_rd            ),
   .rst_n          ( rst_n && init_done          ),
   .i_HSYNC        ( i_HSYNC        ),
   .i_VSYNC        ( i_VSYNC        ),
   .i_BLANK        ( i_BLANK        ),
   .i_display_data ( i_display_data ),
   .H_SYNC         ( H_SYNC         ),
   .V_SYNC         ( V_SYNC         ),
   .BLANK          ( BLANK          ),
   .display_data   ( display_data   ));
`endif

`ifdef color_histogram_en
COLOR_HISTOGRAM U_COLOR_HISTOGRAM_0
(  .clk            ( clk_rd            ),
   .rst_n          ( rst_n && init_done          ),
   .i_HSYNC        ( H_SYNC        ),
   .i_VSYNC        ( V_SYNC        ),
   .i_BLANK        ( BLANK        ),
   .i_display_data ( i_display_data ),
   .H_SYNC         ( H_SYNC         ),
   .V_SYNC         ( V_SYNC         ),
   .BLANK          ( BLANK          ),
   .display_data   ( display_data   ));
`endif

endmodule
