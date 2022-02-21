`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/11/21 20:55:22
// Design Name: 
// Module Name: sram_ctrl
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


module sdram_ctrl(
  input clk,
  input rst_n,
  input [23:0] wr_sys_addr,
  input [23:0] rd_sys_addr,
  input [9:0] br_length,
  input wr_req,
  input rd_req,
  input [15:0] wdata,
  output [15:0] rdata,
  output reg init_done,
  output reg wr_ack,
  output reg rd_ack,
  output sdrma_ref_clk,
  output sdram_cke,
  output sdram_cs_n,
  output sdram_ras_n,
  output sdram_cas_n,
  inout [15:0] sdram_data,
  output sdram_we_n,
  output [1:0] sdram_dqm,
  output reg [1:0] sdram_bank,
  output reg [12:0] sdram_addr
    );
  reg [14:0] state_cnt;
  reg [4:0] state;
  reg [4:0] next_state;
  reg [3:0] init_ar_cnt;
  reg [4:0] sdram_cmd;
  reg arf_req;
  reg arf_ack;
  reg [7:0] arf_cnt;
  reg wr_en;
  reg [15:0] sdram_data_r;
  reg rd_post_d;
  parameter IDLE = 0;
  parameter PRE_CHARGE = 1;
  parameter T_PRE_CHARGE = 2;
  parameter AUTO_REFRESH = 3;
  parameter T_AUTO_REFRESH = 4;
  parameter MODE_REG_SET = 5;
  parameter T_MODE_REG_SET = 6;
  parameter ARBIT = 7;
  parameter W_AUTO_REFRESH = 8;
  parameter T_W_AUTO_REFRESH = 9;
  parameter ACTIVE = 10;
  parameter WR_PRE = 11;
  parameter WRITE = 12;
  parameter WD = 13;
  parameter WR_TERM = 14;
  parameter W_PRE_CHARGE = 15;
  parameter T_W_PRE_CHARGE = 16;
  parameter READ = 17;
  parameter R_CL = 18;
  parameter RD = 19;
  parameter RD_TERM = 20;
  parameter RD_POST = 21;


  assign {sdram_cke, sdram_cs_n, sdram_ras_n, sdram_cas_n, sdram_we_n} = sdram_cmd;
  always @(posedge clk or negedge rst_n) begin
      if(!rst_n) begin
        state_cnt <= 15'b0;
      end
      else if(state == PRE_CHARGE ||
              state == AUTO_REFRESH ||
              state == MODE_REG_SET ||
              state == W_AUTO_REFRESH ||
              state == WRITE ||
              state == W_PRE_CHARGE ||
              state == READ
            ) begin
        state_cnt <= 15'b0;
      end
      else begin
        state_cnt <= state_cnt + 1'b1;
      end
  end

  always @(posedge clk or negedge rst_n) begin
      if(!rst_n) begin
        arf_req <= 1'b0;
      end
      else if(arf_cnt == 8'd250) begin
        arf_req <= 1'b1;
      end
      else if(arf_ack) begin
        arf_req <= 1'b0;
      end
  end

  always @(posedge clk or negedge rst_n) begin
      if(!rst_n) begin
        arf_cnt <= 8'b0;
      end
      else if(arf_cnt == 8'd250) begin
        arf_cnt <= 8'b0;
      end
      else begin
        arf_cnt <= arf_cnt + 1'b1;
      end
  end

  always @(posedge clk or negedge rst_n) begin
      if(!rst_n) begin
        state <= IDLE;
      end
      else begin
        state <= next_state;
      end
  end

  always @(posedge clk or negedge rst_n) begin
      if(!rst_n) begin
        init_ar_cnt <= 4'b0;
      end
      else if(state == AUTO_REFRESH) begin
        init_ar_cnt <= init_ar_cnt + 1'b1;
      end
      else begin
        init_ar_cnt <= init_ar_cnt;
      end
  end

  always @(*) begin
    next_state = state;
    case (state)
      IDLE:
        if (state_cnt == 20000 - 1)
          next_state = PRE_CHARGE;
      PRE_CHARGE:
        next_state = T_PRE_CHARGE;
      T_PRE_CHARGE:
        if (state_cnt == 2)
          next_state = AUTO_REFRESH;
      AUTO_REFRESH:
          next_state = T_AUTO_REFRESH;
      T_AUTO_REFRESH:
        if (state_cnt == 5) begin
          if (init_ar_cnt == 8) begin
            next_state = MODE_REG_SET;
          end
          else begin
            next_state = AUTO_REFRESH;
          end
        end
      MODE_REG_SET:
        next_state = T_MODE_REG_SET;
      T_MODE_REG_SET:
        if (state_cnt == 5)
          next_state = ARBIT;
      ARBIT:
        if (arf_req) begin
          next_state = W_AUTO_REFRESH;
        end
        else if (wr_req | rd_req) begin
          next_state = ACTIVE;
        end
      W_AUTO_REFRESH:
        next_state = T_W_AUTO_REFRESH;
      T_W_AUTO_REFRESH:
        if (state_cnt == 5) begin
          next_state = ARBIT;
        end
      ACTIVE:
        next_state = WR_PRE;
      WR_PRE:
        if (wr_req) begin
          next_state = WRITE;
        end
        else begin
          next_state = READ;
        end
      WRITE:
        if (br_length == 1) begin
          next_state = WR_TERM;
        end
        else begin
          next_state = WD;
        end
      WD:
        if (state_cnt == br_length - 2) begin
          next_state = WR_TERM;
        end
      WR_TERM:
        next_state = W_PRE_CHARGE;
      W_PRE_CHARGE:
        next_state = T_W_PRE_CHARGE;
      T_W_PRE_CHARGE:
        if (state_cnt == 2) begin
          next_state = ARBIT;
        end
      READ:
        next_state = R_CL;
      R_CL:
        if (state_cnt == 1) begin
          next_state = RD;
        end
      RD:
        if (state_cnt == br_length - 2) begin
          next_state = RD_TERM;
        end
      RD_TERM:
        next_state = RD_POST;
      RD_POST:
        if (state_cnt == br_length + 1) begin
          next_state = W_PRE_CHARGE;
        end
    endcase
  end

  always @(posedge clk or negedge rst_n) begin
      if(!rst_n) begin
        arf_ack <= 1'b0;
      end
      else if(state == W_AUTO_REFRESH) begin
        arf_ack <= 1'b1;
      end
      else begin
        arf_ack <= 1'b0;
      end
  end
  always @(posedge clk or negedge rst_n) begin
      if(!rst_n) begin
        init_done <= 1'b0;
      end
      else if(state == ARBIT) begin
        init_done <= 1'b1;
      end
      else begin
        init_done <= init_done;
      end
  end

  always @(posedge clk or negedge rst_n) begin
      if(!rst_n) begin
        sdram_cmd <= 5'b01111;
        sdram_addr <= 13'h1fff;
        sdram_bank <= 2'b11;
      end
      else begin
        case(state)
          IDLE, ARBIT, T_PRE_CHARGE, T_AUTO_REFRESH, T_MODE_REG_SET, T_W_AUTO_REFRESH, WR_PRE, WD, T_W_PRE_CHARGE, R_CL, RD, RD_POST:begin
            sdram_cmd <= 5'b10111;
            sdram_addr <= 13'h1fff;
            sdram_bank <= 2'b11;
          end
          PRE_CHARGE, W_PRE_CHARGE:begin
            sdram_cmd <= 5'b10010;
            sdram_addr <= 13'h1fff;
            sdram_bank <= 2'b11;
          end
          AUTO_REFRESH, W_AUTO_REFRESH:begin
            sdram_cmd <= 5'b10001;
            sdram_addr <= 13'h1fff;
            sdram_bank <= 2'b11;
          end
          MODE_REG_SET:begin
            sdram_cmd <= 5'b10000;
            sdram_bank <= 2'b00;
            sdram_addr <= {
                          3'b000,
                          1'b0,
                          2'b00,
                          3'b011,
                          1'b0,
                          3'b111
                          };
          end
          ACTIVE:begin
            sdram_cmd <= 5'b10011;
            if (wr_req) begin
              sdram_bank <= wr_sys_addr[23:22];
              sdram_addr <= wr_sys_addr[21:9];
            end
            else begin
              sdram_bank <= rd_sys_addr[23:22];
              sdram_addr <= rd_sys_addr[21:9];
            end
          end
          WRITE:begin
            sdram_cmd <= 5'b10100;
            sdram_bank <= wr_sys_addr[23:22];
            sdram_addr <= {4'b0, wr_sys_addr[8:0]};
          end
          READ:begin
            sdram_cmd <= 5'b10101;
            sdram_bank <= rd_sys_addr[23:22];
            sdram_addr <= {4'b0, rd_sys_addr[8:0]};
          end
          WR_TERM, RD_TERM:begin
            sdram_cmd <= 5'b10110;
            sdram_bank <= 2'b11;
            sdram_addr <= 13'h1fff;
          end
        endcase
      end
    end

  always @(posedge clk or negedge rst_n) begin
      if(!rst_n) begin
        wr_en <= 1'b0;
      end
      else if(wr_ack) begin
        wr_en <= 1'b1;
      end
      else begin
        wr_en <= 1'b0;
      end
  end

  always @(posedge clk or negedge rst_n) begin
      if(!rst_n) begin
        wr_ack <= 1'b0;
      end
      else if (br_length == 1) begin
        if (state == WR_PRE && wr_req) begin
          wr_ack <= 1'b1;
        end
        else begin
          wr_ack <= 1'b0;
        end
      end
      else if (br_length == 2) begin
        if ((state == WR_PRE && wr_req) || state == WRITE) begin
          wr_ack <= 1'b1;
        end
        else begin
          wr_ack <= 1'b0;
        end
      end
      else begin
        if(   state == WR_PRE && wr_req ||
              state == WRITE ||
              state == WD && state_cnt < br_length - 2) begin
          wr_ack <= 1'b1;
        end
        else begin
          wr_ack <= 1'b0;
        end
      end
  end

  always @(posedge clk or negedge rst_n) begin
      if(!rst_n) begin
        rd_post_d <= 1'b0;
      end
      else if(state == RD_POST) begin
        rd_post_d <= 1'b1;
      end
      else begin
        rd_post_d <= 1'b0;
      end
  end

  always @(posedge clk or negedge rst_n) begin
      if(!rst_n) begin
        rd_ack <= 1'b0;
      end
      else if(state == RD && state_cnt >= 3 ||
              state == RD_TERM ||
              state == RD_POST ||
              rd_post_d
              ) begin
              rd_ack <= 1'b1;
      end
      else begin
        rd_ack <= 1'b0;
      end
  end
  assign sdram_data = wr_en ? wdata: 16'hzzzz;

  always @(posedge clk or negedge rst_n) begin
      if(!rst_n) begin
        sdram_data_r <= 16'b0;
      end
      else begin
        sdram_data_r <= sdram_data;
      end
  end
  assign rdata = sdram_data_r;
endmodule
