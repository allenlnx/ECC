/*************************************************
this module is the control unit of the baseband 
module name : control
auther: xshen & xgchang & lhzhu & chengwu
date : 2010-11-20
modified: 2010-12-25
modified: 2014-12-12
***************************************************/
`timescale 1ns/100ps
module control (
	input			clk		,
	input			rst_n	,
	input			SET ,
	input	[5:0]	i_tpri_dem	,
	input			i_newcmd_dem	,
	input			i_valid_dem   ,
	input			i_data_dem  ,
	input	[8:0]	i_t1_dem		,
	input			i_t1_start_dem	,
	input			i_Query_dec	,
	input			i_QueryAdjust_dec	,
	input			i_QueryRep_dec	,
	input			i_ACK_dec	,
	input			i_ReqRN_dec	,
	input			i_Read_dec	,
	input			i_Write_dec	,
	input			i_TestWrite_dec	,
	input			i_TestRead_dec	,
	input			i_inventory_dec	,
	input			i_Lock_dec	,
	input			i_Select_dec	,
	input			i_Access_dec	,
	input			i_cmdok_dec	,
	input	[15:0]	i_handle_dec	,
	input	[1:0]	i_m_dec		,
	input			i_ebv_flag_dec	,
	input			i_addr_shift_dec	,
	input			i_data_shift_dec	,
	input			i_wcnt_shift_dec	,
	input			i_data_dec	,
	input			i_Lock_payload_dec	,
	input			i_target_dec	,
	input	[1:0]	i_session_dec	,
	input			i_session_done	,
	input	[1:0]	i_session2_dec	,
	input	[1:0]	i_sel_dec	,
	input			i_length_shift_dec	,
	input			i_mask_shift_dec	,
	input			i_targetaction_shift_dec	,
	input			i_access_shift_dec	,
	input	[15:0]	i_data_rom_16bits	,
	input			i_done_rom	,
	input			i_done_ECC	,
	//-----added by lhzhu----- //
	input			i_fifo_full_rom	,
	input			i_shiftaddr_ocu	,
	input			TEST,
	//------------------------ //
	
	input			i_reload_ocu  ,
	input			i_crcen_ocu  ,
	input			i_data_ocu  ,
	input			i_done_ocu	,
	input			i_back_rom_ocu	,
	input	[15:0]	i_random_rng	,
	input			i_slotz_rng	,
	input			i_en_ECC  ,
	
	//-----added by chengwu----//
	input	[7:0]	i_AuthParam_dec,
	input			i_Authenticate_ok_dec,
	input	[15:0]	i_Address_dec,
	input			i_Authenticate_dec  ,
	//-------------------------//
	
	//-----added by lhzhu----- //
	output	reg [6:0]	o_addr_rom		,
	output	reg			o_rd_rom		,
	output	reg 		o_wr_rom		,
	//-------------------------//
	
	output	reg	[7:0]	o_wordcnt_rom	,
	output	reg	[15:0]	o_handle_cu		,
	output	reg [15:0]	o_random_cu		,
	output	reg 		o_decSlot_cu	,
	output	reg 		o_newSlot_cu	,
	output	reg 		o_clear_cu	,
	output	reg 		o_key_shift_cu	,	
	output	reg			o_seed_in_rng	,
	output	reg 		o_datarate_ocu	,
	output	reg 		o_en2blf_mod	,
	output	reg 		o_reload_crc ,
	output	reg 		o_valid_crc ,
	output	reg 		o_data_in_crc ,
	output		 		o_time_up   ,
	output	 			o_payload_valid_cu ,
	//---------added by lhzhu----- //
	output	reg [1:0]	o_Authenticate_step_cu , //mark the current authenticate step
	output				o_done_key	,
	//---------------------------- //
	output	reg 		o_clk_rom 	 ,
	output	reg 		o_clk_dem  ,
	output	reg 		o_clk_aes  ,
	output	reg 		o_clk_act  ,
	output	reg 		o_clk_mod  ,
	output	reg 		o_clk_ocu  ,
	output	reg 		o_clk_crc  ,
	output	reg 		o_clk_rng	
			);
	
parameter   Poweron=4'b0000;
parameter	Ready=4'b0001;
parameter   Arbitrate=4'b0010;
parameter   Reply=4'b0011;
parameter   Acknowledged=4'b0100;
parameter   Open=4'b0101;
parameter	Secure=4'b0110;

parameter 	
IDLE=5'd0,
waiting=5'd1,
readPC=5'd2,
readCRC=5'd3,
readMODE=5'd4,
read_public_KEY=5'd5,
read_private_KEY=5'd6,
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
calculate = 5'd26 ;
 
reg [3:0] 	state,next_ts	;
reg [4:0]	op,next_op	;
reg	[4:0]	pc		;
wire		newstate	;
wire 		handle_valid	;
//---------amended-------//
reg 		read_valid	;
reg 		write_valid	;
//---------amended-------//
reg	[16:0] 	timer;     //for time counter, 100ms limited
reg 		back_rom		;	
reg [5:0]	c_pri		;
reg	[2:0]	c_m		;
//		reg 	[8:0]	counter		; temp way to run ecc -- chengwu
reg [15:0]	counter		;
reg 		t1_start	;
reg	[19:0]	Lock_payload	;
reg	[9:0]	Lock_flag	;
reg	[4:0]	Inventoried_flag;
reg	[7:0]	mask_length	;
reg	[4:0]	mask_word_length;
reg	[255:0]	mask		;   //mask used for Inventory
reg	[255:0] mask_comparation;
reg 		Select_done	;
reg			Compare_done	;
reg			Select_match	;
reg	[3:0]	mask_length_adjust	;
reg [5:0]	targetaction	;
reg			adjust_flag	;
reg	[31:0]	access_psw	;
reg			access_flag	;
reg	[15:0]	access_par	;  //access_par
reg			access_delay	;
wire		access_posedge	;
wire		Query_match	;
wire		Query_ar_match	;
reg	[1:0]	pre_session	;
reg			new_session	;
reg			query_delay	;
reg			querya_delay	;
reg			queryr_delay	;
wire		query_posedge	;
wire		query_ar_posedge;	
reg			trans_flag	;
// those update in Poweron 
reg 		en_poweron	; //power mode equals to 1
reg 		clk_poweron	;	

// ------------ added by lhzhu -------------- //
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
	        else	next_op =	readCRC ;
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
		i_Write_dec :
			if (handle_valid && write_valid)
				next_op 	=	writeRom 	; 
			else 
				begin 
				next_op 	=	clearCmd 	;
				next_ts 	=	Arbitrate 	;
				end
		i_Read_dec :
			if (handle_valid && read_valid )
				next_op 	=	waitT1   	;
			else 
				begin 
				next_op 	=	clearCmd 	;
				next_ts 	=	Arbitrate 	;
				end	
		i_TestWrite_dec :
			if (i_handle_dec ==16'h789a )
				next_op 	=	writeRom 	;
			else 
				begin 
				next_op 	=	clearCmd 	;
				next_ts 	=	Arbitrate 	;
				end
		i_TestRead_dec :
			if	(i_handle_dec ==16'h789a )
				next_op 	=	waitT1   	;
			else 
				begin 
				next_op 	=	clearCmd 	;
				next_ts 	=	Arbitrate 	;
				end		
		i_Lock_dec:
			if((state == Open)||(state == Ready)||(state == Arbitrate))  //OPEN READY ARBITRATE 不能用lock
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
			if((mask_length == 0 && Select_done) ||o_addr_rom[5:4]==2'b00 ) //mask_length？
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
			if(access_flag)
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
		i_Authenticate_dec  : 			
			if(state == Open)
			begin
				if(~handle_valid)
				next_op		=	clearCmd	;
				else if (o_Authenticate_step_cu == 'd0 && i_AuthParam_dec =='h01) //Intentionally use "!=" to mark the correctness of authenticate step
				next_op 	= 	read_public_KEY 	;
				else if (o_Authenticate_step_cu == 'd1 && i_AuthParam_dec =='h02)
				next_op 	= 	read_private_KEY 		;
				else 
				next_op		=	clearCmd	;
			end
			else
				next_op		=	clearCmd	;
			default;
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
			else if (i_ReqRN_dec &&state ==Acknowledged && access_psw!= 32'h0000_0000)
				next_ts =	Open 		;
			else if (i_ReqRN_dec &&state ==Acknowledged && access_psw== 32'h0000_0000)
				next_ts =	Secure 		;
			else if (i_ReqRN_dec &&(state ==Open||state == Secure) )
				next_ts =	state 		;
			else if (i_ReqRN_dec)
				next_ts =	Arbitrate 	;
			else if (i_Lock_dec)
				next_ts	=	Secure		;
			else if (i_Authenticate_dec)
				next_ts =	state	;		
			else 
				next_ts =	state ;
			end
		else
			next_op		=	op	;
	read_public_KEY :
			if (done_rom)	
					next_op =	waitT1 ;
			else 	next_op =	op 	 ;
	read_private_KEY:
			if (done_rom)	
					next_op =	authen ;
			else 	next_op =	op; 	
	authen:
			if (i_done_ECC)
				next_op		=	waitT1	;
			else 	
				next_op		=	op ;
	clearCmd :
				next_op		=	waiting		;
	default :	next_op 	=	clearCmd 	;														
	endcase		
end

//------------------------------------------------------------------------------
// Logic for o_Authenticate_step_cu
//------------------------------------------------------------------------------
	
always	@ (posedge clk or negedge rst_n)
	if (~rst_n)
		o_Authenticate_step_cu <= 2'b00;
	else if ((next_op == clearCmd) && (i_AuthParam_dec == 'h01))
		o_Authenticate_step_cu <= 2'b01;
	else if ((next_op == clearCmd) && (i_AuthParam_dec == 'h02))
		o_Authenticate_step_cu <= 2'b00;
	else;
		

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
	o_rd_rom	=	op ==readrom || back_rom ||op ==readCRC ||op ==readPC ||op ==read_public_KEY ||op ==read_private_KEY||op == readLock||op == readAccess ;
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
	assign o_done_key	=	done_rom && (op == read_public_KEY ||op == read_private_KEY);
	
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
	else if (i_back_rom_ocu && i_ACK_dec )
		begin 
		o_addr_rom 	<=	7'b0010001 	;  //PC,EPC
		o_wordcnt_rom 	<=	{3'b000,pc} + 8'b1 ; //pc的倒数四个数字
		end
//-------------------------------------------------00 indicates Reserved bank
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
	else if (newstate && next_op ==read_public_KEY )
		begin
		o_addr_rom	<=	i_Address_dec[6:0]	;	// AES EnKEY,128bits
		o_wordcnt_rom	<=	8'd11	;
		end	
	else if (newstate && next_op ==read_private_KEY )
		begin
		o_addr_rom	<=	'd0	;	// ECC private,163bits
		o_wordcnt_rom	<=	8'd11	;
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
//即：access_flag和i_flag都是表征之前曾接收过到一个相应的指令（1‘b1）。此时再次接收就翻转回0


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
		// tempraral way to run ecc 
		//counter 		<=	i_t1_dem	; 
		//t1_start 		<=	1'b1 	;
		if (i_AuthParam_dec != 'h02)
			begin
				counter 		<=	i_t1_dem	;
				t1_start 		<=	1'b1 	;
			end
		else
			begin
				counter			<= 16'ha000 - 1;
				t1_start 		<=	1'b1 	;
			end
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
	o_key_shift_cu	=	op ==read_public_KEY && shiftaddr	;
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
	assign Init_cu		=	(op ==IDLE)||(op ==readCRC)||(op ==readPC)||(op ==readLock)||(op ==readAccess)||(op ==InitDone);
	 
//democulate 的时钟在poweron/backscatter时期是不工作的。不接收I_PIE的信号。只有在waiting时有效。
always @ (negedge clk or negedge rst_n)
  if(!rst_n)
    begin 
		en_rom 	=	1'b0;
		en_dem  =	1'b0	;
		en_aes 	=	1'b0;
		en_act  = 	1'b0;
		en_mod 	=	1'b0;
		en_ocu  =	1'b0;
		en_crc 	=	1'b0;
		en_rng	=	1'b0;
		end
	else
		begin 
		en_rom 	=	((~backing_cu ) ? o_rd_rom ||o_wr_rom : backing_cu && o_en2blf_mod	);
		en_dem  =	demoding_cu || clear_top 		;
		en_aes 	=	i_en_ECC || clear_top	;
		en_act  = 	1'b1 || clear_top	;
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

