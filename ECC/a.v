`define SEND_QUERY 500
`define trext_par 1  

//----relase t1 requirement----
	`define t1_min_relax 100
	`define t1_max_relax 100000
//----relase t1 requirement----

`define reader_freq_span 156   //6.4mhz
`define tag_freq_span    521   //1.92 mhz
//`define tag_freq_span    781   //1.28 mhz
//----------------------------------------------//
// 					  Dr=0						//
//----------------------------------------------//
 `define dr_par 0


//----------------------
// Tari = 25us  (for 6.4m clk)
//	(T1:238 ~ 262 us)
//----------------------
 `define tari_par 160
 `define rtcal_par 480
 `define trcal_par 1280  
 `define t1_min 1523
 `define t1_max 1677
 `define t1_nominal 1600
 `define delimiter 80
 
//working clk 6.4M Hz
 
// trcal can not always be exact 3 times rtcal 
// see resstriction table

 
//----------------------
//  Tari = 12.5us
//----------------------
/*	`define tari_par 80
	`define rtcal_par 240
	`define trcal_par 720
	`define t1_min 845
	`define t1_max 955*/

//----------------------
//  Tari = 6.25us	
//----------------------
/* `define tari_par 40
 `define rtcal_par 120
 `define trcal_par 360
 `define t1_min 428
 `define t1_max 482*/

//----------------------------------------------//
// 					  Dr=1						//
//----------------------------------------------//
// `define dr_par 1

//----------------------
// // Tari = 25us
//----------------------
// `define tari_par 160
// `define rtcal_par 480
// `define trcal_par 1440
// `define t1_min 630
// `define t1_max 720

//----------------------
//  Tari = 12.5us
//----------------------
// `define tari_par 80
// `define rtcal_par 240
// `define trcal_par 720
// `define t1_min 309
// `define t1_max 366

//----------------------
// Tari = 6.25us
//----------------------
//`define tari_par 40
//`define rtcal_par 120
//`define trcal_par 360
//`define t1_min 149
//`define t1_max 188
