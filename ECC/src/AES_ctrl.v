 /*************************************************
this module is to control the AES_core
module name :AES_ctrl
copy right : xshen ,ASIC,Fudan university,
date : 2010-11-20
***************************************************/

`include "./parameters.v"
`timescale 1ns/100ps

module AES_ctrl(
	TEST	,
	clk		,
	rst_n	,
	i_time_up ,
	i_key_shift_cu	,
	i_data_dec	,
	i_data_rom_16bits	,
	i_random_rng	,
	i_done_AES	,
	i_result_AES	,
	//-------------added by lhzhu--------------//
	i_done_key	,
	i_Crypto_Authenticate_step_cu	,
	i_Crypto_Authenticate_ok_dec	,
	i_Crypto_Authenticate_shift_dec	,
	//------------------------------------//
	o_load_key	,
	o_load_state ,
	o_start_AES	,
	o_key		,
	o_state		,
	o_en_AES		,
	o_equal_correct	,
	o_equal_wrong 	,
	o_decry		,
	o_PID_N_ctrl
			);

input			TEST		;
input			clk		;
input			rst_n		;
input    		i_time_up ;
input			i_key_shift_cu	;
input			i_data_dec	;

input	[15:0]		i_data_rom_16bits	;
input	[15:0]		i_random_rng	;
input			i_done_AES	;
input	[127:0]		i_result_AES	;

output			o_load_key	;
output      o_load_state;
output			o_start_AES	;
output	[127:0]		o_key		;
output	[127:0]		o_state		;
output			o_en_AES		;
output			o_equal_correct	;
output	[63:0]	o_PID_N_ctrl;

reg			o_equal_correct	;
output			o_equal_wrong	;
reg			o_equal_wrong	;
output		o_decry		;
reg			o_decry		;
reg 	[31:0] Nt_reg ;
reg		[31:0] OPR;
reg		[63:0] RID;
reg		[127:0]	o_state;
reg		[63:0]	o_PID_N_ctrl;
//-----------added by lhzhu --------------//

input			i_done_key	;
wire			i_done_key	;
input[1:0]		i_Crypto_Authenticate_step_cu	;
wire[1:0]		i_Crypto_Authenticate_step_cu	;
input			i_Crypto_Authenticate_shift_dec	;
wire			i_Crypto_Authenticate_shift_dec ;
input			i_Crypto_Authenticate_ok_dec	;
wire			i_Crypto_Authenticate_ok_dec ;
reg		[31:0]  Ns_reg ;
reg		[1:0]	Decrypt_round;
//-----------added by lhzhu --------------//

