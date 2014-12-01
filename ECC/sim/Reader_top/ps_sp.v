`timescale 1ns/100ps


`include "./a.v"


module 	ps_sp(reset,/*rx,r_clk,*/ack,clk,dbus_in,dbus_out,tx,/*t_clk,collision,ask,crc_err,*/dr_sel0,dr_sel1,response_eof,challenge_eof);
input	reset,/*rx,r_clk,*/ack,clk,dr_sel0,dr_sel1;
input	[7:0]	dbus_in;		//critical for reader to tag 
output	tx;

output response_eof ;			//Tag Backscatter finished
output challenge_eof ;			//Reader to tag signal finished
output	[7:0]	dbus_out;
reg	tx;
/*reg collision,ask,crc_err*/
//output  t_clk;
/*output collision,ask,crc_err;*/
//reg t_clk;

reg	[7:0]	dbus_out;
reg 	[2:0]	state;			//WAITING,JUDGING,INVALID,RECEIVE,TRANSIT,SENDING state reg
reg 	[4:0]	pre_state;		//when JUDGING,preamble state reg
reg 	[2:0]	send_state;		//when SENDING,sending state reg for produce PIE
reg 	[1:0]	code_mode;		//when JUDGING,the state of decode mode FM0 or Miller
reg 	[1:0]	FM0;			//FM0 decode reg
reg 	[15:1]	Miller;			//Miller decode reg
reg 	[7:0]	pre_cnt;		//when JUDGING,the counter used to find edge
reg 	[3:0]	mil_cnt;		//when RECEIVE,the counter used in Miller mode in 3 rates
reg 	[15:0]	end_cnt;		//the counter to judge the end of data
reg 	[15:0]	data_cnt;		//the counter to store the length of data
reg 	[511:0]	ex_data;		//the reg to store data
reg 	[15:0]	transit_cnt;	//when TRANSIT,the counter used to transit data byte by byte
reg 	[15:0]	sending_cnt;	//when SENDING,the counter used to send data with PIE
reg 	[15:0]	send_time;		//when SENDING,the counter to produce the Tari
reg 	[7:0]	send_clk;		//when SENDING,the counter to produce the t_clk

//reg 	pre_r_clk;				//reg storing former r_clk to find posedge
reg 	pre_ack;				//reg storing former ack to find posedge
reg 	pre_rx;					//reg storing former rx to find edge
reg 	shift;					//decode_crc shift signal,posedge enable
reg 	decode;					//reg to store decode bit
reg 	receive_pre16;			//decode_crc16 set signal
reg 	send_pre16;				//encode_crc16 set signal
reg 	send_pre5;				//encode_crc5 set signal
reg 	transit_total;			//the flag to show the length of data has been transitted
reg		send_total;				//the flag to show all data has been sent and ready to send with PIE
reg 	crc_flag;				//the flag to show the crc code ready
reg 	encode;					//the reg storing the data which should be encode to PIE
reg 	high_bit;				//the flag to show the high 8 bit of the number of data

wire [15:0] 	r_crc;			//crc deocde data
wire [15:0] 	s16_crc; 
wire [15:0]		s16_crc_temp;	//crc16 encode data
wire [4:0]  	s5_crc;			//crc5 encode data

reg	[15:0]	Tari;
reg	[15:0]	H_Tari;
reg	[15:0]	RTcal;
reg	[15:0]	TRcal;
reg	[15:0]	delimiter;
reg	[15:0]	END_COUNTER;

//-----------------------------------port and reg declaration

parameter SEND_FINISHED= 3'b111;
parameter WAITING=	3'b000;
parameter JUDGING=	3'b001;
parameter INVALID=	3'b010;
parameter RECEIVE=	3'b011;
parameter TRANSIT=	3'b100;
parameter SENDING=	3'b101;


//parameter tari_par = 16'd20   ;
//parameter `rtcal_par = 16'd100 ;
//parameter trcal_par  = 16'd220 ;



//160k
//parameter Tari=16'd20;
//parameter H_Tari=16'd10;
//parameter RTcal=16'd100;
//parameter TRcal=16'd220;
//parameter delimiter=16'd80;
//parameter END_COUNTER=16'd120;
//Query 10000000

