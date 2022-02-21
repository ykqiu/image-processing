`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/12/05 21:49:35
// Design Name: 
// Module Name: EMBOSS
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


module EMBOSS(
  input clk,
  input [7:0] shreshold,
  input rst_n,
  input i_HSYNC,
  input i_VSYNC,
  input i_BLANK,
  input [7:0] i_Y0,
  output reg H_SYNC,
  output reg V_SYNC,
  output reg BLANK,
  output reg [15:0] display_data
    );
  wire signed [9:0] emboss_value;
  reg [7:0] r_Y0;

  always @(posedge clk or negedge rst_n) begin
      if(!rst_n) begin
        r_Y0 <= 8'b0;
      end
      else begin
        r_Y0 <= i_Y0;
      end
  end

  assign emboss_value = r_Y0 - i_Y0 + shreshold;

  always @(*) begin
      if(emboss_value > 255) begin
        display_data = 16'hffff;
      end
      else if(emboss_value < 0) begin
        display_data = 16'b0;
      end
      else begin
        display_data = {emboss_value[7:3], emboss_value[7:2], emboss_value[7:3]};
      end
  end


  always @(posedge clk or negedge rst_n) begin
      if(!rst_n) begin
        H_SYNC <= 1'b0;
        V_SYNC <= 1'b0;
        BLANK <= 1'b0;
      end
      else begin
        H_SYNC <= i_HSYNC;
        V_SYNC <= i_VSYNC;
        BLANK <= i_BLANK;
      end
  end
endmodule
