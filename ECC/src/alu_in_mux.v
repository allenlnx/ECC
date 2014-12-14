/*******************************
module name : ALU INPUT MUX
author : wu cheng
describe: this module is designed for selecting operands for ALU module 
          as well as determining their sequence
version:1.2  
*********************************/
module alu_in_mux( 
				input	[162:0]	xa,
				input	[162:0]	xb,
				input	[162:0]	g,
				input	[162:0]	za,
				input	[162:0]	zb,
				input	[162:0]	zc,
				input			select_x,
				input			select_xab,				   
				input			select_z,
				input			select_zab, 
				
				output  [162:0]	alu_x,
				output  [162:0]	alu_z
				);
				  
/*******************internal via *********************/
wire    [162:0]    x_ab;
wire    [162:0]    z_ab;
/*******************procedure ***************************/

        
assign x_ab[162:0] = select_xab ? xa[162:0] : xb[162:0];
assign alu_x[162:0] = select_x ? x_ab[162:0] : g[162:0];

assign z_ab[162:0] = select_zab ? za[162:0] : zb[162:0];
assign alu_z[162:0] = select_z ? z_ab[162:0] : zc[162:0];
  
endmodule
