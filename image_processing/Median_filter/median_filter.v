`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/12/13 22:21:08
// Design Name: 
// Module Name: median_filter
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


module median_filter(
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

  wire [7:0] max1;
  wire [7:0] mid1;
  wire [7:0] min1;
  wire [7:0] max2;
  wire [7:0] mid2;
  wire [7:0] min2;
  wire [7:0] max3;
  wire [7:0] mid3;
  wire [7:0] min3;

  wire [7:0] max_max;
  wire [7:0] mid_mid;
  wire [7:0] min_min;

  reg [2:0] r_hsync;
  reg [2:0] r_vsync;
  reg [2:0] r_blank;  
  wire [7:0] Y0;

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

sort u_sort_1
(  .clk        ( clk        ),
   .rst_n      ( rst_n      ),
   .data1      (o_matrix11),
   .data2      (o_matrix12),
   .data3      (o_matrix13),
   .max        (max1),
   .mid        (mid1),
   .min        (min1));

sort u_sort_2
(  .clk        ( clk        ),
   .rst_n      ( rst_n      ),
   .data1      (o_matrix21),
   .data2      (o_matrix22),
   .data3      (o_matrix23),
   .max        (max2),
   .mid        (mid2),
   .min        (min2));

sort u_sort_3
(  .clk        ( clk        ),
   .rst_n      ( rst_n      ),
   .data1      (o_matrix31),
   .data2      (o_matrix32),
   .data3      (o_matrix33),
   .max        (max3),
   .mid        (mid3),
   .min        (min3));

sort u_sort_4
(  .clk        ( clk        ),
   .rst_n      ( rst_n      ),
   .data1      (max1),
   .data2      (max2),
   .data3      (max3),
   .max        (max_max),
   .mid        (),
   .min        ());

sort u_sort_5
(  .clk        ( clk        ),
   .rst_n      ( rst_n      ),
   .data1      (mid1),
   .data2      (mid2),
   .data3      (mid3),
   .max        (),
   .mid        (mid_mid),
   .min        ());

sort u_sort_6
(  .clk        ( clk        ),
   .rst_n      ( rst_n      ),
   .data1      (min1),
   .data2      (min2),
   .data3      (min3),
   .max        (),
   .mid        (),
   .min        (min_min));

sort u_sort_7
(  .clk        ( clk        ),
   .rst_n      ( rst_n      ),
   .data1      (max_max),
   .data2      (mid_mid),
   .data3      (min_min),
   .max        (),
   .mid        (Y0),
   .min        ());

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

  assign H_SYNC = r_hsync[2];
  assign V_SYNC = r_vsync[2];
  assign BLANK = r_blank[2];
  assign display_data = {Y0[7:3], Y0[7:2], Y0[7:3]};
endmodule

module sort(
  input clk,
  input rst_n,
  input [7:0] data1,
  input [7:0] data2,
  input [7:0] data3,
  output reg [7:0] max,
  output reg [7:0] mid,
  output reg [7:0] min
    );

  always @(posedge clk or negedge rst_n) begin
      if(!rst_n) begin
        max <= 8'b0;
        mid <= 8'b0;
        min <= 8'b0;
      end
      else if(data1 >= data2 && data2 >= data3) begin
        max <= data1;
        mid <= data2;
        min <= data3;
      end
      else if(data1 >= data3 && data3 >= data2) begin
        max <= data1;
        mid <= data3;
        min <= data2;
      end
      else if(data2 >= data1 && data1 >= data3) begin
        max <= data2;
        mid <= data1;
        min <= data3;
      end
      else if(data2 >= data3 && data3 >= data1) begin
        max <= data2;
        mid <= data3;
        min <= data1;
      end
      else if(data3 >= data1 && data1 >= data2) begin
        max <= data3;
        mid <= data1;
        min <= data2;
      end
      else if(data3 >= data2 && data2 >= data1) begin
        max <= data3;
        mid <= data2;
        min <= data1;
      end
    end
endmodule
