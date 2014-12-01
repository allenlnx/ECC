//for 
`timescale 1ns/100ps

module	reader_cdr(testcase, CLK, RESET, /*RX,*/ MOD, /*RX_CLK,*/ TX_R, dr_sel0, dr_sel1,POR,Tag_data,Tag_finish,Tag_data_number);

input[1:0]	testcase;
input	CLK;	//6.4mhz
input	RESET;
//input	RX;
input 	MOD ;
//input	RX_CLK;
input	dr_sel0;
input	dr_sel1;
input[255:0] 	Tag_data;
input 	Tag_finish;
input[15:0] 	Tag_data_number;

output	TX_R;
output 	POR ;

wire	[7:0]	DBUS_OUT;
wire	[7:0]	DBUS_IN;
wire	ACK;
wire	response_eof, challenge_eof ;
//wire	RX;
//wire 	RX_CLK;
wire	CLK;
wire	TX_R;
//wire	dr_sel10;
//wire	dr_sel11;
wire[1:0] testcase;
wire 	pssp_reset;

assign reset_pssp = (pssp_reset && RESET);

ps_sp 	PS_SP(	.reset(reset_pssp),
//			.rx(RX),
//	        .r_clk(RX_CLK),
	        .ack(ACK),
	        .clk(CLK),
	        .dbus_in(DBUS_IN),
	        .dbus_out(DBUS_OUT),
	        .tx(TX_R),
//	        .t_clk(T_CLK),
//	        .collision(COLLISION),
//	        .ask(ASK),
//	        .crc_err(CRC_ERR),
	        .dr_sel0(dr_sel0),
	        .response_eof (response_eof) ,
	        .challenge_eof (challenge_eof) ,
	        .dr_sel1(dr_sel1)					
);

r_control	CON(	.reset(RESET),
//			.rx(RX),
			.clk(CLK),
			.ack(ACK),
			.mod (MOD) ,
			.POR(POR) ,
			.response_eof(response_eof) ,
			.challenge_eof (challenge_eof) ,
			.db_in(DBUS_OUT),
			.db_out(DBUS_IN),
			.testcase(testcase),
			.pssp_reset(pssp_reset),
			.Tag_data(Tag_data[32:0]),
			.Tag_finish(Tag_finish),
			.Tag_data_number(Tag_data_number)
);

endmodule


