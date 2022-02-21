`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/12/21 22:06:14
// Design Name: 
// Module Name: sobel
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


module sobel(
  input clk,
  input rst_n,
  input i_HSYNC,
  input i_VSYNC,
  input i_BLANK,
  input [7:0] i_Y0,
  input [10:0] thresh_min,
  input [10:0] thresh_max,
  output H_SYNC,
  output V_SYNC,
  output BLANK,
  output [14:0] canny_in,
  output [15:0] display_data
    );
  wire [7:0] o_matrix11;
  wire [7:0] o_matrix12;
  wire [7:0] o_matrix13;
  wire [7:0] o_matrix21;
  wire [7:0] o_matrix22;
  wire [7:0] o_matrix23;
  wire [7:0] o_matrix31;
  wire [7:0] o_matrix32;
  wire [7:0] o_matrix33;

matrix_generator U_MATRIX_GENERATOR_0
(  .clk        ( clk        ),
   .rst_n      ( rst_n      ),
   .i_HSYNC    ( i_HSYNC    ),
   .i_BLANK    ( i_BLANK    ),
   .i_Y0       ( i_Y0       ),
   .i_VSYNC    ( i_VSYNC    ),
   .o_VSYNC    ( o_VSYNC    ),
   .o_BLANK    ( o_BLANK    ),
   .o_HSYNC    ( o_HSYNC    ),
   .o_matrix11 ( o_matrix11 ),
   .o_matrix12 ( o_matrix12 ),
   .o_matrix13 ( o_matrix13 ),
   .o_matrix21 ( o_matrix21 ),
   .o_matrix22 ( o_matrix22 ),
   .o_matrix23 ( o_matrix23 ),
   .o_matrix31 ( o_matrix31 ),
   .o_matrix32 ( o_matrix32 ),
   .o_matrix33 ( o_matrix33 ));

  reg [9:0] gx_1;
  reg [9:0] gx_3;
  reg [9:0] gy_1;
  reg [9:0] gy_3;
  reg [9:0] gx;
  reg [9:0] gy;
  reg [19:0] g;
  wire [15:0] sqrg;
  reg [13:0] r_hsync;
  reg [13:0] r_vsync;
  reg [13:0] r_blank;
  reg [1:0] direction;
  reg [1:0] phase;
  reg [21:0] phase_d;
  wire [1:0] phase_o;
  reg [1:0] thresh;


cordic_0 sqr (
  .aclk(clk),                                      // input wire aclk
  .s_axis_cartesian_tvalid(rst_n),  // input wire s_axis_cartesian_tvalid
  .s_axis_cartesian_tdata({4'b0,g}),    // input wire [23 : 0] s_axis_cartesian_tdata
  .m_axis_dout_tvalid(),            // output wire m_axis_dout_tvalid
  .m_axis_dout_tdata(sqrg)              // output wire [15 : 0] m_axis_dout_tdata
);

  always @(posedge clk or negedge rst_n) begin
      if(!rst_n) begin
        gx_1 <= 10'b0;
        gx_3 <= 10'b0;
        gy_1 <= 10'b0;
        gy_3 <= 10'b0;
      end
      else begin
        gx_1 <= o_matrix11 + 2*o_matrix12 + o_matrix13;
        gx_3 <= o_matrix31 + 2*o_matrix32 + o_matrix33;
        gy_1 <= o_matrix11 + 2*o_matrix21 + o_matrix31;
        gy_3 <= o_matrix13 + 2*o_matrix23 + o_matrix33;
      end
    end

  always @(posedge clk or negedge rst_n) begin
      if(!rst_n) begin
        gx <= 10'b0;
        gy <= 10'b0;
        direction <= 2'b0;
      end
      else begin
        gx <= (gx_1 > gx_3) ? gx_1 - gx_3 : gx_3 - gx_1;
        gy <= (gy_1 > gy_3) ? gy_1 - gy_3 : gy_3 - gy_1;
        direction <= {{gx_1 > gx_3}, {gy_1 > gy_3}};
      end
    end


  always@(posedge clk or negedge rst_n) begin
      if (gx > 2 * gy) begin
        phase <= 2'b00;
      end
      else if (gy > 2 * gx) begin
        phase <= 2'b10;
      end
      else if (direction[0] == direction[1]) begin
        phase <= 2'b01;
      end
      else begin
        phase <= 2'b11;
      end
    end

  always @(*) begin
      if(sqrg > thresh_max) begin
        thresh <= 2'b11;
      end
      else if (sqrg < thresh_min) begin
        thresh <= 2'b01;
      end
      else begin
        thresh <= 2'b10;
      end
  end

  assign canny_in = {phase, thresh, sqrg[10:0]};

  always @(posedge clk or negedge rst_n) begin
      if(!rst_n) begin
        phase_d <= 22'b0;
      end
      else begin
        phase_d <= {phase_d[19:0], phase};
      end
    end

  assign phase_o = phase_d[21:20];


  always @(posedge clk or negedge rst_n) begin
      if(!rst_n) begin
        g <= 20'b0;
      end
      else begin
        g <= gx * gx + gy * gy;
      end
    end

  always @(posedge clk or negedge rst_n) begin
      if(!rst_n) begin
        r_vsync <= 14'b0;
      end
      else begin
        r_vsync <= {r_vsync[12:0], o_VSYNC};
      end
  end

  always @(posedge clk or negedge rst_n) begin
      if(!rst_n) begin
        r_hsync <= 14'b0;
      end
      else begin
        r_hsync <= {r_hsync[12:0], o_HSYNC};
      end
  end

  always @(posedge clk or negedge rst_n) begin
      if(!rst_n) begin
        r_blank <= 14'b0;
      end
      else begin
        r_blank <= {r_blank[12:0], o_BLANK};
      end
    end
  assign display_data = (sqrg > 120) ? 16'hffff : 0;
  assign H_SYNC = r_hsync[13];
  assign V_SYNC = r_vsync[13];
  assign BLANK = r_blank[13];
endmodule
