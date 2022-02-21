`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/12/29 21:52:26
// Design Name: 
// Module Name: canny
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


module canny(
  input clk,
  input rst_n,
  input i_HSYNC,
  input i_VSYNC,
  input i_BLANK,
  output [14:0] canny_in,
  output reg H_SYNC,
  output reg V_SYNC,
  output reg BLANK,
  output [15:0] display_data
    );
  wire [14:0] o_matrix11;
  wire [14:0] o_matrix12;
  wire [14:0] o_matrix13;
  wire [14:0] o_matrix21;
  wire [14:0] o_matrix22;
  wire [14:0] o_matrix23;
  wire [14:0] o_matrix31;
  wire [14:0] o_matrix32;
  wire [14:0] o_matrix33;
  reg is_edge;
  reg r_hsync;
  reg r_vsync;
  reg r_blank;

matrix_generator
#( .DATA_WIDTH (15)) U_MATRIX_GENERATOR_0
(  .clk        ( clk        ),
   .rst_n      ( rst_n      ),
   .i_HSYNC    ( i_HSYNC    ),
   .i_BLANK    ( i_BLANK    ),
   .i_Y0       ( canny_in       ),
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
        is_edge <= 1'b0;
      end
      else if(o_matrix22[12:11] == 2'b11) begin
        is_edge <= 1'b1;
      end
      else if(o_matrix22[12:11] == 2'b01) begin
        is_edge <= 1'b0;
      end
      else if(o_matrix22[12:11] == 2'b10) begin
        case (o_matrix22[14:13])
          2'b00: begin
            if (o_matrix22[10:0] >= o_matrix21[10:0] && o_matrix22[10:0] >= o_matrix23[10:0]) begin
              is_edge <= 1'b1;
            end
            else begin
              is_edge <= 1'b0;
            end
          end
          2'b10: begin
            if (o_matrix22[10:0] >= o_matrix12[10:0] && o_matrix22[10:0] >= o_matrix32[10:0]) begin
              is_edge <= 1'b1;
            end
            else begin
              is_edge <= 1'b0;
            end
          end
          2'b10: begin
            if (o_matrix22[10:0] >= o_matrix13[10:0] && o_matrix22[10:0] >= o_matrix31[10:0]) begin
              is_edge <= 1'b1;
            end
            else begin
              is_edge <= 1'b0;
            end
          end
          2'b11: begin
            if (o_matrix22[10:0] >= o_matrix11[10:0] && o_matrix22[10:0] >= o_matrix33[10:0]) begin
              is_edge <= 1'b1;
            end
            else begin
              is_edge <= 1'b0;
            end
          end
        endcase
      end
    end

  assign display_data = (is_edge) ? 16'hffff : 0;

  always @(posedge clk or negedge rst_n) begin
      if(!rst_n) begin
        H_SYNC <= 1'b0;
        V_SYNC <= 1'b0;
        BLANK <= 1'b0;
      end
      else begin
        H_SYNC <= o_HSYNC;
        V_SYNC <= o_VSYNC;
        BLANK <= o_BLANK;
      end
  end
endmodule
