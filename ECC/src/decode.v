`timescale 1ns/100ps
module	decode	(
	clk		,
	rst_n	,
	i_valid_dem	,
	i_data_dem	,
	i_newcmd_dem	,
	i_preamble_dem	,
	i_clear_cu	,
	//--------------added by lhzhu -------------//
	i_Crypto_Authenticate_step_cu ,
	//--------------added by lhzhu -------------//
	o_Query_dec	,
	o_QueryRep_dec	,
	o_QueryAdjust_dec	,
	o_ACK_dec	,
	o_ReqRN_dec	,
	o_Read_dec	,
	o_Write_dec	,
	o_TestWrite_dec	,
	o_TestRead_dec,
	o_Lock_dec	,
	o_Select_dec	,
	o_inventory_dec	,
	o_data_dec	,
	o_cmdok_dec	,
	o_dr_dec		,
	o_handle_dec	,
	o_Lock_payload_dec	,
	o_q_dec		,
	o_m_dec		,
	o_length_shift_dec	,
	o_mask_shift_dec	,
	o_targetaction_shift_dec	,
	o_addr_shift_dec	,
	o_data_shift_dec	,
	o_wcnt_shift_dec	,
	o_trext_dec	,
	o_target_dec	,
	o_session_dec	,
	o_session_done	,
	o_session2_dec	,
	o_sel_dec	,
	o_Access_dec	,
	o_access_shift_dec	,
	o_ebv_flag_dec	,
//--------------added by lhzhu -------------//
	o_Crypto_Authenticate_dec ,
	o_Crypto_Authenticate_step_dec ,
	o_Crypto_Authenticate_shift_dec	,			//authenticate��ѭ����λ�ź�
	o_Crypto_Authenticate_ok_dec	,							//authenticate������������
	o_Crypto_En_dec ,
	o_Crypto_En_shift_dec ,						//cryptoָ��λ���ź�
	o_Crypto_En_shift_ok_dec ,
	o_Crypto_Comm_dec ,
	o_CSI_dec									//CSI����ֵ
			);
//--------------added by lhzhu -------------//
input			clk		;
input			rst_n		;
input			i_valid_dem	;
input			i_data_dem	;
input			i_newcmd_dem	;
input			i_preamble_dem	;
input			i_clear_cu	;
input[1:0]		i_Crypto_Authenticate_step_cu ;

output			o_Query_dec	;
reg			o_Query_dec	;
output			o_QueryRep_dec	;
reg			o_QueryRep_dec	;
output			o_QueryAdjust_dec	;
reg			o_QueryAdjust_dec	;
output			o_ACK_dec	;
reg			o_ACK_dec	;
//output			o_NAK_dec	;
reg			o_NAK_dec	;
output			o_ReqRN_dec	;
reg			o_ReqRN_dec	;
output			o_Read_dec	;
reg			o_Read_dec	;
output			o_Write_dec	;
reg			o_Write_dec	;
output			o_TestWrite_dec	;
reg			o_TestWrite_dec	;
output		o_TestRead_dec	;
reg			o_TestRead_dec	;
output			o_Lock_dec	;
reg			o_Lock_dec	;
output			o_Select_dec	;
reg			o_Select_dec	;
output		o_Crypto_En_shift_ok_dec ;
reg			o_Crypto_En_shift_ok_dec ;

//------------added by lhzhu--------------//
output		o_Crypto_Authenticate_dec  ;
reg			o_Crypto_Authenticate_dec  ; 
output		o_Crypto_En_dec  ;	
reg			o_Crypto_En_dec  ;	
output		o_Crypto_Comm_dec   ;
reg			o_Crypto_Comm_dec   ;
output[1:0]	o_Crypto_Authenticate_step_dec   ;
reg[1:0]   	o_Crypto_Authenticate_step_dec   ;
output		o_CSI_dec ;
reg[7:0]	o_CSI_dec ;
output 		o_Crypto_Authenticate_shift_dec	;
output 		o_Crypto_Authenticate_ok_dec		;
reg			o_Crypto_Authenticate_shift_dec	;
reg			o_Crypto_Authenticate_ok_dec		;
output		o_Crypto_En_shift_dec ;
reg 		o_Crypto_En_shift_dec ;

//------------added by lhzhu--------------//

output			o_inventory_dec	;
reg			o_inventory_dec	;
output			o_data_dec	;
reg			o_data_dec	;
output			o_cmdok_dec	;
reg			o_cmdok_dec	;
output			o_dr_dec		;
reg			o_dr_dec		;
output	[15:0]		o_handle_dec	;
reg	[15:0]		o_handle_dec	;
output			o_Lock_payload_dec	;
reg			o_Lock_payload_dec	;
output	[3:0]		o_q_dec		;
reg	[3:0]		o_q_dec		;
output	[1:0]		o_m_dec		;
reg	[1:0]		o_m_dec		;
output			o_length_shift_dec	;
reg			o_length_shift_dec	;
output			o_mask_shift_dec	;
reg			o_mask_shift_dec	;
output			o_targetaction_shift_dec	;
reg			o_targetaction_shift_dec	;
output			o_addr_shift_dec	;
reg			o_addr_shift_dec	;
output			o_data_shift_dec	;
reg			o_data_shift_dec	;
output			o_wcnt_shift_dec	;
reg			o_wcnt_shift_dec	;
output			o_trext_dec	;
reg			o_trext_dec	;
output			o_target_dec	;
reg			o_target_dec	;
output	[1:0]		o_session_dec	;
reg	[1:0]		o_session_dec	;
output			o_session_done	;
reg			o_session_done	;
output	[1:0]		o_session2_dec	;
reg	[1:0]		o_session2_dec	;
output	[1:0]		o_sel_dec	;
reg	[1:0]		o_sel_dec	;
output			o_Access_dec	;
reg			o_Access_dec	;
output			o_access_shift_dec	;
reg			o_access_shift_dec	;
output	o_ebv_flag_dec	;
reg			o_ebv_flag_dec;

parameter	IDLE     	=	3'b000	; 
parameter	HUFFMAN 	=	3'b001	; 
parameter	DATA     	=	3'b010	; 
parameter	HANDLE   	=	3'b011	; 
parameter	CRC     	=	3'b100	; 
parameter	DONE     	=	3'b101	; 
	
reg	[2:0] 	state, next	;
reg	[10:0]	counter		;
reg	[7:0]	length		;
reg	[7:0]	huffbuf		;
reg			cmd_name_ok	;
reg	[10:0]	max_bits_data	;

always	@(posedge clk or negedge rst_n)
	if (~rst_n)
		state	<=	IDLE		;
	else state	<=	next		;
	
always @ (*)
	begin
			next	=	state	;
	case	(state	)
	IDLE:	
		if (i_newcmd_dem)
			next	=	HUFFMAN	;
		else
			next	=	state	;
	HUFFMAN:
		if (cmd_name_ok && o_NAK_dec) //NAKָ�ʹ�ص�arbitrate״̬������һ��ʼ��ready״̬��
			next	=	DONE	;
		else if (cmd_name_ok && (o_ACK_dec||o_ReqRN_dec))//�⼸������ֱ�ӵ�HANDLE��
			next	=	HANDLE	;
		else if (cmd_name_ok)		  
			next	=	DATA	;
		else
			next	=	state	;
	DATA:
		if (counter==max_bits_data && o_Query_dec) //DATA�ε������λ��
			next	=	CRC	;
		else if(counter>=max_bits_data && o_Select_dec && length == 8'h00) //selectָ��ֱ������handle
			next	=	CRC	;
		else if (counter==max_bits_data && (o_QueryAdjust_dec||o_QueryRep_dec) )//queryadjust ��queryrep ָ������CRC��handle
			next	=	DONE	;
		else if (counter==(max_bits_data-'d8)&& (o_Write_dec ||o_Read_dec ||o_TestRead_dec ||o_TestWrite_dec ) && ~o_ebv_flag_dec ) //δ��ebv���뷽ʽ�Σ���read/write��ָ��max_bit_data-8
			next	=	HANDLE	;
		else if ((counter==(max_bits_data))&& (o_Crypto_Authenticate_dec ||o_Crypto_En_dec || o_Crypto_Comm_dec) )
			next	=	HANDLE	;
		else if (~o_Select_dec && counter==max_bits_data)//���������
			next	=	HANDLE	;
		else 
			next	=	state	;
	HANDLE:
		if (counter=='d16 && o_ACK_dec) //ACKָ��û��CRC16��
			next	=	DONE	;
		else if (counter=='d16) //handle�ε�16�������ת��CRC��ȥ�ˣ�clk�Ǻܿ�ģ�
			next	=	CRC	;
		else
			next	=	state	;
	CRC:
		if (counter==max_bits_data )
			next	=	DONE	;
		else 
			next	=	state 	;
	DONE :		next 	=	IDLE 	;
	default:	next	=	IDLE	;
	endcase
	end	

always	@(posedge clk or negedge rst_n)
	if (~rst_n)
		huffbuf		<=	8'h0	;
	else if (i_newcmd_dem)
		huffbuf		<=	8'h0	;
	else if (state==HUFFMAN && i_valid_dem)//�μ����ģ�飺PIE�����Ч�ź�
		huffbuf		<=	{huffbuf[6:0],i_data_dem}	; //i_valid_dem��ʱ��huffbufѭ������
		
always	@(posedge clk or negedge rst_n) //��counter����,counter�����Ѿ�decode����λ��
	if (~rst_n)
		counter		<=	'h0	;
	else if (o_Select_dec && (counter >= 'd24) && length> 8'h01 ) //��selectָ��ĵ�25λ��ʼ��������mask�Σ���������counter�ˣ���counter����24��ֵ������ȡmask
		counter		<=	counter	; 								//Ϊʲôlength��>8'h01?
	else if (o_Crypto_Comm_dec && (counter >= 'd1) && length> 8'h01 ) 
		counter		<=	counter	; 
	else if (i_valid_dem)
		counter		<=	counter + 'h1	;   //ֻҪ��i_valid_dem����һ�Σ�����1��CLK�����´�clk��counter+1
	else if (state!=next)
		counter		<=	'h0	; 				//��״̬�� ��0��ʼ����

always	@(posedge clk or negedge rst_n)//ֻ��Selectָ������� Select�еĲ���Length��Ϊ��IventoryĳЩtag population����
	if(~rst_n)
		length		<=	8'h00	;
	else if (o_Select_dec||o_Select_dec && counter >= 'd16 && counter <= 'd23 && i_valid_dem)  //EBV��8bit���ȣ���3+3+2+8=16Ϊlength֮ǰ�ĳ��ȣ�lengthΪ��17-24λ	��counter=8��d16�����Ѿ�ȡ����16λ���ڵȴ�ȡ��17λ
		length		<=	{length[6:0],i_data_dem}	;											//��counter=23Ϊȡ��24λ��counter=24�Ѿ���Maskλ�ˡ�
	else if (o_Select_dec && (counter >= 'd24) && i_valid_dem && length != 'h0) //��ߵĲ�������Mask�����ˣ����Ҫ���ϼ�1
		length		<=	length - 8'h1	;
	else if (o_Crypto_Comm_dec && counter >= 'd1 && counter <= 8'd16 && i_valid_dem) //��2-17λ��o_Crypto_Comm_dec��lengthλ
		length		<=	{length[6:0],i_data_dem}	;
	else if (o_Crypto_Comm_dec && counter > 'd18 && i_valid_dem)
		length		<=	length - 8'h1	;
	else if (state != next)
		length		<=	8'h00;
		
always	@(posedge clk or negedge rst_n)
	if (~rst_n )
		begin
		o_QueryRep_dec		<=	1'b0	;
		o_ACK_dec			<=	1'b0	;
		o_Query_dec			<=	1'b0	;
		o_QueryAdjust_dec	<=	1'b0	;
		o_NAK_dec			<=	1'b0	;
		o_ReqRN_dec			<=	1'b0	;
		o_Read_dec			<=	1'b0	;
		o_Write_dec			<=	1'b0	;
		o_TestWrite_dec		<=	1'b0	;
		o_Lock_dec			<=	1'b0	;
		o_Select_dec		<=	1'b0	;
		o_Access_dec		<=	1'b0	;
		o_TestRead_dec		<=	1'b0	;
		o_Crypto_Authenticate_dec <= 1'd0  ;//by lhzhu
		o_Crypto_En_dec  	<= 1'b0;		//by lhzhu
		o_Crypto_Comm_dec   <= 1'b0;		//by lhzhu
		end
	else if (i_newcmd_dem || i_clear_cu)
		begin
		o_QueryRep_dec		<=	1'b0	;
		o_ACK_dec			<=	1'b0	;
		o_Query_dec			<=	1'b0	;
		o_QueryAdjust_dec	<=	1'b0	;
		o_NAK_dec			<=	1'b0	;
		o_ReqRN_dec			<=	1'b0	;
		o_Read_dec			<=	1'b0	;
		o_Write_dec			<=	1'b0	;
		o_TestWrite_dec		<=	1'b0	;
		o_Lock_dec			<=	1'b0	;
		o_Select_dec		<=	1'b0	;
		o_Access_dec		<=	1'b0	;
		o_TestRead_dec		<=	1'b0	;
		o_Crypto_Authenticate_dec <= 1'd0  ;//by lhzhu
		o_Crypto_En_dec  	<= 1'b0;		//by lhzhu
		o_Crypto_Comm_dec   <= 1'b0;		//by lhzhu
		end
	else if (state==HUFFMAN) begin 
		if (counter=='h2)
			case(huffbuf[1:0])
			2'b00:		o_QueryRep_dec		<=	1'b1	;
			2'b01:		o_ACK_dec			<=	1'b1	;
			default:	;
			endcase
		else if (counter=='h4)
			case(huffbuf[3:0])
			4'b1000:	
				if (i_preamble_dem)
					o_Query_dec			<=	1'b1	;
			4'b1001:	o_QueryAdjust_dec		<=	1'b1	;	
			4'b1010:	o_Select_dec		<=	1'b1	;
			default:	;
			endcase
		else if (counter=='h8) //����ʲô״̬���������롣controlģ���������
			case(huffbuf)
			8'hc0:		o_NAK_dec			<=	1'b1	;	
			8'hc1:		o_ReqRN_dec			<=	1'b1	;	
			8'hc2:		o_Read_dec			<=	1'b1	;	
			8'hc3:		o_Write_dec			<=	1'b1	;
			8'hc5:		o_Lock_dec			<=	1'b1	;	
			8'hc6:		o_Access_dec		<=	1'b1	;
			8'hc8:		o_TestWrite_dec		<=	1'b1	;	
			8'hda:		o_TestRead_dec		<=	1'b1	;
			8'hdc:		o_Crypto_En_dec		<=	1'b1	;
			8'hdb:		o_Crypto_Authenticate_dec <=1'b1; 
			8'hdd:		o_Crypto_Comm_dec   <=	1'b1	;
			default:	;
			endcase
			else;
		end
		else;
		
always @ (*)
	cmd_name_ok	=	o_QueryRep_dec	|| o_ACK_dec	|| o_Query_dec	|| o_QueryAdjust_dec
				|| o_NAK_dec	|| o_ReqRN_dec	|| o_Read_dec	|| o_Write_dec	
				|| o_TestWrite_dec || o_Lock_dec || o_Select_dec|| o_Access_dec||o_TestRead_dec||o_Crypto_Authenticate_dec||o_Crypto_En_dec ||o_Crypto_Comm_dec	;

always @ (*)
	o_inventory_dec	=	o_Query_dec || o_QueryAdjust_dec || o_QueryRep_dec	;

always	@(posedge clk or negedge rst_n)
	if (~rst_n)
		o_cmdok_dec		<=	1'b0	; //command ok 
	else if (i_newcmd_dem || i_clear_cu)  //�յ��µ�command�����ڲ���λ�ź�
		o_cmdok_dec		<=	1'b0	;
	else if (state==DONE)
		o_cmdok_dec		<=	1'b1	; //�����������,����state=done��ʱ����һ��clk�ĸߵ�ƽ
	else
		o_cmdok_dec		<=	1'b0	;
		
always @ (*)
	if (state==DATA)
		case	(1'b1)
		o_QueryRep_dec:	
			max_bits_data	=	'd2	;
		o_Query_dec:
			max_bits_data	=	'd13	;
		o_QueryAdjust_dec:
			max_bits_data	=	'd5	;
		o_Read_dec,o_TestRead_dec:
			max_bits_data	=	'd26	;
		o_Write_dec, o_TestWrite_dec:
			max_bits_data	=	'd34	;
		o_Lock_dec	:			
			max_bits_data	=	'd20	;
		o_Select_dec :
			max_bits_data	=	'd25	;
		o_Access_dec :	
			max_bits_data	=	'd16	;
		o_Crypto_En_dec :
			max_bits_data	=	'd19	;
		o_Crypto_Comm_dec :	
			max_bits_data	=	'd19	;
		o_Crypto_Authenticate_dec:
			if(i_Crypto_Authenticate_step_cu == 2'd0)
				max_bits_data	=	'd106	;
			else if (i_Crypto_Authenticate_step_cu ==2'd1)
				max_bits_data	=	'd138	;
			else if (i_Crypto_Authenticate_step_cu ==2'd2)
				max_bits_data	=	'd266	;
			else max_bits_data 	=	'd0;
		default :
			max_bits_data 	=	'd0	;
		endcase
	else if (state ==CRC && o_Query_dec )
		max_bits_data 		=	'd5 	;
	else if (state ==CRC )
		max_bits_data 		=	'd16	;
		
	else
		max_bits_data	=	'd0	;
		/////

		/////
always @ (*)
	o_session_done	=	counter=='d8&&i_valid_dem&&o_Query_dec&&state==DATA; //query��data counter����8 ���ɲ�ѯ�����õ�sessionλ������

always	@(posedge clk or negedge rst_n)
	if (~rst_n)
		begin
		o_q_dec	<=	4'h0	;
		o_dr_dec	<=	1'b0	;
		o_m_dec	<=	2'h0	;
		o_trext_dec	<=	1'b0	;
		o_sel_dec	<=	2'b0	;
		o_session_dec<=	2'b0	;
		o_target_dec<=	1'b0	;
		o_session2_dec<=	2'b0	;
		o_Crypto_Authenticate_step_dec <=2'b0 ;
		o_CSI_dec	<=8'b0 ;
		end
	else if (o_Query_dec && state==DATA && i_valid_dem)
		begin
		if (counter=='d0)
			o_dr_dec	<=	i_data_dem		;
		else if (counter=='d1 || counter=='d2)
			o_m_dec	<=	{o_m_dec[0],i_data_dem}	;
		else if (counter=='d3)
			o_trext_dec	<=	i_data_dem		;
		else if (counter == 'd4 || counter == 'd5)
			o_sel_dec	<=	{o_sel_dec[0],i_data_dem}		;
		else if (counter == 'd6 || counter == 'd7 )
			begin	
			o_session_dec	<=	{o_session_dec[0],i_data_dem}	; // ��query��data 6/7 λȡ����Ϊ o_session_dec��������session��λ��
			end
		else if	(counter == 'd8)
			o_target_dec<=	i_data_dem		;
		else if (counter[3:0]>='d9)
			o_q_dec	<=	{o_q_dec[2:0],i_data_dem};
		end
	else if (o_QueryAdjust_dec  && state==DATA && i_valid_dem)
		begin 
		if (counter =='d2 && i_data_dem )
			o_q_dec 	<=	o_q_dec +1 		;
		else if (counter == 'd0 || counter == 'd1)
			o_session2_dec<=	{o_session2_dec[0],i_data_dem}; // ��query adjust��data 0/1 λȡ����Ϊ o_session_dec��������session��λ��
		else if (counter =='d4 && i_data_dem )
			o_q_dec 	<=	o_q_dec -1 		;
		end
	else if(o_QueryRep_dec && state == DATA&& (counter == 'd0 || counter == 'd1)&& i_valid_dem)
		o_session2_dec	<=	{o_session2_dec[0],i_data_dem};     // ��query rep��data 0/1 λȡ����Ϊ o_session_dec��������session��λ��
	else if(o_Crypto_Authenticate_dec && state == DATA && (counter <= 'd1) && i_valid_dem )
				o_Crypto_Authenticate_step_dec	<=	{o_Crypto_Authenticate_step_dec[0],i_data_dem}; 
	else if (o_Crypto_Authenticate_dec && state == DATA&& (counter >= 'd2 ) && (counter <= 'd9 )&& i_valid_dem)
				o_CSI_dec <= {o_CSI_dec[6:0],i_data_dem} ;
	else;
	
always @(posedge clk or negedge rst_n)
	if(~rst_n)
		o_ebv_flag_dec	<=	1'b0	;
	else if((o_Write_dec ||o_Read_dec ||o_TestRead_dec ||o_TestWrite_dec ) && state ==DATA &&counter=='d2&& i_data_dem) //ֻ�е�=1��ʱ����λ��չΪ1ʱ������EBV����
		o_ebv_flag_dec	<=	1'b1	; //counter��2��ʱ��,�Ѿ���ȡ��bank��Ϣ��׼��������λ����ʱo_ebv_flag_dec=1'b1����ʾ�ѽ���EBV��ʽ
	 else if(i_newcmd_dem)//~(o_Write_dec ||o_Read_dec ||o_TestRead_dec ||o_TestWrite_dec ) )
		o_ebv_flag_dec	<=	1'b0	;

always @ (*)
	if(o_Access_dec && state == DATA)
		o_access_shift_dec	=	i_valid_dem		;
	else 
		o_access_shift_dec	=	1'b0			;

always @ (*)
	if(o_Lock_dec && state ==  DATA && counter <'d20 )
		o_Lock_payload_dec	=	i_valid_dem		;
	else
		o_Lock_payload_dec	=	1'b0			;
always @ (*)
	if (o_Select_dec && state == DATA && counter > 'd15 && counter < 'd24 ) //
		o_length_shift_dec	=	i_valid_dem		;
	else 
		o_length_shift_dec	=	1'b0			;

always @ (*) 
	if(o_Select_dec && state == DATA && counter == 'd24 && length >0) //selectָ���mask shift�ź�
		o_mask_shift_dec 	=	i_valid_dem			;
	else	
		o_mask_shift_dec	=	1'b0			;
always @ (*)
	if (o_Select_dec && state == DATA && counter < 'd6) //
		o_targetaction_shift_dec	=	i_valid_dem		;
	else	
		o_targetaction_shift_dec	=	1'b0		;

always @ (*) 
	if (o_ebv_flag_dec && (o_Write_dec ||o_Read_dec ||o_TestRead_dec ||o_TestWrite_dec ) && state ==DATA &&((counter <'d2)|| (counter >'d2&&counter< 'd18)&&(counter != 'd10 )))//��������3λ�Լ���11λ������λ����EBV����չλ,����֮
		o_addr_shift_dec	=	i_valid_dem 	;
	else if (~o_ebv_flag_dec&&(o_Write_dec ||o_Read_dec ||o_TestRead_dec ||o_TestWrite_dec ) && state ==DATA &&((counter <'d2) || (counter >'d2&&counter< 'd10) ))//��������3λ,û�еڶ��ε���չλ
		o_addr_shift_dec	=	i_valid_dem 	;
	else if(o_Select_dec && state == DATA && counter >'d5 && counter <'d12)
		o_addr_shift_dec	=	i_valid_dem 	;
	else 
		o_addr_shift_dec 	=	1'b0 			;

always @ (*) 
	if (o_ebv_flag_dec&&(o_Read_dec ||o_TestRead_dec) &&state ==DATA && (counter >'d17 && counter <'d26)) //Wordcount for read
		o_wcnt_shift_dec	=	i_valid_dem 	;
	else if (~o_ebv_flag_dec&&(o_Read_dec ||o_TestRead_dec) &&state ==DATA && (counter >'d9 && counter <'d18))
		o_wcnt_shift_dec	=	i_valid_dem 	;
	else 
		o_wcnt_shift_dec 	=	1'b0 			;
		
always @ (*) 
	if (o_ebv_flag_dec&&( (o_Write_dec ||o_TestWrite_dec ) &&state ==DATA && (counter >'d17 && counter <'d34)))
		o_data_shift_dec	=	i_valid_dem 	;
	else if (~o_ebv_flag_dec&&((o_Write_dec ||o_TestWrite_dec ) &&state ==DATA && (counter >'d9 && counter <'d26)))
		o_data_shift_dec	=	i_valid_dem 	;
	else 
		o_data_shift_dec  	=	1'b0 			;			
	
	
always @ (*)
	if (i_valid_dem )
		o_data_dec		=	i_data_dem 	;
	else
		o_data_dec 		=	1'b0			;

always 	@(posedge clk or negedge rst_n ) //handle����λ����
	if (~rst_n )
		o_handle_dec	<=	16'h0 			;
	else if (state ==HANDLE && i_valid_dem )
		o_handle_dec 	<=	{o_handle_dec [14:0], i_data_dem }	;


		
 //-------------for bimod Tag, by lhzhu
 
 always @ (*)
	if(o_Crypto_En_dec && state == DATA && counter <='d15)
		begin
		o_Crypto_En_shift_dec	 <=	i_valid_dem		;    //
		o_Crypto_En_shift_ok_dec <= (counter == 'd16) ;
		end
	else begin
		o_Crypto_En_shift_dec	 <=	1'b0			;
		o_Crypto_En_shift_ok_dec <=  1'b0			;
		end
 
 //-------------for authentication control, by lhzhu-------------
always @ (*)
	if (state ==DATA && o_Crypto_Authenticate_dec && counter >= 'd10)
		begin 
		o_Crypto_Authenticate_shift_dec <= i_valid_dem;  // authenticate �½����������Ч�ź�
		o_Crypto_Authenticate_ok_dec    <= counter == max_bits_data ;
		end
	else begin
		o_Crypto_Authenticate_shift_dec 	<=	1'b0 	;
		o_Crypto_Authenticate_ok_dec 	<=	1'b0 	;
	end

endmodule 