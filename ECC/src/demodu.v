`timescale 1ns/100ps
module demodu	(
	input	clk		,
	input	rst_n		,
	input	i_pie	  ,
	input	i_dr_dec		,
	output reg 			o_data_dem	,
	output reg 			o_valid_dem	,
	output reg 			o_newcmd_dem	,
	output reg 			o_preamble_dem,
	output reg [5:0] 	o_tpri_dem	,
	output reg [8:0]	o_t1_dem		,
	output reg 			o_t1_start_dem	
	);

// state[3] means counter to work
// state[4] means counter to clear
parameter	IDLE     	=	5'b1_0_000	;
parameter	DELIMITER	=	5'b1_1_000	;
parameter	TARI     	=	5'b1_1_001	; 
parameter	RTCAL    	=	5'b1_1_011	;
parameter	TRCAL    	=	5'b1_1_111	;
parameter	DATA     	=	5'b1_1_110	;
parameter	T1_WAIT  	=	5'b0_1_100	;
parameter	TPRI_CAL 	=	5'b0_1_101	;
parameter	TIMEOUT  	=	5'b0_1_110	;

parameter	TariMax		= 	'd50	;
parameter	TariMin		=	'd6	;
//parameter	RtMax		=	128	;
parameter	RtMax		=	'd150	;
parameter	RtMin		=	'd15	;
parameter	TrMax		=	'd450	;
parameter	Delta		=	'd2	;
parameter	T1_margin	=	'd6	;
parameter	Delimiter_min	=	'd10	;
parameter	Delimiter_max	=	'd25	;

//parameter	TR_W 		=	10	;
parameter	CntW		=	'd10	; //512可能会超过

reg			pie_data_d	;
reg			rd			;
reg			rd_posedge	;

reg	[4:0]		next		;
reg	[4:0]		state		;

reg	[CntW-1:0]	counter		;
reg	[CntW-1:0]	tari_r		;
reg	[CntW-1:0]	rt_r		;
reg	[CntW-1:0]	tr_r		;
reg	[CntW-1:0]	Tari_x2p5	;
reg	[CntW-1:0]	Tari_x3		;
reg	[CntW-1:0]	Rt_x3		;
reg	[CntW-1:0]	Pilot		;
reg	[CntW-1:0]	t1_tr_wire	;
reg	[CntW-1:0]	t1_wire		;

reg			Tari_match	;
reg			Tari_error	;
reg			Rt_Tari_match	;
reg			Rt_Tari_error	;
reg			Tr_Rt_match	;
reg			Tr_Rt_error	;
reg			Data_match	;
reg			Data_error	;
reg			Delimiter_match;
reg			Delimiter_error;

wire		steady;
assign		steady = (counter != 'd1);

// -------------------------------------------------------------
// async input synchronizer
// -------------------------------------------------------------
always @(posedge clk or negedge rst_n)
	if (~rst_n)
		begin
		pie_data_d	<=	1'b1		;
		rd			<=	1'b1		;
		end
	else 
		begin
		pie_data_d	<=	i_pie		;
		rd			<=	pie_data_d	;
		end

always @ (*) 
	rd_posedge	=	pie_data_d && ~rd		; //找出输入信号的上升沿 rd_d是最早到的数据，早到的数据为0，晚到的数据为1，故是上升沿

always @ (*)
	if (state==TARI && rd_posedge && steady)
		begin
			Tari_match	=	(counter>=TariMin) && (counter<=TariMax)	;
			Tari_error	=	(counter < TariMin) || (counter>TariMax)	;	
		end
	else
		begin
			Tari_match	=	1'b0		;
			Tari_error	=	1'b0		;
		end
		
always @ (*)
	if (state==DELIMITER && rd_posedge && steady)
		begin
			Delimiter_match	=	(counter>=Delimiter_min) && (counter<=Delimiter_max)	;
			Delimiter_error	=	(counter< Delimiter_min) || (counter> Delimiter_max) 	;
		end
	else
		begin
			Delimiter_match	=	1'b0		;
			Delimiter_error	=	1'b0		;
		end
		
always @(posedge clk or negedge rst_n)
	if (~rst_n)
		tari_r		<=	0		;
	else if (Tari_match)
		tari_r		<=	counter		; //tari_r存一个tari长度的counter值

always @ (*)
	begin
	Tari_x3		=	tari_r + (tari_r<<1)	; //3 tari长度
	Tari_x2p5	=	tari_r + (tari_r>>1) + tari_r[0]	; //2.5 tari长度的counter值
	Rt_x3		=	rt_r + (rt_r<<1)	;	// 3 rt_cal
	Pilot		=	(rt_r + tari_r)>>1	;   //Pilot是什么？似乎没有用到。值等于(rt_cal + tari)/2
	end

always @ (*)
	if (state==RTCAL && rd_posedge && steady)
		begin
			Rt_Tari_match	=	(counter>=Tari_x2p5-4*Delta) && (counter<=Tari_x3+4*Delta)	; // 2.5 tari < RTcal < 3 tari
			Rt_Tari_error	=	(counter< Tari_x2p5-4*Delta) || (counter>Tari_x3+4*Delta) ;
		end
	else
		begin
			Rt_Tari_match	=	1'b0		;
			Rt_Tari_error	=	1'b0		;
		end
		
always @(posedge clk or negedge rst_n)
	if (~rst_n)
		rt_r		<=	0		;
	else if (Rt_Tari_match)
		rt_r		<=	counter		; //rt_cal的记录数值

always @ (*)
	if (state==TRCAL && rd_posedge && steady )
		begin
			Tr_Rt_match	=	(counter>rt_r) && (counter<=Rt_x3+4*Delta)	; // rt_cal <tr_cal <= 3 tari
			Tr_Rt_error	=	(counter<= rt_r) || (counter> Rt_x3+4*Delta) ;
		end
	else 
		begin
			Tr_Rt_match	=	1'b0		;
			Tr_Rt_error	=	1'b0		;
		end

always @(posedge clk or negedge rst_n)
	if (~rst_n)
		tr_r		<=	0		;
	else if (Tr_Rt_match)
		tr_r		<=	counter		;

always @ (*)
	if ((state==TRCAL || state==DATA) && rd_posedge)
		begin
			Data_match	=	counter<=(rt_r+2*Delta)	;      //TRCAL或者DATA状态下，有可能是DATA的输入，也可能是TRCAL，故若比Rt_cal(2.5-3 tari)小，则认为是输入的是DATA，否则认为是TRcal
			Data_error	=	counter>(rt_r+2*Delta)	;
		end
	else												//rt_cal长度=0的长度+1的长度
		begin
			Data_match	=	1'b0		;
			Data_error	=	1'b0;
		end

// ---------------------------------------------------------------
// state machine
// ---------------------------------------------------------------
always @(posedge clk or negedge rst_n)
	if (!rst_n)
		state	<=	IDLE	;
	else state	<=	next	;

always @ (*)
	case (state)
	IDLE:
		if (!rd )
	               	next = DELIMITER;
	        else
	               	next = state    ;
	DELIMITER:
		if (Delimiter_match) 		
	               	next = TARI    	;
		else if (Delimiter_error) 
	               	next = IDLE    ;
		else 		next = state	;
	TARI:
		if (Tari_match )  
					next = RTCAL    ;
	     	else if (Tari_error)  //6.25us<tari<25us
	                next = IDLE     ; 
	     	else
	                next = state    ;
	RTCAL:
		if (Rt_Tari_match)
	                next = TRCAL   ;
		else if (Rt_Tari_error)
	                next = IDLE ;
		else
	                next = state  ;
	TRCAL:        //if frame_sync, data_translation begin at this state.
		if (Tr_Rt_match || Data_match ) //TRCAL记录合法 或者 DATA记录合法
	                next = DATA   ;
		else if (rd_posedge || counter==TrMax|| counter==Rt_x3+4*Delta ) //DATA不合法（TrMax）,RTCAL不合法（Counter>3*RTcal）
	                next = IDLE 	;
		else
	                next = state  ;
	DATA:
		if (Data_match)
		        next = state ;
		else if (rd_posedge || counter==(tari_r<<1)+2*Delta)
		        next = TIMEOUT ;
		else
		        next = state ;
	TIMEOUT:
		next = IDLE  ;
	/*	
	T1_WAIT:
		if (counter==t1_wire-T1_margin)
	                next = TPRI_CAL ;
		else
	                next = state ;
	TPRI_CAL:
		next = IDLE ;
	*/
	default:	next = IDLE ;
	endcase


always @(posedge clk or negedge rst_n)
	if (~rst_n)
		counter		<=	1		;
	else if (next!=DELIMITER && (next==IDLE || state!=next && next[4]==1'b1 || Data_match)) //next状态的第四位
		counter		<=	1		;
	else if (next==DELIMITER||state[3]==1'b1) //counter除了在IDLE以外都计数
		counter		<=	counter+1	;

always @ (*)
	if (i_dr_dec)
		o_tpri_dem	=	(tr_r>>5) + (tr_r>>6) + (tr_r[4]|tr_r[5])	;	// 3/64 TRcal
	else
		o_tpri_dem	=	(tr_r>>3) + tr_r[2]	;    //1/8 TRcal ,其中tr_r[2]用来四舍五入

always @ (*)
	if (i_dr_dec)
		t1_tr_wire	=	(tr_r>>1) - (tr_r>>5) + (tr_r[0]|(~tr_r[4]))	; //(trcal/2 - trcal/32)=15/32 trcal
	else
		t1_tr_wire	=	tr_r + (tr_r>>2) + tr_r[1]			;  //tr_cal+1/4 trcal

always @ (*)
	if (rt_r>t1_tr_wire)
		t1_wire		=	rt_r		;
	else
		t1_wire		=	t1_tr_wire	;

always @ (*)
	begin
	o_newcmd_dem	=	Rt_Tari_match	;
	o_t1_start_dem	=	state==TIMEOUT	;
	end

always @(posedge clk or negedge rst_n)
	if (~rst_n)
		o_t1_dem	<=	0		;
	else if (next==TIMEOUT)
		o_t1_dem	<=	t1_wire-counter	;

always @(posedge clk or negedge rst_n)
	if (~rst_n)
		begin
		o_data_dem		<=	1'b0		;
		o_valid_dem		<=	1'b0		;
		end
	else if (Data_match)
		begin
		o_data_dem		<=	counter>(rt_r>>1)	;  // 计算pivot，即 > (rt_cal/2) 的情况下判断为 1'b1
		o_valid_dem		<=	1'b1		;		// 根据clock 来1bit数据，o_valid_dem 便置高。
		end
	else if (o_valid_dem)
		begin
		o_data_dem		<=	1'b0		;
		o_valid_dem		<=	1'b0		;
		end

always	@(posedge clk or negedge rst_n)
	if (~rst_n)
		o_preamble_dem	<=	1'b0		;
	else if (next==DELIMITER || Tr_Rt_match)
		o_preamble_dem	<=	Tr_Rt_match	;

endmodule
        
        
        
 
 
