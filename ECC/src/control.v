/*************************************************
this module is the control unit of the baseband 
module name : control
auther: xshen & xgchang
date : 2010-11-20
modified: 2010-12-25
***************************************************/
`timescale 1ns/100ps
module control (
	clk		,
	rst_n	,
	SET ,
	i_force_Crypto	,
	i_tpri_dem	,
	i_newcmd_dem	,
	i_valid_dem   ,
	i_data_dem  ,
	i_t1_dem		,
	i_t1_start_dem	,
	i_Query_dec	,
	i_QueryAdjust_dec	,
	i_QueryRep_dec	,
	i_ACK_dec	,
	i_ReqRN_dec	,
	i_Read_dec	,
	i_Write_dec	,
	i_TestWrite_dec	,
	i_TestRead_dec	,
	i_inventory_dec	,
	i_Lock_dec	,
	i_Select_dec	,
	i_Access_dec	,
	i_cmdok_dec	,
	i_handle_dec	,
	i_m_dec		,
	i_ebv_flag_dec	,
	i_addr_shift_dec	,
	i_data_shift_dec	,
	i_wcnt_shift_dec	,
	i_data_dec	,
	i_Lock_payload_dec	,
	i_target_dec	,
	i_session_dec	,
	i_session_done	,
	i_session2_dec	,
	i_sel_dec	,
	i_length_shift_dec	,
	i_mask_shift_dec	,
	i_targetaction_shift_dec	,
	i_access_shift_dec	,
	i_data_rom_16bits	,
	i_done_rom	,
	//-----added by lhzhu----- //
	i_fifo_full_rom	,
	i_shiftaddr_ocu	,
	TEST,
	i_decry_ctrl,
	//-----added by lhzhu----- //
	i_reload_ocu  ,
	i_crcen_ocu  ,
	i_data_ocu  ,
	i_done_ocu	,
	i_back_rom_ocu	,
	i_random_rng	,
	i_slotz_rng	,
	i_en_AES  ,
	//-----added by lhzhu----- //
	i_equal_correct	,
	i_equal_wrong	,
	i_Crypto_Authenticate_dec  ,
	i_Crypto_En_dec  ,
	i_Crypto_Comm_dec   ,
	i_Crypto_Authenticate_step_dec   ,
	i_Crypto_En_shift_dec	,
	i_CSI_dec		,
	//-----added by lhzhu----- //
	o_addr_rom		,
	o_rd_rom		,
	o_wr_rom		,
//	o_data_rom	,
	o_wordcnt_rom	,
	o_handle_cu		,
	o_random_cu		,
	o_decSlot_cu	,
	o_newSlot_cu	,
	o_clear_cu	,
	o_key_shift_cu	,
	o_payload_valid_cu ,
	o_seed_in_rng	,
	o_datarate_ocu	,
	o_en2blf_mod	,
	o_reload_crc ,
	o_valid_crc ,
	o_data_in_crc ,
	o_time_up   ,
	//---------added by lhzhu----- //
//	o_Authenticate_flag_cu	, //mark if tag has been authenticated
	o_Crypto_Authenticate_step_cu , //mark the current authenticate step
	o_done_key	,
	//---------------------------- //
	o_clk_rom 	 ,
	o_clk_dem  ,
	o_clk_aes  ,
	o_clk_act  ,
	o_clk_mod  ,
	o_clk_ocu  ,
	o_clk_crc  ,
	o_clk_rng	
			);
	
input			clk		;
input			rst_n		;
input     SET ;			//set=1 代表有时间限制
input			i_Query_dec	;
input			i_QueryAdjust_dec	;
input			i_QueryRep_dec	;
input			i_ACK_dec	;
input			i_ReqRN_dec	;
input			i_Read_dec	;
input			i_TestWrite_dec;
input			i_Write_dec	;
input			i_TestRead_dec	;
input			i_inventory_dec	;
input			i_Lock_dec	;
input			i_Select_dec	;
input			i_Access_dec	;
input			i_cmdok_dec	;
input	[15:0]		i_handle_dec	;
input	[1:0]		i_m_dec		;
input			i_addr_shift_dec	;
input			i_data_shift_dec	;
input			i_wcnt_shift_dec	;
input			i_ebv_flag_dec		;
input			i_data_dec	;
input			i_Lock_payload_dec	;
input			i_target_dec	;
input	[1:0]		i_session_dec	;  //什么含义？
input			i_session_done	;
input	[1:0]		i_session2_dec	;  //什么含义？
input	[1:0]		i_sel_dec	;
input	[5:0]		i_tpri_dem	;
input			i_newcmd_dem	;
input     i_valid_dem   ;
input   	i_data_dem  ;
input	[8:0]		i_t1_dem		;
input			i_t1_start_dem	;
input			i_length_shift_dec	;
input			i_mask_shift_dec	;
input			i_targetaction_shift_dec	;
input			i_access_shift_dec	;
input	[15:0]		i_data_rom_16bits	;
input			i_done_rom	;
input			i_fifo_full_rom	;
input     i_reload_ocu  ;
input    	i_crcen_ocu  ;
input   	i_data_ocu  ;
input			i_done_ocu	;
input			i_back_rom_ocu	;
input	[15:0]		i_random_rng	;
input			i_slotz_rng	;
input			i_force_Crypto	;
input     i_en_AES    ;
input			i_equal_correct	;
input			i_equal_wrong	;
input			i_shiftaddr_ocu	;
input			i_decry_ctrl;
output	[7:0]		o_wordcnt_rom	;
reg	[7:0]		o_wordcnt_rom	;
output	[6:0]		o_addr_rom		;
reg	[6:0]		o_addr_rom		;
output			o_rd_rom		;
reg			o_rd_rom		;
output			o_wr_rom		;
reg			o_wr_rom		;
//output	[15:0]		o_data_rom	;
//reg	[15:0]		o_data_rom	;
output	[15:0]		o_handle_cu		;
reg	[15:0]		o_handle_cu		;
output	[15:0]		o_random_cu		;
reg	[15:0]		o_random_cu		;
output			o_seed_in_rng	;
reg			o_seed_in_rng	;
output			o_decSlot_cu	;
reg			o_decSlot_cu	;
output			o_newSlot_cu	;
reg			o_newSlot_cu	;
output			o_clear_cu	;
reg			o_clear_cu	;
output			o_datarate_ocu	;
reg			o_datarate_ocu	;
output			o_key_shift_cu	;
reg			o_key_shift_cu	;
output			o_en2blf_mod	;
reg			o_en2blf_mod	;
output  o_payload_valid_cu;
output  o_reload_crc ;
reg     o_reload_crc ;
output	o_valid_crc ;
reg     o_valid_crc ;
output	o_data_in_crc ;
reg  o_data_in_crc ;
output o_time_up ;

output  o_clk_rom 	 ;
output	o_clk_dem  ;
output	o_clk_aes  ;
output	o_clk_act  ;
output	o_clk_mod  ;
output	o_clk_ocu  ;
output	o_clk_crc  ;
output	o_clk_rng	;

reg  o_clk_rom 	 ;
reg	o_clk_dem  ;
reg	o_clk_aes  ;
reg	o_clk_act  ;
reg	o_clk_mod  ;
reg	o_clk_ocu  ;
reg	o_clk_crc  ;
reg	o_clk_rng	;


parameter   Poweron=4'b0000;
parameter	Ready=4'b0001;
parameter   Arbitrate=4'b0010;
parameter   Reply=4'b0011;
parameter   Acknowledged=4'b0100;
parameter   Open=4'b0101;
parameter	Secure=4'b0110;
parameter   Crypto=4'b0111;

parameter 	
IDLE=5'd0,
waiting=5'd1,
readPC=5'd2,
readCRC=5'd3,
readMODE=5'd4,
readKEY_En=5'd5,
readKEY_De=5'd6,
//readID=5'd5,
readLock=5'd7,
readAccess=5'd8,
InitDone=5'd9, 
readrom=5'd10, 
writeRom=5'd11,
newSlot=5'd12, 
newQ=5'd13,
 checkSlot=5'd14,
 authen=5'd15, 
 newHandle=5'd16,
 newRN=5'd17, 
 waitT1=5'd18, 
 BackScatter=5'd19, 
 clearCmd=5'd20, 
 Lock=5'd21, 
 Compare=5'd22,
 UpdateID=5'd23,
 readCrypto_En_psw = 5'd24 ,
 readCryptoflag = 5'd25 ,
 calculate = 5'd26 ;
 
reg [3:0] 	state,next_ts	;
reg [4:0]	op,next_op	;
reg	[4:0]	pc		;
//reg	[2:0]	mode		;
wire		newstate	;
//wire 		mode_security	;
wire 		handle_valid	;
//---------amended-------//
reg 		read_valid	;
reg 		write_valid	;
//---------amended-------//
reg[16:0] timer;     //for time counter, 100ms limited
reg 		back_rom		;	
reg  	[5:0]	c_pri		;
reg  	[2:0]	c_m		;
reg 	[8:0]	counter		;
reg 		t1_start	;
reg	[19:0]	Lock_payload	;
reg	[9:0]	Lock_flag	;
//wire	[9:0]	Lock_flag_w	;
reg 	[4:0]	Inventoried_flag;
reg	[7:0]	mask_length	;
reg	[4:0]	mask_word_length;
reg	[255:0]	mask		;   //mask 用于 Inventory
reg	[255:0] mask_comparation;	 //mask_comparation 是什么？
reg 		Select_done	;
reg		Compare_done	;
reg		Select_match	;
reg	[3:0]	mask_length_adjust	;
reg 	[5:0]	targetaction	;
reg		adjust_flag	;
reg	[31:0]	access_psw	;
reg		access_flag	;
reg	[15:0]	access_par	;  //access_par
reg		access_delay	;
wire		access_posedge	;
wire		Query_match	;
wire		Query_ar_match	;
reg	[1:0]	pre_session	;
reg		new_session	;
reg		query_delay	;
reg		querya_delay	;
reg		queryr_delay	;
wire		query_posedge	;
wire		query_ar_posedge;	
reg		trans_flag	;
// those update in Poweron 
reg 		en_poweron	; //只要在poweron的状态下就有这个值为1
reg 		clk_poweron	;	

// ------------ added by lhzhu -------------- //
input		TEST	;
wire		TEST	;
input		i_Crypto_Authenticate_dec  ; 
input[1:0]		i_Crypto_Authenticate_step_dec	;

input		i_Crypto_En_dec  ;	
input		i_Crypto_En_shift_dec ;
input		i_Crypto_Comm_dec   ;
input		i_CSI_dec	;
wire [7:0]	i_CSI_dec	;
//output[1:0]		o_Authenticate_flag_cu ;
//reg	[1:0]		o_Authenticate_flag_cu ; 

reg [15:0]	Crypto_En_par ; 

reg			Crypto_flag ;			//read from ROM
reg [31:0]  Crypto_En_psw ;
reg			Crypto_En_step_cu ;
wire 		Crypto_Tag ;
output[1:0]		o_Crypto_Authenticate_step_cu ;
reg[1:0]			o_Crypto_Authenticate_step_cu ;

output		o_done_key	;
wire		o_done_key	;
reg			done_rom_d	;
wire		done_rom	;
wire		Init_cu		;

//------------------------------------------------------------------------------
// key part: state transition
//------------------------------------------------------------------------------
always	@ (posedge clk or negedge rst_n)
	if (~rst_n)
		begin 
		state 		<=	Poweron 	;
		op 			<=	IDLE 		;
		end 	
	else if(o_time_up)   // time up mode 无论在什么状态 一旦超时，状态转换到arbitrate
	  begin 
		state 		<=	Arbitrate 	;
		op 			<=	waiting 	;
		end
	else  begin 
		state 		<=	next_ts 	;
		op 			<=	next_op 	;
		end 
	
assign	newstate	=	{next_ts, next_op}!={state, op}	;

//---------added by lhzhu---------------//

always @ (*)// 对next_op进行操作，op=operate，大片组合逻辑
	begin
	next_ts 		=	state 		;
	next_op 		=	op 			;
	case (op )
	IDLE :	if(o_time_up) next_op = op ;
	        else	next_op =	readCryptoflag ;
	readCryptoflag:
		if (done_rom )	begin
			next_op =	readCrypto_En_psw ;
		end
		else 			next_op =	op 	;
	readCrypto_En_psw:
		if (done_rom ) next_op =	readCRC ;
		else			next_op = 	op;
	readCRC :
		if (done_rom )	next_op =	readPC 	;
		else 			next_op =	op 	;
	readPC :
		if (done_rom )	
					    next_op =	readLock ;
		else 			next_op =	op 	;
	readLock:
		if (done_rom && en_poweron) 		//只要在poweron的状态下就有这个值为1 //若在初始化状态，就进行readAccess
					next_op	=	readAccess	;
		else if(done_rom && i_Lock_dec) 	//收到LOCK 指令 ，动做就跳转到backscatter，以反馈信号
					next_op	=	BackScatter	;
		else if(done_rom)					//既非初始化亦非收到LOCK指令，两个都没有，就静止
					next_op	=	clearCmd	;//跳到Clearcmd也就是跳到了waiting，但是需要clearcmd状态完成一些工作。
		else			next_op	=	op		;
	readAccess:			 // access password
		if (done_rom && en_poweron)		//初始状态，跳转到InitDone状态
					next_op	=	InitDone	;
		else if(done_rom)
					next_op	=	clearCmd	;
		else			next_op	=	op		;
	InitDone :
		begin 
		next_op 	=	waiting 		;
		next_ts 	=	Ready 			;
		end
	
	waiting : //在waiting op下，接受所有的指令译码情况
	if (~i_cmdok_dec )//指令就绪cmd+ok_decode，若为0，始终无反应
		next_op 	=	op 			;	
	//.................................//
	else case (1'b1)
		i_Query_dec :
			if(Query_match)
				next_op		=	newSlot 	;
			else 
				next_op		=	op		;
		i_QueryRep_dec :
			if(Query_ar_match) //Query_ar_match含义为：Query和QueryRep/Adjust中的Session是符合的
			begin
			if (state ==Arbitrate )
				next_op 	=	newSlot 	;
			else if (state ==Reply )
				begin 
				next_ts 	=	Arbitrate 	;
				next_op 	=	clearCmd 	;
				end
			else
				begin 
				next_ts 	= 	Ready 		;
				next_op 	=	clearCmd 	;
				end
			end
		i_QueryAdjust_dec :
			if(Query_ar_match)
			begin
			if (state ==Arbitrate || state ==Reply )
				next_op 	=	newQ		;
			else 
				begin 
				next_ts 	= 	Ready 		;
				next_op 	=	clearCmd 	;
				end
			end
		i_ACK_dec :
				if (handle_valid)
					next_op 	=	waitT1  	;
				else
					begin 
					next_op 	=	clearCmd 	;
					next_ts 	=	Arbitrate 	;
					end
		i_ReqRN_dec :
		if(~Crypto_Tag)
			begin
				if(access_flag)
					if (handle_valid && ( state == Open || state == Secure ))
						next_op 	=	newRN 		;
					else
						begin 
						next_op 	=	clearCmd 	;
						next_ts 	=	Arbitrate 	;
						end
				else if (handle_valid && state ==Acknowledged)
						next_op 	=	newHandle 	;
					else if (handle_valid && (state == Open || state == Secure))
						next_op  	=	newRN 		;
					else
						begin 
						next_op 	=	clearCmd 	;
						next_ts 	=	Arbitrate 	;
						end
			end
		else if (Crypto_Tag)
			begin
				if	(handle_valid && state ==Acknowledged)
						next_op 	=	newHandle 	;
					else if (handle_valid && (state == Crypto))
						next_op  	=	newRN 		;
					else
						begin 
						next_op 	=	clearCmd 	;
						next_ts 	=	Arbitrate 	;
						end
			end
		i_Write_dec :
			if(Crypto_Tag)
				begin 
				next_op 	=	clearCmd 	;
				next_ts 	=	Crypto 	;
				end	
			else if (handle_valid && write_valid)
				next_op 	=	writeRom 	; 
			else 
				begin 
				next_op 	=	clearCmd 	;
				next_ts 	=	Arbitrate 	;
				end
		i_Read_dec :
			if(Crypto_Tag)
				begin 
				next_op 	=	clearCmd 	;
				next_ts 	=	Crypto 	;
				end	
			else if (handle_valid &&read_valid )
				next_op 	=	waitT1   	;
			else 
				begin 
				next_op 	=	clearCmd 	;
				next_ts 	=	Arbitrate 	;
				end	
		i_TestWrite_dec :
			if(Crypto_Tag)
				begin 
				next_op 	=	clearCmd 	;
				next_ts 	=	Crypto 	;
				end	
			else if (i_handle_dec ==16'h789a )
				next_op 	=	writeRom 	;
			else 
				begin 
				next_op 	=	clearCmd 	;
				next_ts 	=	Arbitrate 	;
				end
		i_TestRead_dec :
			if(Crypto_Tag)
				begin 
				next_op 	=	clearCmd 	;
				next_ts 	=	Crypto 	;
				end	
			else if	(i_handle_dec ==16'h789a )
				next_op 	=	waitT1   	;
			else 
				begin 
				next_op 	=	clearCmd 	;
				next_ts 	=	Arbitrate 	;
				end		
		i_Lock_dec:
			if(Crypto_Tag)
				begin 
				next_op 	=	clearCmd 	;
				next_ts 	=	Crypto 	;
				end	
			else if((state == Open)||(state == Ready)||(state == Arbitrate))  //OPEN READY ARBITRATE 不能用lock
				begin
				next_op		=	clearCmd	;
				next_ts		=	state		;
				end
			else if(state == Reply || state == Acknowledged)	//OPEN READY ARBITRATE 不能用lock
				begin	
				next_op		=	clearCmd	;
				next_ts		=	Arbitrate	;
				end
			else if(state == Secure)
				if(~handle_valid)
				begin
					next_op		=	clearCmd	;
					next_ts		=	state		;
				end
				else if(o_payload_valid_cu)  //为什么 payload valid是1'b1?
				begin
					next_op		=	Lock		;
					next_ts		=	state		;	
				end
				else
				begin
					next_op		=	waitT1		;	
					next_ts		=	state		;
				end
		i_Select_dec :
			if(Crypto_Tag)
				begin 
				next_op 	=	clearCmd 	;
				next_ts 	=	Crypto 	;
				end	
			else if((mask_length == 0 && Select_done) ||o_addr_rom[5:4]==2'b00 ) //mask_length？
			begin
				next_op		=	clearCmd	;
				next_ts		=	Ready		;
			end
			else if(mask_length != 0 )
			begin
				next_op		=	readrom		;
				next_ts		=	Ready		;
			end					
		i_Access_dec  :
			if(Crypto_Tag)
				begin 
				next_op 	=	clearCmd 	;
				next_ts 	=	Crypto 	;
				end	
			else if(access_flag)
			  begin
			   if(~handle_valid)
				      next_op		=	clearCmd	;
			   else if(access_psw[31:16] == (access_par^o_random_cu) && (state == Open || state == Secure))
			        begin
				      next_ts		=	Secure		;
				      next_op		=	waitT1		;
			        end
			  else if((state == Open || state == Secure) && access_psw[31:16] != (access_par^o_random_cu))
			     begin
				   next_ts		=	Arbitrate	;
				   next_op		=	clearCmd	;
			     end	
			     else 	next_op		=	clearCmd	;
			   end
			else begin
			  if(~handle_valid)
				    next_op		=	clearCmd	;
			     else if(access_psw[15:0] == (access_par^o_random_cu) && (state == Open || state == Secure))
			       begin
				     next_ts		=	Secure		;
				     next_op		=	waitT1		;
			       end
			     else if((state == Open || state == Secure) && access_psw[15:0] != (access_par^o_random_cu))
			       begin
				     next_ts		=	Arbitrate	;
				     next_op		=	clearCmd	;
			       end	
			     else 	next_op		=	clearCmd	;
			    end
//-----------------added by lhzhu---------------------------//
		i_Crypto_Authenticate_dec  : 			
			if((o_Crypto_Authenticate_step_cu == 2'b00) && (state == Crypto) && (i_CSI_dec == 8'b00000001))
			begin
				if(~handle_valid)
				next_op		=	clearCmd	;
				else if (i_Crypto_Authenticate_step_dec == o_Crypto_Authenticate_step_cu) //Intentionally use "!=" to mark the correctness of authenticate step
				next_op 	= 	waitT1 ;
			end	
			else if(((o_Crypto_Authenticate_step_cu == 2'b01) || (o_Crypto_Authenticate_step_cu == 2'b10) )&& (state == Crypto) && (i_CSI_dec == 8'b00000001))
			begin
				if(~handle_valid)
				next_op		=	clearCmd	;
				else if (i_Crypto_Authenticate_step_dec == o_Crypto_Authenticate_step_cu) //Intentionally use "!=" to mark the correctness of authenticate step
				next_op 	= 	readKEY_De ;
			end	
			else
				next_op 	= 	clearCmd ;
		i_Crypto_En_dec :
			if(Crypto_Tag)
				begin 
				next_op 	=	clearCmd 	;
				next_ts 	=	Crypto 	;
				end	
			else if(Crypto_Tag || ~handle_valid ||!(state == Open || state == Secure) )
				begin
					next_op		=	clearCmd	;
					next_ts		=	Arbitrate	;
				end
			else if( Crypto_En_step_cu && (Crypto_En_psw[15:0] == (Crypto_En_par^o_random_cu) ))//Crypto_En_par是decode出来的指令中的Crypto passowrd
			    begin
				    next_op		=	writeRom		;
			    end
			else if( Crypto_En_step_cu && (Crypto_En_psw[15:0] != (access_par^o_random_cu)))
			    begin
					next_ts		=	Arbitrate	;
					next_op		=	clearCmd	;
			    end	
			else if(~Crypto_En_step_cu && (Crypto_En_psw[31:16] == (Crypto_En_par^o_random_cu)))
			    begin
					next_op		=	waitT1		;
			    end
			else if(~Crypto_En_step_cu && (Crypto_En_psw[31:16] != (Crypto_En_par^o_random_cu)))
			    begin
					next_ts		=	Arbitrate	;
					next_op		=	clearCmd	;
			    end	
			else ;
//		i_Crypto_Comm_dec:
			
			default ;
			endcase
//-----------------added by lhzhu---------------------------//		
		
	newQ :		next_op 	=	newSlot 	;
	newSlot :	next_op 	=	checkSlot	;
	checkSlot :
	if (i_slotz_rng)//slotz=slot zero in RNG Part
			next_op		=	newHandle	;
		else
			begin 
			next_ts		=	Arbitrate 	;
			next_op		=	clearCmd 	;
			end
			
	newHandle ,newRN :
			next_op		=	waitT1 		;
	writeRom :	
			next_op 	= 	waitT1   ;
	readrom :
		if (i_Select_dec && done_rom)
			next_op		=	Compare		;
                else if (done_rom )
                        next_op         =       BackScatter     ;
                else
                        next_op         =       op              ;
	Lock	:
		if(done_rom)
			next_op		=	readLock	;
		else	
			next_op		=	op		;

	waitT1 :			//why wait t1?
			if (counter ==6)
				next_op =	BackScatter 	;
			else 
				next_op =	op 		;
	Compare	:	
		if(Compare_done && Select_done)
			next_op		=	clearCmd	;
		else 	next_op		=	op		;

	BackScatter :   //for states that need to backscatter
		if (i_done_ocu)  //done outctrl
			begin
			next_op		=	clearCmd 	;
			if (i_inventory_dec )
				next_ts =	Reply 		;
			else if ((i_ACK_dec )&& state ==Reply )
				next_ts =	Acknowledged 	;
			else if (i_ACK_dec )
				next_ts =	state 	 	;
			else if (i_ReqRN_dec &&state ==Acknowledged && Crypto_Tag)
				next_ts =	Crypto 		;
			else if (i_ReqRN_dec &&state ==Acknowledged && access_psw!= 32'h0000_0000)
				next_ts =	Open 		;
			else if (i_ReqRN_dec &&state ==Acknowledged && access_psw== 32'h0000_0000)
				next_ts =	Secure 		;
			else if (i_ReqRN_dec &&(state ==Open||state == Secure) )
				next_ts =	state 		;
			else if (i_ReqRN_dec &&(state == Crypto))
				next_ts =	Crypto 	;
			else if (i_ReqRN_dec)
				next_ts =	Arbitrate 	;
			else if (i_Lock_dec)
				next_ts	=	Secure		;
			else if (i_Crypto_Authenticate_dec)
				next_ts =	state	;
			else if (i_Crypto_En_dec && Crypto_En_step_cu)	
				next_ts =	Crypto ;				
			else 
				next_ts =	state ;
			end
		else
			next_op		=	op	;
	readKEY_De :
			if (i_equal_correct)	
							next_op =	readKEY_En ;
			else 			next_op =	op 	 ;
	readKEY_En :	//KEY是读到AES控制模块 AES_CTRL 中的 利用 o_key_shift_cu
			if (done_rom )	next_op =	authen ;
			else 			next_op =	op 	 ;
	authen:
			if (i_equal_correct)
				next_op		=	waitT1	;
			else if (i_equal_wrong)
				next_op		=	clearCmd	;
			else 	
				next_op		=	op ;
	clearCmd :
			next_op		=	waiting		;
	default :	next_op 	=	clearCmd 	;														
	endcase		
	end
//------------------------------------------------------------------------------
// Logic for o_Authenticate_flag_cu
//------------------------------------------------------------------------------
/*always 	@ ( posedge clk or negedge rst_n )
	if(~rst_n)
		o_Authenticate_flag_cu <= 2'b0;
	else if (i_Crypto_Authenticate_dec && state == BackScatter && i_Crypto_Authenticate_step_dec == 2'd0 )
		o_Authenticate_flag_cu <= 2'd1 ;
	else if (i_Crypto_Authenticate_dec && state == BackScatter && i_Crypto_Authenticate_step_dec == 2'd1 )
		o_Authenticate_flag_cu <= o_Authenticate_flag_cu + 2'd2 ;
	else o_Authenticate_flag_cu <= o_Authenticate_flag_cu ;*/

//------------------------------------------------------------------------------
// Logic for o_Authenticate_step_cu
//------------------------------------------------------------------------------
	
always	@ (posedge clk or negedge rst_n)
	if (~rst_n)
		o_Crypto_Authenticate_step_cu <= 2'd0;
	else if (i_Crypto_Authenticate_dec == 1'b1)
		if ((next_op == clearCmd) && (i_Crypto_Authenticate_step_dec == o_Crypto_Authenticate_step_cu))
		o_Crypto_Authenticate_step_cu <= o_Crypto_Authenticate_step_cu + 1'b1;
		else  ;
	else;
		
//------------------------------------------------------------------------------
// Logic for Crypto_Step_cu
//------------------------------------------------------------------------------
always	@ (posedge clk or negedge rst_n)
	if (~rst_n)
		begin 
		Crypto_En_step_cu 		<=	1'b0 	;
		end 	
	else if (i_Crypto_En_dec && op == clearCmd)
	begin
		if  ( ~Crypto_En_step_cu && Crypto_En_psw[31:16] == (Crypto_En_par^o_random_cu) && (state == Open || state == Crypto))   
			Crypto_En_step_cu 		<=	1'b1 	;
					
		else if ( ~Crypto_En_step_cu && access_psw[31:16] != (Crypto_En_par^o_random_cu) && (state == Open || state == Crypto)) 
			Crypto_En_step_cu		<=	1'b0	;
			
		else if ( Crypto_En_step_cu && (state == Open || state == Crypto) && access_psw[15:0] != (access_par^o_random_cu))
			Crypto_En_step_cu		<=	1'b0	;
			
		else;
	end
	else;
//--------------------------------------//		
//------------------------------------------------------------------------------
// Address for read&write
//------------------------------------------------------------------------------

always 	@ ( posedge clk or negedge rst_n )
	if (~rst_n )
		back_rom 	<=	1'b0		;
	else if (done_rom )
		back_rom 	<=	1'b0 		;
	else if (i_back_rom_ocu )  //脉冲信号，表示需要存储器到输出的数据链路
		back_rom 	<=	1'b1		;
	
always @ (*)
	begin
	o_rd_rom	=	op ==readrom || back_rom ||op ==readCRC ||op ==readPC ||op ==readKEY_En ||op ==readKEY_De||op == readLock||op == readAccess || op==readCryptoflag || op==readCrypto_En_psw;
	o_wr_rom	=	op ==writeRom || op == Lock;
	end
	
reg 		shiftaddr_d	;
wire		shiftaddr	;

always	@(posedge clk or negedge rst_n )
	if (~rst_n )
		begin 
		shiftaddr_d <=	1'b0		;
		done_rom_d	<=	1'b0		;
		end
	else if(i_ACK_dec||i_Read_dec)
		begin 
		shiftaddr_d <=	i_shiftaddr_ocu	;   
		done_rom_d	<=	i_done_rom	;
		end
	else
		begin 
		shiftaddr_d <=	1'b0		;
		done_rom_d	<=	1'b0		;
		end
		
	assign shiftaddr 	=	(i_ACK_dec||i_Read_dec)? (~shiftaddr_d && i_shiftaddr_ocu): i_fifo_full_rom ; //读写存储器的word总数的递减控制信号
	assign done_rom 	=	~done_rom_d &i_done_rom	; 
	assign o_done_key	=	done_rom && (op == readKEY_En || op == readKEY_De);
	
always	@(posedge clk or negedge rst_n)
	if (~rst_n)
		begin
		o_addr_rom	<=	7'h0	;
		o_wordcnt_rom	<=	8'h0	;
		end
	else if (i_newcmd_dem )   //demodulate察觉到了新指令
		begin
		o_addr_rom	<=	7'h0	;
		o_wordcnt_rom	<=	8'h0	;
		end		
	else if ( shiftaddr &&(~done_rom))    //increase address
		begin
		o_addr_rom 	<=	o_addr_rom + 6'h1	;
		o_wordcnt_rom 	<=	o_wordcnt_rom - 8'h1	;
		end
	else if (newstate && next_op ==readCRC )
		begin
		o_addr_rom	<=	7'b0010000	;	// crc of epc
		o_wordcnt_rom	<=	8'h1	;
		end
	else if (newstate && next_op ==readPC )
		begin
		o_addr_rom	<=	7'b0010001	;	// pc
		o_wordcnt_rom	<=	8'h1	;
		end	
	else if (i_back_rom_ocu && i_ACK_dec && !Crypto_Tag )
		begin 
		o_addr_rom 	<=	7'b0010001 	;  //PC,EPC
		o_wordcnt_rom 	<=	{3'b000,pc} + 8'b1 ; //pc的倒数四个数字
		end
	else if (i_back_rom_ocu && i_ACK_dec && Crypto_Tag )
		begin 
		o_addr_rom 	<=	7'b0100000 	;  //PC,TID
		o_wordcnt_rom 	<=	{3'b000,pc} + 8'b1 ; //pc的倒数四个数字
		end
//-------------------------------------------------00 indicates Reserved bank
	else if (newstate && next_op ==readCryptoflag)
		begin
		o_addr_rom	<=	7'b0000010	;	// Cryptoflag
		o_wordcnt_rom	<=	8'h1	;
		end
	else if (newstate && next_op ==readCrypto_En_psw)
		begin
		o_addr_rom	<=	7'b0000100	;	// Crypto_En_psw
		o_wordcnt_rom	<=	8'h2	;
		end
	else if (newstate && next_op == readAccess) //指令，状态寄存器即将变化即将变化那么newstate就有效
		begin
		o_addr_rom	<=	7'b0000000	;	//Access password 
		o_wordcnt_rom	<=	8'h2	;
		end
	else if (newstate && next_op == readLock || next_op == Lock && newstate)
		begin
		o_addr_rom	<=	7'b0000011	;	//Lock flag 
		o_wordcnt_rom	<=	8'h1	;
		end
	else if (newstate && next_op ==readKEY_En )
		begin
		o_addr_rom	<=	7'b0110000	;	// AES EnKEY,128bits
		o_wordcnt_rom	<=	8'd8	;
		end	
	else if (newstate && next_op ==readKEY_De )
		begin
		o_addr_rom	<=	7'b0111000	;	// AES DeKEY,128bits
		o_wordcnt_rom	<=	8'd8	;
		end	
	else if (newstate &&next_op ==writeRom )
		begin 
		o_wordcnt_rom 	<=	8'h1	 ;
		end		
	
	else if (i_Select_dec && i_addr_shift_dec) //取地址参数使能，高有效，当有效时，指令中（read，write，testwrite）的地址参数串行进入地址寄存器（addr_rom）
		o_addr_rom	<=	{o_addr_rom[4:0],i_data_dec}	;
		
	else if (i_Select_dec && newstate && next_op == readrom)
		o_wordcnt_rom	<=	{3'b000,mask_word_length}	;
		
	else if (op ==waiting &&i_addr_shift_dec )
		o_addr_rom 	<=	{o_addr_rom [5:0],i_data_dec }	;
		
	else if (op ==waiting &&i_wcnt_shift_dec )
		o_wordcnt_rom 	<=	{o_wordcnt_rom [6:0],i_data_dec }	;
	else begin
		o_addr_rom	<=	o_addr_rom	;
		o_wordcnt_rom	<= o_wordcnt_rom 	;
	end

			
			
 //gated clock for poweron read 
always @ (negedge clk or negedge rst_n)   
if(!rst_n)
    en_poweron = 1'b0;
    
	else	en_poweron =	state ==Poweron	;
	  
always @ (*)
	clk_poweron =	en_poweron &clk	;

always	@(posedge clk or negedge rst_n)
	if (~rst_n)
		Crypto_flag		<=	1'b0	;
	else if (shiftaddr && op ==readCryptoflag )
		Crypto_flag		<=	i_data_rom_16bits[0]	;
	else if (op == writeRom)
		Crypto_flag		<=	1'b1	;
	else ;
		
//-----------------------------------------------//
always 	@(posedge clk_poweron or negedge rst_n )
	if (~rst_n )
		pc 	<=	5'h0 		;
	else if (op ==readPC && shiftaddr)
		pc 	<=	i_data_rom_16bits [15:11]	;

always 	@(posedge clk_poweron or negedge rst_n )
	if (~rst_n )
		access_psw 	<=	32'h0 		;//access password
	else if (op ==readAccess && shiftaddr)  //fifo只有16位，i_data_rom_16bits存储器读出数据，16 bit形式
		access_psw 	<=	{access_psw[15:0],i_data_rom_16bits}	;
		
//---------------added by lhzhu------------------//
always 	@(posedge clk_poweron or negedge rst_n )
	if (~rst_n )
		Crypto_En_psw 	<=	32'h0 		;//Crypto_En password
	else if (op ==readCrypto_En_psw && shiftaddr)  //fifo只有16位，i_data_rom_16bits存储器读出数据，16 bit形式
		Crypto_En_psw 	<=	{Crypto_En_psw[15:0],i_data_rom_16bits}	;
//---------------added by lhzhu------------------//	
/*
//gated clock for write
reg		en_data_rom	;
reg		clk_data_rom	;
always @ (*)
	if (~clk)	en_data_rom =	i_data_shift_dec || (op !=writeRom &&next_op ==writeRom ) || (op != Lock&&next_op==Lock);

always @ (*)
	clk_data_rom =	en_data_rom &clk	;

always 	@(posedge clk_data_rom or negedge rst_n )
	if (~rst_n )
		o_data_rom	<=	16'h0 	;
	else if(op != Lock && next_op == Lock && i_Lock_dec ) //为即将到来的next_op=lock做准备数据，共9-0 10位
		begin
		o_data_rom[15:10]	<=	6'b0;
		o_data_rom[8]	<=	(Lock_flag[8]||~Lock_payload[18])?Lock_flag[8]:Lock_payload[8];//lock_payload？ 
		o_data_rom[6]	<=	(Lock_flag[6]||~Lock_payload[16])?Lock_flag[6]:Lock_payload[6];
		o_data_rom[4]	<=	(Lock_flag[4]||~Lock_payload[14])?Lock_flag[4]:Lock_payload[4];
		o_data_rom[2]	<=	(Lock_flag[2]||~Lock_payload[12])?Lock_flag[2]:Lock_payload[2];
		o_data_rom[0]	<=	(Lock_flag[0]||~Lock_payload[10])?Lock_flag[0]:Lock_payload[0];
		o_data_rom[9]	<=	(Lock_flag[8]&&~Lock_flag[9])?Lock_flag[9]:(Lock_payload[19]?Lock_payload[9]:Lock_flag[9])	;
		o_data_rom[7]	<=	(Lock_flag[6]&&~Lock_flag[7])?Lock_flag[7]:(Lock_payload[17]?Lock_payload[7]:Lock_flag[7])	;
		o_data_rom[5]	<=	(Lock_flag[4]&&~Lock_flag[5])?Lock_flag[5]:(Lock_payload[15]?Lock_payload[5]:Lock_flag[5])	;
		o_data_rom[3]	<=	(Lock_flag[2]&&~Lock_flag[3])?Lock_flag[3]:(Lock_payload[13]?Lock_payload[3]:Lock_flag[3])	;
		o_data_rom[1]	<=	(Lock_flag[0]&&~Lock_flag[1])?Lock_flag[1]:(Lock_payload[11]?Lock_payload[1]:Lock_flag[1])	;
		end
	else if (i_data_shift_dec )//取数据参数使能，高有效，当有效时，指令中（write，testwrite）的数据参数串行进入数据寄存器
		o_data_rom 	<=	{o_data_rom [14:0],i_data_dec }	;//每次左移一位
	else if (op !=writeRom && next_op ==writeRom &&(i_Write_dec) )
			o_data_rom 	<=	o_data_rom^o_random_cu	;//o_random_rng	16	RNG输出的随机数
	else ;*/

//------------------------------------------------------------------------------
// New function: UpdateID and timer. by xshen
// set代表有时间限制
//------------------------------------------------------------------------------
		  
		
	always	@(posedge clk or negedge rst_n)
	 if(~rst_n)
		timer	<=	17'h0	;
	 else if(SET)
	   if (state==Reply)
	     timer <= 17'd128000;    //set initial value of time, 100ms
	   else if(state==Acknowledged)
	     timer <= timer -1'b1 ;
	 else timer	<=	17'h0	;
	 
	 assign o_time_up = SET && state==Acknowledged && timer ==17'b0;
	 
		
//------------------------------------------------------------------------------
// Select,Access and Lock commands, by xgchang
//------------------------------------------------------------------------------

always	@(posedge clk or negedge rst_n)//mask这一套东西是用来设置flag的，就是一段数据，比如EPC。用来挑选对象
	if(~rst_n)
		mask_length	<=	8'h0	;
	else if(i_Select_dec && i_length_shift_dec)
		mask_length	<=	{mask_length[6:0],i_data_dec};
	else if(Select_done)
		mask_length	<=	8'h0	;
	else	mask_length	<=	mask_length	;

always	@(posedge clk or negedge rst_n)
	if(~rst_n)
		mask_length_adjust	<=	4'h0	;
	else if(i_mask_shift_dec)
		mask_length_adjust 	<=	4'hf -	mask_length[3:0]+ 4'h1	;
	else if(Compare_done)
		mask_length_adjust	<=	4'h0		;

always @ (*)
	mask_word_length	=	{1'b0,mask_length[7:4]} + 5'h1	;

	
always 	@(posedge clk or negedge rst_n)
	if (~rst_n)
		mask		<=	256'h0	;
	else if (i_Select_dec && i_mask_shift_dec)
		mask		<=	{mask[254:0],i_data_dec}	;
	else if (newstate && op == Compare)
		mask		<=	255'h0	;
			
always @(posedge clk or negedge rst_n)
	if(~rst_n)
		targetaction	<=	6'h00	;
	else if(i_Select_dec && i_targetaction_shift_dec)
		targetaction	<=	{targetaction[4:0],i_data_dec}	;
		
always 	@(posedge clk or negedge rst_n)
	if(~rst_n)
	begin
		Select_match	<=	1'b0	;
		Compare_done	<=	1'b0	;
	end
	else if( i_Select_dec && mask_length == 8'h00 &&i_cmdok_dec )
	begin
		Select_match	<=	1'b1	;
		Compare_done	<=	1'b1	;
	end
	else if( adjust_flag && op == Compare && mask[255:0]==mask_comparation[255:0])
	begin
		Select_match	<=	1'b1	;
		Compare_done	<=	1'b1	;
	end
	else if (op == Compare && adjust_flag)
	begin
		Compare_done	<=	1'b1	;
		Select_match	<=	1'b0	;
	end	
	else if(op != Compare)
	begin
		Compare_done	<=	1'b0	;
		Select_match	<=	1'b0	;
	end
	else;
		

always	@(posedge clk or negedge rst_n)
	if(~rst_n)
		Lock_payload		<=	20'h00000	;
	else if(i_Lock_dec && i_Lock_payload_dec)
		Lock_payload	<=	{Lock_payload[18:0],i_data_dec}	;

always	@(posedge clk or negedge rst_n)
	if(~rst_n)
		access_par	<=	16'h0000	;
	else if(i_Access_dec && i_access_shift_dec)
		access_par	<=	{access_par[15:0],i_data_dec}	;

always	@(posedge clk or negedge rst_n)
	if(~rst_n)
		Crypto_En_par	<=	16'h0000	;
	else if(i_Crypto_En_dec && i_Crypto_En_shift_dec)
		Crypto_En_par	<=	{Crypto_En_par[15:0],i_data_dec}	;
		
assign o_payload_valid_cu =1'b1;
/* ((Lock_flag[8]&i_data_rom[8])||~Lock_flag[8]) && 
((Lock_flag[7]&i_data_rom[16])||~Lock_flag[7]) && 
((Lock_flag[5]&i_data_rom[14])||~Lock_flag[5]) && 
((Lock_flag[3]&i_data_rom[12])||~Lock_flag[3]) &&
((Lock_flag[1]&i_data_rom[10])|| ~Lock_flag[1])	; */



always @(posedge clk or negedge rst_n)
	if(~rst_n)
		access_delay	<=	1'b0	;
	else access_delay	<=	i_Access_dec	;

always @(posedge clk or negedge rst_n)
	if(~rst_n)
		access_flag	<=	1'b0	;
	else if(access_posedge )
		access_flag	<=	~access_flag		;
//--------------------------------------//

	
assign	access_posedge = i_Access_dec && ~access_delay	;

//i_access_dec到来的那个瞬间，到下一个clk来之前，access_posedge有效。
//这个access_posedge使得该clk的到来后access_flag=1'b1。即挑出刚译码完成的时间
//即：access_flag和i_Crypto_flag都是表征之前曾接收过到一个相应的指令（1‘b1）。此时再次接收就翻转回0


//-------------------------------------------//
always 	@(posedge clk  or negedge rst_n)
	if(~rst_n)
		Lock_flag	<=	10'h0	;
	else if(op == readLock && shiftaddr)
		Lock_flag	<=	i_data_rom_16bits[9:0]	;
		
always	@(posedge clk or negedge rst_n)
	if(~rst_n)
		begin
		adjust_flag		<=	1'b0	;
		mask_comparation	<=	255'h0	;
		end
	else if(shiftaddr && op== readrom && i_Select_dec)
		mask_comparation	<=	{mask_comparation[239:0],i_data_rom_16bits};
	else if(op == Compare && ~adjust_flag && ~Compare_done )
		begin
		adjust_flag		<=	1'b1	;
		mask_comparation	<=	mask_comparation 	>> 	mask_length_adjust	;
		end
	else	if(Compare_done)
		begin
		mask_comparation	<=	255'h0	;
		adjust_flag		<=	1'b0	;
		end
	else	begin
		mask_comparation	<=	mask_comparation	;
		adjust_flag		<=	adjust_flag		;
		end


always 	@(posedge clk or negedge rst_n)
	if(~rst_n)
		pre_session	<=	2'b00	;
	else if(i_session_done)
		pre_session	<=	i_session_dec	;

always 	@(posedge clk or negedge rst_n)
	if(~rst_n)
		new_session	<=	1'b0	;
	else if(i_Query_dec && pre_session != i_session_dec&& i_session_done)
		new_session	<=	1'b1	;
	else if(~i_Query_dec)
		new_session	<=	1'b0	;
		
always 	@(posedge clk or negedge rst_n)
	if(~rst_n)
		begin
		query_delay		<=	1'b0	;
		querya_delay	<=	1'b0	;
		queryr_delay	<=	1'b0	;
		end
	else 
		begin
		query_delay		<=	i_Query_dec	;
		querya_delay	<=	i_QueryAdjust_dec	;
		queryr_delay	<=	i_QueryRep_dec	;
		end

assign	query_posedge	=	(i_Query_dec)&&( ~query_delay)	;
assign	query_ar_posedge=	(i_QueryRep_dec && ~queryr_delay) || (i_QueryAdjust_dec && ~ querya_delay)	;

/////------------------------------------------------------//////////////////
/////------------------------------------------------------//////////////////
/////------------------------------------------------------//////////////////
/////------------------------------------------------------//////////////////
/////------------------------------------------------------//////////////////
/////------------------------------------------------------//////////////////
/////------------------------------------------------------//////////////////

//update inventoried flags
always	@(posedge clk or negedge rst_n)
	if(~rst_n)
		begin
		Inventoried_flag	<=	5'h0	;
		Select_done		<=	1'b0	;
		trans_flag		<=	1'b0	;
		end
	else if((Compare_done && Select_match && (op == Compare||(op == waiting && mask_length == 8'h00 )))&& ~Select_done)
	case (targetaction[2:0])
		3'b000,3'b001	:
			begin
			if(targetaction[5:3] == 3'b000)
				Inventoried_flag[0]	<=	1'b0	;
			else if(targetaction[5:3] == 3'b001)
				Inventoried_flag[1]	<=	1'b0	;	
			else if(targetaction[5:3] == 3'b010)
				Inventoried_flag[2]	<=	1'b0	;
			else if(targetaction[5:3] == 3'b011)
				Inventoried_flag[3]	<=	1'b0	;
			else if(targetaction[5:3] == 3'b100)
				Inventoried_flag[4]	<=	1'b1	;
			Select_done		<=	1'b1			;
			end
		3'b100,3'b101	:
			begin
			if(targetaction[5:3] == 3'b000)
				Inventoried_flag[0]	<=	1'b1	;
			else if(targetaction[5:3] == 3'b001)
				Inventoried_flag[1]	<=	1'b1	;	
			else if(targetaction[5:3] == 3'b010)
				Inventoried_flag[2]	<=	1'b1	;
			else if(targetaction[5:3] == 3'b011)
				Inventoried_flag[3]	<=	1'b1	;
			else if(targetaction[5:3] == 3'b100)
				Inventoried_flag[4]	<=	1'b0	;
			Select_done		<=	1'b1			;
			end
		3'b011	:
			begin
			if(targetaction[5:3] == 3'b000)
				Inventoried_flag[0]	<=	~Inventoried_flag[0]	;
			else if(targetaction[5:3] == 3'b001)
				Inventoried_flag[1]	<=	~Inventoried_flag[1]	;	
			else if(targetaction[5:3] == 3'b010)
				Inventoried_flag[2]	<=	~Inventoried_flag[2]	;
			else if(targetaction[5:3] == 3'b011)
				Inventoried_flag[3]	<=	~Inventoried_flag[3]	;
			else if(targetaction[5:3] == 3'b100)
				Inventoried_flag[4]	<=	~Inventoried_flag[4]	;
			Select_done		<=	1'b1			;
			end
		default:begin 
			Inventoried_flag[4:0]	<=	Inventoried_flag[4:0]	;
			Select_done		<=	1'b1			;
			end
		endcase	
	else if(Compare_done && ~Select_match && op == Compare && ~ Select_done)
	case (targetaction[2:0])
		3'b000,3'b010	:
			begin
			if(targetaction[5:3] == 3'b000)
				Inventoried_flag[0]	<=	1'b1	;
			else if(targetaction[5:3] == 3'b001)
				Inventoried_flag[1]	<=	1'b1	;	
			else if(targetaction[5:3] == 3'b010)
				Inventoried_flag[2]	<=	1'b1	;
			else if(targetaction[5:3] == 3'b011)
				Inventoried_flag[3]	<=	1'b1	;
			else if(targetaction[5:3] == 3'b100)
				Inventoried_flag[4]	<=	1'b0	;
			Select_done		<=	1'b1			;
			end
		3'b100,3'b110	:
			begin
			if(targetaction[5:3] == 3'b000)
				Inventoried_flag[0]	<=	1'b0	;
			else if(targetaction[5:3] == 3'b001)
				Inventoried_flag[1]	<=	1'b0	;	
			else if(targetaction[5:3] == 3'b010)
				Inventoried_flag[2]	<=	1'b0	;
			else if(targetaction[5:3] == 3'b011)
				Inventoried_flag[3]	<=	1'b0	;
			else if(targetaction[5:3] == 3'b100)
				Inventoried_flag[4]	<=	1'b1	;
			Select_done		<=	1'b1			;
			end
		3'b111	:
			begin
			if(targetaction[5:3] == 3'b000)
				Inventoried_flag[0]	<=	~Inventoried_flag[0]	;
			else if(targetaction[5:3] == 3'b001)
				Inventoried_flag[1]	<=	~Inventoried_flag[1]	;	
			else if(targetaction[5:3] == 3'b010)
				Inventoried_flag[2]	<=	~Inventoried_flag[2]	;
			else if(targetaction[5:3] == 3'b011)
				Inventoried_flag[3]	<=	~Inventoried_flag[3]	;
			else if(targetaction[5:3] == 3'b100)
				Inventoried_flag[4]	<=	~Inventoried_flag[4]	;
			Select_done		<=	1'b1			;
			end
		default:begin 
			Inventoried_flag[4:0]	<=	Inventoried_flag[4:0]	;
			Select_done		<=	1'b1			;
			end
		endcase	
		else if ( (state == Acknowledged || state == Open || state == Secure) && i_session_done && ~new_session )
			case (pre_session)
			2'b00:	Inventoried_flag[0]	<=	~Inventoried_flag[0]	;	
			2'b01:	Inventoried_flag[1]	<=	~Inventoried_flag[1]	;
			2'b10:	Inventoried_flag[2]	<=	~Inventoried_flag[2]	;
			2'b11:	Inventoried_flag[3]	<=	~Inventoried_flag[3]	;
			endcase
		else if (~trans_flag&&~access_flag&& (state == Acknowledged || state == Open || state == Secure) &&i_cmdok_dec&&(i_QueryRep_dec||i_QueryAdjust_dec)  && i_session2_dec == i_session_dec)
			begin
			case (i_session_dec)
			2'b00:	Inventoried_flag[0]	<=	~Inventoried_flag[0]	;	
			2'b01:	Inventoried_flag[1]	<=	~Inventoried_flag[1]	;
			2'b10:	Inventoried_flag[2]	<=	~Inventoried_flag[2]	;
			2'b11:	Inventoried_flag[3]	<=	~Inventoried_flag[3]	;
			endcase
			trans_flag	<=	1'b1	;
			end
		else if(Select_done && ~i_Select_dec)
			Select_done	<=	1'b0	;
		else if(~(i_QueryRep_dec||i_QueryAdjust_dec))
			trans_flag	<=	1'b0	;

	always @ (*) //Lock functions here
	if (TEST)
	  begin
			read_valid <= 1'b1	;
			write_valid	<= 1'b1	;
		end
	else if(i_ebv_flag_dec)
		begin
		if(o_addr_rom[5:4]==2'b11)
			begin
				read_valid	<=	i_Read_dec&&(state == Open || state == Secure)	;
			case(Lock_flag[1:0])
			2'b00,2'b01	:	
				write_valid	<=	i_Write_dec && (state == Open)||(state == Secure);
			2'b10		:	
				write_valid	<=	i_Write_dec && (state == Secure)	;
			2'b11		:	
				write_valid	<=	1'b0	;
		       endcase	
			end
		else 	
			begin
				write_valid	<=	i_Write_dec && state == Secure	;
				read_valid	<=	i_Read_dec	&& state == Secure	;
			end	
		end	
	else
		case(o_addr_rom[3:2])
		2'b01:begin
				read_valid	<=	i_Read_dec&&(state == Open || state == Secure)	;
			case(Lock_flag[5:4])
			2'b00,2'b01	:
				write_valid	<=	i_Write_dec && (state == Open)||(state == Secure);
			2'b10		:	
				write_valid	<=	i_Write_dec && (state == Secure)	;
			2'b11		:	
				write_valid	<=	1'b0	;
			endcase
		       end	
		2'b10:begin
				read_valid	<=	i_Read_dec&&(state == Open || state == Secure)	;
			case(Lock_flag[3:2])
			2'b00,2'b01	:	
				write_valid	<=	i_Write_dec && (state == Open)||(state == Secure);
			2'b10		:	
				write_valid	<=	i_Write_dec && (state == Secure)	;
			2'b11		:	
				write_valid	<=	1'b0	;
			endcase
		       end	
		2'b11:begin
				read_valid	<=	i_Read_dec&&(state == Open || state == Secure)	;
			case(Lock_flag[1:0])
			2'b00,2'b01	:	
				write_valid	<=	i_Write_dec && (state == Open)||(state == Secure);
			2'b10		:	
				write_valid	<=	i_Write_dec && (state == Secure)	;
			2'b11		:	
				write_valid	<=	1'b0	;
			endcase
		       end	
		2'b00:begin
			if((o_addr_rom[5:0] == 6'h2)||(o_addr_rom[5:0] == 6'h3))
			case(Lock_flag[7:6])
			2'b00,2'b01:
				begin
				write_valid	<=	i_Write_dec && (state == Open || state == Secure)	;
				read_valid	<=	i_Read_dec	&& (state == Open || state == Secure)	;
				end	
			2'b10	:
				begin
				write_valid	<=	i_Write_dec && state == Secure	;
				read_valid	<=	i_Read_dec	&& state == Secure	;
				end	
			2'b11	:
				begin
				write_valid	<=	1'b0	;
				read_valid	<=	1'b0	;
				end
			endcase
			else 
				begin
				write_valid	<=	i_Write_dec && state == Secure	;
				read_valid	<=	i_Read_dec	&& state == Secure	;
				end	
		
			end
		endcase			
	

//------------------------------------------------------------------------------
// control for output
//------------------------------------------------------------------------------	
always 	@(posedge clk or negedge rst_n )
	if (~rst_n )
		begin 
		c_m 		<=	'h0 	;
		c_pri 		<=	'h0 	;
		end 
	else if (op !=BackScatter && next_op ==BackScatter )
		begin 
		c_m 		<=	'h0 	;
		c_pri 		<=	'h0 	;
		end 		
	else if (op ==BackScatter && c_pri =='h0 ) //c_pri?
		begin
		c_pri		<=	{i_tpri_dem[5:1],1'b1}	;
		if (c_m =='h0)
				case (i_m_dec)
			2'b00:	c_m <= 'h0 	;
			2'b01:	c_m <= 'h1 	;
			2'b10:	c_m <= 'h3 	;
			2'b11:	c_m <= 'h7	;
			endcase
		else 
			c_m 	<=	c_m - 'h1 ;
		end
	else if (op ==BackScatter )
		c_pri 		<=	c_pri - 'h1	;

always 	@(posedge clk or negedge rst_n )
	if (~rst_n )
		o_datarate_ocu	<=	1'b0 	;
	else if (op ==BackScatter && c_pri =='h0 && c_m =='h0)
		o_datarate_ocu 	<=	1'b1 	;
	else if (o_datarate_ocu )
		o_datarate_ocu 	<=	1'b0 	;

		
always 	@(posedge clk or negedge rst_n )
	if (~rst_n )
		o_en2blf_mod	<=	1'b0 	;
	else if (op ==BackScatter && (c_pri =={i_tpri_dem[5:1],1'b0} || c_pri ==((i_tpri_dem >>1)-'h1)))
		o_en2blf_mod 	<=	1'b1 	;
	else if (o_en2blf_mod )
		o_en2blf_mod 	<=	1'b0 	;

//moduel for waiting T1
reg 		en_t1	;
//reg 		clk_t1	;
always @ (negedge clk or negedge rst_n)
 if(!rst_n)
  en_t1 = 1'b0;
else	
		en_t1 	=	i_t1_start_dem || i_newcmd_dem || counter >0 ;
	  
//always @ (*) 
//	clk_t1 	=	en_t1 &clk ;
	
always 	@(posedge clk or negedge rst_n )
	if (~rst_n )
		begin 
		counter 		<=	0 	;
		t1_start 		<=	1'b0 	;
		end 
	else if (i_t1_start_dem )
		begin 
		counter 		<=	i_t1_dem	;
		t1_start 		<=	1'b1 	;
		end
	else if (i_newcmd_dem )
		t1_start 		<=	1'b0 	;
	else if (en_t1 && counter >0)
		counter 		<=	counter -1'b1 	;


			
// those registers should be controlled repectively	
reg 		en_rn16		;
reg 		clk_rn16	;
always @ (negedge clk or negedge rst_n)
if(!rst_n)
    en_rn16 = 1'b0;
	else		en_rn16 	=	op ==newHandle || op ==newRN ;

always @ (*) 
	clk_rn16 	=	en_rn16 &clk ;	
		
always	@(posedge clk_rn16 or negedge rst_n)
	if (~rst_n)
		begin 
		o_handle_cu	<=	16'h0	;
		o_random_cu	<=	16'h0 	;
		end
	else if (op==newHandle)
		begin 
		o_handle_cu	<=	i_random_rng	;
		o_random_cu 	<=	i_random_rng 	;
		end
	else if (op==newRN )
		o_random_cu 	<=	i_random_rng 	;
		
assign	Crypto_Tag	= i_force_Crypto || Crypto_flag ;
assign 	handle_valid 	=	i_handle_dec == o_handle_cu	;

always @ (*)
	if (shiftaddr && op ==readCRC )
	o_seed_in_rng=	1'b1	; 	
	else
		o_seed_in_rng=	1'b0	;
		
always @ (*)
	begin 
	o_clear_cu		=	op ==clearCmd			 	; //将 状态/指令全部清零
	o_newSlot_cu	=	op ==newSlot && ~i_QueryRep_dec 	;
	o_decSlot_cu	=	op ==newSlot && i_QueryRep_dec 	;
	o_key_shift_cu	=	(op ==readKEY_En ||op ==readKEY_De) && shiftaddr	;
	o_reload_crc 	=	i_newcmd_dem || i_reload_ocu 	;
	o_valid_crc 	 =	i_valid_dem || i_crcen_ocu 	;
	o_data_in_crc =  i_data_dem || i_data_ocu  ;
	end
		

assign	Query_match	=	(i_session_dec==2'b00 && ~(i_target_dec^Inventoried_flag[0]) ||
				i_session_dec==2'b01 && ~(i_target_dec^Inventoried_flag[1]) ||
				i_session_dec==2'b10 && ~(i_target_dec^Inventoried_flag[2]) ||
				i_session_dec==2'b11 && ~(i_target_dec^Inventoried_flag[3]) )&& 
				 ((i_sel_dec== 2'b10 && ~Inventoried_flag[4]) ||(i_sel_dec == 2'b11 && Inventoried_flag[4])||(i_sel_dec==2'b00|| i_sel_dec==2'b01 ));
						 // i_select_decode
assign 	Query_ar_match 	=  i_session2_dec == i_session_dec	;


//----------------------------------------------------------------------
// clock management
//----------------------------------------------------------------------
wire		clear_top	;
wire    backing_cu ;
wire    demoding_cu ;
 
reg			en_rom		;
reg 		en_dem		;
reg 		en_aes		;
reg 		en_act		;
reg 		en_mod		;
reg 		en_ocu		;
reg 		en_crc		;
reg 		en_rng		;
 
	assign clear_top	=	o_clear_cu || i_newcmd_dem	;
	assign backing_cu	=	op ==BackScatter ;
	assign demoding_cu	=	state !=Poweron &&(~t1_start ||op ==waiting )&&(op!=BackScatter)	;
	assign Init_cu		=	(op ==IDLE)||(op ==readCryptoflag)||(op ==readCrypto_En_psw)||(op ==readCRC)||(op ==readPC)||(op ==readLock)||(op ==readAccess)||(op ==InitDone);
	 
//democulate 的时钟在poweron/backscatter时期是不工作的。不接收I_PIE的信号。只有在waiting时有效。
always @ (negedge clk or negedge rst_n)
  if(!rst_n)
    begin 
		en_rom 	=	1'b0;
		en_dem  =	1'b0	;
		en_aes 	=	1'b0;
		en_act  = 1'b0;
		en_mod 	=	1'b0;
		en_ocu  =	1'b0;
		en_crc 	=	1'b0;
		en_rng	=	1'b0;
		end
	else
		begin 
		en_rom 	=	((~backing_cu ) ? o_rd_rom ||o_wr_rom : backing_cu && o_en2blf_mod	);
		en_dem  =	demoding_cu || clear_top 		;
		en_aes 	=	i_en_AES || clear_top	;
		en_act  = 	Crypto_Tag || clear_top	;
		en_mod 	=	o_en2blf_mod || clear_top 		;
		en_ocu  =	o_datarate_ocu || clear_top 	;
		en_crc 	=	o_reload_crc || o_valid_crc	;
		en_rng	=	backing_cu || Init_cu	;
		end
		
always @ (*) 
	begin 
		o_clk_rom =	en_rom &clk ;
		o_clk_dem =	en_dem &clk ;
		o_clk_aes =	en_aes &clk ;
		o_clk_act = en_act &clk ;
		o_clk_mod =	en_mod &clk ;
		o_clk_ocu =	en_ocu &clk ;
		o_clk_crc =	en_crc &clk ;
		o_clk_rng =	en_rng &clk	;
	end
	
endmodule

