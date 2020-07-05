//////////////////////////////////////////////////////////////////////////////////
//
// This file is part of the N64 RGB/YPbPr DAC project.
//
// Copyright (C) 2016-2018 by Peter Bartmann <borti4938@gmail.com>
//
// N64 RGB/YPbPr DAC is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//
//////////////////////////////////////////////////////////////////////////////////
//
// Company:  Circuit-Board.de
// Engineer: borti4938
//
// Module Name:    n64_deblur
// Project Name:   N64 RGB DAC Mod
// Target Devices: universial
// Tool versions:  Altera Quartus Prime
// Description:    estimates whether N64 uses blur or not
//
// Dependencies: vh/n64rgb_params.vh
//
// Revision: 1.2
//
//////////////////////////////////////////////////////////////////////////////////


module n64_deblur (
  VCLK,
  nDSYNC,

  nRST,

  vdata_pre,
  D_i,

  deblurparams_i,
  ndo_deblur
);

`include "vh/n64rgb_params.vh"

input VCLK;
input nDSYNC;

input nRST;

input [`VDATA_FU_SLICE] vdata_pre;
input [color_width-1:0] D_i;

input [5:0] deblurparams_i;         // order: data_cnt,vmode,n64_480i,nForceDeBlur,nDeBlurMan
output reg  ndo_deblur = 1'b1;


// some pre-assignments and definitions

wire   [1:0] data_cnt = deblurparams_i[5:4];
wire            vmode = deblurparams_i[  3];
wire         n64_480i = deblurparams_i[  2];
wire     nForceDeBlur = deblurparams_i[  1];
wire       nDeBlurMan = deblurparams_i[  0];

wire negedge_nVSYNC =  vdata_pre[3*color_width+3] & !D_i[3];
wire posedge_nCSYNC = !vdata_pre[3*color_width  ] &  D_i[0];

wire [2:0] Rcmp_pre = vdata_pre[3*color_width-1:3*color_width-3];
wire [2:0] Gcmp_pre = vdata_pre[2*color_width-1:2*color_width-3];
wire [2:0] Bcmp_pre = vdata_pre[  color_width-1:  color_width-3];

wire [2:0] Rcmp_cur = D_i[color_width-1:color_width-3];
wire [2:0] Gcmp_cur = D_i[color_width-1:color_width-3];
wire [2:0] Bcmp_cur = D_i[color_width-1:color_width-3];


// some more definitions for the heuristics

`define TREND_RANGE    8:0  // width of the trend filter
`define NBLUR_TH_BIT   8    // MSB

localparam init_trend = 9'h100;  // initial value (shall have MSB set, zero else)


// start of rtl

reg blur_pix = 1'b0;

always @(posedge VCLK)
  if (!nDSYNC) begin
    if(posedge_nCSYNC) // posedge nCSYNC -> reset blanking
      blur_pix <= ~vmode;
    else
      blur_pix <= ~blur_pix;
  end


reg run_estimation = 1'b0;  // do not use first frame after switching to 240p (e.g. from 480i)

reg [1:0] gradient[2:0];  // shows the (sharp) gradient direction between neighbored pixels
                          // gradient[x][1]   = 1 -> decreasing intensity
                          // gradient[x][0]   = 1 -> increasing intensity
                          // else                 -> constant
reg [1:0] gradient_changes = 2'b00; // value is 2'b11 if all gradients has been changed

reg [1:0] nblur_est_cnt     = 2'b00;  // register to estimate whether blur is used or not by the N64
reg [`TREND_RANGE] nblur_n64_trend = init_trend;  // trend shows if the algorithm tends to estimate more blur enabled rather than disabled
                                                  // this acts as like as a very simple mean filter
reg nblur_n64 = 1'b1;                             // blur effect is estimated to be off within the N64 if value is 1'b1

always @(posedge VCLK) begin // estimation of blur effect
  if (!n64_480i) begin
    if (!nDSYNC) begin
      if(negedge_nVSYNC) begin  // negedge at nVSYNC detected - new frame
        if (run_estimation) begin
          if (&nblur_est_cnt) // add to weight
              nblur_n64_trend <= &nblur_n64_trend ? nblur_n64_trend :         // saturate if needed
                                                    nblur_n64_trend + 1'b1;
          else                // subtract
              nblur_n64_trend <= |nblur_n64_trend ? nblur_n64_trend - 1'b1 :
                                                    nblur_n64_trend;          // saturate if needed

          nblur_n64 <= nblur_n64_trend[`NBLUR_TH_BIT];
        end

        nblur_est_cnt <= 2'b00;

        run_estimation <= 1'b1;
      end

      if(!blur_pix) begin  // incomming (potential) blurry pixel
                           // (blur_pix changes on next @(posedge VCLK))

        if (&gradient_changes)  // evaluate gradients
          if (~&nblur_est_cnt)
            nblur_est_cnt <= nblur_est_cnt +1'b1;

        gradient_changes    <= 2'b00; // reset
      end
    end else begin
      if (blur_pix) begin
        case(data_cnt)
            2'b01: gradient[2] <= {(Rcmp_pre < Rcmp_cur),(Rcmp_pre > Rcmp_cur)};
            2'b10: gradient[1] <= {(Gcmp_pre < Gcmp_cur),(Gcmp_pre > Gcmp_cur)};
            2'b11: gradient[0] <= {(Bcmp_pre < Bcmp_cur),(Bcmp_pre > Bcmp_cur)};
        endcase
      end else begin
        case(data_cnt)
            2'b01: if ( &(gradient[2] ^ {(Rcmp_pre < Rcmp_cur),(Rcmp_pre > Rcmp_cur)})) gradient_changes[0] <= 1'b1;
            2'b10: if (~&(gradient[1] ^ {(Gcmp_pre < Gcmp_cur),(Gcmp_pre > Gcmp_cur)})) gradient_changes[0] <= 1'b0;
            2'b11: if ( &(gradient[0] ^ {(Bcmp_pre < Bcmp_cur),(Bcmp_pre > Bcmp_cur)})) gradient_changes[1] <= 1'b1;
        endcase
      end
    end
  end else begin
    run_estimation <= 1'b0;
  end
  if (!nRST) begin
    nblur_n64_trend <= init_trend;
    nblur_n64       <= 1'b1;
    run_estimation  <= 1'b0;
  end
end


// finally the blanking management

always @(posedge VCLK) begin
  if (!nDSYNC) begin
    if (negedge_nVSYNC) begin // negedge at nVSYNC detected - new frame, new setting
      if (nForceDeBlur)
        ndo_deblur <= n64_480i | nblur_n64;
      else
        ndo_deblur <= n64_480i | nDeBlurMan;
    end
  end
end

endmodule
