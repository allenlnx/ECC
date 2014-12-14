/*******************************
module name : Arithmetic Logic Unit
author : wu cheng
describe: this module defines three operations: addition,multiplication and square
version:1.2
*********************************/
module alu(	input			clk,
			input			rst_n,
			input	[162:0]	a,
			input	[162:0]	b,
			input			ss,
			input			st,
			input			sy,
			input			m_start,			   				  
			
			output	[162:0]	y,
			output			m_done
			);
				  				  
/*******************internal via *********************/
wire    [162:0]    s_in,y_tmp,m_out,a_out,s_out;
/*******************procedure ***************************/
assign s_in[162:0] = ss ? a[162:0] : b[162:0];
assign y_tmp[162:0] = st ? a_out[162:0] : m_out[162:0];
assign y[162:0] = sy ? s_out[162:0] : y_tmp[162:0];

ff_squarer  squarer(
					.a(s_in),
					.c(s_out)
					);
ff_adder    adder(
				.a(a),
				.b(b),
				.c(a_out)
				);

ff_mult     multiplication(
							.clk(clk),
							.rst_n(rst_n),
							.start(m_start),
							.a(a),
							.b(b),							
							.p(m_out),
							.done(m_done));
endmodule
