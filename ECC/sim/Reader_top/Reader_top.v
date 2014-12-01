//Version: V2.00
//Data: 2013.11.24
//Block Information: Clock generation / RST function for the RTL UHF reader testcase
//Modification Information: Create by lhzhu

`timescale 1ns/100ps

module	Reader_top(
			clk_6p4m,
			testcase,
			POR,
			FPGA_RESET,
			TX,
			MOD
			);

input[1:0] testcase;
input clk_6p4m;
input FPGA_RESET;
input MOD;

output TX;
output POR;

wire clk_6p4m;

parameter Addr_Width = 5 ;
wire MOD ;
wire TX	;
//wire DAT_clk;
wire POR ;
//wire DAT_BUFFER;
wire[1:0] testcase;
wire [255:0] Tag_data;
wire [15:0] Tag_data_number;

//------------- end of clk divide -------------

pulse_cnt	PULSE_CNT(
				.clk(clk_6p4m),
				.data(MOD),
				.reset(TX),
				.Tag_data(Tag_data),
				.Tag_finish(Tag_finish),
				.Tag_data_number(Tag_data_number));
           
//-------------instantiation for reader-------------
reader_cdr	READER(	
				.CLK(clk_6p4m),			//INPUT 6.25mhz
	       		.RESET(FPGA_RESET), 				//INPUT global RESET
//	       		.RX(DAT_BUFFER),			//INPUT DATA (synchronized)
	       		.MOD(MOD) ,					//INPUT tag's backscatter
//	       		.RX_CLK(DAT_clk),			//INPUT clk for DATA(synchronized)
				.POR(POR) ,					//OUTPUT tag/reader RESET
	       		.TX_R(TX),					//OUTPUT reader's command to tag 
	       		.dr_sel0(1'b0),		   	//INPUT fixed 0
	       		.dr_sel1(1'b1),			//INPUT fixed 1
				.testcase(testcase),			//INPUT testcase select (added by lhzhu)
				.Tag_data(Tag_data),
				.Tag_finish(Tag_finish),
				.Tag_data_number(Tag_data_number)
				);
endmodule



