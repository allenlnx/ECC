`timescale 1ns/100ps
module T_top_reader();
  
`include "./a.v"
`include "./parameters.v"

reg clk_6p4m;
reg clk_1p92m;
reg FPGA_RESET;
reg[1:0] testcase;

wire i_force_Crypto;
wire TEST;		
wire SET;

assign i_force_Crypto = `i_force_Crypto;
assign TEST = `TEST;
assign SET = `SET;


parameter reader_freq = `reader_freq_span;
parameter tag_freq    = `tag_freq_span	  ;
wire TX;

initial begin
      clk_6p4m <= 1'b0;
	  clk_1p92m <= 1'b0;
end

always 
#(reader_freq/2) 	clk_6p4m <= !clk_6p4m ;

always
#(tag_freq/2)	clk_1p92m <= !clk_1p92m; 

initial begin
	FPGA_RESET<=1'b0;
#100 FPGA_RESET<=!FPGA_RESET;
#50000000	$stop;
	end
	
initial begin
testcase<= 2'b0;
end
 
Reader_top reader(
			.clk_6p4m(clk_6p4m), //in 6p4m
			.testcase(testcase), //in
			.POR(POR),			
			.FPGA_RESET(FPGA_RESET), //in
			.TX(TX),
			.MOD(MOD)				//in	
			);
			
//-------------instantiation for tag-------------
tag tag(
  .clk		(clk_1p92m		),  //1.5625mhz
  .rst_n	(POR		),
  .i_pie	(TX			),
  .o_mod	(MOD),
  .i_force_Crypto(i_force_Crypto),
  .TEST(TEST),		
  .SET(SET)
           );
           
			
endmodule