reg	[3:0]	 state_AES, state_next	;
  parameter Idle=4'd0;
  parameter Read_key_De=4'd1;  
  parameter Read_authen=4'd2;
  parameter Load_key=4'd3;
  parameter Load_state=4'd4;
  parameter Start_en=4'd5;
  parameter Read_key_En=4'd6; 
  parameter Comparison=4'd7;
  parameter Authen_success=4'd8;
  parameter Computing = 4'd9;
	
  reg [7:0] cnt;
  reg [127:0] data_AES_1;
  reg [127:0] data_AES_2;
  reg [127:0] key_reg;


  always @(posedge clk or negedge rst_n)
   if (!rst_n) state_AES<=Idle;
   else  if(i_time_up) state_AES<=Idle;
     else state_AES<=state_next;
        
  always @ (*)
   	begin
   	  state_next = state_AES;
   case (state_AES)
	Idle:		if(i_Crypto_Authenticate_shift_dec)
					state_next=Read_authen ;
				else state_next=state_AES;
	Read_authen: if( i_Crypto_Authenticate_ok_dec && i_Crypto_Authenticate_step_cu!=2'd0) 
					state_next=Read_key_De;//读authenticate 指令中的内容数据完毕
				else if( i_Crypto_Authenticate_ok_dec && i_Crypto_Authenticate_step_cu==2'd0)
					state_next = Authen_success;
                else state_next=state_AES;               
    Read_key_De: if(i_done_key) 
					state_next=Load_key; //读key
              else state_next=state_AES;       
    Read_key_En: if(i_done_key) 
					state_next=Load_key; //读key
              else state_next=state_AES;    	
    Load_key:   state_next=Load_state; 
    Load_state: state_next=Start_en;   
    Start_en: 	state_next=Computing;
	Computing: if(!o_decry && i_done_AES) state_next = Authen_success; 
			       else if (o_decry && i_done_AES) state_next = Comparison;
	Comparison: if(o_decry) state_next=Read_key_En;     
                else if(!o_decry) state_next=Authen_success;
				else state_next = state_next;
    Authen_success: state_next=Idle;
    default: state_next=Idle;                        
   endcase
 end
   
 //--------key的传入---------//
 
  always @(posedge clk or negedge rst_n)
   if (!rst_n)
         key_reg<=128'b0;
   else if(i_key_shift_cu) 
         key_reg<={key_reg[111:0],i_data_rom_16bits};
   else  key_reg<=key_reg;
   
 //--------------------------//
 
 
 //-------NT的读入-------//
 always @(posedge clk or negedge rst_n)
   if (!rst_n)
    begin
     cnt<=8'b0;
     Nt_reg<=32'b0;
    end
   else if((state_AES==Read_authen) )      
        if(TEST)  Nt_reg<=`NT;
        else if (cnt < 2)
         begin
         Nt_reg <= {Nt_reg[15:0],i_random_rng} ;      // Nt from RNG
         cnt <= cnt + 1'b1;
         end
        else ;
 //--------------------------//
   
 always @(posedge clk or negedge rst_n)
   if (!rst_n)
     o_PID_N_ctrl<=`PID_N;
   else o_PID_N_ctrl <=o_PID_N_ctrl;
		
  //-------RID\OPR\明文的读入-------//  
  
  always @(posedge clk or negedge rst_n)
   if (!rst_n)      
	begin
	data_AES_1<=128'b0;
	data_AES_2<=128'b0;
	RID	<= 64'b0;
	OPR <= 32'b0;
   end
   else if(state_AES == Read_authen)
   case (i_Crypto_Authenticate_step_cu)
   2'd0:if (i_Crypto_Authenticate_shift_dec)
			{RID,OPR} <= {RID[62:0],OPR[31:0],i_data_dec} ;
   2'd1:if (i_Crypto_Authenticate_shift_dec)
			data_AES_1 <= {data_AES_1[126:0],i_data_dec} ;
   2'd2:if (i_Crypto_Authenticate_shift_dec)
			{data_AES_2,data_AES_1} <= {data_AES_2[126:0],data_AES_1,i_data_dec}  ; 
   default:;
   endcase    
	else;
    

   //--------------gating clock for AES
   assign o_en_AES = state_AES==Computing||o_load_key ||o_load_state ||o_start_AES;
   assign o_load_key = state_AES==Load_key;
   assign o_load_state = state_AES==Load_state;
   assign o_start_AES= state_AES==Start_en; 
   assign o_key= key_reg;    
      
   //o_state definition
   
   always@(posedge clk or negedge rst_n)
	if(!rst_n)
		o_state <=128'd0;
	else if(state_next == Load_state || state_AES == Load_state)
	case (i_Crypto_Authenticate_step_cu)
		2'd0:o_state <=128'd0;
		2'd1:if (o_decry)
					o_state <=	data_AES_1;
			else if	(!o_decry)
					o_state <=	{64'b0,Ns_reg,Nt_reg} ;
			else	o_state <=128'd0;
		2'd2:if (Decrypt_round =='d0 && o_decry)
				o_state <=	data_AES_2;
			else if (Decrypt_round =='d1 && o_decry)
				o_state <= 	data_AES_1;
			else if (!o_decry)
				o_state <=	`M;
   default:
			o_state <= 128'b0;
	endcase
	else 
			o_state <= 128'b0;
			
   //------verify the result-------//
  always @(posedge clk or negedge rst_n)
   if (!rst_n) begin
      o_equal_correct<=1'b0;
      o_equal_wrong<=1'b0;	
      end
   else case(i_Crypto_Authenticate_step_cu)
   2'd1: if(state_AES==Comparison)
				if (i_result_AES[127:96]==Nt_reg)
					begin
					o_equal_correct	<= 1'b1;
					o_equal_wrong	<= 1'b0;
					end
				else
					begin
					o_equal_correct	<= 1'b0;
					o_equal_wrong	<= 1'b1;
					end
   2'd2: ;
	default:	begin
					o_equal_correct<=1'b0;
					o_equal_wrong<=1'b0;
				end
	endcase
	
	//------------read Ns---------//    
		always @(posedge clk or negedge rst_n)
   if (!rst_n)
         Ns_reg <= 32'b0;
   else if(i_Crypto_Authenticate_step_cu == 2'd1 && i_done_AES && o_decry) 
         Ns_reg<=i_result_AES[95:64];
   else	 Ns_reg<=Ns_reg;
	  
	 //------------logic for o_decry---------//   
	  always @(posedge clk or negedge rst_n)
   if (!rst_n )
         o_decry <= 1'b1 ;
	else if (state_AES == Authen_success)
		o_decry <= 1'b1 ;
	else case  (i_Crypto_Authenticate_step_cu)
	2'd1:	if(state_next ==Read_key_En)
			o_decry <= 1'b0;
			else 
			o_decry <= o_decry;
	2'd2:	if(Decrypt_round == 'd1 && (state_next ==Comparison))
			o_decry <= 1'b0;
			else 
			o_decry <= o_decry;
	default:
			o_decry <= o_decry;
   endcase
   
    //------------logic for decrypt_round---------//   
	 always @(posedge clk or negedge rst_n)
   if (!rst_n )
         Decrypt_round <= 1'b0 ;
	else ;
  endmodule
