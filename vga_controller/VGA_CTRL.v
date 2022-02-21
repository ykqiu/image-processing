`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/11/11 21:53:04
// Design Name: 
// Module Name: VGA_CTRL
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


module VGA_CTRL(
  input clk,
  input rst_n,
  output H_SYNC,
  output V_SYNC,
  output BLANK,
  output [10:0]h_position,
  output [9:0] v_position,
  input [15:0] i_data,
  output [15:0] data,
  output data_req
    );
  parameter H_SYNC_PULSE = 96;
  parameter LEFT_BLANK = 48;
  parameter H_DATA = 640;
  parameter RIGHT_BLANK = 16;

  parameter V_SYNC_PULSE = 2;
  parameter TOP_BLANK = 33;
  parameter V_DATA = 480;
  parameter BOTTOM = 10;

  reg [10:0] h_cnt;
  reg [10:0] v_cnt;
  wire line_end;

  //always @(posedge clk or negedge rst_n) begin
      //if(!rst_n) begin
        //line_end <= 1'b0;
      //end
      //else if(h_cnt == 800 - 1) begin
        //line_end <= 1'b1;
      //end
      //else begin
        //line_end <= 1'b0;
      //end
  //end
  assign line_end = h_cnt == 800 - 1;
  always @(posedge clk or negedge rst_n) begin
      if(!rst_n) begin
        h_cnt <= 10'b0;
      end
      else if(h_cnt == 800 - 1) begin
        h_cnt <= 10'b0;
      end
      else begin
        h_cnt <= h_cnt + 1'b1;
      end
  end

  always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
      v_cnt <= 10'b0;
    end
    else if (line_end) begin
      if(v_cnt == 525 - 1) begin
        v_cnt <= 10'b0;
      end
      else begin
      v_cnt <= v_cnt + 1'b1;
      end
    end
  end
  
  assign H_SYNC = h_cnt <= H_SYNC_PULSE -1 ? 0:1'b1;
  assign V_SYNC = v_cnt <= V_SYNC_PULSE -1 ? 0:1'b1;
  assign BLANK = (h_cnt >= H_SYNC_PULSE + LEFT_BLANK) &&
                 (h_cnt <= H_SYNC_PULSE + LEFT_BLANK + H_DATA - 1) &&
                 (v_cnt >= V_SYNC_PULSE + TOP_BLANK) &&
                 (v_cnt <= V_SYNC_PULSE + TOP_BLANK + V_DATA - 1);
  assign h_position = BLANK?(h_cnt - H_SYNC_PULSE - LEFT_BLANK):10'b0;
  assign v_position = (v_cnt >= V_SYNC_PULSE + TOP_BLANK) &&(v_cnt <= V_SYNC_PULSE + TOP_BLANK + V_DATA - 1)?(v_cnt - V_SYNC_PULSE - TOP_BLANK):9'b0;
  assign data = BLANK? i_data:24'b0;
  assign data_req = (h_cnt >= H_SYNC_PULSE + LEFT_BLANK - 1) &&
                 (h_cnt <= H_SYNC_PULSE + LEFT_BLANK + H_DATA - 1 - 1) &&
                 (v_cnt >= V_SYNC_PULSE + TOP_BLANK) &&
                 (v_cnt <= V_SYNC_PULSE + TOP_BLANK + V_DATA - 1);
endmodule

