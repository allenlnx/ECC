/////////////////////////////////////////////////////////////////////////////////////
//FILE:         control.v
//TITLE:        the module which is for the test of tag
//AUTHOR:       chlhuang
//DATA:         Nov.24,2004
//COPYRIGHT:    Fudan Auto-ID Lab
//DESCRIPTION:  The file used for simulation,NOT for synthesis
//REVISION:     Modified by lhzhu to be RTL:
//				input clk freq: 6.4mhz
/////////////////////////////////////////////////////////////////////////////////////
`timescale 1ns/100ps

`include "./a.v"

//----------------------
// Tari = 25us  (for 6.4m clk)
//----------------------
//`define tari_par 160
// `define rtcal_par 480
// `define trcal_par 1440  
// `define t1_min 1700
// `define t1_max 1900
// `define delimiter 80

module r_control(pssp_reset,testcase,reset,response_eof,challenge_eof,mod, db_in,db_out,clk,ack,POR,Tag_data,Tag_finish,Tag_data_number);
input[1:0] testcase;
input   clk,reset;
input  response_eof ;
input  challenge_eof ;
input  mod ;
input   [7:0]   db_in;
input 	[32:0] Tag_data;
input 	Tag_finish;
input 	[15:0] Tag_data_number;

output  ack;
output  [7:0]   db_out;
output POR ;
output pssp_reset ;
reg     [7:0]   db_out;
reg     ack;

parameter Period        = 156.25 ;
parameter Rn_r  = 64'hfedcba9876543210 ;
//parameter KEY_A51 = 64'h34b2f441a1fb83ce ;    //key for stream cipher
//parameter FN  = 22'h0645a1 ;
parameter KEY_A51 = 64'hffff_ffff_ffff_ffff ;   //key for stream cipher
parameter FN    = 22'h3f_ffff ;

parameter Key_en=128'h2b7e151628aed2a6abf7158809cf4f3c;              //key for AES;
parameter Key_de=128'hd014f9a8c9ee2589e13f0cc8b6630ca6;              //key for decry
parameter Ns	=64'h 313198a2e0370734;        
parameter Key_c=128'h00112233445566778899aabbccddeeff;         //for update key
parameter PID_c=128'h00112233445566778899aabbccddeeff;         //for update pid

parameter DELTA=32'h9e3779b9;
parameter DELTA1=32'b0;
parameter CRC_16=16'h0;
parameter PC=16'b0011000000000000;          //EPC is 16 bit
parameter EPC=16'h0;
parameter EPC1=16'h0;
parameter EPC2=16'h1111;
parameter EPC3=16'h2222;
parameter EPC4=16'h3333;
parameter EPC5=16'h4444;
parameter EPC6=16'h5555;
parameter ERROR_CODE=16'h0f0f ;

parameter AD_CRC_16=8'b0000_0000;       //EPC bank;     
parameter AD_PC    =8'b0000_0001;
parameter AD_EPC   =8'b0000_0010;
parameter AD_DATA  =8'b0000_1001;       //  reserved bank,the first word after K3 
parameter AD_k_0   =10'b00_0001_0000;
parameter AD_user_data  =10'b11_0001_0000;   //user bank,the second word;  
parameter user_data=16'h1234;
parameter AD_MASK  =10'b11_0000_0000;
parameter MASK     =8'b0;
parameter AD_TMO   =10'b00_0000_0000;
parameter TMO      =16'b0;

parameter     	Target_par  =3'b001  ;
parameter       action_par  =3'b101  ;
parameter       membank_par =2'b01   ;
parameter       pointer_par =8'h01   ;
parameter       Length_par  =8'h08   ;
parameter       Mask_par    =8'h97	 ;
parameter		session_par =2'b00	 ;
parameter		session2_par=2'b00	 ;
parameter		Sel_par		=2'b00	 ;
parameter		target_par	=1'b0	 ;	
parameter		q_par		=4'b0000 ;
parameter		m_par		=2'b00	 ;
parameter		trext_par   =1'b0;
parameter		dr_par   =1'b0	;

// ADDED BY LHZHU :state
parameter WAIT			=5'b00000	;
parameter POWEROFFTAG	=5'b00001	;
parameter ISSUE_QUERY	=5'b00011	;	
parameter ISSUE_ACK		=5'b00010	;
parameter ISSUE_REQRN	=5'b00110	;
parameter ISSUE_CRYPTO_AUTHEN_1	= 5'b00111 ;
parameter ISSUE_CRYPTO_AUTHEN_2	= 5'b01111 ;
parameter ISSUE_CRYPTO_AUTHEN_3	= 5'b01110 ;
parameter FINISH		= 5'b11110 ;

