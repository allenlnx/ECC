`timescale 1ns/100ps
module crc16 (
	clk		,
	rst_n		,
	i_reload_crc	,
	i_valid_crc	,
	i_data_crc	,
	i_shift_crc	,
	o_data_crc		);

input			clk		;
input			rst_n		;
input			i_reload_crc	;
input			i_valid_crc	;
input			i_data_crc	;
input			i_shift_crc	;
output	[15:0]		o_data_crc	;
reg	[15:0]		o_data_crc	;

reg	[15:0]	crc16_d		;
wire		temp	 	;

assign temp =  o_data_crc [15] ^ i_data_crc		;

always @ (*) 
	if (i_shift_crc )
		crc16_d		=	o_data_crc<<1	;
	else
		begin
		crc16_d 	=	o_data_crc<<1	;
		crc16_d[0]	=	temp			;
		crc16_d[5]	=	o_data_crc [4] ^ temp 	;
		crc16_d[12]	= 	o_data_crc [11] ^ temp	;
		end

always 	@(posedge clk or negedge rst_n )
	if (~rst_n )
		o_data_crc 	<=	16'hffff		;
	else if (i_reload_crc )
		o_data_crc 	<=	16'hffff		;
	else if (i_valid_crc )
		o_data_crc 	<=	crc16_d 		;
	
endmodule 
 
 
 
