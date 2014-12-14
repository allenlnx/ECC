`timescale 1ns/100ps
module modulate(
	input			clk		,
	input			rst_n	,
	input			i_data_ocu	,
	input	[1:0]	i_m_dec		,
	input			i_enable_mod	,
	input			i_mblf_mod	,
	input			i_violate_mod	,
	input			i_en2blf_mod	,
	input			i_clear_cu	,
	
	output	reg		o_data_mod	
			);

parameter 	P1H	=	3'd1 	,
			P1L	=	3'd0 	,
			P2H	=	3'd3 	,
			P2L	=	3'd2 	,
			IDLE=	3'd4	,
			DONE=	3'd6 	;
	
reg [2:0]	state, next	;
reg 		mode_fm0	;
reg 		mode_miller	;
reg [3:0]	mc			;
reg 		half_datarate	;
reg 		datarate	;
reg 		data_d		;

always @ (*) 
	begin 
	mode_fm0 	=	i_m_dec ==2'b00	;
	mode_miller 	=	i_m_dec !=2'b00 	;
	end

always	@(posedge clk or negedge rst_n )
	if (~rst_n )
		state <=	IDLE	;
	else if (i_clear_cu )
		state <=	IDLE 	;
	else
		state <=	next 	;

always @ (*) 
begin
    next = state;
	if (mode_fm0 && i_en2blf_mod )
		case (state )
		IDLE :	next 	=	(i_enable_mod ) ? P1H :IDLE ;
		P1H :	next 	=	(i_data_ocu )? P2H :P2L 	;
		P1L :	next 	=	(i_data_ocu )? P2L :P2H 	;
		P2H :	next 	=	(~i_enable_mod )? DONE :P1L 	;
		P2L :	next 	=	(~i_enable_mod )? DONE :(i_violate_mod)? P1L :P1H 	;
		default :	next 	=	IDLE 	;
		endcase
	else if (i_en2blf_mod )
		case (state )
		IDLE :	next 	=	(i_enable_mod ) ? P1H :IDLE ;
		P1H :	next 	=	P2L 	;
		P1L :	next 	=	P2H 	;
		P2H :
			begin 
			if (datarate )
				next 	=	(~i_data_ocu && ~data_d ) ? P1H : P1L 	;
			else if (half_datarate )
				next 	=	(i_data_ocu )? P1H : P1L 	;
			else 
				next 	=	P1L 	;
			end
		P2L :
			begin 
			if (datarate )
				next 	=	(~i_data_ocu && ~data_d ) ? P1L : P1H  	;
			else if (half_datarate )
				next 	=	(i_data_ocu && ~i_mblf_mod )? P1L : P1H  	;
			else 
				next 	=	P1H  	;
			end	
		default :	next 	=	IDLE 	;
		endcase 	
	else
		next 	=	state 			;
end

always	@(posedge clk or negedge rst_n )
	if (~rst_n )
		mc 		<=	4'h0	;
	else if (state ==IDLE || state ==DONE )
		mc 		<=	4'h0 	;
	else if (i_en2blf_mod )
		mc 		<=	mc + 'h1	;

always 	@(posedge clk  or negedge rst_n )
	if (~rst_n )
		data_d 		<=	1'b0 	;
	else if (i_en2blf_mod )
		data_d 		<=	i_data_ocu 	;

always @ (*) 
	begin 
	o_data_mod 	=	state [0]		;
	case (i_m_dec )
	2'b01:	
		begin 
		half_datarate 	=	mc [0]==1'b1		;
		datarate 	=	mc [1:0]==2'b11		;
		end
	2'b10:
		begin 
		half_datarate 	=	mc [1:0]==2'b11 	;     
		datarate 	=	mc [2:0]==3'b111	;     
		end 
	2'b11:
		begin 
		half_datarate 	=	mc [2:0]==3'b111 	;
		datarate 	=	mc [3:0]==4'b1111	;
		end 
	default :
		begin 
		half_datarate 	=	1'b0		;
		datarate 	=	1'b0 		;
		end
	endcase 
	end
	
endmodule
 
 
 
 