// ADDED BY LHZHU :op
parameter COMMU_OUT		=3'b000	;
parameter JUDGE_T1		=3'b001	;
parameter WAIT_T2		=3'b011 ;
parameter COMMU_IN		=3'b010	;	
parameter WAIT_OP		=3'b110 ;

// ADDED BY LHZHU :send command time ;
parameter SEND_QUERY		= `SEND_QUERY	;
//parameter SEND_ACK			= 16'd2212	;
//parameter SEND_REQRN		= 16'd5944 	;
//parameter SEND_CRY_1		= 16'd9200	;	
//parameter SEND_CRY_2		= 16'd18800 ;
//parameter SEND_OVER			= 16'd27000 ;

reg [15:0]      handle;
reg             POR ;
/*
reg			target;
reg[1:0]		session;
reg[1:0]		Sel;
reg[1:0]		m;
reg[3:0]		q;
reg			trext;
reg			dr;*/
		
////////////////////////////////////////////////
// ------------added by lhzhu: for state transition --------------//
////////////////////////////////////////////////

reg [4:0] 		state;
reg [4:0] 		nextstate;
reg [2:0]		op;
reg [2:0]		next_op;
reg [512:0]		data_out;
reg [7:0]		num_out_byte;
reg [15:0]		num_out ;
reg [7:0]		clk_count;
reg [7:0]		ack_count;
reg [15:0] 		counter_T1; 
//reg [63:0] 		response_cn ;
reg 			judge_T1_complete;
reg [15:0] 		counter_T2; 
reg 			judge_T2_complete;
reg [2:0]		COMMU_OUT_STEP;
reg				T1_violate;
reg				handle_done;
reg [15:0]		counter_nus; //counter for us
reg [4:0]		counter_1us; //counter for 1us
////////////////////////////////////////////////
// Commu_in over indicator
////////////////////////////////////////////////

////////////////////////////////////////////////
// Time indicator
////////////////////////////////////////////////
always@ (posedge clk or negedge reset)
begin
	if(!reset)
		begin
		counter_1us <= 'd0 ;
		counter_nus <= 'd0 ;
		end
	else if (counter_1us == 'd6)
		begin
		counter_1us <= 'd1;	
		counter_nus <= counter_nus + 16'd1;
		end
	else
	  begin
		counter_1us <= counter_1us + 1'b1;
		counter_nus <= counter_nus;
		end
end

////////////////////////////////////////////////
// ------------added by lhzhu: for pssp reset --------------//
////////////////////////////////////////////////
wire pssp_reset;
assign  pssp_reset = !(state !=nextstate);

////////////////////////////////////////////////
// Main 
////////////////////////////////////////////////

always@ (posedge clk or negedge reset)
begin
	if(!reset)
	  begin
		state <= POWEROFFTAG ;
		op	  <= COMMU_OUT ;
		end
	else 
	  begin
		state <= nextstate;
		op	  <= next_op ;
		end
end


//------------ state transition	------------
always@ (*)
	begin
	nextstate <= state;
	if(!reset)
	nextstate <= POWEROFFTAG;
	else if(T1_violate)
	nextstate <= POWEROFFTAG;
	else case(state)
	POWEROFFTAG:nextstate <= WAIT;	
	WAIT:		if (counter_nus ==SEND_QUERY ) nextstate <= ISSUE_QUERY;
	ISSUE_QUERY:begin
				if( (handle_done==1'b1) && (op==COMMU_IN))
				nextstate <= ISSUE_ACK ;
				else
				nextstate <= ISSUE_QUERY;
				end
	ISSUE_ACK:	begin
//				if( counter_nus ==SEND_REQRN)
				if( Tag_finish && (op==COMMU_IN))
				nextstate <= ISSUE_REQRN ;
				else
				nextstate <= ISSUE_ACK;
				end	
	ISSUE_REQRN:begin
//				if( counter_nus ==SEND_CRY_1 )
				if( (handle_done==1'b1) && (op==COMMU_IN))
				nextstate <= ISSUE_CRYPTO_AUTHEN_1 ;
				else
				nextstate <= ISSUE_REQRN;
				end	
	ISSUE_CRYPTO_AUTHEN_1:	begin
//				if( counter_nus ==SEND_CRY_2 )
				if( Tag_finish && (op==COMMU_IN))
				nextstate <= ISSUE_CRYPTO_AUTHEN_2 ;
				else
				nextstate <= ISSUE_CRYPTO_AUTHEN_1;
				end 
	ISSUE_CRYPTO_AUTHEN_2:	 begin
//				if( counter_nus ==SEND_OVER )
				if( Tag_finish && (op==COMMU_IN))
				nextstate <= ISSUE_CRYPTO_AUTHEN_3 ;
				else
				nextstate <= ISSUE_CRYPTO_AUTHEN_2;
				end 
	ISSUE_CRYPTO_AUTHEN_3:	 begin
//				if( counter_nus ==SEND_OVER )
				if( Tag_finish && (op==COMMU_IN))
				nextstate <= FINISH ;
				else
				nextstate <= ISSUE_CRYPTO_AUTHEN_3;
				end 
	FINISH:		nextstate <= FINISH;
	default:	nextstate <= POWEROFFTAG	 ;
	endcase
	end
	
always@ (*)	
	begin
	next_op <= op;
	if(!reset)
	next_op <= COMMU_OUT;
	else if(T1_violate)
	next_op <= COMMU_OUT;
	else case(op)
	COMMU_OUT:	if(challenge_eof)
//				begin
//					if((state == ISSUE_QUERY)||(state == ISSUE_REQRN))
					next_op <= JUDGE_T1;
//					else 
//					next_op <= op;
//				end
//				else next_op <= op;
	JUDGE_T1:	if(judge_T1_complete)  
				next_op <= WAIT_T2;
				else next_op<=op;
	WAIT_T2:	if(judge_T2_complete)
				next_op <= COMMU_IN;
				else next_op <= op;
	COMMU_IN:	if(state!=nextstate)
				next_op <= COMMU_OUT;
				else next_op <= op;
	default:	next_op <= COMMU_OUT;
	endcase
	end
	
 //------------ output content definition ------------

always@ (posedge clk or negedge reset)	
	if(!reset)
				begin
				data_out<='d0	;
				num_out <='d0 ;
				num_out_byte <= 'd0;	
				end
	else if(op == JUDGE_T1||op==WAIT_T2)
				begin
				data_out<='d0	;
				num_out <='d0 ;
				num_out_byte <= 'd0;	
				end
	else if((nextstate==ISSUE_QUERY)&&(state!=ISSUE_QUERY))
				begin
				data_out<={4'b1000,dr_par,m_par,trext_par,Sel_par,session_par,target_par,q_par,7'b0}	;
				num_out <=16'd17 ;
				num_out_byte <= 8'd3;
				end
	else if((nextstate==ISSUE_ACK)&&(state!=ISSUE_ACK))
				begin
				data_out<={2'b01,handle,6'b0}	;
				num_out <=16'd18 ;
				num_out_byte <= 8'd3;
				end	
	else if((nextstate==ISSUE_REQRN)&&(state!=ISSUE_REQRN))
	      begin
				data_out<={8'b1100_0001,handle}	;
				num_out <=16'd24 ;
				num_out_byte <= 8'd3;
				end	
	else if((nextstate==ISSUE_CRYPTO_AUTHEN_1)&&(state!=ISSUE_CRYPTO_AUTHEN_1))
				begin
				data_out<={8'b11011011,2'd0,8'd1,64'b0,32'h10000000,handle,6'b0}	;
				num_out <=16'd130 ;
				num_out_byte <= 8'd17;
				end 
	else if((nextstate==ISSUE_CRYPTO_AUTHEN_2)&&(state!=ISSUE_CRYPTO_AUTHEN_2))
				begin
				data_out<={8'b11011011,2'd1,8'd1,128'h2083ECB864C352D92ABA75FF4EF290F1,handle,6'b0}	;
				num_out <=16'd162 ;
				num_out_byte <= 8'd21;
				end 
	else if((nextstate==ISSUE_CRYPTO_AUTHEN_3)&&(state!=ISSUE_CRYPTO_AUTHEN_3))
				begin
				data_out<={8'b11011011,2'd2,8'd1,128'hD4CCBED38DF03F156B7A8A31966D9C0F,128'h316EB30764EEA8C50AAFACAF63D82EA8,handle,6'b0}	;
				num_out <=16'd290 ;
				num_out_byte <= 8'd37;
				end 
				
	else if((op == COMMU_OUT) && (clk_count==8'd10) && (num_out_byte>1'b0)) //for output the initial 8'b0
				case (COMMU_OUT_STEP)
				3'd0: data_out<=data_out;
				3'd1: data_out<={data_out[503:0],8'h00}; //preshift for the next 'd2 state
				3'd2: begin 
					 data_out<={8'h00, data_out[511:8]}	;
					 num_out_byte <= num_out_byte -1'b1	;			
					 end
				default :
					begin
					data_out<=data_out	;
					num_out <=num_out ;
					num_out_byte <= num_out_byte;	
					end
				endcase
  else begin
			data_out<=data_out	;
			num_out <=num_out ;
			num_out_byte <= num_out_byte;		
		end
		
// --------------- logic for POWEROFFTAG state ---------------
always@ (posedge clk or negedge reset)
begin
	if(!reset)
		POR <= 1'b0;
	else if(state == POWEROFFTAG)
		POR <= 1'b0;
	else 
		POR <= 1'b1;
end		


// --------------- logic of db_out for op=COMMU_OUT ---------------		
always@ (posedge clk or negedge reset)
	begin
	if(!reset)
		begin
			COMMU_OUT_STEP <=3'd0;
			db_out <= 8'b0;
		end
	else if(op!=next_op)
		begin
			COMMU_OUT_STEP <=3'd0;
			db_out <= 8'b0;
		end
	else if(op==COMMU_OUT && (state !=WAIT && state !=POWEROFFTAG && state!=FINISH))
		if(clk_count==8'd5)
			begin
				case(COMMU_OUT_STEP)
				3'd0: 
					begin
						COMMU_OUT_STEP<=3'd1;
						db_out<= num_out[15:8];
					end
				3'd1: 
					begin
						COMMU_OUT_STEP<=3'd2;
						db_out<= num_out[7:0];
					end
				3'd2:
					db_out<={data_out[0], data_out[1], data_out[2], data_out[3], data_out[4], data_out[5], data_out[6], data_out[7] };
				default:	
						begin
							COMMU_OUT_STEP <=COMMU_OUT_STEP;
							db_out <= db_out;
						end
				endcase
			end
		else			begin
							COMMU_OUT_STEP <=COMMU_OUT_STEP;
							db_out <= db_out;
						end
		else
		begin
						COMMU_OUT_STEP <=COMMU_OUT_STEP;
						db_out <= db_out;
		end
	end
// --------------- logic of clk counter  ---------------		
always@ (posedge clk or negedge reset)
		if(!reset)
			clk_count <= 8'b0;
		else if(state!=nextstate)
			clk_count <= 8'b0;
		else if(op==COMMU_OUT)
				if(clk_count == 8'b00001010)
				clk_count <= 8'd1;
				else
				clk_count <= (clk_count+8'd1);
		else clk_count<=clk_count;

// ---------------  logic for op=JUDGE_T1 ---------------	
always@ (posedge clk or negedge reset )
	begin
		if(!reset)
			begin
				T1_violate <= 1'b0;
				counter_T1 <= 16'd0;
				judge_T1_complete 	  <= 1'b0;
//				response_cn <=8'b0;
			end
		else if((op!=next_op) || (state!=nextstate))
			begin
				T1_violate <= 1'b0;
				counter_T1 <= 16'd0;
				judge_T1_complete 	  <= 1'b0;
//				response_cn <=8'b0;
			end
		else if(state == WAIT)
				counter_T1 <= counter_T1 +1'b1;
		else if(op == JUDGE_T1)
				if(judge_T1_complete == 1'b0)
					begin
						counter_T1 <= counter_T1 + 1'b1 ;
						if (mod==1'b1 && counter_T1<`t1_min)
							begin 
								T1_violate <= 1'b1;
							end
						else if ((mod==1'b1 && counter_T1>=`t1_min && counter_T1<=`t1_max))
							begin
								judge_T1_complete <= 1'b1 ;
							end
						else if ( counter_T1>`t1_max && (q_par==0))
							begin
								T1_violate <= 1'b1;
							end
						else if (counter_T1>`t1_max)	//Q value for anti collision
							begin
								judge_T1_complete <= 1'b1 ;
							end
						else 
							begin
								T1_violate <= T1_violate;
								judge_T1_complete 	  <= judge_T1_complete;
//								response_cn <= response_cn;
							end
					end
		else				begin
								T1_violate <= T1_violate;
								counter_T1 <= counter_T1;
								judge_T1_complete 	  <= judge_T1_complete;
	//							response_cn <= response_cn;
							end
		end
	
// --------------- logic for op=WAIT_T2 ---------------		
always@ (posedge clk or negedge reset )
	if(!reset)
		begin
		counter_T2 <= 16'b0 ;
		judge_T2_complete <= 1'b0 ;
		end
	else if (state!=nextstate)
		begin
		counter_T2 <= 16'b0 ;
		judge_T2_complete <= 1'b0 ;
		end
	else if (op!=next_op)
		begin
		counter_T2 <= `t1_max- counter_T1;
		judge_T2_complete <= 1'b0;
		end
	else if (op==WAIT_T2 && counter_T2 <`t1_max)
		begin
		counter_T2 <= counter_T2 + 1'b1 ;
		judge_T2_complete <= 1'b0;
		end
	else if (op==WAIT_T2 && counter_T2 ==`t1_max)
		begin
		judge_T2_complete <= 1'b1;
		counter_T2 <= 16'd0;
		end
	else 
		begin
			counter_T2 <=counter_T2;
			judge_T2_complete <= judge_T2_complete;
		end
	
reg[1:0] ack_stop; // to fix the ack pulse;
// --------------- logic for ack pin (for both commu_in and commu_out)---------------		
always@ (posedge clk or negedge reset )
	begin
		if(!reset)
			begin
			ack <= 1'b0;
			ack_stop <= 2'b0;
			end
		else if(state!=nextstate || op!=next_op)
			begin
			ack <= 1'b0; 	
			ack_stop <= 2'b0;
			end			
		else if(ack_stop!=2'd2)
				if((clk_count==8'd10) || (clk_count == 8'd5))
					if((state !=WAIT) && (state !=POWEROFFTAG) && op ==COMMU_OUT)	
							begin
								ack <=!ack;
								ack_stop<=ack_stop + (num_out_byte==8'd0);
							end
					else;
				else;
		else;
	end


// --------------- logic for handle ---------------		
always@ (posedge clk or negedge reset )
	begin
		if(!reset)
			begin
			handle <=16'd0;
			handle_done <= 1'b0;
			end
		else if (op != next_op)
			handle_done <= 1'b0;
		else if( (state == ISSUE_QUERY) && (Tag_finish))
			begin
				if(Tag_data_number == 'd17)
					begin
			/*			handle <= {  Tag_data[1],Tag_data[2],Tag_data[3],
									Tag_data[4],Tag_data[5],Tag_data[6],Tag_data[7],
									Tag_data[8],Tag_data[9],Tag_data[10],Tag_data[11],
									Tag_data[12],Tag_data[13],Tag_data[14],Tag_data[15],Tag_data[16]							
									};*/
						handle <= Tag_data[16:1];
						handle_done <= 1'b1;
					end
				else if(Tag_data_number =='d16)
					begin
			/*			handle <= {  Tag_data[0],Tag_data[1],Tag_data[2],Tag_data[3],
									Tag_data[4],Tag_data[5],Tag_data[6],Tag_data[7],
									Tag_data[8],Tag_data[9],Tag_data[10],Tag_data[11],
									Tag_data[12],Tag_data[13],Tag_data[14],Tag_data[15]};*/
						handle <=  Tag_data[15:0];
						handle_done <= 1'b1;
					end
				end
			else if( ( state == ISSUE_REQRN) && (Tag_finish))
				begin
					if(Tag_data_number == 'd33)
						begin
				/*			handle <= {  Tag_data[1],Tag_data[2],Tag_data[3],
										Tag_data[4],Tag_data[5],Tag_data[6],Tag_data[7],
										Tag_data[8],Tag_data[9],Tag_data[10],Tag_data[11],
										Tag_data[12],Tag_data[13],Tag_data[14],Tag_data[15],Tag_data[16]							
										};*/
							handle <= Tag_data[32:17];
							handle_done <= 1'b1;
						end
					else if(Tag_data_number =='d32)
						begin
				/*			handle <= {  Tag_data[0],Tag_data[1],Tag_data[2],Tag_data[3],
										Tag_data[4],Tag_data[5],Tag_data[6],Tag_data[7],
										Tag_data[8],Tag_data[9],Tag_data[10],Tag_data[11],
										Tag_data[12],Tag_data[13],Tag_data[14],Tag_data[15]};*/
							handle <=  Tag_data[31:16];
							handle_done <= 1'b1;
						end
				end
		else begin
			handle <=handle;
			handle_done <= handle_done;
			end
	end
	
	// --------------- logic for ack_count ( for commu_out )---------------	
always@ (posedge clk or negedge reset )
		if(!reset)
			ack_count <=8'd0;
		else if( op != next_op )
			ack_count <=8'd0;
		else if(((clk_count == 8'd5)||(clk_count == 8'd10))&&((op == COMMU_OUT)||(op == COMMU_IN)))
			ack_count <= (ack_count + 8'd1);
		else ack_count <= ack_count;

	
	endmodule