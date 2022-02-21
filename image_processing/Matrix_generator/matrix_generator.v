`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/12/12 19:26:38
// Design Name: 
// Module Name: matrix_generator
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


module matrix_generator
#( parameter DATA_WIDTH = 8)
(
  input clk,
  input rst_n,
  input i_BLANK,
  input i_HSYNC,
  input [DATA_WIDTH - 1:0] i_Y0,
  input i_VSYNC,
  output o_VSYNC,
  output o_BLANK,
  output o_HSYNC,
  output reg [DATA_WIDTH - 1:0] o_matrix11,
  output reg [DATA_WIDTH - 1:0] o_matrix12,
  output reg [DATA_WIDTH - 1:0] o_matrix13,
  output reg [DATA_WIDTH - 1:0] o_matrix21,
  output reg [DATA_WIDTH - 1:0] o_matrix22,
  output reg [DATA_WIDTH - 1:0] o_matrix23,
  output reg [DATA_WIDTH - 1:0] o_matrix31,
  output reg [DATA_WIDTH - 1:0] o_matrix32,
  output reg [DATA_WIDTH - 1:0] o_matrix33
    );
  wire wr_en1;
  wire wr_en2;
  wire rd_en1;
  wire rd_en2;
  reg [802:0] r_vsync;
  reg [802:0] r_blank;
  reg [2:0] r_hsync;
  wire [DATA_WIDTH - 1:0] dout1;
  wire [DATA_WIDTH - 1:0] dout2;
  wire i_BLANK_neg;
  reg [DATA_WIDTH - 1:0] i_Y0_r2;
  reg [DATA_WIDTH - 1:0] i_Y0_r;

  assign o_HSYNC = r_hsync[2];
  assign o_VSYNC = r_vsync[802];
  assign o_BLANK = r_blank[802];

  always @(posedge clk or negedge rst_n) begin
      if(!rst_n) begin
        r_vsync <= 803'b0;
      end
      else begin
        r_vsync <= {r_vsync[801:0], i_VSYNC};
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
        r_blank <= 803'b0;
      end
      else begin
        r_blank <= {r_blank[801:0], i_BLANK};
      end
  end
  generate 
    if (DATA_WIDTH == 15) begin:gen_15
fifo_15bit fifo_1 (
  .clk(clk),                  // input wire clk
  .rst(~rst_n),                  // input wire rst
  .din(i_Y0 | (i_Y0_r & {15{i_BLANK_neg}})),                  // input wire [7 : 0] din
  .wr_en(wr_en1),              // input wire wr_en
  .rd_en(rd_en1),              // input wire rd_en
  .dout(dout1),                // output wire [7 : 0] dout
  .full(),                // output wire full
  .empty(),              // output wire empty
  .wr_rst_busy(),  // output wire wr_rst_busy
  .rd_rst_busy()  // output wire rd_rst_busy
);
fifo_15bit fifo_2 (
  .clk(clk),                  // input wire clk
  .rst(~rst_n),                  // input wire rst
  .din(i_Y0 | (i_Y0_r & {15{i_BLANK_neg}})),                  // input wire [7 : 0] din
  .wr_en(wr_en2),              // input wire wr_en
  .rd_en(rd_en2),              // input wire rd_en
  .dout(dout2),                // output wire [7 : 0] dout
  .full(),                // output wire full
  .empty(),              // output wire empty
  .wr_rst_busy(),  // output wire wr_rst_busy
  .rd_rst_busy()  // output wire rd_rst_busy
);
    end
    else begin :gen_8
matrix_fifo fifo_1 (
  .clk(clk),                  // input wire clk
  .rst(~rst_n),                  // input wire rst
  .din(i_Y0 | (i_Y0_r & {8{i_BLANK_neg}})),                  // input wire [7 : 0] din
  .wr_en(wr_en1),              // input wire wr_en
  .rd_en(rd_en1),              // input wire rd_en
  .dout(dout1),                // output wire [7 : 0] dout
  .full(),                // output wire full
  .empty(),              // output wire empty
  .wr_rst_busy(),  // output wire wr_rst_busy
  .rd_rst_busy()  // output wire rd_rst_busy
);
matrix_fifo fifo_2 (
  .clk(clk),                  // input wire clk
  .rst(~rst_n),                  // input wire rst
  .din(i_Y0 | (i_Y0_r & {8{i_BLANK_neg}})),                  // input wire [7 : 0] din
  .wr_en(wr_en2),              // input wire wr_en
  .rd_en(rd_en2),              // input wire rd_en
  .dout(dout2),                // output wire [7 : 0] dout
  .full(),                // output wire full
  .empty(),              // output wire empty
  .wr_rst_busy(),  // output wire wr_rst_busy
  .rd_rst_busy()  // output wire rd_rst_busy
);
end
endgenerate
//matrix_fifo fifo_3 (
  //.clk(clk),                  // input wire clk
  //.rst(~rst_n),                  // input wire rst
  //.din(din3),                  // input wire [7 : 0] din
  //.wr_en(wr_en3),              // input wire wr_en
  //.rd_en(rd_en3),              // input wire rd_en
  //.dout(dout3),                // output wire [7 : 0] dout
  //.full(),                // output wire full
  //.empty(),              // output wire empty
  //.wr_rst_busy(),  // output wire wr_rst_busy
  //.rd_rst_busy()  // output wire rd_rst_busy
//);
reg [1:0] r_i_BLANK;
reg [8:0] line_cnt;
reg [9:0] col_cnt;

assign data_valid = i_BLANK | r_blank[799];

  always @(posedge clk or negedge rst_n) begin
      if(!rst_n) begin
        i_Y0_r <= {DATA_WIDTH{1'b0}};
      end
      else begin
        i_Y0_r <= i_Y0;
      end
  end

  always @(posedge clk or negedge rst_n) begin
      if(!rst_n) begin
        i_Y0_r2 <= {DATA_WIDTH{1'b0}};
      end
      else begin
        i_Y0_r2 <= i_Y0_r;
      end
  end

  always @(posedge clk or negedge rst_n) begin
      if(!rst_n) begin
        r_i_BLANK <= 2'b00;
      end
      else begin
        r_i_BLANK <= {r_i_BLANK[0], data_valid};
      end
    end


  assign i_BLANK_neg = {data_valid, r_i_BLANK[0]} == 2'b01;

  always @(posedge clk or negedge rst_n) begin
      if(!rst_n) begin
        line_cnt <= 9'b0;
      end
      else if(col_cnt == 639) begin
        if (line_cnt == 480) begin
          line_cnt <= 9'b0;
        end
        else begin
          line_cnt <= line_cnt + 1'b1;
        end
      end
      else begin
        line_cnt <= line_cnt;
      end
  end

  always @(posedge clk or negedge rst_n) begin
      if(!rst_n) begin
        col_cnt <= 10'b0;
      end
      else if (col_cnt == 639) begin
        col_cnt <= 10'b0;
      end
      else if(r_i_BLANK[1]) begin
        col_cnt <= col_cnt + 1'b1;
      end
      else begin
        col_cnt <= col_cnt;
      end
  end

  assign wr_en1 = line_cnt <= 479 && (data_valid | r_i_BLANK[0]);
  assign wr_en2 = line_cnt <= 478 && (data_valid | r_i_BLANK[0]);
  assign rd_en1 = line_cnt >= 1 && (data_valid | r_i_BLANK[0]);
  assign rd_en2 = line_cnt >= 2 && (data_valid | r_i_BLANK[0]);
  //assign wr_en3 = line_cnt == 479 && i_BLANK;


  always @(posedge clk or negedge rst_n) begin
      if(!rst_n) begin
        o_matrix11 <= {DATA_WIDTH{1'b0}};
        o_matrix12 <= {DATA_WIDTH{1'b0}};
        o_matrix13 <= {DATA_WIDTH{1'b0}};
        o_matrix21 <= {DATA_WIDTH{1'b0}};
        o_matrix22 <= {DATA_WIDTH{1'b0}};
        o_matrix23 <= {DATA_WIDTH{1'b0}};
        o_matrix31 <= {DATA_WIDTH{1'b0}};
        o_matrix32 <= {DATA_WIDTH{1'b0}};
        o_matrix33 <= {DATA_WIDTH{1'b0}};
      end
      else if(line_cnt == 0) begin
        if (col_cnt == 0) begin
        o_matrix11 <= i_Y0_r;
        o_matrix12 <= i_Y0_r;
        o_matrix13 <= i_Y0_r;
        o_matrix21 <= i_Y0_r;
        o_matrix22 <= i_Y0_r;
        o_matrix23 <= i_Y0_r;
        o_matrix31 <= i_Y0_r;
        o_matrix32 <= i_Y0_r;
        o_matrix33 <= i_Y0_r;
        end
        else if (col_cnt == 639) begin
        o_matrix11 <= o_matrix12;
        o_matrix12 <= o_matrix13;
        o_matrix13 <= i_Y0_r2;
        o_matrix21 <= o_matrix22;
        o_matrix22 <= o_matrix23;
        o_matrix23 <= i_Y0_r2;
        o_matrix31 <= o_matrix32;
        o_matrix32 <= o_matrix33;
        o_matrix33 <= i_Y0_r2;
        end
        else begin
        o_matrix11 <= o_matrix12;
        o_matrix12 <= o_matrix13;
        o_matrix13 <= i_Y0_r;
        o_matrix21 <= o_matrix22;
        o_matrix22 <= o_matrix23;
        o_matrix23 <= i_Y0_r;
        o_matrix31 <= o_matrix32;
        o_matrix32 <= o_matrix33;
        o_matrix33 <= i_Y0_r;
        end
      end
      else if(line_cnt == 1) begin
        if (col_cnt == 0) begin
        o_matrix11 <= dout1;
        o_matrix12 <= dout1;
        o_matrix13 <= dout1;
        o_matrix21 <= dout1;
        o_matrix22 <= dout1;
        o_matrix23 <= dout1;
        o_matrix31 <= i_Y0_r;
        o_matrix32 <= i_Y0_r;
        o_matrix33 <= i_Y0_r;
        end
        else if (col_cnt == 639) begin
        o_matrix11 <= o_matrix12;
        o_matrix12 <= o_matrix13;
        o_matrix13 <= dout1;
        o_matrix21 <= o_matrix22;
        o_matrix22 <= o_matrix23;
        o_matrix23 <= dout1;
        o_matrix31 <= o_matrix32;
        o_matrix32 <= o_matrix33;
        o_matrix33 <= i_Y0_r2;
        end
        else begin
        o_matrix11 <= o_matrix12;
        o_matrix12 <= o_matrix13;
        o_matrix13 <= dout1;
        o_matrix21 <= o_matrix22;
        o_matrix22 <= o_matrix23;
        o_matrix23 <= dout1;
        o_matrix31 <= o_matrix32;
        o_matrix32 <= o_matrix33;
        o_matrix33 <= i_Y0_r;
        end
      end
      else if(line_cnt == 480) begin
        if (col_cnt == 0) begin
        o_matrix11 <= dout2;
        o_matrix12 <= dout2;
        o_matrix13 <= dout2;
        o_matrix21 <= dout1;
        o_matrix22 <= dout1;
        o_matrix23 <= dout1;
        o_matrix31 <= dout1;
        o_matrix32 <= dout1;
        o_matrix33 <= dout1;
        end
        else begin
        o_matrix11 <= o_matrix12;
        o_matrix12 <= o_matrix13;
        o_matrix13 <= dout2;
        o_matrix21 <= o_matrix22;
        o_matrix22 <= o_matrix23;
        o_matrix23 <= dout1;
        o_matrix31 <= o_matrix32;
        o_matrix32 <= o_matrix33;
        o_matrix33 <= dout1;
        end
      end
      else begin
        if (col_cnt == 0) begin
        o_matrix11 <= dout2;
        o_matrix12 <= dout2;
        o_matrix13 <= dout2;
        o_matrix21 <= dout1;
        o_matrix22 <= dout1;
        o_matrix23 <= dout1;
        o_matrix31 <= i_Y0_r;
        o_matrix32 <= i_Y0_r;
        o_matrix33 <= i_Y0_r;
      end
        else if (col_cnt == 639) begin
        o_matrix11 <= o_matrix12;
        o_matrix12 <= o_matrix13;
        o_matrix13 <= dout2;
        o_matrix21 <= o_matrix22;
        o_matrix22 <= o_matrix23;
        o_matrix23 <= dout1;
        o_matrix31 <= o_matrix32;
        o_matrix32 <= o_matrix33;
        o_matrix33 <= i_Y0_r2;
        end
        else begin
        o_matrix11 <= o_matrix12;
        o_matrix12 <= o_matrix13;
        o_matrix13 <= dout2;
        o_matrix21 <= o_matrix22;
        o_matrix22 <= o_matrix23;
        o_matrix23 <= dout1;
        o_matrix31 <= o_matrix32;
        o_matrix32 <= o_matrix33;
        o_matrix33 <= i_Y0_r ;
      end
      end
  end
endmodule
