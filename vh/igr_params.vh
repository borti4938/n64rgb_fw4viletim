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
// Company: Circuit-Board.de
// Engineer: borti4938
//
// VH-file Name:   igr_params
// Project Name:   n64rgb
// Target Devices: several MaxII & MaxV devices
// Tool versions:  Altera Quartus Prime
// Description:
//
// Revision: 1.0
// Features: assign user button combinations for IGR feature
//           edit only lines from line 50 on
//
//////////////////////////////////////////////////////////////////////////////////

`ifndef _igr_params_vh_
`define _igr_params_vh_


// controller data bits:
//  0: 7 - A, B, Z, St, Du, Dd, Dl, Dr
//  8:15 - 'Joystick reset', (0), L, R, Cu, Cd, Cl, Cr
// 16:23 - X axis
// 24:31 - Y axis
// 32    - Stop bit
// (bits[0:15] used here)

// define constants
// don't edit these constants

`define A  16'h0001 // button A
`define B  16'h0002 // button B
`define Z  16'h0004 // trigger Z
`define St 16'h0008 // Start button

`define Du 16'h0010 // D-pad up
`define Dd 16'h0020 // D-pad down
`define Dl 16'h0040 // D-pad left
`define Dr 16'h0080 // D-pad right

`define L  16'h0400 // shoulder button L
`define R  16'h0800 // shoulder button R

`define Cu 16'h1000 // C-button up
`define Cd 16'h2000 // C-button down
`define Cl 16'h4000 // C-button left
`define Cr 16'h8000 // C-button right

// user definitions:
// - add your button combinations here

`define IGR_RESET         (`A + `B + `Z + `St + `R)

`define IGR_DEBLUR_OFF    (`Z + `St + `R + `Cl)
`define IGR_DEBLUR_ON     (`Z + `St + `R + `Cr)

`define IGR_16BITMODE_OFF (`Z + `St + `R + `Cu)
`define IGR_16BITMODE_ON  (`Z + `St + `R + `Cd)

`define IGR_TOGGLE_LPF    (`Z + `St + `L + `Dl)

`endif