//`include "./parameters.v"
`timescale 1ns/1ns
module ECC_ctrl(
	clk,
	rst_n,
	i_key_shift_cu,
	i_time_up,
	i_data_rom_16bits,
	i_data_dec,
	i_done_ECC,
	i_done_key,
	i_Authenticate_shift_dec,
	i_Authenticate_ok_dec,
	i_Authenticate_step_cu,
	o_start_ECC,
	o_key,
	o_basepoint,
	o_en_ECC,
	o_done_ECC
	);
	
input clk;
input rst_n;
input i_key_shift_cu;
input i_time_up;
input[15:0] i_data_rom_16bits;
input i_data_dec;

input i_done_ECC;
input i_done_key;
input i_Authenticate_shift_dec;
input i_Authenticate_ok_dec;
input[1:0] i_Authenticate_step_cu;

output o_start_ECC;
output[175:0] o_key;
output[162:0] o_basepoint;
output o_en_ECC;
output o_done_ECC;

reg[3:0] state_ECC, state_next;
parameter Idle = 4'd0;
parameter Read_authen = 4'd1;
parameter Read_key = 4'd2;
parameter Load_key = 4'd3;
parameter Start_en = 4'd4;
parameter Computing = 4'd5;
parameter Computing_finish = 4'd6;

reg[175:0] key_reg;
reg[162:0] basepoint;

always @(posedge clk or negedge rst_n)
    if (!rst_n) 
		state_ECC<=Idle;
    else	if(i_time_up) 
				state_ECC<=Idle;
			else 
				state_ECC<=state_next;

always@(*)
begin
	state_next = state_ECC;
	case(state_ECC)
	Idle:
	if(i_Authenticate_shift_dec)
		state_next=Read_authen;
	else
		state_next=state_ECC;
	
	Read_authen:
	if(		i_Authenticate_ok_dec)
			state_next = Read_key;
	else
			state_next = state_ECC;
				
	Read_key:
	if(i_done_key)
		if (i_Authenticate_step_cu == 2'd0 )
			state_next = Computing_finish;
		else if (i_Authenticate_step_cu == 2'd1 )
			state_next = Start_en;
	else
		state_next = state_ECC;
		
	Start_en:
		state_next=Computing;
		
	Computing:
		if(i_done_ECC)
			state_next=Computing_finish;
		else
			state_next=state_next;
	
	Computing_finish:
		state_next=Idle;
	default: state_next=Idle;
	endcase
end

//-------gating information for ECC module-------//
assign o_start_ECC = state_ECC==Start_en;
assign o_key = key_reg;
assign o_basepoint = basepoint;
assign o_en_ECC = state_ECC==Computing||o_start_ECC;
assign o_done_ECC = state_ECC == Computing_finish;

//-------------load the key------------------//	
always@(posedge clk or negedge rst_n)
if(!rst_n)
	key_reg <= 176'b0;
else	if(i_key_shift_cu)
			key_reg <= {key_reg[159:0],i_data_rom_16bits};
		else
			key_reg <= key_reg;
//-------------load the basepoint------------------//	
always@(posedge clk or negedge rst_n)
if(!rst_n)
	basepoint <= 163'b0;
else	if(state_ECC == Read_authen)
		case(i_Authenticate_step_cu)
		2'd1:if(i_Authenticate_shift_dec)
			basepoint <= {basepoint[161:0],i_data_dec};
		default:;
		endcase
		else;
		
		

endmodule