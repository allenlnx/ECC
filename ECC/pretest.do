
virtual type {
		 {5'd1 waiting}
		 {5'd2 readPC}
		 {5'd3 readCRC}
		 {5'd4 readMODE}
		 {5'd5 readKEY}
		 {5'd6 readLock}
		 {5'd7 readAccess}
		 {5'd8 InitDone}
		 {5'd9 readRom}
		 {5'd10 writeRom}
		 {5'd11 newSlot}
		 {5'd12 newQ}
		 {5'd13 checkSlot}
		 {5'd14 authen}
		 {5'd15 newHandle}
		 {5'd16 newRN}
		 {5'd17 waitT1}
		 {5'd18 BackScatter}
		 {5'd19 clearCmd}
		 {5'd20 Lock}
		 {5'd21 Compare}
		 {5'd22 UpdateID} 
		 {5'd23 readCrypto_En_psw}
		 {5'd24 readCryptoflag}
		 {5'd25 calculate}
} TASK_TAG_CU_TYPE

virtual type {
		 {4'b0000 Poweron}
		 {4'b0001 Ready}
		 {4'b0010 Arbitrate}
		 {4'b0011 Reply}
		 {4'b0100 Acknowledged}
		 {4'b0101 Open}
		 {4'b0110 Secured}
		 {4'b0111 Crypto}
} FSM_TAG_CU_TYPE

virtual type {
		 {5'b10000 IDLE}
		 {5'b10001 DELIMITER}
		 {5'b11000 TARI}
		 {5'b11001 RTCAL}
		 {5'b11010 TRCAL}
		 {5'b11011 DATA}
		 {5'b01100 T1_WAIT }
		 {5'b01101 TPRI_CAL }
		 {5'b01110 TIMEOUT }
} FSM_TAG_DEM_TYPE

virtual type {
		 {3'b000 IDLE}
		 {3'b001 HUFFMAN}
		 {3'b010 DATA}
		 {3'b011 HANDLE}
		 {3'b100 CRC}
		 {3'b101 DONE}
} FSM_TAG_DEC_TYPE

virtual type {
		 {5'd0 DONE}
		 {5'd1 IDLE}
		 {5'd16 newRN}
		 {5'd17 TwelveZ}
		 {5'd18 SixtromnZ}
		 {5'd19 LockError}
		 {5'd24 Preamble}
		 {5'd25 Header}
		 {5'd26 rom} 
		 {5'd27 Handle}
		 {5'd28 DATA}
		 {5'd29 RN}
		 {5'd30 CRC}
		 {5'd31 DUMMY}
} FSM_TAG_OCU_TYPE

virtual type {
		 {4'd0 Idle}
		 {4'd1 Read_key}
		 {4'd2 Read_authen}
		 {4'd3 Load_key}
		 {4'd4 Load_state}
		 {4'd5 Start_en}
		 {4'd6 Encry}
		 {4'd7 Read_key_c}
		 {4'd8 Comparison}
		 {4'd9 Authen_success}
} FSM_TAG_AESCTRL_TYPE
	