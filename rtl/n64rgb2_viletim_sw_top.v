//////////////////////////////////////////////////////////////////////////////////
//
// This file is part of the N64 RGB/YPbPr DAC project.
//
// Copyright (C) 2016-2019 by Peter Bartmann <borti4938@gmail.com>
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
// Company: Circuit-Board.de
// Engineer: borti4938
// (initial design file by Ikari_01)
//
// Module Name:    n64rgb2_viletim_sw_top
// Project Name:   N64 RGB DAC Mod
// Target Devices: MaxII: EPM240T100C5
// Tool versions:  Altera Quartus Prime
// Description:
//
// Dependencies: rtl/n64_vinfo_ext.v  (Rev. 1.0)
//               rtl/n64_deblur.v     (Rev. 1.1)
//               rtl/n64_vdemux.v     (Rev. 1.0)
//               vh/n64rgb_params.vh
//
// Revision: 1.5
// Features: BUFFERED version (no color shifting around edges)
//           de-blur with heuristic estimation (auto)
//           15bit color mode (5bit for each color) if wanted
//
//////////////////////////////////////////////////////////////////////////////////

module n64rgb2_viletim_sw_top (
  // N64 Video Input
  VCLK,
  nDSYNC,
  D_i,

  nAutoDeBlur,
  nForceDeBlur,  // feature to enable de-blur (0 = feature on, 1 = feature off)
  n15bit_mode,      // 15bit color mode if input set to GND (weak pull-up assigned)

  // Video output
  nHSYNC,
  nVSYNC,
  nCSYNC,
  nCLAMP,

  R_o,
  G_o,
  B_o
);

`include "vh/n64rgb_params.vh"

input                   VCLK;
input                   nDSYNC;
input [color_width-1:0] D_i;

input nAutoDeBlur;
input nForceDeBlur;
input n15bit_mode;

output nHSYNC;
output nVSYNC;
output nCSYNC;
output nCLAMP;

output [color_width-1:0] R_o;
output [color_width-1:0] G_o;
output [color_width-1:0] B_o;


// start of rtl

// Part 1: connect switches
// ========================

reg nForceDeBlur_L, nDeBlurMan_L, nrst_deblur_L;

always @(*) begin
  nForceDeBlur_L <= !nAutoDeBlur & nForceDeBlur;
  nDeBlurMan_L   <= nForceDeBlur;
  nrst_deblur_L  <= !nAutoDeBlur;
end


// Part 2 - 4: RGB Demux with De-Blur Add-On
// =========================================
//
// short description of N64s RGB and sync data demux
// -------------------------------------------------
//
// pulse shapes and their realtion to each other:
// VCLK (~50MHz, Numbers representing negedge count)
// ---. 3 .---. 0 .---. 1 .---. 2 .---. 3 .---
//    |___|   |___|   |___|   |___|   |___|
// nDSYNC (~12.5MHz)                           .....
// -------.       .-------------------.
//        |_______|                   |_______
//
// more info: http://members.optusnet.com.au/eviltim/n64rgb/n64rgb.html
//

// Part 2: get all of the vinfo needed for further processing
// ==========================================================

wire [3:0] vinfo_pass;

n64_vinfo_ext get_vinfo(
  .VCLK(VCLK),
  .nDSYNC(nDSYNC),
  .Sync_pre(vdata_r[`VDATA_SY_SLICE]),
  .Sync_cur(D_i[3:0]),
  .vinfo_o(vinfo_pass)
);


// Part 3: DeBlur Management (incl. heuristic)
// ===========================================

wire ndo_deblur;

n64_deblur deblur_management(
  .VCLK(VCLK),
  .nDSYNC(nDSYNC),
  .nRST(nrst_deblur_L),
  .vdata_pre(vdata_r),
  .D_i(D_i),
  .deblurparams_i({vinfo_pass,nForceDeBlur_L,nDeBlurMan_L}),
  .ndo_deblur(ndo_deblur)
);


// Part 4: data demux
// ==================

wire [`VDATA_FU_SLICE] vdata_r;

n64_vdemux video_demux(
  .VCLK(VCLK),
  .nDSYNC(nDSYNC),
  .D_i(D_i),
  .demuxparams_i({vinfo_pass[3:1],ndo_deblur,n15bit_mode}),
  .vdata_r_0(vdata_r),
  .vdata_r_1({nVSYNC,nCLAMP,nHSYNC,nCSYNC,R_o,G_o,B_o})
);


endmodule
