/*******************************
module name : Arithmetic Logic Unit
author : wu cheng
describe: this module defines three operations: addition,multiplication and square
version:1.1  
*********************************/
module alu(    clk,
               rst_n,
				   a,
				   b,
				   ss,
				   st,
				   sy,
				   m_start,			   				  
				   y,
				   m_done);
				  
				  
input                clk,rst_n,m_start;
input     [162:0]    a;
input     [162:0]    b;
input                ss;
input                st;
input                sy;

output  [162:0]    y;
output             m_done;

wire    [162:0]    y;
/*******************internal via *********************/
wire    [162:0]    s_in,y_tmp,m_out,a_out,s_out;
/*******************procedure ***************************/
assign s_in[162:0] = ss ? a[162:0] : b[162:0];
assign y_tmp[162:0] = st ? a_out[162:0] : m_out[162:0];
assign y[162:0] = sy ? s_out[162:0] : y_tmp[162:0];

ff_squarer  squarer(s_in,s_out);
ff_adder    adder(a,b,a_out);
ff_mult     multiplication(clk,rst_n,a,b,m_start,m_out,m_done);
endmodule