//80k
//parameter Tari=16'd40;
//parameter H_Tari=16'd20;
//parameter RTcal=16'd200;
//parameter TRcal=16'd580;
//parameter delimiter=16'd80;
//parameter END_COUNTER=16'd240;
//Query 10000000

//40k
//parameter Tari=16'd80;
//parameter H_Tari=16'd40;
//parameter RTcal=16'd400;
//parameter TRcal=16'd1180;
//parameter delimiter=16'd80;
//parameter END_COUNTER=16'd480;
//Query 10000000

crc_16 decode_crc16 (.pre(receive_pre16),.clk(shift),.c(r_crc),.data(decode));		//receiving crc16 check
crc_16 encode_crc16 (.pre(send_pre16),.clk(~tx),.c(s16_crc_temp),.data(encode));		//sending crc16 encode
crc_5  encode_crc5  (.pre(send_pre5),.clk(~tx),.c(s5_crc),.data(encode));			//sending crc5 encode

assign s16_crc = ~s16_crc_temp ;
assign response_eof = state==TRANSIT ;
assign challenge_eof = state==SEND_FINISHED ;


always @(posedge clk or negedge reset)
begin
	if (reset==1'b0)
	begin
		tx<=1'b1;
//		t_clk<=1'b0;
//		collision<=1'b0;
//		ask<=1'b0;
//		crc_err<=1'b0;
		dbus_out<=8'b1111_1111;
		state<=WAITING;
		pre_state<=5'b0;
		send_state<=3'd7;
		code_mode<=2'b0;
		FM0<=2'b0;
		Miller<=15'b0;
		pre_cnt<=8'b0;
		mil_cnt<=4'b0;
		end_cnt<=16'b0;
		data_cnt<=16'b0;
		ex_data<=512'b0;
		transit_cnt<=16'b0;
		sending_cnt<=16'b0;
		send_time<=16'b0;
		send_clk<=8'b0;
//		pre_r_clk<=1'b0;
		pre_ack<=1'b0;
		pre_rx<=1'b0;
		shift<=1'b0;
		decode<=1'b0;
		receive_pre16<=1'b1;
		send_pre16<=1'b1;
		send_pre5<=1'b1;
		transit_total<=1'b0;
		send_total<=1'b0;
		crc_flag<=1'b0;
		encode<=1'b0;
		high_bit<=1'b0;
		END_COUNTER <=16'd0;
		TRcal	<=16'b0;
		delimiter <=16'd0;
		Tari	<=16'd0;
		RTcal	<=16'd0;
//		Tari<=16'd80;
//		H_Tari<=16'd40;
//		RTcal<=16'd400;
//		TRcal<=16'd1180;
//		delimiter<=16'd80;
//		END_COUNTER<=16'd480;

//--------------------------------------------------------initial all reg and state
	end
	else
	begin
//		pre_r_clk<=r_clk;
		pre_ack<=ack;

		if (dr_sel0==1'b0 && dr_sel1==1'b1)
		begin
			Tari <=`tari_par/2;  //16'd20;
			H_Tari <= `tari_par/2 ;//16'd10;
			RTcal <= `rtcal_par - (`tari_par/2) ;//16'd100;
			TRcal <= `trcal_par  -(`tari_par/2) ;//16'd220;
			delimiter <= `delimiter;
			END_COUNTER <= 6* `tari_par ;//16'd120;
		end
		else if (dr_sel0==1'b1 && dr_sel1==1'b1)
		begin
			Tari <= `tari_par ;//16'd20;
			H_Tari <= `tari_par/2 ;//16'd10;
			RTcal <= `rtcal_par ;//16'd100;
			TRcal <= `trcal_par ;//16'd220;
			delimiter <= 16'd80;
			END_COUNTER <= 6* `tari_par ;//16'd120;
		end
		else if (dr_sel0==1'b1 && dr_sel1==1'b0)
           		begin
                            /*
                              Tari<=16'd80;
                              H_Tari<=16'd40;
                              RTcal<=16'd400;
                              TRcal<=16'd1180;
                              delimiter<=16'd80;
                  	END_COUNTER<=16'd480;
                  	*/
                  		Tari <= `tari_par ;//16'd20;
			H_Tari <= `tari_par/2 ;//16'd10;
			RTcal <= `rtcal_par ;//16'd100;
			TRcal <= `trcal_par ;//16'd220;
			delimiter <= 16'd80;
			END_COUNTER <= 6* `tari_par ;//16'd120;
           		end
		else
		      begin
		      /*
		      	Tari<=16'd20;
		      	H_Tari<=16'd10;
		      	RTcal<=16'd100;
		      	TRcal<=16'd220;
		      	delimiter<=16'd80;
		      	END_COUNTER<=16'd120;
		      */
		     Tari <= `tari_par ;//16'd20;
			H_Tari <= `tari_par/2 ;//16'd10;
			RTcal <= `rtcal_par ;//16'd100;
			TRcal <= `trcal_par ;//16'd220;
			delimiter <= 16'd80;
			END_COUNTER <= 6* `tari_par ;//16'd120;
		      end

		case (state)
		WAITING:
				if (pre_ack==1'b0 && ack==1'b1) //posedge ack
				begin
					if (high_bit==1'b0)
					begin
						data_cnt[15:8]<=dbus_in;										//store the high 8 bit of data
						high_bit<=1'b1;
					end
					else if (high_bit==1'b1)
					begin
						data_cnt[7:0]<=dbus_in;
						high_bit<=1'b0;
						ex_data<=512'b0;
						sending_cnt<=16'b0;
						send_time<=16'b0;
						state<=SENDING;
					end
				end
				else
				begin
					state<=WAITING;
					tx<=1'b1;
				end
	
		SENDING:
		 	begin
			   pre_rx<=1'b0;                      //liudan
				if (send_total==1'b0)
				begin
					if (pre_ack==1'b0 && ack==1'b1)
					begin
						if (sending_cnt<data_cnt)	  							//store the data byte by byte
						begin
							ex_data[7]<=dbus_in[7];
							ex_data[6]<=dbus_in[6];
							ex_data[5]<=dbus_in[5];
							ex_data[4]<=dbus_in[4];
							ex_data[3]<=dbus_in[3];
							ex_data[2]<=dbus_in[2];
							ex_data[1]<=dbus_in[1];
							ex_data[0]<=dbus_in[0];
							ex_data[511:0]<={ex_data[503:0],dbus_in[7],dbus_in[6],dbus_in[5],dbus_in[4],dbus_in[3],dbus_in[2],dbus_in[1],dbus_in[0]};
							sending_cnt<=sending_cnt+16'd8;
							if (sending_cnt+8>=data_cnt)							//the last byte of data
							begin
//								t_clk<=1'b1;
								send_total<=1'b1;  								//set the flag to start sending
								sending_cnt<=16'b0;
								if (dbus_in[7:0]==8'b10110011 ||dbus_in[7:0]==8'b01110011 || dbus_in[7:0]==8'b11110011)
									send_state<=3'd0;
								else if (dbus_in[3:0]==4'b0001)						//if the command is Query
									send_state<=3'd0;		     				//the preamble is special
								else
									send_state<=3'b1;

							end
						end
					end
				end
				else if (send_total==1'b1)
				begin
					send_time<=send_time+16'd1;
					if (send_clk==H_Tari)										//produce the t_clk
					begin
//						t_clk<=~t_clk;
						send_clk<=8'b1;
					end
					else
						send_clk<=send_clk+8'b1;
					case (send_state)
					3'd0:
						begin
							if (send_time<delimiter)
								tx<=1'b0;
							else if (send_time==delimiter)		   				//produce the preamble
								tx<=1'b1;
							else if (send_time==delimiter+Tari)
								tx<=1'b0;
							else if (send_time==delimiter+Tari+Tari)
								tx<=1'b1;
							else if (send_time==delimiter+Tari+Tari+RTcal)
								tx<=1'b0;
							else if (send_time==delimiter+Tari+Tari+RTcal+Tari)
								tx<=1'b1;
							else if (send_time==delimiter+Tari+Tari+RTcal+Tari+TRcal)
								tx<=1'b0;
							else if (send_time==delimiter+Tari+Tari+RTcal+Tari+TRcal+Tari)
							begin
								tx<=1'b1;
								send_state<=3'd2;
								send_time<=16'd1;
								encode<=ex_data[0];								//the first encode data
								ex_data[511:0]<={1'b0,ex_data[511:1]};
								if (ex_data[5:0]==6'b110011)
								begin
									send_pre16<=1'b1;
									send_pre5<=1'b1;
								end
								else
									send_pre5<=1'b0;								//enable the crc5 encoder

							end
						end
					3'd1:
						begin
							if (send_time<delimiter)
								tx<=1'b0;
							else if (send_time==delimiter)	    					//produce the Frame_Sync
								tx<=1'b1;
							else if (send_time==delimiter+Tari)
								tx<=1'b0;
							else if (send_time==delimiter+Tari+Tari)
								tx<=1'b1;
							else if (send_time==delimiter+Tari+Tari+RTcal)
								tx<=1'b0;
							else if (send_time==delimiter+Tari+Tari+RTcal+Tari)
							begin
								tx<=1'b1;
								send_state<=3'd2;
								send_time<=16'd1;
								encode<=ex_data[0];
								ex_data[511:0]<={1'b0,ex_data[511:1]};
								if (ex_data[5:0]==6'b110011)
								begin
									send_pre16<=1'b1;
									send_pre5<=1'b1;
								end
								else if (ex_data[1:0]==2'b00 || ex_data[1:0]==2'b10 || ex_data[3:0]==4'b1001 || ex_data[7:0]==8'b0000_0011)
									send_pre16<=1'b1;		   					//if the command is QueryRep,ACK,QueryAdjust and NAK, don't need crc code
								else
									send_pre16<=1'b0;							//else enable the crc16 encoder
							end
						end
					3'd2:
						begin
							if (send_time==Tari)
								begin
									if (encode==1'b1)
									begin
										send_state<=3'd3;
										send_time<=16'b1;
										tx<=1'b1;
									end
									else if (encode==1'b0)
									begin
										send_state<=3'd5;
										send_time<=16'b1;
										tx<=1'b0;
									end
								end
						end
					3'd3:
						begin
							if (send_time==Tari)
							begin
								tx<=1'b1;
								send_state<=3'd4;
								send_time<=16'd1;
							end
						end
					3'd4:
						begin
							if (send_time==Tari)
							begin
								tx<=1'b0;
								send_state<=3'd5;
								send_time<=16'd1;
							end
						end
					3'd5:
						begin
							if (send_time==Tari)
							begin
								if (sending_cnt+1>=data_cnt)
								begin
									if (crc_flag==1'b0)	  						//has sent all data
									begin
										send_time<=16'd1;
										send_state<=3'd2;
										tx<=1'b1;
										if (send_pre5==1'b0)	  				//send crc5
										begin
											ex_data[0]<=s5_crc[3];
											ex_data[1]<=s5_crc[2];
											ex_data[2]<=s5_crc[1];
											ex_data[3]<=s5_crc[0];
				//							ex_data[4]<=s5_crc[0];
											encode<=s5_crc[4];
											sending_cnt<=16'd0;
											data_cnt<=16'd5;
											send_pre5<=1'b1;
											crc_flag<=1'b1;					//show next time should send crc
										end
										if (send_pre16==1'b0)				//send crc16
										begin
											ex_data[0]<=s16_crc[14];
											ex_data[1]<=s16_crc[13];
											ex_data[2]<=s16_crc[12];
											ex_data[3]<=s16_crc[11];
											ex_data[4]<=s16_crc[10];
											ex_data[5]<=s16_crc[9];
											ex_data[6]<=s16_crc[8];
											ex_data[7]<=s16_crc[7];
											ex_data[8]<=s16_crc[6];
											ex_data[9]<=s16_crc[5];
											ex_data[10]<=s16_crc[4];
											ex_data[11]<=s16_crc[3];
											ex_data[12]<=s16_crc[2];
											ex_data[13]<=s16_crc[1];
											ex_data[14]<=s16_crc[0];
									//		ex_data[15]<=s16_crc[0];
											encode<=s16_crc[15];
											sending_cnt<=16'd0;
											data_cnt<=16'd16;
											send_pre16<=1'b1;
											crc_flag<=1'b1;					//show next time should send crc
										end
										if (send_pre5==1'b1 && send_pre16==1'b1)
										begin								//don't need to send
											state<=SEND_FINISHED;
											crc_flag<=1'b0;
											send_total<=1'b0;
//											crc_err<=1'b0;
											pre_state<=5'b0;
											data_cnt<=16'b0;
											receive_pre16<=1'b1;
											tx<=1'b1;
//											t_clk<=1'b0;
											sending_cnt<=16'b0;
											send_clk<=8'b0;
										end
									end
									else if (crc_flag==1'b1)	 					//has sent all data and crc
									begin
										state<=SEND_FINISHED;
										//
//										ask<=1'b1;
										//
										crc_flag<=1'b0;
										send_total<=1'b0;
										sending_cnt<=16'b0;
										tx<=1'b1;
//										crc_err<=1'b0;
										pre_state<=5'b0;
										data_cnt<=16'b0;
										receive_pre16<=1'b1;
										tx<=1'b1;
//										t_clk<=1'b0;
										send_clk<=8'b0;
									end
								end
								else
								begin
									tx<=1'b1;
									send_state<=3'd2;
									send_time<=16'd1;
									sending_cnt<=sending_cnt+16'b1;
									encode<=ex_data[0];
									ex_data[511:0]<={1'b0,ex_data[511:1]};
								end
							end
						end
					default:
						state<=INVALID;
					endcase
				end
			end
		SEND_FINISHED:
			state<=WAITING;
		default:
			state<=WAITING;
		endcase
	end
end
endmodule


module crc_5(pre,clk,c,data);
input pre,clk,data;
output [4:0] c;

wire d0,d3;

FDSET 	F0 (pre,clk,   d0, c[0]);
FDRST 	F1 (pre,clk, c[0], c[1]);
FDRST 	F2 (pre,clk, c[1], c[2]);
FDSET 	F3 (pre,clk,   d3, c[3]);
FDRST 	F4 (pre,clk, c[3], c[4]);

xor	X1(d0 ,c[4],data);
xor	X2(d3 ,c[2],d0);

endmodule

module crc_16(pre,clk,c,data);
input pre,clk,data;
output [15:0] c;

wire d0,d5,d12;
wire[15:0] c;

FDSET 	F0 (pre,clk,   d0, c[0]);
FDSET 	F1 (pre,clk, c[0], c[1]);
FDSET 	F2 (pre,clk, c[1], c[2]);
FDSET 	F3 (pre,clk, c[2], c[3]);
FDSET 	F4 (pre,clk, c[3], c[4]);
FDSET 	F5 (pre,clk,   d5, c[5]);
FDSET 	F6 (pre,clk, c[5], c[6]);
FDSET 	F7 (pre,clk, c[6], c[7]);
FDSET 	F8 (pre,clk, c[7], c[8]);
FDSET 	F9 (pre,clk, c[8], c[9]);
FDSET 	F10(pre,clk, c[9],c[10]);
FDSET 	F11(pre,clk,c[10],c[11]);
FDSET 	F12(pre,clk,  d12,c[12]);
FDSET 	F13(pre,clk,c[12],c[13]);
FDSET 	F14(pre,clk,c[13],c[14]);
FDSET 	F15(pre,clk,c[14],c[15]);

xor	X1(d0 ,c[15],data);
xor	X2(d5 , c[4],d0);
xor	X3(d12,c[11],d0);

endmodule

module FDSET(S,C,DI,DO);
input S,C,DI;
output DO;
reg DO;

always @(posedge C or posedge S)
begin
	if (S)
		DO <= 1'b1;
	else
		DO <= DI;
end
endmodule

module FDRST(R,C,DI,DO);
input R,C,DI;
output DO;
reg DO;

always @(posedge C or posedge R)
begin
	if (R)
		DO <= 1'b0;
	else
		DO <= DI;
end

endmodule