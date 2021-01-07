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
//
// Description:
//
// short description of N64s RGB and sync data demux
// -------------------------------------------------
//
// pulse shapes and their realtion to each other:
// VCLK (~50MHz, Numbers representing posedge count)
// ---. 3 .---. 0 .---. 1 .---. 2 .---. 3 .---
//    |___|   |___|   |___|   |___|   |___|
// nDSYNC (~12.5MHz)                           .....
// -------.       .-------------------.
//        |_______|                   |_______
//
// more info: http://members.optusnet.com.au/eviltim/n64rgb/n64rgb.html
//
//////////////////////////////////////////////////////////////////////////////////

`define v1

module n64rgb2_viletim_sw_top (
  // N64 Video Input
  VCLK,
  nDSYNC,
  D_i,

  nAutoPad,    // used for VI-DeBlur off (open) and on (shorted to GND)
  nManualPad,  // used for 16bit mode off (open) and on (shorted to GND)
  `ifdef v1
    nManualPad_p1,  // pin 1 dublicate of this pad
  `endif

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

input nAutoPad;
input nManualPad;
`ifdef v1
  input nManualPad_p1;
`endif

output nHSYNC;
output nVSYNC;
output nCSYNC;
output nCLAMP;

output [color_width-1:0] R_o;
output [color_width-1:0] G_o;
output [color_width-1:0] B_o;


// start of rtl

wire n16bit_mode, nDeBlur;
wire [3:0] vinfo_pass;
wire [`VDATA_FU_SLICE] vdata_r;

`ifndef v1
  assign n16bit_mode = nManualPad;
`else
  assign n16bit_mode = nManualPad & nManualPad_p1;
`endif
assign nDeBlur = nAutoPad;

// acquire vinfo
// =============

n64_vinfo_ext get_vinfo(
  .VCLK(VCLK),
  .nDSYNC(nDSYNC),
  .Sync_pre(vdata_r[`VDATA_SY_SLICE]),
  .Sync_cur(D_i[3:0]),
  .vinfo_o(vinfo_pass)
);


// video data demux
// ================

n64_vdemux video_demux(
  .VCLK(VCLK),
  .nDSYNC(nDSYNC),
  .D_i(D_i),
  .demuxparams_i({vinfo_pass[3:1],nDeBlur,n16bit_mode}),
  .vdata_r_0(vdata_r),
  .vdata_r_1({nVSYNC,nCLAMP,nHSYNC,nCSYNC,R_o,G_o,B_o})
);


endmodule
