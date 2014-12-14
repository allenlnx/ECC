`timescale 1ns/100ps
module tag (
	input	clk	,
	input	rst_n	,
	input	i_pie	,
	input	i_force_Crypto,
	input	TEST	,
	input	SET	,
	
	output	o_mod
	) ;

	// wires 
	wire [15:0] Q	;
    wire [6:0] A	;
	wire 	clk_rom ;
	wire 	CEN	;

tag_digital_core	core(
	.clk		(clk 		),	
	.rst_n		(rst_n 		),
	.i_pie		(i_pie 		),
	.o_mod		(o_mod 		),
	.TEST(TEST)  , 		
	.SET (SET) ,
	.o_A_rom(A) ,
	.o_clk_rom(clk_rom),
	.i_Q_rom(Q) ,
	.o_CEN_rom(CEN)
	);
	
//Bimod_Tag_ROM rom (
reg_rom rom(
    .Q(Q),
    .CLK(clk_rom),
    .CEN(CEN),
    .A(A[5:0]),
	.rst_n(rst_n)
                )	;
//assign rom_romout = 1'b0	;

endmodule

