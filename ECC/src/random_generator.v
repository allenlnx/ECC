`timescale 1ns/100ps
module random_generator (
	input			clk		,
	input			rst_n	,
	input	[3:0]	i_q_dec		,
	input			i_newSlot_cu	,
	input			i_decSlot_cu	,
	input			i_seed_in_rng	,
	input	[15:0]	i_data_rom_16bits	,
	
	output reg [15:0] 	o_random_rng	,
	output reg 			o_slotz_rng	
			);

//----------------------------------------------------------------------
// random number generator
//----------------------------------------------------------------------
reg	[15:0]	random_number	;
reg	[14:0]	slot		;
reg 	[14:0]	slot_mask	;
reg 	[15:0]	random_d	;
integer 	i	= 0	;

always @ (*)
	begin 
	o_random_rng	=	random_number 	 		;
	o_slotz_rng		=	(slot & slot_mask )==15'b0	;
	end

always @ (*) 
	begin 
	slot_mask 	=	15'b0		;
	if (i_q_dec >0)
		for (i=0;i<15;i=i+1)
			slot_mask [i]	=	i<i_q_dec ;
	end

reg		en_slot		;
reg		clk_slot	;
always @ (negedge clk or negedge rst_n)	
  if(~rst_n)
    en_slot = 1'b0;
	else	en_slot =	i_newSlot_cu || i_decSlot_cu 	;
	
always @ (*)
	clk_slot =	en_slot	&clk	;

always 	@(posedge clk_slot or negedge rst_n)
	if(!rst_n)
		slot	<= 'd0	;
	else if (i_newSlot_cu )
		slot 	<=	o_random_rng ;
	else if (i_decSlot_cu )
		slot 	<=	slot -1		;
	else slot	<=	slot		;
	
always @ (*) 
	begin 
	random_d 	=	random_number <<1 ;
	random_d [0]	=	~(random_number[8]^random_number[9]^random_number[12]);  
 	random_d [5]	=	~(random_number[15]^random_number[14]^random_number[2]);
	random_d [10]	=	~(random_number[3]^random_number[4]^random_number[7]);
	end             	

always 	@(posedge clk or negedge rst_n )
	if (~rst_n )
		random_number  	<=	16'hbeaf	;
	else if (i_seed_in_rng )
		random_number  	<=	i_data_rom_16bits	;
	else 
		random_number  	<=	random_d 	;
endmodule 

 
 
 
 
