//Version: V1.00
//Data: 2005.10.24
//Block Information: The sub module of CLOCK RECOVERY Module for detecting the incomplete preamble
//Modification Information: Create by chlhuang

`timescale 1ns/100ps

module	pulse_cnt(clk,data,reset,Tag_data,Tag_finish,Tag_data_number);
input	clk,data,reset;
output	Tag_data_number;
output	Tag_finish;
output  [255:0] Tag_data;
reg		Tag_finish;
//
//	Port_Name	Length		Type	Function
//	clk			1 bit		input	the clock input (6.4MHz for this version)
//	data		1 bit		input	the input port which receives the signal from the upper module
//	reset		1 bit		input	the reset port
//
reg	pre_data;
reg	[15:0]	tari;
reg [15:0]  Tag_data_number;
reg	[2:0]	state;
reg	[15:0]	pre_len;
reg	[15:0]	len;
reg	[15:0]	violation;
reg	[15:0]	delta;
reg [255:0] Tag_data;
reg			next_turn;
//
//	Variation_Name	Length		Function
//	pre_data	1 bit		the reg to detect the change of PORT:data; it indicates a change in the level of PORT:data when pre_data is not equal to data
//	tari		16 bits		the reg to store the half length of the '1' symbol in FM0 code
//	state		3 bits		the FSM of the Module:PULSE_CNT
//	pre_len		16 bits		the reg to store the length of the previous PP, which could compare with the current length of PP and thus detect the valid preamble
//	len		16 bits		the reg	to store the current length of PP
//	violation	16 bits		the reg	to store the length of violation in preamble
//	delta		16 bits		the reg to store the toleration of the variation in one serial receiving data
//
parameter DELTA=16'd20;
//
//	Parameter_Name	Function
//	DELTA		the initial of the toleration of the Reg:delta
//
always	@(posedge clk)
begin
	if (reset==1'b0)
	begin
		Tag_finish <= 1'b0 ;
		Tag_data <= 256'b0;
		pre_data<=1'b0;
		tari[15:0]<=16'b0;
		state<=3'd0;
		pre_len<=16'b1;
		len<=16'b1;
		delta<=DELTA;
		violation<=16'b0;
		Tag_data_number <=16'b0;
		next_turn <= 1'b0;
	end
	//
	//	Segment Explanation:
	//	all the reg of Module:PULSE_CNT is resetted
	//
	else
	begin
		Tag_finish<=1'b0;
		len<=len+16'd1;
		pre_data<=data;
		//
		//	Segment Explanation:
		//	the Reg:len counts the length of each PP
		//	replace the Reg:pre_data with the current data
		//	if there is a level change in PORT:data, the PORT:data must be different from Reg:pre_data
		//	then the code downward could be executed
		//
		if (len==16'b0010_0000_0000_0000)
		begin
			Tag_finish<=1'b0;
			state<=3'd0;
			pre_len<=16'b1;
			len<=16'b0;
			delta<=DELTA;
			Tag_data_number <=16'b0;
		end
		//
		//	Segment Explanation:
		//	if there is a long period of time (about 1.2ms) without any level change in the PORT:data
		//	reset the FSM and all reg of Module:PULSE_CNT
		//	
		if (data!=pre_data)
		begin
			pre_len<=len;
			len<=16'b1;
			//
			//	Segment Explanation:
			//	replace the Reg:pre_len with the current len
			//	reset the Reg:len to 1 for the next count of PP
			//
			case (state)
			3'd0:	
			begin
				if ((len>=pre_len-delta) && (len<=pre_len+delta) && (pre_data==1'b1))
				begin
					state<=3'd1;
					delta<=DELTA;
				end
			end
			//
			//	Segment Explanation:
			//	the initial state of the FSM
			//	if Reg:len is equal to Reg:pre_len (within the toleration)
			//	the first pattern of the preamble is detected
			//	then change the FSM to State:3'd1
			//	if not
			//	leave the FSM unchanged
			//
			3'd1:
			begin
				if ((len>=(pre_len-delta)<<1) && (len<=(pre_len+delta)<<1))
				begin
					state<=3'd2;
				end
				else
				begin
					state<=3'd0;
				end
			end
			//
			//	Segment Explanation:
			//	if Reg:len is equal to the twice of Reg:pre_len (within the toleration)
			//	the second pattern of the preamble is detected
			//	then change the FSM to State:3'd2
			//	if not
			//	set the state back to initial state
			//
			3'd2:
			begin
				if (((len<<1)>=(pre_len-(delta<<1))) && ((len<<1)<=(pre_len+(delta<<1))))
				begin
					state<=3'd3;
				end
				else
				begin
					state<=3'd0;
				end
			end
			//
			//	Segment Explanation:
			//	if twice of REG:len is equal to REG:pre_len (within the toleration)
			//	the third pattern of the preamble is detected
			//	then change the FSM to state:3'd3
			//	if not
			//	set the state back to initial state
			//
			3'd3:
			begin
				if ((len>=3*(pre_len-delta)) && (len<= 3*(pre_len+delta)))
				begin
					state<=3'd4;
					violation<=pre_len;
				end
				else
				begin
					state<=3'd0;
				end
			end
			//
			//	Segment Explanation:
			//	if Reg:len is equal to the three times of Reg:pre_len (within the toleration)
			//	the fourth pattern of the preamble is detected
			//	then change the FSM to State:3'd4 and store the period of violation and delta for the next state's compare
			//	if not
			//	set the state back to initial state
			//
			3'd4:
			begin
				if ((len>=(violation-delta)<<1) && (len<=(violation+delta)<<1))
				begin
					tari<=len>>1;
					delta<=len>>2;
					state<=3'd5;
				end
				else
				begin
					state<=3'd0;
					delta<=DELTA;
				end
			end
			//
			//	Segment Explanation:
			//	if Reg:len is equal to the twice of Reg:pre_len (within the toleration)
			//	all parts of preamble is valided
			//	then change the FSM to State:3'd5
			//	set Reg:tari to half of the Reg:len, which indicates the difference between the FM0 symbol of '0' and '1'
			//	set Reg:delta to half of Reg:tari, which indicates the max tolerance of the FM0 symbol
			//	if PORT:data is high at that time, set the BUFFER with all '1', which could present the first negative edge of the valid data
			//	or if PORT:data is low at that time, set the BUFFER with all '0', which could also present the first rising edge of the valid data
			//	thus such kind of design is to satisfy the different phases of the signal of PORT:data
			//
			3'd5:
			begin
				if ((len>=tari-delta) && (len<=tari+delta) && (pre_data==next_turn) )
				begin
					Tag_data[255:0] <= {Tag_data[254:0],1'b0} ;
					Tag_data_number <= Tag_data_number + 1'b1;
				end
				//
				//	Segment Explanation:
				//	the PP is one part of symbol '0', which equals the tari (within the tolerance)
				//	then set the half of the len as it's clock cycle and push it into the Module:FIFO
				//
				else if ((len>=tari+tari-delta) && (len<=tari+tari+delta) && (pre_data==next_turn) )
				begin
					Tag_data[255:0] <= {Tag_data[254:0],1'b1} ;
					Tag_data_number <= Tag_data_number + 1'b1;
					next_turn <= !next_turn;
				end
				//
				//	Segment Explanation:
				//	the PP is symbol '1', which equals the twice of tari (within the tolerance)
				//	then set the quarter of the len as it's clock cycle and push it into the Module:FIFO
				//
				else;
				//
				//	Segment Explanation:
				//	if the PP is shorter than symbol '0' or longer than symbol '1'
				//	it suggests that receiving of the valid data be Tag_finished
				//	then no more clock cycle is needed
				//	so set both control0 and control1 to high level, which prevents Module:BUFFER to receive new data from the PORT:data
				//	and reset all the reg for the next time of receiving
				//
			end
			default:
			begin
				state<=3'd0;
				len<=16'd1;
			end
			endcase
		end	
		else if (state =='d5 && len >= tari+tari+delta)
			begin
				state<=3'd0;
				pre_len<=16'b1;
				delta<=DELTA;
				Tag_finish <= 1'b1;
			end
	end
end
endmodule
	
				