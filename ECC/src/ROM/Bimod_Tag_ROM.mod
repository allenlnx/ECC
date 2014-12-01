/*
 *      CONFIDENTIAL  AND  PROPRIETARY SOFTWARE OF ARTISAN COMPONENTS, INC.
 *      
 *      Copyright (c) 2012  Artisan Components, Inc.  All  Rights Reserved.
 *      
 *      Use of this Software is subject to the terms and conditions  of the
 *      applicable license agreement with Artisan Components, Inc. In addition,
 *      this Software is protected by patents, copyright law and international
 *      treaties.
 *      
 *      The copyright notice(s) in this Software does not indicate actual or
 *      intended publication of this Software.
 *      
 *      name:			High Speed/Density Diffusion ROM Generator (ROM-DIFF)
 *           			SMIC Logic013 Process
 *      version:		2005Q2V1
 *      comment:		
 *      configuration:	 -instname "Bimod_Tag_ROM" -words 128 -bits 16 -frequency 5 -ring_width 5.0 -code_file "Bimod.rom" -mux 16 -top_layer "met5-8" -power_type rings -horiz met3 -vert met4 -cust_comment "" -bus_notation on -left_bus_delim "[" -right_bus_delim "]" -pwr_gnd_rename "VDD:VDD,GND:VSS" -prefix "" -pin_space 0.0 -name_case upper -check_instname on -diodes on -inside_ring_type GND -drive 6 -corners ff_1.32_-40.0,tt_1.2_25.0,ss_1.08_125.0,ff_1.32_0.0
 *
 *      Synopsys model for Synchronous Single-Port Rom
 *
 *      Library Name:   aci
 *      Instance Name:  Bimod_Tag_ROM
 *      Words:          128
 *      Word Width:     16
 *      Mux:            16
 *
 *      Creation Date:  2012-12-16 02:17:49Z
 *      Version:        2005Q2V1
 *
 *      Verified With: Synopsys Primetime
 *
 *      Modeling Assumptions: This library contains a black box description
 *          for a memory element.  At the library level, a
 *          default_max_transition constraint is set to the maximum
 *          characterized input slew.  Each output has a max_capacitance
 *          constraint set to the highest characterized output load.
 *          Different modes are defined in order to disable false path
 *          during the specific mode activation when doing static timing analysis. 
 *
 *
 *      Modeling Limitations: This stamp does not include power information.
 *          Due to limitations of the stamp modeling, some data reduction was
 *          necessary.  When reducing data, minimum values were chosen for the
 *          fast case corner and maximum values were used for the typical and
 *          best case corners.  It is recommended that critical timing and
 *          setup and hold times be checked at all corners.
 *
 *      Known Bugs: None.
 *
 *      Known Work Arounds: N/A
 *
 */

MODEL
MODEL_VERSION "1.0";
DESIGN "Bimod_Tag_ROM";
INPUT A[6:0];
INPUT CEN;
INPUT CLK;
OUTPUT Q[15:0];
MODE mem_mode_2_A =
                        ChipEnabled_A  COND(CEN==0),
                        DMYChipEnabled_A  COND(!(CEN==0));
setup_a_A: SETUP(POSEDGE) A CLK MODE(mem_mode_2_A=ChipEnabled_A);
hold_a_A:  HOLD(POSEDGE) A CLK MODE(mem_mode_2_A=ChipEnabled_A);

setup_cen_A: SETUP(POSEDGE) CEN CLK ;
hold_cen_A:  HOLD(POSEDGE) CEN CLK ;






period_clk_0_A: PERIOD(POSEDGE) CLK;
pulsewidth_clk_h_0_A: WIDTH(POSEDGE) CLK;
pulsewidth_clk_l_0_A: WIDTH(NEGEDGE) CLK;

/* CLK->Q Delay */
dly_clk_q_0_A: DELAY(POSEDGE) CLK Q ;

ENDMODEL
