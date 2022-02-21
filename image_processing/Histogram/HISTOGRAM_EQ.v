`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/12/08 22:15:14
// Design Name: 
// Module Name: HISTOGRAM_EQ
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


module HISTOGRAM_EQ(
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
  reg [7:0] r_Y0;
  reg r_i_BLANK;
  wire wea1;
  wire [7:0] addra1;
  wire [31:0] doutb1;
  wire [31:0] dina1;
  wire [31:0] addrb1;
  wire wea2;
  wire [7:0] addra2;
  wire [31:0] doutb2;
  wire [31:0] dina2;
  wire [31:0] addrb2;
  reg [31:0] w_cnt;
  reg [1:0] r_i_VSYNC;
  wire i_VSYNC_neg;
  wire i_VSYNC_neg_d;
  reg [7:0] r_addr;
  reg [39:0] r_addr_delay;
  reg [31:0] histogram_value;
  reg [31:0] histogram_value_left_shift1;
  reg [31:0] histogram_value_left_shift2;
  reg [31:0] histogram_value_add;
  reg [7:0] histogram_eq_value;



  reg histogram_value_valid;
  reg [3:0] histogram_value_valid_r;

  blk_mem_gen_1 u_ram_1 (
  .clka(clk),    // input wire clka
  .ena(1'b1),      // input wire ena
  .wea(wea1),      // input wire [0 : 0] wea
  .addra(addra1),  // input wire [7 : 0] addra
  .dina(dina1),    // input wire [31 : 0] dina
  .clkb(clk),    // input wire clkb
  .enb(1'b1),      // input wire enb
  .addrb(addrb1),  // input wire [7 : 0] addrb
  .doutb(doutb1)  // output wire [31 : 0] doutb
);
  blk_mem_gen_1 u_ram_2 (
  .clka(clk),    // input wire clka
  .ena(1'b1),      // input wire ena
  .wea(wea2),      // input wire [0 : 0] wea
  .addra(addra2),  // input wire [7 : 0] addra
  .dina(dina2),    // input wire [31 : 0] dina
  .clkb(clk),    // input wire clkb
  .enb(1'b1),      // input wire enb
  .addrb(addrb2),  // input wire [7 : 0] addrb
  .doutb(doutb2)  // output wire [31 : 0] doutb
);
  assign addrb1 = (i_BLANK)? i_Y0 : r_addr;

  assign wea2 = histogram_value_valid_r[3];
  assign addra2 = r_addr_delay[39:32];
  assign dina2 = histogram_eq_value;
  assign addrb2 = i_Y0;

  always @(posedge clk or negedge rst_n) begin
      if(!rst_n) begin
        r_addr <= 8'b0;
      end
      else if(i_VSYNC_neg) begin
        r_addr <= 8'b0;
      end
      else begin
        r_addr <= r_addr + 1'b1;
      end
  end

  always @(posedge clk or negedge rst_n) begin
      if(!rst_n) begin
        histogram_value_valid <= 1'b0;
      end
      else if(i_VSYNC_neg_d) begin
        histogram_value_valid <= 1'b1;
      end
      else if(r_addr == 8'b0) begin
        histogram_value_valid <= 1'b0;
      end
  end


  always @(posedge clk or negedge rst_n) begin
      if(!rst_n) begin
        histogram_value <= 32'b0;
      end
      else if(histogram_value_valid) begin
        histogram_value <= histogram_value + doutb1;
      end
      else if (i_VSYNC_neg)begin
        histogram_value <= 32'b0;
      end
  end

  always @(posedge clk or negedge rst_n) begin
      if(!rst_n) begin
        histogram_value_left_shift1 <= 32'b0;
        histogram_value_left_shift2 <= 32'b0;
      end
      else begin
        histogram_value_left_shift1 <= (histogram_value << 5) + (histogram_value << 4);
        histogram_value_left_shift2 <= (histogram_value << 2) + (histogram_value << 1);
      end
  end

  always @(posedge clk or negedge rst_n) begin
      if(!rst_n) begin
        histogram_value_add <= 32'b0;
      end
      else begin
        histogram_value_add <= histogram_value_left_shift1 + histogram_value_left_shift2;
      end
  end

  always @(posedge clk or negedge rst_n) begin
      if(!rst_n) begin
        histogram_value <= 32'b0;
      end
      else begin
        histogram_eq_value <= histogram_value_add >> 16;
      end
    end

  always @(posedge clk or negedge rst_n) begin
      if(!rst_n) begin
        histogram_value_valid_r <= 4'b0;
      end
      else begin
        histogram_value_valid_r <= {histogram_value_valid_r[2:0], histogram_value_valid};
      end
  end

  always @(posedge clk or negedge rst_n) begin
      if(!rst_n) begin
        r_addr_delay <= 40'b0;
      end
      else begin
        r_addr_delay <= {r_addr_delay[31:0], r_addr};
      end
  end

  always @(posedge clk or negedge rst_n) begin
      if(!rst_n) begin
        r_i_BLANK <= 1'b0;
      end
      else begin
        r_i_BLANK <= i_BLANK;
      end
  end


  always @(posedge clk or negedge rst_n) begin
      if(!rst_n) begin
        r_i_VSYNC <= 2'b00;
      end
      else begin
        r_i_VSYNC <= {r_i_VSYNC[0], i_VSYNC};
      end
  end

  assign i_VSYNC_neg = {i_VSYNC, r_i_VSYNC[0]} == 2'b01;
  assign i_VSYNC_neg_d = r_i_VSYNC == 2'b10;

  always @(posedge clk or negedge rst_n) begin
      if(!rst_n) begin
        r_Y0 <= 8'b0;
      end
      else begin
        r_Y0 <= i_Y0;
      end
  end

  assign wea1 = ((r_Y0 != i_Y0) && r_i_BLANK) | ({i_BLANK, r_i_BLANK} == 2'b01) | histogram_value_valid;
  assign addra1 = (!histogram_value_valid) ? r_Y0 : r_addr_delay[7:0];
  assign dina1 = (!histogram_value_valid) ? w_cnt + doutb1 : 32'b0;

  always @(posedge clk or negedge rst_n) begin
      if(!rst_n) begin
        w_cnt <= 32'b1;
      end
      else if (i_VSYNC_neg) begin
        w_cnt <= 32'b1;
      end
      else if (r_i_BLANK) begin
        if(wea1) begin
          w_cnt <= 1'b1;
        end
        else begin
          w_cnt <= w_cnt + 1'b1;
      end
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
  assign display_data = {doutb2[7:3], doutb2[7:2], doutb2[7:3]};

endmodule
