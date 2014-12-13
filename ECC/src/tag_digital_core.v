/////////////////////////////////////////////////////////////////////////////////////
//FILE:         tag_digital_core.v
//TITLE:        the top module of tag DBB
//AUTHOR:       xshen
//DATA:         Nov.21,2010
//COPYRIGHT:    Fudan Auto-ID Lab
//DESCRIPTION:  Glue logic removed, only wires an moudules reserved
//REVISION:     1.1
/////////////////////////////////////////////////////////////////////////////////////

`timescale 1ns/100ps
module tag_digital_core	(
	input			clk			,
	input			rst_n		,
	input			i_pie		,
	//--------tfrom rom---------//
	input	[15:0]	i_Q_rom 	,
	//----------------------//
	input   		TEST 		,
	input   		SET 		,
	output			o_mod 		,
	//--------to rom---------//
	output			o_clk_rom 	,
	output	[6:0] 	o_A_rom 	,
	output			o_CEN_rom
	//----------------------//
	);
	
	// wires for demodulate module          	 
	wire			data_dem		;
	wire			valid_dem		;
	wire			newcmd_dem		;
	wire			preamble_dem	;
	wire	[5:0]	tpri_dem		;
	wire 	[8:0]	t1_dem			;
	wire 			t1_start_dem	;
	                                        	
	// wires for decode module        
	wire			Query_dec		;
	wire			QueryRep_dec	;
	wire			QueryAdjust_dec	;
	wire			ACK_dec			;
	wire			ReqRN_dec		;
	wire			Read_dec		;
	wire			Write_dec		;
	wire			TestWrite_dec	;
	wire      		TestRead_dec	;
	wire			inventory_dec	;
	wire			Lock_dec		;
	wire			Select_dec		;
	wire			cmdok_dec		;
	wire 			addr_shift_dec	;
	wire 			data_shift_dec	;
	wire 			wcnt_shift_dec	;
	wire			length_shift_dec;
	wire			mask_shift_dec	;
	wire			targetaction_shift_dec	;
	wire			Lock_payload_dec		;
	wire      		data_dec             	;
	wire	[1:0]	sel_dec					;
	wire	[1:0]	session_dec				;
	wire			target_dec				;
	wire			session_done			;
	wire	[1:0]	session2_dec			;
	wire			Access_dec				;
	wire			access_shift_dec	;
	wire			dr_dec		;
	wire	[15:0]	handle_dec		;
	wire	[3:0]	q_dec			;
	wire	[1:0]	m_dec			;
	wire			trext_dec		;

	wire	 		ebv_flag_dec				;
	wire		 	Authenticate_dec	;
	wire	 		Authenticate_shift_dec	;
	wire	 		Authenticate_ok_dec	;
	wire 	[7:0]	AuthParam_dec;
	wire	[15:0]	Address_dec;
	wire	[7:0]	csi_dec		;
	
	
	// wires for random generator          	
	wire			sromd_in_rng		;
	wire	[15:0]	random_rng		;
	wire			slotz_rng		;
	wire			seed_in_rng			;
	// wires for crc module
	wire 	[15:0]	data_out_crc		;
	wire      		reload_crc  ;
	wire      		valid_crc   ;
	wire      		data_in_crc ;
	wire 			shift_crc		;

	// wires for outctrl unit
	wire 			datarate_ocu		;
	wire 			back_rom_ocu		;
	wire 			data_ocu		;
	wire 			crcen_ocu		;
	wire 			reload_ocu		;
	wire			done_ocu		;
	wire			shiftaddr_ocu	;
	
	// wires for modulate unit
	wire 			en2blf_mod		;
	wire 			enable_mod		;
	wire 			mblf_mod		;
	wire 			violate_mod		;

  // wires for romprom interface
	wire			rd_rom			;
	wire			wr_rom			;
	wire	[6:0]		addr_rom			;
	wire	[7:0]		wordcnt_rom		;
	wire	[15:0]		data_rom_16bits		;
	wire			fifo_full_rom		;
	wire			done_rom		;

	// wires for ECC ctrl
	
	wire done_key;
	wire load_key;
	wire load_state;
	wire start_ECC;
	wire [175:0] key;
	wire [175:0] ecc_outxa;
	wire [175:0] ecc_outza;
	
	wire [162:0] basepoint;
	// wires for ECC core                   	
	wire done_ECC;
    wire ecc_done_init;
	// other GPRs
	wire			clear_cu		;
	wire 			newSlot_cu		;
	wire 			decSlot_cu		;
	wire 			key_shift_cu	;
	wire	[15:0]		handle_cu			;
	wire 	[15:0]		random_cu			;
	wire			payload_valid_cu		;
	wire     		 time_up ;
	wire [1:0]		Authenticate_step_cu ;
	
	// wires for gated clock
	wire 		clk_rom		;
	wire 		clk_dem		;
	wire 		clk_aes		;
	wire 		clk_act		;
	wire 		clk_mod		;
	wire 		clk_ocu		;
	wire 		clk_crc		;
    wire		clk_rng		;
	
	assign		o_clk_rom = clk_rom	;
			
control CU (
	.clk	(clk),
	.rst_n	(rst_n),
	.SET (SET) ,
	.i_tpri_dem	(tpri_dem),
	.i_newcmd_dem	(newcmd_dem),
	.i_valid_dem   (valid_dem),
	.i_data_dem    (data_dem),
	.i_t1_dem		(t1_dem),
	.i_t1_start_dem	(t1_start_dem),
	.i_Query_dec	(Query_dec),
	.i_QueryAdjust_dec	(QueryAdjust_dec),
	.i_QueryRep_dec	(QueryRep_dec),
	.i_ACK_dec	(ACK_dec),
	.i_ReqRN_dec	(ReqRN_dec),
	.i_Read_dec	(Read_dec),
	.i_Write_dec	(Write_dec),
	.i_TestWrite_dec	(TestWrite_dec),
	.i_TestRead_dec	(TestRead_dec),
	.i_inventory_dec	(inventory_dec),
	.i_Lock_dec	(Lock_dec),
	.i_Select_dec	(Select_dec),
	.i_Access_dec	(Access_dec),
	.i_cmdok_dec	(cmdok_dec),
	.i_handle_dec	(handle_dec),
	.i_m_dec		(m_dec),
	.i_ebv_flag_dec	(ebv_flag_dec),
	.i_addr_shift_dec	(addr_shift_dec),
	.i_data_shift_dec	(data_shift_dec),
	.i_wcnt_shift_dec	(wcnt_shift_dec),
	.i_data_dec	(data_dec),
	.i_Lock_payload_dec	(Lock_payload_dec),
	.i_target_dec	(target_dec),
	.i_session_dec	(session_dec),
	.i_session_done	(session_done),
	.i_session2_dec	(session2_dec),
	.i_sel_dec	(sel_dec),
	.i_length_shift_dec	(length_shift_dec),
	.i_mask_shift_dec	(mask_shift_dec),
	.i_targetaction_shift_dec	(targetaction_shift_dec),
	.i_access_shift_dec	(access_shift_dec),
	.i_data_rom_16bits	(data_rom_16bits),
	.i_done_rom	(done_rom),
	//-----added by chengwu----- //
	.i_done_ECC (done_ECC),
	.i_fifo_full_rom	(fifo_full_rom),
	.i_Authenticate_ok_dec	(Authenticate_ok_dec)	,
	//-----added by lhzhu----- //
	.i_shiftaddr_ocu	(shiftaddr_ocu),
	.TEST (TEST) ,
	//-----added by lhzhu----- //
	.i_reload_ocu  (reload_ocu),
	.i_crcen_ocu  (crcen_ocu),
	.i_data_ocu  (data_ocu),
	.i_done_ocu	(done_ocu),
	.i_back_rom_ocu	(back_rom_ocu),
	.i_random_rng	(random_rng),
	.i_slotz_rng	(slotz_rng),
	.i_en_ECC(en_ECC) ,
	//-----added by chengwu----- //
	.i_Authenticate_dec (Authenticate_dec) ,
	.i_AuthParam_dec (AuthParam_dec),
	.i_Address_dec(Address_dec),
	//-----added by lhzhu----- //
	.o_addr_rom		(addr_rom),
	.o_rd_rom		(rd_rom),
	.o_wr_rom		(wr_rom),
	.o_wordcnt_rom	(wordcnt_rom),
	.o_handle_cu		(handle_cu),
	.o_random_cu		(random_cu),
	.o_decSlot_cu	(decSlot_cu),
	.o_newSlot_cu	(newSlot_cu),
	.o_clear_cu	(clear_cu),
	.o_key_shift_cu	(key_shift_cu),
	.o_payload_valid_cu (payload_valid_cu),
	.o_seed_in_rng (seed_in_rng),
	.o_datarate_ocu	(datarate_ocu),
	.o_en2blf_mod	  (en2blf_mod)  ,
	.o_reload_crc (reload_crc),
	.o_valid_crc (valid_crc),
	.o_data_in_crc (data_in_crc),
	.o_time_up   (time_up),
	//-----added by lhzhu----- //
	.o_Authenticate_step_cu (Authenticate_step_cu),
	.o_done_key(done_key),
	//-----added by lhzhu----- //
	.o_clk_rom 	(clk_rom),
	.o_clk_dem  (clk_dem),
	.o_clk_aes  (clk_aes),
	.o_clk_act  (clk_act),
	.o_clk_mod  (clk_mod),
	.o_clk_ocu  (clk_ocu),
	.o_clk_crc  (clk_crc),
	.o_clk_rng	(clk_rng)
			);


demodu DEM (
	.clk	(clk_dem),
	.rst_n	(rst_n),
	.i_pie	(i_pie) ,
	.i_dr_dec		(dr_dec),
	.o_data_dem	(data_dem),
	.o_valid_dem	(valid_dem),
	.o_newcmd_dem	(newcmd_dem),
	.o_preamble_dem (preamble_dem),
	.o_tpri_dem	(tpri_dem),
	.o_t1_dem		(t1_dem),
	.o_t1_start_dem	(t1_start_dem)
			);


decode DEC (
	.clk		(clk_dem		),
	.rst_n		(rst_n		),
	.i_valid_dem	(valid_dem	),
	.i_data_dem	(data_dem	),
	.i_newcmd_dem	(newcmd_dem	),
	.i_preamble_dem	(preamble_dem	),
	.i_clear_cu	(clear_cu	),
	
	.i_Authenticate_step_cu(Authenticate_step_cu) ,
	
	.o_Query_dec	(Query_dec	),
	.o_QueryRep_dec	(QueryRep_dec	),
	.o_QueryAdjust_dec	(QueryAdjust_dec	),
	.o_ACK_dec	(ACK_dec	),
	.o_ReqRN_dec	(ReqRN_dec	),
	.o_Read_dec	(Read_dec	),
	.o_Write_dec	(Write_dec	),
	.o_TestWrite_dec (TestWrite_dec) ,
	.o_TestRead_dec (TestRead_dec) ,
	.o_Lock_dec	(Lock_dec	),
	.o_Select_dec	(Select_dec	),
	.o_inventory_dec	(inventory_dec	),
	.o_data_dec	(data_dec	),
	.o_cmdok_dec	(cmdok_dec	),
	.o_dr_dec		(dr_dec		),
	.o_handle_dec	(handle_dec	),
	.o_Lock_payload_dec	(Lock_payload_dec	),
	.o_q_dec		(q_dec		),
	.o_m_dec		(m_dec		),
	.o_length_shift_dec	(length_shift_dec	),
	.o_mask_shift_dec	(mask_shift_dec	),
	.o_targetaction_shift_dec	(targetaction_shift_dec	),
	.o_addr_shift_dec	(addr_shift_dec	),
	.o_data_shift_dec	(data_shift_dec	),
	.o_wcnt_shift_dec	(wcnt_shift_dec	),
	.o_trext_dec	(trext_dec	),
	.o_target_dec	(target_dec	),
	.o_session_dec	(session_dec	),
	.o_session_done	(session_done	),
	.o_session2_dec	(session2_dec	),
	.o_sel_dec	(sel_dec	),
	.o_Access_dec	(Access_dec	),
	.o_access_shift_dec	(access_shift_dec	),
	.o_ebv_flag_dec (ebv_flag_dec),
	
	.o_Authenticate_dec (Authenticate_dec) ,
	.o_Authenticate_shift_dec(Authenticate_shift_dec) ,
	.o_Authenticate_ok_dec(Authenticate_ok_dec) ,
	.o_csi_dec(csi_dec),
  .o_AuthParam_dec(AuthParam_dec),
	.o_Address_dec(Address_dec)
);


random_generator RNG (
	.clk		(clk_rng		),
	.rst_n		(rst_n		) ,
	.i_q_dec		(q_dec		),
	.i_newSlot_cu	(newSlot_cu	),
	.i_decSlot_cu	(decSlot_cu	),
	.i_seed_in_rng	(seed_in_rng	),
	.i_data_rom_16bits	(data_rom_16bits	),
	.o_random_rng	(random_rng	),
	.o_slotz_rng	(slotz_rng	)
);

crc16 CRC (
	.clk		(clk_crc		),
	.rst_n		(rst_n		),
	.i_reload_crc	(reload_crc),
	.i_valid_crc	(valid_crc),
	.i_data_crc	 (data_in_crc),
	.i_shift_crc	(shift_crc),
	.o_data_crc		(data_out_crc)
);


outctrl OCU (
	.clk		(clk_ocu		),
	.rst_n		(rst_n		),
	.i_ACK_dec	(ACK_dec	),
	
	.i_Authenticate_dec (Authenticate_dec) ,
	.i_Authenticate_step_cu (Authenticate_step_cu)  ,
	.i_data_rom_16bits	(data_rom_16bits	),
	
	.i_ReqRN_dec	(ReqRN_dec	),
	.i_Read_dec	(Read_dec	),
	.i_TestRead_dec	(TestRead_dec	),
	.i_Write_dec	(Write_dec	),
	.i_TestWrite_dec	(TestWrite_dec	),
	.i_inventory_dec	(inventory_dec	),
	.i_Lock_dec	(Lock_dec	),
	.i_payload_valid_cu	(payload_valid_cu	),
	.i_wordcnt_rom	(wordcnt_rom[3:0]	),
	.i_datarate_ocu	(datarate_ocu	),
	.i_trext_dec	(trext_dec	),
	.i_m_dec		(m_dec		),
	.i_clear_cu	(clear_cu	),
	.i_handle_cu		(handle_cu		),
	.i_random_cu		(random_cu		),
	.i_data_crc	(data_out_crc	),
	//-------------added by chengwu-------------//
	.i_key(key),
	.i_ecc_outxa(ecc_outxa),
	.i_ecc_outza(ecc_outza),
	//-----------------------------------------//
	.o_data_ocu	(data_ocu	),
	.o_done_ocu	(done_ocu	),
	.o_back_rom_ocu	(back_rom_ocu	),
	.o_crcen_ocu	(crcen_ocu	),
	.o_reload_ocu	(reload_ocu	),
	.o_shift_crc	(shift_crc	),
	.o_enable_mod	(enable_mod	),
	.o_mblf_mod	(mblf_mod	),
	.o_violate_mod	(violate_mod	),
	.o_shiftaddr_ocu	(shiftaddr_ocu)
);


modulate MOD (
  .clk		(clk_mod		),
	.rst_n		(rst_n		),
	.i_data_ocu	(data_ocu	),
	.i_m_dec		(m_dec		),
	.i_enable_mod	(enable_mod	),
	.i_mblf_mod	(mblf_mod	),
	.i_violate_mod	(violate_mod	),
	.i_en2blf_mod	(en2blf_mod	),
	.i_clear_cu	(clear_cu	),
	.o_data_mod	(o_mod	)
);

rominterface romInterface (
	.clk(clk_rom),
	.rst_n(rst_n),
	.i_rd_rom(rd_rom),
	.i_wr_rom(wr_rom),
	.i_addr_rom(addr_rom),
	.i_wordcnt_rom(wordcnt_rom)	,
	.o_data_rom_16bits(data_rom_16bits)	,
	.o_fifo_full_rom(fifo_full_rom)	,	
	.o_done_rom(done_rom)	,
	.Q(i_Q_rom)		,
	.CEN(o_CEN_rom)	,
	.A(o_A_rom) 
	);

ecc_processor ECC(
	.clk		(clk_aes	),
	.rst_n		(rst_n),
	.ecc_start  (start_ECC),
	.g          (basepoint),
	.k          (key[162:0]),
	.ecc_outxa	(ecc_outxa	),
	.ecc_outza	(ecc_outza	),
	.ecc_done	(ecc_done_init	)
);


ECC_ctrl ECC_CTRL (
	.clk		(clk_act		),
	.rst_n		(rst_n		),
	.i_key_shift_cu	(key_shift_cu	),	
	.i_time_up (time_up) ,
	.i_data_rom_16bits	(data_rom_16bits	),
	.i_data_dec (data_dec) ,
	.i_done_ECC	(ecc_done_init	),
	.i_done_key (done_key),
	.i_Authenticate_step_cu	(Authenticate_step_cu)	,
	.i_Authenticate_ok_dec	(Authenticate_ok_dec)	,
	.i_Authenticate_shift_dec	(Authenticate_shift_dec)	,
	.o_start_ECC	(start_ECC	),
	.o_key		(key		),
	.o_basepoint(basepoint),
	.o_en_ECC		(en_ECC		),
	.o_done_ECC(done_ECC) 
);

endmodule
