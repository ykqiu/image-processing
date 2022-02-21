`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/12/06 21:31:35
// Design Name: 
// Module Name: LOG
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


module LOG(
  input clk,
  input rst_n,
  input i_HSYNC,
  input i_VSYNC,
  input i_BLANK,
  input [7:0] i_Y0,
  output reg H_SYNC,
  output reg V_SYNC,
  output reg BLANK,
  output [15:0] display_data
    );
  wire [7:0] dout;
  assign display_data = {dout[7:3], dout[7:2], dout[7:3]};

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



blk_mem_gen_0 u_log (
  .clka(clk),    // input wire clka
  .ena(1'b1),      // input wire ena
  .addra(i_Y0),  // input wire [7 : 0] addra
  .douta(dout)  // output wire [7 : 0] douta
);
endmodule
