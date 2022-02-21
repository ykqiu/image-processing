`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/11/28 19:49:57
// Design Name: 
// Module Name: fifo_ctrl
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


module fifo_ctrl(
  input clk,
  input rst_n,
  input ping_pong_en,
  input [9:0] br_length,
  input [23:0] sdram_wr_addr_max,
  input [23:0] sdram_wr_addr_min,
  input [23:0] sdram_rd_addr_max,
  input [23:0] sdram_rd_addr_min,
  input [9:0] wr_data_count,
  input [9:0] rd_data_count,
  input wr_ack,
  input rd_ack,
  input rd_valid,
  output reg wr_req,
  output reg rd_req,
  output reg [23:0] sdram_wr_addr,
  output reg [23:0] sdram_rd_addr
    );

  reg [1:0] wr_ack_r;
  reg [1:0] rd_ack_r;
  wire wr_ack_pos;
  wire rd_ack_pos;

  always @(posedge clk or negedge rst_n) begin
      if(!rst_n) begin
        wr_ack_r <= 2'b00;
      end
      else begin
        wr_ack_r <= {wr_ack_r[0], wr_ack};
      end
  end

  assign wr_ack_pos = wr_ack_r == 2'b10;

  always @(posedge clk or negedge rst_n) begin
      if(!rst_n) begin
        rd_ack_r <= 2'b00;
      end
      else begin
        rd_ack_r <= {rd_ack_r[0], rd_ack};
      end
  end

  assign rd_ack_pos = rd_ack_r == 2'b10;

  always @(posedge clk or negedge rst_n) begin
      if(!rst_n) begin
        sdram_wr_addr <= sdram_wr_addr_min;
      end
      else if(wr_ack_pos) begin
        if (sdram_wr_addr + br_length >= {sdram_wr_addr[23], sdram_wr_addr_max[22:0]}) begin
          if (ping_pong_en) begin
            sdram_wr_addr <= {~sdram_wr_addr[23], sdram_wr_addr_min[22:0]};
          end
          else begin
            sdram_wr_addr <= sdram_wr_addr_min;
          end
        end
        else begin
          sdram_wr_addr <= sdram_wr_addr + br_length;
        end
      end
      else begin
        sdram_wr_addr <= sdram_wr_addr;
      end
  end

  always @(posedge clk or negedge rst_n) begin
      if(!rst_n) begin
        if (ping_pong_en) begin
          sdram_rd_addr <= {~sdram_rd_addr_min[23], sdram_rd_addr_min[22:0]};
        end
        else begin
          sdram_rd_addr <= sdram_rd_addr_min;
        end
      end
      else if(rd_ack_pos) begin
        if (sdram_rd_addr + br_length >= {sdram_rd_addr[23], sdram_rd_addr_max[22:0]}) begin
          if (ping_pong_en) begin
            if (sdram_wr_addr[23] ^ sdram_rd_addr[23]) begin
              sdram_rd_addr <= {sdram_rd_addr[23], sdram_rd_addr_min[22:0]};
            end
            else begin
              sdram_rd_addr <= {~sdram_rd_addr[23], sdram_rd_addr_min[22:0]};
            end
          end
          else begin
            sdram_rd_addr <= sdram_rd_addr_min;
          end
        end
        else begin
          sdram_rd_addr <= sdram_rd_addr + br_length;
        end
      end
      else begin
        sdram_rd_addr <= sdram_rd_addr;
      end
  end

  always @(posedge clk or negedge rst_n) begin
      if(!rst_n) begin
        wr_req <= 1'b0;
      end
      else if(wr_data_count >= br_length) begin
        wr_req <= 1'b1;
      end
      else begin
        wr_req <= 1'b0;
      end
  end

  always @(posedge clk or negedge rst_n) begin
      if(!rst_n) begin
        rd_req <= 1'b0;
      end
      else if(rd_data_count < br_length && rd_valid) begin
        rd_req <= 1'b1;
      end
      else begin
        rd_req <= 1'b0;
      end
  end

endmodule
