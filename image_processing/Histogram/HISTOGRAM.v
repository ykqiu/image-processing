`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/12/07 22:03:59
// Design Name: 
// Module Name: HISTOGRAM
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


module HISTOGRAM(
  input clk,
  input rst_n,
  input i_HSYNC,
  input i_VSYNC,
  input i_BLANK,
  input [7:0] i_Y0,
  output H_SYNC,
  output V_SYNC,
  output BLANK,
  output reg [7:0] Y0,
  output [15:0] display_data
    );
  reg [7:0] min;
  reg [7:0] max;
  reg [1:0] r_i_VSYNC;
  reg [7:0] min_r;
  reg [7:0] max_r;
  wire i_VSYNC_neg;
  reg [15:0] numerator;
  reg [7:0] denominator;
  reg [1:0] r_hsync;
  reg [1:0] r_vsync;
  reg [1:0] r_blank;

  always @(posedge clk or negedge rst_n) begin
      if(!rst_n) begin
        r_i_VSYNC <= 2'b00;
      end
      else begin
        r_i_VSYNC <= {r_i_VSYNC[0], i_VSYNC};
      end
  end

  assign i_VSYNC_neg = r_i_VSYNC == 2'b10;

  always @(posedge clk or negedge rst_n) begin
      if(!rst_n) begin
        min <= 255;
      end
      else if(i_BLANK) begin
        if(i_Y0 < min) begin
          min <= i_Y0;
        end
      end
      else if (i_VSYNC_neg) begin
        min <= 255;
      end
      else begin
        min <= min;
      end
  end

  always @(posedge clk or negedge rst_n) begin
      if(!rst_n) begin
        max <= 0;
      end
      else if(i_BLANK) begin
        if(i_Y0 > max) begin
          max <= i_Y0;
        end
      end
      else if (i_VSYNC_neg) begin
        max <= 0;
      end
      else begin
        max <= max;
      end
  end

  always @(posedge clk or negedge rst_n) begin
      if(!rst_n) begin
        min_r <= 8'b0;
      end
      else if(i_VSYNC_neg) begin
        min_r <= min;
      end
      else begin
        min_r <= min_r;
      end
  end

  always @(posedge clk or negedge rst_n) begin
      if(!rst_n) begin
        max_r <= 8'b0;
      end
      else if(i_VSYNC_neg) begin
        max_r <= max;
      end
      else begin
        max_r <= max_r;
      end
  end

  always @(posedge clk or negedge rst_n) begin
      if(!rst_n) begin
        numerator <= 16'b0;
      end
      else if(i_BLANK) begin
        if (min_r == max_r) begin
          numerator <= i_Y0;
        end
        else if (i_Y0 > max_r) begin
          numerator <= 255*(max_r - min_r);
        end
        else if (i_Y0 < min_r) begin
          numerator <= 0;
        end
        else begin
          numerator <= 255*(i_Y0 - min_r);
        end
      end
      else begin
        numerator <= numerator;
      end
  end

  always @(posedge clk or negedge rst_n) begin
      if(!rst_n) begin
        denominator <= 255;
      end
      else if(i_BLANK) begin
        if(max_r == min_r) begin
          denominator <= 1;
        end
        else begin
          denominator <= max_r - min_r;
        end
      end
      else begin
        denominator <= denominator;
      end
  end

  always @(posedge clk or negedge rst_n) begin
      if(!rst_n) begin
        Y0 <= 8'b0;
      end
      else begin
        Y0 <= numerator/denominator;
      end
  end

  always @(posedge clk or negedge rst_n) begin
      if(!rst_n) begin
        r_vsync <= 2'b0;
      end
      else begin
        r_vsync <= {r_vsync[0], i_VSYNC};
      end
  end

  always @(posedge clk or negedge rst_n) begin
      if(!rst_n) begin
        r_hsync <= 2'b0;
      end
      else begin
        r_hsync <= {r_hsync[0], i_HSYNC};
      end
  end

  always @(posedge clk or negedge rst_n) begin
      if(!rst_n) begin
        r_blank <= 2'b0;
      end
      else begin
        r_blank <= {r_blank[0], i_BLANK};
      end
  end

  assign H_SYNC = r_hsync[1];
  assign V_SYNC = r_vsync[1];
  assign BLANK = r_blank[1];
  assign display_data = {Y0[7:3], Y0[7:2], Y0[7:3]}; 
endmodule
