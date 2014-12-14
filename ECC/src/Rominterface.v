`timescale 1ns/100ps
module rominterface (
	input			clk		,
	input			rst_n	,
	input			i_rd_rom		,
	input			i_wr_rom		,
	input	[6:0]	i_addr_rom		,
	input	[7:0]	i_wordcnt_rom	,
	input	[15:0]	Q		,
		
	output				o_fifo_full_rom	,	
	output				o_done_rom	,	
	output				CEN	,
	output	reg [6:0]	A	,
	output	reg [15:0]	o_data_rom_16bits	
	);


parameter
	Idle =2'd0 , Addr =2'd1 , Cen =2'd2 , Finish =2'd3 ;
//	CEN2nd =4 , Store =5, Finish = 6;
	
//----------------------to ROM ---------------//
wire			new_round;
reg				CEN_d ;
reg		[6:0]	addr_buf	;
//-------------------------------------------//

reg	[1:0]	next, state ;

always @ (posedge clk or negedge rst_n)
begin
	if(~rst_n)
	state <= Idle 	;
	else if (o_done_rom)
	state <= Idle	;
	else 
	state <= next	;
end

always @ (posedge clk or negedge rst_n)
	begin
	if (!rst_n)
		addr_buf <= 7'b0;
	else 
		addr_buf <= i_addr_rom;
	end

assign new_round = (addr_buf != i_addr_rom) ;		
//------------------------------------------------//

assign	o_done_rom = (state == Finish && i_wordcnt_rom == 8'b1)	;
assign	o_fifo_full_rom = (state == Finish)	;

//------------------------------------------------//
always @ (posedge clk or negedge rst_n)
begin
	if(~rst_n)
		A <= 7'b0 	;
	else if (state==Addr && next ==Cen)
		A <= i_addr_rom	;
	else 
		A <= A	;
end
//------------------------------------------------//

always @ (negedge clk or negedge rst_n)
begin
	if (~rst_n)
		CEN_d <= 1'b0 ;
	else if (state==Cen)
		CEN_d <= 1'b1 ;
	else
		CEN_d <= 1'b0 ;
end

assign CEN = !CEN_d ;
//------------------------------------------------//

always @ (negedge clk or negedge rst_n)
begin
	if (~rst_n)
		o_data_rom_16bits <= 16'b0 ;
	else if (state==Finish)
		o_data_rom_16bits <= Q ;
	else;
	
end
//------------------------------------------------//
always @ (*)
 begin
	next <= state ;
	case (state)
	Idle: if(new_round && ~o_done_rom) 
		  next<=Addr;
		  else if(o_done_rom)
		  next<=Idle ;
		  else 
		  next<=state ;
	Addr: if (i_rd_rom||i_wr_rom) 
			next<=Cen ;
		  else 
			next<=state;
	Cen:  next<=Finish ;
	Finish:  next<=Idle ;
	default: next<=Idle ;	
	endcase
end
	
	//------------------------------------------------//
	
 
 endmodule
 
