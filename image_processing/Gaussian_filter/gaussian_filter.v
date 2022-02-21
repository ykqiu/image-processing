`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/12/21 21:16:10
// Design Name: 
// Module Name: gaussian_filter
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


module gaussian_filter(
  input clk,
  input rst_n,
  input i_HSYNC,
  input i_VSYNC,
  input i_BLANK,
  input [7:0] i_Y0,
  output H_SYNC,
  output V_SYNC,
  output BLANK,
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
  reg [9:0] gs_1;
  reg [10:0] gs_2;
  reg [9:0] gs_3;
  reg [11:0] gs_sum;
  reg [7:0] gs_data;
  reg [2:0] r_hsync;
  reg [2:0] r_vsync;
  reg [2:0] r_blank;

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


  always @(posedge clk or negedge rst_n) begin
      if(!rst_n) begin
        gs_1 <= 10'b0;
        gs_2 <= 11'b0;
        gs_3 <= 10'b0;
      end
      else begin
        gs_1 <= o_matrix11 + 2*o_matrix12 + o_matrix13;
        gs_2 <= 2*o_matrix21 + 4*o_matrix22 + 2*o_matrix23;
        gs_3 <= o_matrix31 + 2*o_matrix32 + o_matrix33;
      end
  end

  always @(posedge clk or negedge rst_n) begin
      if(!rst_n) begin
        gs_sum <= 12'b0;
      end
      else begin
        gs_sum <= gs_1 + gs_2 + gs_3;
      end
  end

  always @(posedge clk or negedge rst_n) begin
      if(!rst_n) begin
        gs_data <= 8'b0;
      end
      else begin
        gs_data <= gs_sum >> 4;
      end
  end

  always @(posedge clk or negedge rst_n) begin
      if(!rst_n) begin
        r_vsync <= 3'b0;
      end
      else begin
        r_vsync <= {r_vsync[1:0], o_VSYNC};
      end
  end

  always @(posedge clk or negedge rst_n) begin
      if(!rst_n) begin
        r_hsync <= 3'b0;
      end
      else begin
        r_hsync <= {r_hsync[1:0], o_HSYNC};
      end
  end

  always @(posedge clk or negedge rst_n) begin
      if(!rst_n) begin
        r_blank <= 3'b0;
      end
      else begin
        r_blank <= {r_blank[1:0], o_BLANK};
      end
  end

  assign display_data = {gs_data[7:3], gs_data[7:2], gs_data[7:3]};
  assign H_SYNC = r_hsync[2];
  assign V_SYNC = r_vsync[2];
  assign BLANK = r_blank[2];
endmodule
