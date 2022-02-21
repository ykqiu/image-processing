`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/12/03 21:42:35
// Design Name: 
// Module Name: RGB2YUV
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


module RGB2YUV(
  input clk,
  input rst_n,
  input i_HSYNC,
  input i_VSYNC,
  input i_BLANK,
  input [15:0] i_display_data,
  output H_SYNC,
  output V_SYNC,
  output BLANK,
  output reg [7:0] Y0,
  output [15:0] display_data
    );
  reg [15:0]r0; reg [15:0]r1; reg [15:0]r2; reg [15:0]g0; reg [15:0]g1; reg [15:0]g2; reg [15:0]b0; reg [15:0]b1; reg [15:0]b2;
  reg [15:0]y0; reg [15:0]u0; reg [15:0]v0;
  reg [7:0] U0; reg [7:0] V0;
  reg [2:0] r_hsync;
  reg [2:0] r_vsync;
  reg [2:0] r_blank;
  wire [7:0] R8;
  wire [7:0] G8;
  wire [7:0] B8;
  assign R8 = {i_display_data[15:11], i_display_data[13:11]};
  assign G8 = {i_display_data[10:5], i_display_data[6:5]};
  assign B8 = {i_display_data[4:0], i_display_data[2:0]};
  
  always @(posedge clk or negedge rst_n) begin
      if(!rst_n) begin
        {r0, g0, b0} <= {16'b0, 16'b0, 16'b0};
        {r1, g1, b1} <= {16'b0, 16'b0, 16'b0};
        {r2, g2, b2} <= {16'b0, 16'b0, 16'b0};
      end
      else begin
        {r0, g0, b0} <= {R8*77, G8*150, B8*29};
        {r1, g1, b1} <= {R8*43, G8*85, B8*128};
        {r2, g2, b2} <= {R8*128, G8*107, B8*21};
      end
  end

  always @(posedge clk or negedge rst_n) begin
      if(!rst_n) begin
        y0 <= 16'b0;
        u0 <= 16'b0;
        v0 <= 16'b0;
      end
      else begin
        y0 <= r0 + g0 + b0;
        u0 <= b1 - r1 - g1 + 32768;
        v0 <= r2 - g2 - b2 + 32768;
      end
  end

  always @(posedge clk or negedge rst_n) begin
      if(!rst_n) begin
        Y0 <= 7'b0;
        U0 <= 7'b0;
        V0 <= 7'b0;
      end
      else begin
        Y0 <= y0 >> 8;
        U0 <= u0 >> 8;
        V0 <= v0 >> 8;
      end
  end
  assign display_data = {Y0[7:3], Y0[7:2], Y0[7:3]};

  always @(posedge clk or negedge rst_n) begin
      if(!rst_n) begin
        r_vsync <= 3'b0;
      end
      else begin
        r_vsync <= {r_vsync[1:0], i_VSYNC};
      end
  end

  always @(posedge clk or negedge rst_n) begin
      if(!rst_n) begin
        r_hsync <= 3'b0;
      end
      else begin
        r_hsync <= {r_hsync[1:0], i_HSYNC};
      end
  end

  always @(posedge clk or negedge rst_n) begin
      if(!rst_n) begin
        r_blank <= 3'b0;
      end
      else begin
        r_blank <= {r_blank[1:0], i_BLANK};
      end
  end

  assign H_SYNC = r_hsync[2];
  assign V_SYNC = r_vsync[2];
  assign BLANK = r_blank[2];
endmodule
