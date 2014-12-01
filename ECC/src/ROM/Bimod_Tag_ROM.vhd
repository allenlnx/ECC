--------------------------------------------------------------------------
--      CONFIDENTIAL  AND  PROPRIETARY SOFTWARE OF ARTISAN COMPONENTS, INC.
--      
--      Copyright (c) 2012  Artisan Components, Inc.  All  Rights Reserved.
--      
--      Use of this Software is subject to the terms and conditions  of the
--      applicable license agreement with Artisan Components, Inc. In addition,
--      this Software is protected by patents, copyright law and international
--      treaties.
--      
--      The copyright notice(s) in this Software does not indicate actual or
--      intended publication of this Software.
--      
--      name:			High Speed/Density Diffusion ROM Generator (ROM-DIFF)
--           			SMIC Logic013 Process
--      version:		2005Q2V1
--      comment:		
--      configuration:	 -instname "Bimod_Tag_ROM" -words 128 -bits 16 -frequency 5 -ring_width 5.0 -code_file "Bimod.rom" -mux 16 -top_layer "met5-8" -power_type rings -horiz met3 -vert met4 -cust_comment "" -bus_notation on -left_bus_delim "[" -right_bus_delim "]" -pwr_gnd_rename "VDD:VDD,GND:VSS" -prefix "" -pin_space 0.0 -name_case upper -check_instname on -diodes on -inside_ring_type GND -drive 6 -corners ff_1.32_-40.0,tt_1.2_25.0,ss_1.08_125.0,ff_1.32_0.0
--
--      VHDL model for Synchronous Single-Port Rom
--
--      Instance:       Bimod_Tag_ROM
--      Address Length: 128
--      Word Width:     16
--
--      Creation Date:  2012-12-16 02:17:46Z
--      Version:        2005Q2V1
--
--      Verified With:  Model Technology VCOM V-System VHDL
--			Version 5.2c
--
--      Modeling Assumptions: This model supports full gate-level simulaton
--          including proper x-handling and timing check behavior.  It is
--          VITAL_LEVEL1 compliant.  Unit delay timing is included in the
--          model. Back-annotation of SDF (v2.1) is supported.  SDF can be
--          created utilyzing the delay calculation views provided with this
--          generator and supported delay calculators.  For netlisting
--          simplicity, buses are not exploded.  All buses are modeled
--          [MSB:LSB].  To operate properly, this model must be used with the
--          Artisan's Vhdl packages.
--
--      Modeling Limitations: To be compatible with Synopsys/VSS in term of
--	    SDF back-annotation, this model has to be Vital Level0 compliant.
--	    This feature may result in degraded performances.
--
--      Known Bugs: None.
--
--      Known Work Arounds: N/A
--------------------------------------------------------------------------
LIBRARY IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_textio.all;
use IEEE.std_logic_arith.all;
use STD.TEXTIO.ALL;
use STD.TextIO;
use WORK.vlibs.all;
use IEEE.VITAL_timing.all;
use IEEE.VITAL_primitives.all;

  entity Bimod_Tag_ROM is
    generic(
        BITS : integer := 16;
        WORD_DEPTH : integer := 128;
        ADDR_WIDTH : integer := 7;
        WORDX : std_logic_vector := "XXXXXXXXXXXXXXXX";
        WORDXXX : std_logic_vector := "XXXXXXXXXXXXXXXXXX";
        WORD1 : std_logic_vector := "1111111111111111";
        ADDRX : std_logic_vector := "XXXXXXX";
        ADDR1 : std_logic_vector := "1111111";
        WEN_WIDTH : integer := 1;
        WP_SIZE : integer :=  16;
        RCOLS : integer := 0;
        MASKX : std_logic_vector := "X";
        MASK1 : std_logic_vector := "1";
        MASK0 : std_logic_vector := "0";
        MUX : integer := 16;
        MUX_TIMES_4: integer := 64;
        COL_ADDR_WIDTH : integer := 4;
        RROWS : integer := 0;
        UPM_WIDTH : integer := 3;
        UPM0 : std_logic_vector := "000";
        RCA_WIDTH : integer := 1;
        RED_COLUMNS : integer := 2;

	tipd_CLK: VitalDelayType01:=(0.000 ns, 0.000 ns);
	tipd_CEN: VitalDelayType01:=(0.000 ns, 0.000 ns);
	tipd_A: VitalDelayArrayType01(6 downto 0):=(others=>(0.000 ns, 0.000 ns));
	tisd_CEN_CLK: VitalDelayType:=0.000 ns;
	tisd_A0_CLK: VitalDelayType:=0.000 ns;
	tisd_A1_CLK: VitalDelayType:=0.000 ns;
	tisd_A2_CLK: VitalDelayType:=0.000 ns;
	tisd_A3_CLK: VitalDelayType:=0.000 ns;
	tisd_A4_CLK: VitalDelayType:=0.000 ns;
	tisd_A5_CLK: VitalDelayType:=0.000 ns;
	tisd_A6_CLK: VitalDelayType:=0.000 ns;
	tperiod_CLK  : VitalDelayType := 3.000 ns;
	tpw_CLK_negedge: VitalDelayType := 1.000 ns;
	tpw_CLK_posedge: VitalDelayType := 1.000 ns;
	ticd_CLK: VitalDelayType:=0.000 ns;
	tsetup_CEN_CLK_posedge_posedge: VitalDelayType:=1.000 ns;
	tsetup_CEN_CLK_negedge_posedge: VitalDelayType:=1.000 ns;
	tsetup_A_CLK_posedge_posedge: VitalDelayArrayType(6 downto 0):=(others=>(1.000 ns));
	tsetup_A_CLK_negedge_posedge: VitalDelayArrayType(6 downto 0):=(others=>(1.000 ns));
	thold_CEN_CLK_posedge_posedge: VitalDelayType:=0.500 ns;
	thold_CEN_CLK_negedge_posedge: VitalDelayType:=0.500 ns;
	thold_A_CLK_posedge_posedge: VitalDelayArrayType(6 downto 0):=(others=>(0.500 ns));
	thold_A_CLK_negedge_posedge: VitalDelayArrayType(6 downto 0):=(others=>(0.500 ns));
	tpd_CLK_Q: VitalDelayArrayType01(15 downto 0) := (others => (1.000 ns, 1.000 ns));

        XOn : Boolean := TRUE;
        MsgOn : Boolean := TRUE;
        MsgSeverity : SEVERITY_LEVEL := WARNING;
        InstancePath : STRING := "*";
	NO_SDTC: BOOLEAN := FALSE;
	TimingChecksOn: BOOLEAN := TRUE
    );
    port ( 
	Q: out std_logic_vector(15 downto 0);
	CLK: in std_logic;
	CEN: in std_logic;
	A: in std_logic_vector(6 downto 0)
    );
    attribute VITAL_LEVEL0 of Bimod_Tag_ROM : entity is TRUE;
end Bimod_Tag_ROM;

-----------------------------------------------------------------------------
architecture Behavioral of Bimod_Tag_ROM is
 attribute VITAL_LEVEL0 of behavioral : architecture is TRUE;
        subtype MEM_BITS is integer range 17 downto 0;
        subtype MEM_WORDS is integer range 127 downto 0;
        subtype ROW_WORDS is integer range 63 downto 0;
        subtype MEM_WORD is std_logic_vector(MEM_BITS);
        type MEM_TYPE is array(MEM_WORDS) of MEM_WORD;
        type ROW_TYPE is array(ROW_WORDS) of MEM_WORD;
        signal CLK_ipd :std_logic;
        signal CLK_dly :std_logic;
        signal CEN_ipd :std_logic;
        signal CEN_dly :std_logic;
        signal A_ipd :std_logic_vector(6 downto 0);
        signal A_dly :std_logic_vector(6 downto 0);
        signal WEN_dly : std_logic := '1';
        signal WEN_dlyb : std_logic_vector(0 downto 0) := (others => '1');
        signal D_dly : std_logic_vector(BITS-1 downto 0) := (others => '1');
        signal TD_dly : std_logic_vector(BITS-1 downto 0) := (others => '1');
        signal TA_dly : std_logic_vector(ADDR_WIDTH-1 downto 0) := (others => '1');
        signal TCEN_dly : std_logic := '0';
        signal TEN_dly : std_logic := '1';
        signal BEN_dly : std_logic := '1';
        signal TWEN_dlyb : std_logic_vector(0 downto 0) := (others => '0');
        signal EMA_dly : std_logic_vector(1 downto 0) := (others => '0');
        signal ARTN_dly : std_logic := '0';
        signal CREN_dly: std_logic_vector(BITS-1 downto 0):= (others => '1');
        signal RCA_dly : std_logic := '1';
        signal RREN_dly : std_logic := '1';
        signal RRA_dly : std_logic := '1';
        signal tisd_A_CLK : VitalDelayArrayType(ADDR_WIDTH-1 downto 0) := (
                  tisd_A6_CLK,
                  tisd_A5_CLK,
                  tisd_A4_CLK,
                  tisd_A3_CLK,
                  tisd_A2_CLK,
                  tisd_A1_CLK,
                  tisd_A0_CLK);

Begin
WIREDELAY : BLOCK
BEGIN
          VitalWireDelay( CEN_ipd, CEN, tipd_CEN );
          VitalWireDelay( CLK_ipd, CLK, tipd_CLK );

         Aipd : FOR i IN A'range GENERATE
          VitalWireDelay (A_ipd(i), A(i), tipd_A(i));
         END GENERATE Aipd;

         Dipd : FOR i IN BITS-1 downto 0 GENERATE
         END GENERATE Dipd;



END BLOCK;

SIGNALDELAY : BLOCK
BEGIN
          VitalSignalDelay( CEN_dly, CEN_ipd, tisd_CEN_CLK );
          VitalSignalDelay( CLK_dly, CLK_ipd, ticd_CLK );


         A_Delay : FOR i IN A_dly'range GENERATE
           VitalSignalDelay (A_dly(i), A_ipd(i), tisd_A_CLK(i));
         END GENERATE A_Delay;

         D_Delay : FOR i IN BITS-1 downto 0 GENERATE
         END GENERATE D_Delay;

END BLOCK;


PROCESS( 
         CLK_dly, CEN_dly, WEN_dly, A_dly, 
         D_dly) 

--- Memory declaration
  variable MEM: MEM_TYPE;
  variable ROWS: ROW_TYPE;
  variable LAST_STATUS: ROW_TYPE;


   variable LATCHED_CEN: std_logic;
   variable LATCHED_A: std_logic_vector(ADDR_WIDTH-1 downto 0);

  variable CLK_INT : std_logic := '0';
  variable RdA, WrA : std_logic:='0';
  variable AddIA  : std_logic_vector (ADDR_WIDTH-1 downto 0) ;
  variable DataIA  : std_logic_vector (BITS-1 downto 0) ;
  variable ValidDummyPinsA : std_ulogic;
  variable XlsbA : std_ulogic;
  variable CheckData0: Boolean := False;
  variable CheckTData0: Boolean := False;

  variable WENVio : std_logic := '0';
  variable TWENVio : std_logic := '0';
  variable Qi: std_logic_vector(BITS-1 downto 0);
  variable Qout: std_logic_vector(BITS-1 downto 0);
  variable dummy_qb: std_logic_vector(BITS-1 downto 0);
  variable CLKViol : X01 := '0';
  variable CENViol : X01 := '0';
  variable WENViol : X01 := '0';
  variable WENViolation : X01 := '0';
  variable DViol : X01ArrayT(BITS-1 downto 0) := (others => '0');
  variable AViol : X01ArrayT(ADDR_WIDTH-1 downto 0) := (others => '0');
  variable DVio : std_logic_vector(BITS-1 downto 0) := (others => '0');
  variable AVio : std_logic_vector(ADDR_WIDTH-1 downto 0) := (others => '0');
  variable EMAVio : std_logic_vector(2 downto 0) := (others => '0');
  variable TENViol : X01 := '0';
  variable TCENViol : X01 := '0';
  variable TWENViol : X01 := '0';
  variable TWENViolation : X01 := '0';
  variable TDViol : X01ArrayT(BITS-1 downto 0) := (others => '0');
  variable TAViol : X01ArrayT(ADDR_WIDTH-1 downto 0) := (others => '0');
  variable TDVio : std_logic_vector(BITS-1 downto 0) := (others => '0');
  variable TAVio : std_logic_vector(ADDR_WIDTH-1 downto 0) := (others => '0');
  variable CRENViol : X01ArrayT(BITS-1 downto 0) := (others => '0');
  variable CRENVio :  std_logic_vector(BITS-1 downto 0) := (others => '0');
  variable RCAViol : X01 := '0';
  variable ARTNViol : X01 := '0';
  variable RRENViol : X01 := '0';
  variable RRAViol : X01 := '0';
  variable LAST_CLK : X01 := '0';
  variable valid_cycle : std_logic_vector(WEN_WIDTH-1 downto 0);

  variable PeriodCheckInfo_CLK : VitalPeriodDataType;
  variable TimingDataInfo_CEN_CLK : VitalTimingDataType;
  variable TimingDataInfo_WEN_CLK : VitalTimingDataType := VitalTimingDataInit;
  variable TimingDataInfo_TWEN_CLK : VitalTimingDataType := VitalTimingDataInit;
  variable TimingDataInfo_D_CLK0 : VitalTimingDataType := VitalTimingDataInit;
  variable TimingDataInfo_CREN_CLK0 : VitalTimingDataType := VitalTimingDataInit;
  variable TimingDataInfo_TD_CLK0 : VitalTimingDataType := VitalTimingDataInit;
  variable TimingDataInfo_TQ_CLK0 : VitalTimingDataType := VitalTimingDataInit;
  variable TimingDataInfo_D_CLK1 : VitalTimingDataType := VitalTimingDataInit;
  variable TimingDataInfo_CREN_CLK1 : VitalTimingDataType := VitalTimingDataInit;
  variable TimingDataInfo_TD_CLK1 : VitalTimingDataType := VitalTimingDataInit;
  variable TimingDataInfo_TQ_CLK1 : VitalTimingDataType := VitalTimingDataInit;
  variable TimingDataInfo_D_CLK2 : VitalTimingDataType := VitalTimingDataInit;
  variable TimingDataInfo_CREN_CLK2 : VitalTimingDataType := VitalTimingDataInit;
  variable TimingDataInfo_TD_CLK2 : VitalTimingDataType := VitalTimingDataInit;
  variable TimingDataInfo_TQ_CLK2 : VitalTimingDataType := VitalTimingDataInit;
  variable TimingDataInfo_D_CLK3 : VitalTimingDataType := VitalTimingDataInit;
  variable TimingDataInfo_CREN_CLK3 : VitalTimingDataType := VitalTimingDataInit;
  variable TimingDataInfo_TD_CLK3 : VitalTimingDataType := VitalTimingDataInit;
  variable TimingDataInfo_TQ_CLK3 : VitalTimingDataType := VitalTimingDataInit;
  variable TimingDataInfo_D_CLK4 : VitalTimingDataType := VitalTimingDataInit;
  variable TimingDataInfo_CREN_CLK4 : VitalTimingDataType := VitalTimingDataInit;
  variable TimingDataInfo_TD_CLK4 : VitalTimingDataType := VitalTimingDataInit;
  variable TimingDataInfo_TQ_CLK4 : VitalTimingDataType := VitalTimingDataInit;
  variable TimingDataInfo_D_CLK5 : VitalTimingDataType := VitalTimingDataInit;
  variable TimingDataInfo_CREN_CLK5 : VitalTimingDataType := VitalTimingDataInit;
  variable TimingDataInfo_TD_CLK5 : VitalTimingDataType := VitalTimingDataInit;
  variable TimingDataInfo_TQ_CLK5 : VitalTimingDataType := VitalTimingDataInit;
  variable TimingDataInfo_D_CLK6 : VitalTimingDataType := VitalTimingDataInit;
  variable TimingDataInfo_CREN_CLK6 : VitalTimingDataType := VitalTimingDataInit;
  variable TimingDataInfo_TD_CLK6 : VitalTimingDataType := VitalTimingDataInit;
  variable TimingDataInfo_TQ_CLK6 : VitalTimingDataType := VitalTimingDataInit;
  variable TimingDataInfo_D_CLK7 : VitalTimingDataType := VitalTimingDataInit;
  variable TimingDataInfo_CREN_CLK7 : VitalTimingDataType := VitalTimingDataInit;
  variable TimingDataInfo_TD_CLK7 : VitalTimingDataType := VitalTimingDataInit;
  variable TimingDataInfo_TQ_CLK7 : VitalTimingDataType := VitalTimingDataInit;
  variable TimingDataInfo_D_CLK8 : VitalTimingDataType := VitalTimingDataInit;
  variable TimingDataInfo_CREN_CLK8 : VitalTimingDataType := VitalTimingDataInit;
  variable TimingDataInfo_TD_CLK8 : VitalTimingDataType := VitalTimingDataInit;
  variable TimingDataInfo_TQ_CLK8 : VitalTimingDataType := VitalTimingDataInit;
  variable TimingDataInfo_D_CLK9 : VitalTimingDataType := VitalTimingDataInit;
  variable TimingDataInfo_CREN_CLK9 : VitalTimingDataType := VitalTimingDataInit;
  variable TimingDataInfo_TD_CLK9 : VitalTimingDataType := VitalTimingDataInit;
  variable TimingDataInfo_TQ_CLK9 : VitalTimingDataType := VitalTimingDataInit;
  variable TimingDataInfo_D_CLK10 : VitalTimingDataType := VitalTimingDataInit;
  variable TimingDataInfo_CREN_CLK10 : VitalTimingDataType := VitalTimingDataInit;
  variable TimingDataInfo_TD_CLK10 : VitalTimingDataType := VitalTimingDataInit;
  variable TimingDataInfo_TQ_CLK10 : VitalTimingDataType := VitalTimingDataInit;
  variable TimingDataInfo_D_CLK11 : VitalTimingDataType := VitalTimingDataInit;
  variable TimingDataInfo_CREN_CLK11 : VitalTimingDataType := VitalTimingDataInit;
  variable TimingDataInfo_TD_CLK11 : VitalTimingDataType := VitalTimingDataInit;
  variable TimingDataInfo_TQ_CLK11 : VitalTimingDataType := VitalTimingDataInit;
  variable TimingDataInfo_D_CLK12 : VitalTimingDataType := VitalTimingDataInit;
  variable TimingDataInfo_CREN_CLK12 : VitalTimingDataType := VitalTimingDataInit;
  variable TimingDataInfo_TD_CLK12 : VitalTimingDataType := VitalTimingDataInit;
  variable TimingDataInfo_TQ_CLK12 : VitalTimingDataType := VitalTimingDataInit;
  variable TimingDataInfo_D_CLK13 : VitalTimingDataType := VitalTimingDataInit;
  variable TimingDataInfo_CREN_CLK13 : VitalTimingDataType := VitalTimingDataInit;
  variable TimingDataInfo_TD_CLK13 : VitalTimingDataType := VitalTimingDataInit;
  variable TimingDataInfo_TQ_CLK13 : VitalTimingDataType := VitalTimingDataInit;
  variable TimingDataInfo_D_CLK14 : VitalTimingDataType := VitalTimingDataInit;
  variable TimingDataInfo_CREN_CLK14 : VitalTimingDataType := VitalTimingDataInit;
  variable TimingDataInfo_TD_CLK14 : VitalTimingDataType := VitalTimingDataInit;
  variable TimingDataInfo_TQ_CLK14 : VitalTimingDataType := VitalTimingDataInit;
  variable TimingDataInfo_D_CLK15 : VitalTimingDataType := VitalTimingDataInit;
  variable TimingDataInfo_CREN_CLK15 : VitalTimingDataType := VitalTimingDataInit;
  variable TimingDataInfo_TD_CLK15 : VitalTimingDataType := VitalTimingDataInit;
  variable TimingDataInfo_TQ_CLK15 : VitalTimingDataType := VitalTimingDataInit;
  variable TimingDataInfo_A_CLK0 : VitalTimingDataType := VitalTimingDataInit;
  variable TimingDataInfo_TA_CLK0 : VitalTimingDataType := VitalTimingDataInit;
  variable TimingDataInfo_A_CLK1 : VitalTimingDataType := VitalTimingDataInit;
  variable TimingDataInfo_TA_CLK1 : VitalTimingDataType := VitalTimingDataInit;
  variable TimingDataInfo_A_CLK2 : VitalTimingDataType := VitalTimingDataInit;
  variable TimingDataInfo_TA_CLK2 : VitalTimingDataType := VitalTimingDataInit;
  variable TimingDataInfo_A_CLK3 : VitalTimingDataType := VitalTimingDataInit;
  variable TimingDataInfo_TA_CLK3 : VitalTimingDataType := VitalTimingDataInit;
  variable TimingDataInfo_A_CLK4 : VitalTimingDataType := VitalTimingDataInit;
  variable TimingDataInfo_TA_CLK4 : VitalTimingDataType := VitalTimingDataInit;
  variable TimingDataInfo_A_CLK5 : VitalTimingDataType := VitalTimingDataInit;
  variable TimingDataInfo_TA_CLK5 : VitalTimingDataType := VitalTimingDataInit;
  variable TimingDataInfo_A_CLK6 : VitalTimingDataType := VitalTimingDataInit;
  variable TimingDataInfo_TA_CLK6 : VitalTimingDataType := VitalTimingDataInit;
  variable TimingDataInfo_TCEN_CLK : VitalTimingDataType;
  variable TimingDataInfo_ARTN_CLK : VitalTimingDataType;
  variable TimingDataInfo_RREN_CLK : VitalTimingDataType;
  variable TimingDataInfo_RRA_CLK : VitalTimingDataType;
  variable TimingDataInfo_TEN_CLK : VitalTimingDataType;
  variable TimingDataInfo_BEN_CLK : VitalTimingDataType;
  variable TimingDataInfo_RCA_CLK : VitalTimingDataType;

  variable Qo : std_logic_vector(BITS-1 downto 0);
  variable DY_zd : std_logic_vector(BITS-1 downto 0);
  variable AY_zd : std_logic_vector(ADDR_WIDTH-1 downto 0);
  variable CENY_zd : std_ulogic;
  variable CENY_GlitchData : VitalGlitchDataType;
  variable WENY_GlitchData : VitalGlitchDataType;
  variable Q0_GlitchData : VitalGlitchDataType;
  variable Q1_GlitchData : VitalGlitchDataType;
  variable Q2_GlitchData : VitalGlitchDataType;
  variable Q3_GlitchData : VitalGlitchDataType;
  variable Q4_GlitchData : VitalGlitchDataType;
  variable Q5_GlitchData : VitalGlitchDataType;
  variable Q6_GlitchData : VitalGlitchDataType;
  variable Q7_GlitchData : VitalGlitchDataType;
  variable Q8_GlitchData : VitalGlitchDataType;
  variable Q9_GlitchData : VitalGlitchDataType;
  variable Q10_GlitchData : VitalGlitchDataType;
  variable Q11_GlitchData : VitalGlitchDataType;
  variable Q12_GlitchData : VitalGlitchDataType;
  variable Q13_GlitchData : VitalGlitchDataType;
  variable Q14_GlitchData : VitalGlitchDataType;
  variable Q15_GlitchData : VitalGlitchDataType;
  variable AY0_GlitchData : VitalGlitchDataType;
  variable AY1_GlitchData : VitalGlitchDataType;
  variable AY2_GlitchData : VitalGlitchDataType;
  variable AY3_GlitchData : VitalGlitchDataType;
  variable AY4_GlitchData : VitalGlitchDataType;
  variable AY5_GlitchData : VitalGlitchDataType;
  variable AY6_GlitchData : VitalGlitchDataType;
  variable DY0_GlitchData : VitalGlitchDataType;
  variable DY1_GlitchData : VitalGlitchDataType;
  variable DY2_GlitchData : VitalGlitchDataType;
  variable DY3_GlitchData : VitalGlitchDataType;
  variable DY4_GlitchData : VitalGlitchDataType;
  variable DY5_GlitchData : VitalGlitchDataType;
  variable DY6_GlitchData : VitalGlitchDataType;
  variable DY7_GlitchData : VitalGlitchDataType;
  variable DY8_GlitchData : VitalGlitchDataType;
  variable DY9_GlitchData : VitalGlitchDataType;
  variable DY10_GlitchData : VitalGlitchDataType;
  variable DY11_GlitchData : VitalGlitchDataType;
  variable DY12_GlitchData : VitalGlitchDataType;
  variable DY13_GlitchData : VitalGlitchDataType;
  variable DY14_GlitchData : VitalGlitchDataType;
  variable DY15_GlitchData : VitalGlitchDataType;

  variable Aint : std_logic_vector(ADDR_WIDTH-1 downto 0);
  variable Dint : std_logic_vector(BITS-1 downto 0);
  variable WENint : std_logic_vector(0 downto 0);
  variable CENint : std_logic;
  variable RRENint : std_logic:='1';
  variable RRAint : std_logic:='1';
  variable ARTNint : std_logic:='1';
  variable RCAint : std_logic:='0';
  variable CRENint : std_logic_vector(BITS-1 downto 0):= (others=>'1');
  variable EMAint : std_logic_vector(2 downto 0):= (others=>'1');
 
-- add procedure and function definitions here --
function to_slv(a: in std_logic) return std_logic_vector is
   variable result: std_logic_vector(0 to 0);
begin
   result(0) := a;
   return result;
end;

function to_rr_address (bank_address: in std_logic;
                        radd: in std_logic;
                        a: in std_logic_vector;
                        size: in integer) return std_logic_vector is
   variable result: std_logic_vector(size downto 0);
begin
   if (size > 1) then
      result(size-2 downto 0) := a(size-2 downto 0);
   end if;
   result(size-1) := radd;
   result(size) := bank_address;
   return result;
end;

function bool_to_std_logic (a: in boolean) return std_logic is
begin
   if (a) then
      return '1';
   else
      return '0';
   end if;
end;


function selector (a,b,sel: in std_logic) return std_logic is
begin
   if (sel = '0') then
      return a;
   elsif (sel = '1') then
      return b;
   elsif (a = b) then
      return a;
   else
      return 'X';
   end if;
end;

function selector (a,b: in std_logic_vector; sel: in std_logic; width: in integer) return std_logic_vector is
   variable c: std_logic_vector(width downto 0);
begin
   for n in width downto 0 loop
      c(n) := selector(a(n),b(n),sel);
   end loop;
   return c;
end;

function selector (a,b: in std_logic_vector; sel: in std_logic; width: in integer; high: in integer; low: in integer) return std_logic_vector is
   variable c: std_logic_vector(width downto 0);
begin
   for n in high downto low loop
      c(n-low) := selector(a(n),b(n),sel);
   end loop;
   return c;
end;

function valid_address(a: std_logic_vector;
                       rren: std_logic;
                       radd: std_logic) return boolean is
begin
   if (rren = '1') then
      return not(is_x(a));
   elsif(rren = '0') then
      return is_x(radd) nor is_x(a(COL_ADDR_WIDTH-1 downto 0));
   else
      return False;
   end if;
end;

function shift_right (a: in std_logic_vector) return std_logic_vector is
   variable b: std_logic_vector(a'range);
begin
   for n in a'left downto 0 loop
      if (n = a'left) then
         b(n) := '0';
      else
         b(n) := a(n+1);
      end if;   
   end loop;
   return b;
end;

function valid_cren(cren: std_logic_vector) return boolean is
   variable data : std_logic_vector(cren'range);
begin
   data := cren;
   while (data(0) = '1') loop
     data := shift_right(data);
   end loop;
   if (all_0(data)) then
     return true;
   else
     return false;
   end if;
end;


procedure latch_inputs is
   begin
      LATCHED_CEN := CEN_dly;
      LATCHED_A := A_dly;
end latch_inputs;

procedure x_inputs is
   variable n : integer;
   begin
	 if (is_x(CENViol)) then  LATCHED_CEN := 'X'; end if;
         for n in 0 to ADDR_WIDTH-1 loop
            if (is_x(AViol(n))) then  LATCHED_A(n) := 'X'; end if;
	 end loop;
end x_inputs;

procedure update_status (val: in std_logic_vector;
                         portname: in std_logic) is
   variable tmpdata: std_logic_vector(17 downto 0);
   variable tmpaddr: std_logic_vector(COL_ADDR_WIDTH downto 0);
   variable n: integer;
begin
   for n in 0 to MUX-1 loop
      tmpaddr := conv_std_logic_vector(n,COL_ADDR_WIDTH+1);
      tmpaddr(COL_ADDR_WIDTH) := portname;
      tmpdata := last_status(conv_unsigned_integer(tmpaddr));
      tmpdata(BITS+RED_COLUMNS-1 downto BITS) := val(BITS+RED_COLUMNS-1 downto BITS);
      last_status(conv_unsigned_integer(tmpaddr)) := tmpdata;
   end loop;
end update_status;

procedure clear_status (portname: in std_logic) is
   variable tmpaddr: std_logic_vector(COL_ADDR_WIDTH downto 0);
   variable n: integer;
begin
   for n in 0 to MUX-1 loop
      tmpaddr := conv_std_logic_vector(n,COL_ADDR_WIDTH+1);
      tmpaddr(COL_ADDR_WIDTH) := portname;
      last_status(conv_unsigned_integer(tmpaddr)) := WORDXXX;
   end loop;
end clear_status;

procedure replace_bit_in_mem (a: in std_logic_vector;	 
                              pos: in integer;
                              data: in std_logic) is
   variable tmpdata: std_logic_vector(BITS+RED_COLUMNS-1 downto 0);
   variable tmpaddr: std_logic_vector(ADDR_WIDTH-1 downto 0);
begin
   tmpdata := mem(conv_unsigned_integer(a));
   tmpdata(pos) := data;
   mem(conv_unsigned_integer(a)) := tmpdata;
   -- copy the redundent columns to all all combinations of ymux addresses
   if (pos >= BITS) then
      for n in 0 to MUX-1 loop
         tmpaddr := conv_std_logic_vector(n,ADDR_WIDTH);
         tmpaddr(ADDR_WIDTH-1 downto COL_ADDR_WIDTH) := a(ADDR_WIDTH-1 downto COL_ADDR_WIDTH);
         tmpdata := mem(conv_unsigned_integer(tmpaddr));
         tmpdata(pos) := data;
         mem(conv_unsigned_integer(tmpaddr)) := tmpdata;
      end loop;
   end if;
end replace_bit_in_mem;

procedure replace_bit_in_rows (a: in std_logic_vector;	 
                               pos: in integer;
                               data: in std_logic;
                               radd: in std_logic;
                               bank_address: in std_logic) is
   variable tmpdata: std_logic_vector(BITS+RED_COLUMNS-1 downto 0);
   variable tmpaddr: std_logic_vector(COL_ADDR_WIDTH+1 downto 0);
begin
   tmpdata := rows(conv_unsigned_integer(to_rr_address(bank_address,radd,a,COL_ADDR_WIDTH+1)));
   tmpdata(pos) := data;
   rows(conv_unsigned_integer(to_rr_address(bank_address,radd,a,COL_ADDR_WIDTH+1))) := tmpdata;
   -- copy the redundent columns to all all combinations of ymux addresses
   if (pos >= BITS) then
      for n in 0 to MUX-1 loop
         tmpaddr := conv_std_logic_vector(n,COL_ADDR_WIDTH+2);
         tmpaddr(COL_ADDR_WIDTH) := radd;
         tmpaddr(COL_ADDR_WIDTH+1) := bank_address;
         tmpdata := rows(conv_unsigned_integer(tmpaddr));
         tmpdata(pos) := data;
         rows(conv_unsigned_integer(tmpaddr)) := tmpdata;
      end loop;
   end if;
end replace_bit_in_rows;

procedure x_mem is
   variable n: integer;
begin
   for n in WORD_DEPTH-1 downto 0 loop
      mem(n) := WORDXXX; -- add 2 bits for column redundancy
   end loop;
end x_mem;

procedure x_rows is
   variable n: integer;
begin
   for n in MUX_TIMES_4-1 downto 0 loop
      rows(n) := WORDXXX; -- add 2 bits for column redundancy
   end loop;
end x_rows;

procedure x_row (radd: in std_logic;
                 bank_address: in std_logic) is
   variable n: integer;
   variable tmpaddr: std_logic_vector(6 downto 0);
begin
   for n in MUX-1 downto 0 loop
      tmpaddr := conv_std_logic_vector(n,ADDR_WIDTH);
      tmpaddr(COL_ADDR_WIDTH) := radd;
      tmpaddr(COL_ADDR_WIDTH+1) := bank_address;
      rows(conv_unsigned_integer(tmpaddr)) := WORDXXX; -- add 2 bits for column redundancy
   end loop;
end x_row;

procedure read_mem (q: inout std_logic_vector;
                    other_q: inout std_logic_vector;
                    a: in std_logic_vector;	 
		    d: in std_logic_vector;	 
		    rren: in std_logic;
		    radd: in std_logic; 
		    cren: in std_logic_vector;
                    rca: in std_logic_vector;
                    msb: in integer;
                    lsb: in integer;
                    xout: in boolean;
                    contention: in boolean;
                    portname: in std_logic) is 
   variable tmpdata: std_logic_vector(17 downto 0);
   variable other_status: std_logic_vector(17 downto 0);
   variable status: std_logic_vector(17 downto 0);
   variable m: integer;
   variable n: integer;
begin
   if (rren = 'X') then 
      for n in lsb to msb loop q(n) := 'X'; end loop;
      x_mem;
      x_rows;
   else
      if (not(valid_address(a,rren,radd))) then
         for n in lsb to msb loop q(n) := 'X'; end loop;
      else
         if (rren = '1') then
            tmpdata := mem(conv_unsigned_integer(a));
         elsif (rren = '0') then
            tmpdata := rows(conv_unsigned_integer(to_rr_address('0',radd,a,COL_ADDR_WIDTH+1)));
         end if;
         status := last_status(conv_unsigned_integer(to_rr_address('0',portname,a,COL_ADDR_WIDTH+1)));
         other_status := last_status(conv_unsigned_integer(to_rr_address('0',not(portname),a,COL_ADDR_WIDTH+1)));
         for n in lsb to msb loop
            if (cren(n) = '1') then
               if ((other_status(n) = '0') and contention) then
                  tmpdata(n) := 'X';
                  q(n) := 'X';
               else
                  if (xout) then q(n) := 'X'; else q(n) := tmpdata(n); end if;
                  status(n) := '1';
               end if;
            elsif (cren(n) = '0') then
               if ((n = BITS-1) and (not(is_x(rca)))) then
                  if ((other_status(n+conv_unsigned_integer(rca)+1) = '0') and contention) then
                     tmpdata(n+conv_unsigned_integer(rca)+1) := 'X';
                     q(n) := 'X';
                  else
                     if (xout) then q(n) := 'X'; else q(n) := tmpdata(n+conv_unsigned_integer(rca)+1); end if;
                     status(n+conv_unsigned_integer(rca)+1) := '1';
                  end if;
               elsif ((n = BITS-1) and (is_x(rca))) then
                  for m in 0 to RED_COLUMNS-1 loop
                     if ((other_status(n+m+1) = '0') and contention) then
                        tmpdata(n+m+1) := 'X';
                     end if;
                     status(n+m+1) := '1';
                  end loop;
                  q(n) := 'X';
               else
                  if ((other_status(n+1) = '0') and contention) then
                     tmpdata(n+1) := 'X';
                     q(n) := 'X';
                  else
                     if (xout) then q(n) := 'X'; else q(n) := tmpdata(n+1); end if;
                     status(n+1) := '1';
                  end if;
               end if;
            else
               if ((n = BITS-1) and (not(is_x(rca)))) then
                  if ((other_status(n) = '0') and contention) then
                     tmpdata(n) := 'X';
                  end if;
                  if ((other_status(n+conv_unsigned_integer(rca)+1) = '0') and contention) then
                     tmpdata(n+conv_unsigned_integer(rca)+1) := 'X';
                  end if;
                  status(n) := '1';
                  status(n+conv_unsigned_integer(rca)+1) := '1';
                  q(n) := 'X';
               elsif ((n = BITS-1) and (is_x(rca))) then
                  if ((other_status(n) = '0') and contention) then
                     tmpdata(n) := 'X';
                  end if;
                  for m in 0 to RED_COLUMNS-1 loop
                     if ((other_status(n+m+1) = '0') and contention) then
                        tmpdata(n+m+1) := 'X';
                     end if;
                     status(n+m+1) := '1';
                  end loop;
                  q(n) := 'X';
               else
                  if ((other_status(n) = '0') and contention) then
                     tmpdata(n) := 'X';
                  end if;
                  if ((other_status(n+1) = '0') and contention) then
                     tmpdata(n+1) := 'X';
                  end if;
                  q(n) := 'X';
                  status(n) := '1';
                  status(n+1) := '1';
               end if;  
            end if;  
         end loop;
         if (rren = '1') then
            mem(conv_unsigned_integer(a)) := tmpdata;
         elsif (rren = '0') then
            rows(conv_unsigned_integer(to_rr_address('0',radd,a,COL_ADDR_WIDTH+1))) := tmpdata;
         end if;
         last_status(conv_unsigned_integer(to_rr_address('0',portname,a,COL_ADDR_WIDTH+1))) := status;
         -- copy the redundent columns to all all combinations of ymux addresses
         if (msb = BITS-1) then
            if (rren = '1') then
               for m in 0 to RED_COLUMNS-1 loop
                  replace_bit_in_mem(a,BITS+m,tmpdata(BITS+m));
               end loop;
            elsif (rren = '0') then
               for m in 0 to RED_COLUMNS-1 loop
                  replace_bit_in_rows(a,BITS+m,tmpdata(BITS+m),radd,'0');
               end loop;
            end if;
            update_status(status,portname);
         end if;
      end if;
   end if;
end read_mem;

procedure write_mem (other_q: inout std_logic_vector;
                     a: in std_logic_vector;	 
		     d: in std_logic_vector;	 
		     rren: in std_logic;
		     radd: in std_logic; 
		     cren: in std_logic_vector;
                     rca: in std_logic_vector;
                     msb: in integer;
                     lsb: in integer;
                     xout: in boolean;
                     contention: in boolean;
		     other_cren: in std_logic_vector;
                     portname: in std_logic) is 
   variable tmpdata: std_logic_vector(17 downto 0);
   variable other_status: std_logic_vector(17 downto 0);
   variable status: std_logic_vector(17 downto 0);
   variable tmpaddr: std_logic_vector(6 downto 0);
   variable n: integer;
begin
   if (rren = 'X') then 
      x_mem;
      x_rows;
   else
      if (not(valid_address(a,rren,radd))) then
         if (rren = '1') then
            x_mem;
         elsif (rren = '0') then
            if (is_x(radd)) and ( is_x('0') ) then
               x_rows;
            elsif (is_x(radd)) then
               x_row('0','0');
               x_row('1','0');
            elsif ( is_x('0') ) then
               x_row(radd,'0');
               x_row(radd,'1');
            else
               x_row(radd,'0');
            end if;
         end if;
      else
         if (rren = '1') then
            tmpdata := mem(conv_unsigned_integer(a));
         elsif (rren = '0') then
            tmpdata := rows(conv_unsigned_integer(to_rr_address('0',radd,a,COL_ADDR_WIDTH+1)));
         end if;
         status := last_status(conv_unsigned_integer(to_rr_address('0',portname,a,COL_ADDR_WIDTH+1)));
         other_status := last_status(conv_unsigned_integer(to_rr_address('0',not(portname),a,COL_ADDR_WIDTH+1)));
         for n in lsb to msb loop
            if (cren(n) = '1') then
               if ((other_status(n) = '0') and contention) then
                  tmpdata(n) := 'X';
               elsif ((other_status(n) = '1') and contention) then
                  tmpdata(n) := 'X';
                  if (other_cren(n) = '1') then
                     other_q(n) := 'X';
                  elsif (other_cren(n-1) = '0') then
                     other_q(n-1) := 'X';
                  end if;
               else
                  if (xout) then tmpdata(n) := 'X'; else tmpdata(n) := d(n); end if;
                  status(n) := '0';
               end if;
               if ((n < BITS-1) and (cren(n+1) = '0')) then
                  if ((other_status(n+1) = '0') and contention) then
                     tmpdata(n+1) := 'X';
                  elsif ((other_status(n+1) = '1') and contention) then
                     tmpdata(n+1) := 'X';
                     if (other_cren(n) = '0') then
                        other_q(n) := 'X';
                     elsif (other_cren(n+1) = '1') then
                        other_q(n+1) := 'X';
                     end if;
                  else
                     if (xout) then tmpdata(n+1) := 'X'; else tmpdata(n+1) := d(n); end if;
                     status(n+1) := '0';
                  end if;
               elsif ((n < BITS-1) and (cren(n+1) = 'X')) then
                  tmpdata(n+1) := 'X';
                  status(n+1) := '0';
                  if ((other_status(n+1) = '1') and contention) then
                     if (other_cren(n) = '0') then
                        other_q(n) := 'X';
                     elsif (other_cren(n+1) = '1') then
                        other_q(n+1) := 'X';
                     end if;
                  end if;
               end if;
            elsif (cren(n) = '0') then
               if ((n = BITS-1) and (not(is_x(rca)))) then
                  if ((other_status(n+conv_unsigned_integer(rca)+1) = '0') and contention) then
                     tmpdata(n+conv_unsigned_integer(rca)+1) := 'X';
                  elsif ((other_status(n+conv_unsigned_integer(rca)+1) = '1') and contention) then
                     tmpdata(n+conv_unsigned_integer(rca)+1) := 'X';
                     if (other_cren(n) = '0') then
                        other_q(n) := 'X';
                     end if;
                  else
                     if (xout) then tmpdata(n+conv_unsigned_integer(rca)+1) := 'X'; else tmpdata(n+conv_unsigned_integer(rca)+1) := d(n); end if;
                     status(n+conv_unsigned_integer(rca)+1) := '0';
                  end if;
              elsif ((n = BITS-1) and (is_x(rca))) then
                  for m in 0 to RED_COLUMNS-1 loop
                     tmpdata(n+m+1) := 'X';
                     status(n+m+1) := '0';
                     if ((other_status(n+m+1) = '1') and contention) then
                        if (other_cren(n) = '0') then
                           other_q(n) := 'X';
                        end if;
                     end if;
                  end loop;
               else
                  if ((other_status(n+1) = '0') and contention) then
                     tmpdata(n+1) := 'X';
                  elsif ((other_status(n+1) = '1') and contention) then
                     tmpdata(n+1) := 'X';
                     if (other_cren(n) = '0') then
                        other_q(n) := 'X';
                     elsif (other_cren(n+1) = '1') then
                        other_q(n+1) := 'X';
                     end if;
                  else
                     if (xout) then tmpdata(n+1) := 'X'; else tmpdata(n+1) := d(n); end if;
                     status(n+1) := '0';
                  end if;
               end if;
               if (n = 0) then
                  if ((other_status(0) = '0') and contention) then
                     tmpdata(0) := 'X';
                  elsif ((other_status(0) = '1') and contention) then
                     tmpdata(0) := 'X';
                     if (other_cren(0) = '1') then
                        other_q(0) := 'X';
                     end if;
                  else
                     if (xout) then tmpdata(0) := 'X'; else tmpdata(0) := '0'; end if;
                     status(0) := '0';
                  end if;
               end if;
            else
               if ((n = BITS-1) and (not(is_x(rca)))) then
                  tmpdata(n) := 'X';
                  tmpdata(n+conv_unsigned_integer(rca)+1) := 'X';
                  status(n) := '0';
                  status(n+conv_unsigned_integer(rca)+1) := '0';
                  if ((other_status(n) = '1') and contention) then
                     if (other_cren(n) = '1') then
                        other_q(n) := 'X';
                     elsif (other_cren(n-1) = '0') then
                        other_q(n-1) := 'X';
                     end if;
                  end if;
                  if ((other_status(n+conv_unsigned_integer(rca)+1) = '1') and contention) then
                     other_q(n) := 'X';
                  end if;
               elsif ((n = BITS-1) and (is_x(rca))) then
                  tmpdata(n) := 'X';
                  status(n) := '0';
                  for m in 0 to RED_COLUMNS-1 loop
                     tmpdata(n+m+1) := 'X';
                     status(n+m+1) := '0';
                     if ((other_status(n+m+1) = '1') and contention) then
                        other_q(n) := 'X';
                     end if;
                  end loop;
                  if ((other_status(n) = '1') and contention) then
                     if (other_cren(n) = '1') then
                        other_q(n) := 'X';
                     elsif (other_cren(n-1) = '0') then
                        other_q(n-1) := 'X';
                     end if;
                  end if;
               else
                  tmpdata(n) := 'X';
                  tmpdata(n+1) := 'X';
                  status(n) := '0';
                  status(n+1) := '0';
                  if ((other_status(n) = '1') and contention) then
                     if (other_cren(n) = '1') then
                        other_q(n) := 'X';
                     elsif (other_cren(n-1) = '0') then
                        other_q(n-1) := 'X';
                     end if;
                  end if;
                  if ((other_status(n+1) = '1') and contention) then
                     if (other_cren(n+1) = '1') then
                        other_q(n+1) := 'X';
                     elsif (other_cren(n) = '0') then
                        other_q(n) := 'X';
                     end if;
                  end if;
               end if;
            end if;
         end loop;
         if (rren = '1') then
            mem(conv_unsigned_integer(a)) := tmpdata;
         elsif (rren = '0') then
            rows(conv_unsigned_integer(to_rr_address('0',radd,a,COL_ADDR_WIDTH+1))) := tmpdata;
         end if;
         last_status(conv_unsigned_integer(to_rr_address('0',portname,a,COL_ADDR_WIDTH+1))) := status;
         -- copy the redundent columns to all all combinations of ymux addresses
         if (msb = BITS-1) then
            if (rren = '1') then
               for m in 0 to RED_COLUMNS-1 loop
                  replace_bit_in_mem(a,BITS+m,tmpdata(BITS+m));
               end loop;
            elsif (rren = '0') then
               for m in 0 to RED_COLUMNS-1 loop
                  replace_bit_in_rows(a,BITS+m,tmpdata(BITS+m),radd,'0');
               end loop;
            end if;
            update_status(status,portname);
         end if;
      end if;
   end if;
end write_mem;

procedure write_thru (q: inout std_logic_vector;
                      a: in std_logic_vector;
		      d: in std_logic_vector;	 
		      rren: in std_logic;
		      radd: in std_logic; 
		      cren: in std_logic_vector;
                      rca: in std_logic_vector;
                      msb: in integer;
                      lsb: in integer;
                      xout: in boolean) is 
   variable n: integer;
begin
   if (not(is_x(cren))) then
      for n in lsb to msb loop
         if (xout) then q(n) := 'X'; else q(n) := d(n); end if;
      end loop;
   else
      for n in lsb to msb loop
         q(n) := 'X';
      end loop;
   end if;
end write_thru;

procedure mem_cycle (q: inout std_logic_vector;
                     other_q: inout std_logic_vector;
                     cen: in std_logic;
                     wen: in std_logic_vector;
                     a: in std_logic_vector;	 
		     d: in std_logic_vector;	 
		     ema: in std_logic_vector; 
		     artn: in std_logic;
		     ten: in std_logic; 
		     ben: in std_logic; 
		     tcen: in std_logic;
		     twen: in std_logic_vector;
		     ta: in std_logic_vector;	 
		     td: in std_logic_vector;	 
		     rren: in std_logic;
		     rra: in std_logic; 
		     cren: in std_logic_vector;
                     rca: in std_logic;
                     contention_flag: in boolean;
                     other_cren: in std_logic_vector;
                     portname: in std_logic) is 
   variable mask_section: integer;
   variable lsb: integer;
   variable msb: integer;
   variable CENi: std_logic;
   variable WENi: std_logic_vector(WEN_WIDTH-1 downto 0);
   variable Ai: std_logic_vector(ADDR_WIDTH-1 downto 0);
   variable Di: std_logic_vector(BITS-1 downto 0);
   variable ValidDummyPinsi: boolean;
   variable creni: std_logic_vector(BITS-1 downto 0);

   begin
      CENi := selector(tcen,cen,ten);
      Ai := selector(ta,a,ten,ADDR_WIDTH-1);
      WENi := selector(twen,wen,ten,WEN_WIDTH-1);
      Di := selector(td,d,ten,BITS-1);
      ValidDummyPinsi := not(is_x(ema) or is_x(artn));
      creni := cren;

      if ( (artn /= '1') and (not(is_same(WENi,MASK1))) and not(is_same(WENi,MASK0)) ) then
	 print("ARTN is active and all bits of WEN are not active or inactive");
	 print("Setting WEN bus to x");
         WENi := MASKX;
      end if;
      if (not(valid_cren(creni))) then
         print("CREN is in an invalid state");
         print("Setting CREN bus to x");
	 creni := WORDX;
      end if;

      for mask_section in 0 to WEN_WIDTH-1 loop
         lsb := mask_section * WP_SIZE ;
         if ((lsb+WP_SIZE-1) >= BITS) then
            msb := BITS - 1;
         else
            msb := lsb+WP_SIZE-1;
         end if;

         if ((WENi(mask_section) = '1') and (CENi = '0') and (ValidDummyPinsi = true)) then
            read_mem(q,other_q,Ai,Di,rren,rra,creni,to_std_logic_vector(rca,1),msb,lsb,false,contention_flag,portname);
         elsif ((WENi(mask_section) = '0') and (CENi = '0') and (ValidDummyPinsi = true)) then
	    write_mem(other_q,Ai,Di,rren,rra,creni,to_std_logic_vector(rca,1),msb,lsb,false,contention_flag,other_cren,portname);
	    write_thru(q,Ai,Di,rren,rra,creni,to_std_logic_vector(rca,1),msb,lsb,false);
         elsif (CENi = '1') then
            null;
         elsif (((WENi(mask_section) = '1') and (CENi = '0')) or
                ((WENi(mask_section) = '1') and (CENi = 'X'))) then
	    read_mem(q,other_q,Ai,Di,rren,rra,creni,to_std_logic_vector(rca,1),msb,lsb,true,contention_flag,portname);
         elsif (((WENi(mask_section) = '0') and (CENi = '0')) or
                ((WENi(mask_section) = '0') and (CENi = 'X'))) then
	    write_mem(other_q,Ai,Di,rren,rra,creni,to_std_logic_vector(rca,1),msb,lsb,true,contention_flag,other_cren,portname);
            write_thru(q,Ai,Di,rren,rra,creni,to_std_logic_vector(rca,1),msb,lsb,true);
         elsif (((WENi(mask_section) = 'X') and (CENi = '0')) or
                ((WENi(mask_section) = 'X') and (CENi = 'X'))) then
	    write_mem(other_q,Ai,Di,rren,rra,creni,to_std_logic_vector(rca,1),msb,lsb,true,contention_flag,other_cren,portname);
            read_mem(q,other_q,Ai,Di,rren,rra,creni,to_std_logic_vector(rca,1),msb,lsb,true,contention_flag,portname);
         end if;
      end loop;
end mem_cycle;

procedure process_violations is
   variable cont_flag: boolean;
begin
   if (CLKViol = 'X') then
      if (LATCHED_CEN /= '1') then
         Qi := WORDX;
      end if;
   else
      x_inputs;
      mem_cycle(Qi,
                dummy_qb,
                LATCHED_CEN,
	      	MASK1,
                LATCHED_A,
                WORD1,
		UPM0,
		'1',
                '1',
                '1',
                '1',
                MASK1,
                ADDR1,
                WORD1,
                '1',
                '1',
                WORD1,
                '1',
                false,
                WORD1,
                '0'
		);
   end if;
end process_violations;


procedure FILL_MEM(FileName: in string; 
                   bits_msb: in integer) is
    variable Dx: boolean:=False;
    file fdr: text is in FileName;
    variable l: textIO.line;
    variable Add: integer:=0;
    variable Data: std_logic_vector(bits_msb downto 0);
    variable in_ch: character;
begin
   while not(endfile(fdr)) loop
      READLINE(fdr, l);
      for i in bits_msb downto 0 loop
         READ(l, in_ch);
	 Data(i):=TO_STD_LOGIC(in_ch);
      end loop;
      write_mem(dummy_qb,conv_std_logic_vector(Add,ADDR_WIDTH), Data,'1','0',WORD1,to_std_logic_vector('0',1),BITS-1,0,false,false,WORD1,'0');
      Add:=Add+1;
   end loop;
end FILL_MEM;

     BEGIN
          ---------------------------------------------------
          -- Timing checks section
          ---------------------------------------------------
          IF (TimingChecksOn) THEN


               VitalPeriodPulseCheck (
                   TestSignal     => CLK_dly,
                   TestSignalName => "CLK",
                   Period         => tperiod_CLK,
                   PulseWidthHigh => tpw_CLK_posedge,
                   PulseWidthLow  => tpw_CLK_negedge,
                   PeriodData     => PeriodCheckInfo_CLK,
                   Violation      => CLKViol,
                   HeaderMsg      => InstancePath & "/Bimod_Tag_ROM",
                   CheckEnabled   => TRUE,
                   XOn            => XOn,
                   MsgOn          => MsgOn,
                   MsgSeverity    => MsgSeverity );


               VitalSetupHoldCheck (
                   TestSignal     => CEN_dly,
                   TestSignalName => "CEN",
                   RefSignal      => CLK_dly,
                   RefSignalName  => "CLK",
                   SetupHigh      => tsetup_CEN_CLK_posedge_posedge,
                   SetupLow       => tsetup_CEN_CLK_negedge_posedge,
                   HoldHigh       => thold_CEN_CLK_negedge_posedge,
                   HoldLow        => thold_CEN_CLK_posedge_posedge,
                   CheckEnabled   => TRUE,
                   RefTransition  => 'R',
                   HeaderMsg      => InstancePath & "Bimod_Tag_ROM",
                   TimingData     => TimingDataInfo_CEN_CLK,
                   Violation      => CENViol,
                   XOn            => XOn,
                   MsgOn          => MsgOn,
                   MsgSeverity    => MsgSeverity );

               VitalSetupHoldCheck (
                   TestSignal     => A_dly(0),
                   TestSignalName => "A(0)",
                   RefSignal      => CLK_dly,
                   RefSignalName  => "CLK",
                   SetupHigh      => tsetup_A_CLK_posedge_posedge(0),
                   SetupLow       => tsetup_A_CLK_negedge_posedge(0),
                   HoldHigh       => thold_A_CLK_negedge_posedge(0),
                   HoldLow        => thold_A_CLK_posedge_posedge(0),
                   CheckEnabled   => (To_X01(CEN_dly) /= '1'),
                   RefTransition  => 'R',
                   HeaderMsg      => InstancePath & "Bimod_Tag_ROM",
                   TimingData     => TimingDataInfo_A_CLK0,
                   Violation      => AViol(0),
                   XOn            => XOn,
                   MsgOn          => MsgOn,
                   MsgSeverity    => MsgSeverity );

               VitalSetupHoldCheck (
                   TestSignal     => A_dly(1),
                   TestSignalName => "A(1)",
                   RefSignal      => CLK_dly,
                   RefSignalName  => "CLK",
                   SetupHigh      => tsetup_A_CLK_posedge_posedge(1),
                   SetupLow       => tsetup_A_CLK_negedge_posedge(1),
                   HoldHigh       => thold_A_CLK_negedge_posedge(1),
                   HoldLow        => thold_A_CLK_posedge_posedge(1),
                   CheckEnabled   => (To_X01(CEN_dly) /= '1'),
                   RefTransition  => 'R',
                   HeaderMsg      => InstancePath & "Bimod_Tag_ROM",
                   TimingData     => TimingDataInfo_A_CLK1,
                   Violation      => AViol(1),
                   XOn            => XOn,
                   MsgOn          => MsgOn,
                   MsgSeverity    => MsgSeverity );

               VitalSetupHoldCheck (
                   TestSignal     => A_dly(2),
                   TestSignalName => "A(2)",
                   RefSignal      => CLK_dly,
                   RefSignalName  => "CLK",
                   SetupHigh      => tsetup_A_CLK_posedge_posedge(2),
                   SetupLow       => tsetup_A_CLK_negedge_posedge(2),
                   HoldHigh       => thold_A_CLK_negedge_posedge(2),
                   HoldLow        => thold_A_CLK_posedge_posedge(2),
                   CheckEnabled   => (To_X01(CEN_dly) /= '1'),
                   RefTransition  => 'R',
                   HeaderMsg      => InstancePath & "Bimod_Tag_ROM",
                   TimingData     => TimingDataInfo_A_CLK2,
                   Violation      => AViol(2),
                   XOn            => XOn,
                   MsgOn          => MsgOn,
                   MsgSeverity    => MsgSeverity );

               VitalSetupHoldCheck (
                   TestSignal     => A_dly(3),
                   TestSignalName => "A(3)",
                   RefSignal      => CLK_dly,
                   RefSignalName  => "CLK",
                   SetupHigh      => tsetup_A_CLK_posedge_posedge(3),
                   SetupLow       => tsetup_A_CLK_negedge_posedge(3),
                   HoldHigh       => thold_A_CLK_negedge_posedge(3),
                   HoldLow        => thold_A_CLK_posedge_posedge(3),
                   CheckEnabled   => (To_X01(CEN_dly) /= '1'),
                   RefTransition  => 'R',
                   HeaderMsg      => InstancePath & "Bimod_Tag_ROM",
                   TimingData     => TimingDataInfo_A_CLK3,
                   Violation      => AViol(3),
                   XOn            => XOn,
                   MsgOn          => MsgOn,
                   MsgSeverity    => MsgSeverity );

               VitalSetupHoldCheck (
                   TestSignal     => A_dly(4),
                   TestSignalName => "A(4)",
                   RefSignal      => CLK_dly,
                   RefSignalName  => "CLK",
                   SetupHigh      => tsetup_A_CLK_posedge_posedge(4),
                   SetupLow       => tsetup_A_CLK_negedge_posedge(4),
                   HoldHigh       => thold_A_CLK_negedge_posedge(4),
                   HoldLow        => thold_A_CLK_posedge_posedge(4),
                   CheckEnabled   => (To_X01(CEN_dly) /= '1'),
                   RefTransition  => 'R',
                   HeaderMsg      => InstancePath & "Bimod_Tag_ROM",
                   TimingData     => TimingDataInfo_A_CLK4,
                   Violation      => AViol(4),
                   XOn            => XOn,
                   MsgOn          => MsgOn,
                   MsgSeverity    => MsgSeverity );

               VitalSetupHoldCheck (
                   TestSignal     => A_dly(5),
                   TestSignalName => "A(5)",
                   RefSignal      => CLK_dly,
                   RefSignalName  => "CLK",
                   SetupHigh      => tsetup_A_CLK_posedge_posedge(5),
                   SetupLow       => tsetup_A_CLK_negedge_posedge(5),
                   HoldHigh       => thold_A_CLK_negedge_posedge(5),
                   HoldLow        => thold_A_CLK_posedge_posedge(5),
                   CheckEnabled   => (To_X01(CEN_dly) /= '1'),
                   RefTransition  => 'R',
                   HeaderMsg      => InstancePath & "Bimod_Tag_ROM",
                   TimingData     => TimingDataInfo_A_CLK5,
                   Violation      => AViol(5),
                   XOn            => XOn,
                   MsgOn          => MsgOn,
                   MsgSeverity    => MsgSeverity );

               VitalSetupHoldCheck (
                   TestSignal     => A_dly(6),
                   TestSignalName => "A(6)",
                   RefSignal      => CLK_dly,
                   RefSignalName  => "CLK",
                   SetupHigh      => tsetup_A_CLK_posedge_posedge(6),
                   SetupLow       => tsetup_A_CLK_negedge_posedge(6),
                   HoldHigh       => thold_A_CLK_negedge_posedge(6),
                   HoldLow        => thold_A_CLK_posedge_posedge(6),
                   CheckEnabled   => (To_X01(CEN_dly) /= '1'),
                   RefTransition  => 'R',
                   HeaderMsg      => InstancePath & "Bimod_Tag_ROM",
                   TimingData     => TimingDataInfo_A_CLK6,
                   Violation      => AViol(6),
                   XOn            => XOn,
                   MsgOn          => MsgOn,
                   MsgSeverity    => MsgSeverity );

          END IF;
       ----------------------------------------------------------------
if (now = 0 ns)  then
 FILL_MEM("Bimod_Tag_ROM_vhdl.rcf", BITS-1);
end if;
       --Set flags for violation checking
       CheckData0 := (((CEN_dly nor WEN_dly) = '1') and (To_X01(TEN_dly) /= '0'));


       -- Test Mux Outputs
       CENY_zd := CEN_dly;
       
       -- Set Violation Vectors
       A_vio : FOR i IN A_dly'range LOOP
            AVio(i):= Aviol(i);
       END LOOP A_vio;

       D_vio : FOR i IN D_dly'range LOOP
            DVio(i):= Dviol(i);
       END LOOP D_vio;



       if (CLK_dly'event ) then
          if ((LAST_CLK = '0') and (CLK_dly = '1')) then
	     latch_inputs;
             clear_status('0');
             mem_cycle(Qi,
                       dummy_qb,
                       LATCHED_CEN,
	      	       MASK1,
                       LATCHED_A,
                       WORD1,
		       UPM0,
		       '1',
                       '1',
                       '1',
                       '1',
                       MASK1,
                       ADDR1,
                       WORD1,
                       '1',
                       '1',
                       WORD1,
                       '1',
                       false,
                       WORD1,
                       '0'
		      );

          elsif (((LAST_CLK = '1') and (CLK_dly = '0')) or
                 (LAST_CLK = 'X') or
                 ((LAST_CLK = '0') and (CLK_dly = '0')) or
                 ((LAST_CLK = '1') and (CLK_dly = '1'))) then
                 null; -- nothing
          elsif (CLK_dly = 'X') then
             Qi := WORDX;
	  end if;
          LAST_CLK := CLK_dly;
       end if;

       if (
            is_x(CENViol) or
            is_x(AVio) or
           is_x(CLKViol)) then
          process_violations;
       end if;

       for j in BITS-1 downto 0 LOOP
          Qout(j) := Qi(j);
       end LOOP;

    -----------------
    -- Path Delays --
    -----------------
       VitalPathDelay01(
          OutSignal => Q(0),
          OutSignalName => "Q(0)",
          OutTemp => Qout(0),
          Paths => (
                    0 => ( CLK_dly'LAST_EVENT,
                           tpd_CLK_Q(0),
                           TRUE)
                    ),
          GlitchData => Q0_GlitchData,
          Mode =>OnEvent,
          XOn => XOn,
          MsgOn => MsgOn,
          MsgSeverity => WARNING);

       VitalPathDelay01(
          OutSignal => Q(1),
          OutSignalName => "Q(1)",
          OutTemp => Qout(1),
          Paths => (
                    0 => ( CLK_dly'LAST_EVENT,
                           tpd_CLK_Q(1),
                           TRUE)
                    ),
          GlitchData => Q1_GlitchData,
          Mode =>OnEvent,
          XOn => XOn,
          MsgOn => MsgOn,
          MsgSeverity => WARNING);

       VitalPathDelay01(
          OutSignal => Q(2),
          OutSignalName => "Q(2)",
          OutTemp => Qout(2),
          Paths => (
                    0 => ( CLK_dly'LAST_EVENT,
                           tpd_CLK_Q(2),
                           TRUE)
                    ),
          GlitchData => Q2_GlitchData,
          Mode =>OnEvent,
          XOn => XOn,
          MsgOn => MsgOn,
          MsgSeverity => WARNING);

       VitalPathDelay01(
          OutSignal => Q(3),
          OutSignalName => "Q(3)",
          OutTemp => Qout(3),
          Paths => (
                    0 => ( CLK_dly'LAST_EVENT,
                           tpd_CLK_Q(3),
                           TRUE)
                    ),
          GlitchData => Q3_GlitchData,
          Mode =>OnEvent,
          XOn => XOn,
          MsgOn => MsgOn,
          MsgSeverity => WARNING);

       VitalPathDelay01(
          OutSignal => Q(4),
          OutSignalName => "Q(4)",
          OutTemp => Qout(4),
          Paths => (
                    0 => ( CLK_dly'LAST_EVENT,
                           tpd_CLK_Q(4),
                           TRUE)
                    ),
          GlitchData => Q4_GlitchData,
          Mode =>OnEvent,
          XOn => XOn,
          MsgOn => MsgOn,
          MsgSeverity => WARNING);

       VitalPathDelay01(
          OutSignal => Q(5),
          OutSignalName => "Q(5)",
          OutTemp => Qout(5),
          Paths => (
                    0 => ( CLK_dly'LAST_EVENT,
                           tpd_CLK_Q(5),
                           TRUE)
                    ),
          GlitchData => Q5_GlitchData,
          Mode =>OnEvent,
          XOn => XOn,
          MsgOn => MsgOn,
          MsgSeverity => WARNING);

       VitalPathDelay01(
          OutSignal => Q(6),
          OutSignalName => "Q(6)",
          OutTemp => Qout(6),
          Paths => (
                    0 => ( CLK_dly'LAST_EVENT,
                           tpd_CLK_Q(6),
                           TRUE)
                    ),
          GlitchData => Q6_GlitchData,
          Mode =>OnEvent,
          XOn => XOn,
          MsgOn => MsgOn,
          MsgSeverity => WARNING);

       VitalPathDelay01(
          OutSignal => Q(7),
          OutSignalName => "Q(7)",
          OutTemp => Qout(7),
          Paths => (
                    0 => ( CLK_dly'LAST_EVENT,
                           tpd_CLK_Q(7),
                           TRUE)
                    ),
          GlitchData => Q7_GlitchData,
          Mode =>OnEvent,
          XOn => XOn,
          MsgOn => MsgOn,
          MsgSeverity => WARNING);

       VitalPathDelay01(
          OutSignal => Q(8),
          OutSignalName => "Q(8)",
          OutTemp => Qout(8),
          Paths => (
                    0 => ( CLK_dly'LAST_EVENT,
                           tpd_CLK_Q(8),
                           TRUE)
                    ),
          GlitchData => Q8_GlitchData,
          Mode =>OnEvent,
          XOn => XOn,
          MsgOn => MsgOn,
          MsgSeverity => WARNING);

       VitalPathDelay01(
          OutSignal => Q(9),
          OutSignalName => "Q(9)",
          OutTemp => Qout(9),
          Paths => (
                    0 => ( CLK_dly'LAST_EVENT,
                           tpd_CLK_Q(9),
                           TRUE)
                    ),
          GlitchData => Q9_GlitchData,
          Mode =>OnEvent,
          XOn => XOn,
          MsgOn => MsgOn,
          MsgSeverity => WARNING);

       VitalPathDelay01(
          OutSignal => Q(10),
          OutSignalName => "Q(10)",
          OutTemp => Qout(10),
          Paths => (
                    0 => ( CLK_dly'LAST_EVENT,
                           tpd_CLK_Q(10),
                           TRUE)
                    ),
          GlitchData => Q10_GlitchData,
          Mode =>OnEvent,
          XOn => XOn,
          MsgOn => MsgOn,
          MsgSeverity => WARNING);

       VitalPathDelay01(
          OutSignal => Q(11),
          OutSignalName => "Q(11)",
          OutTemp => Qout(11),
          Paths => (
                    0 => ( CLK_dly'LAST_EVENT,
                           tpd_CLK_Q(11),
                           TRUE)
                    ),
          GlitchData => Q11_GlitchData,
          Mode =>OnEvent,
          XOn => XOn,
          MsgOn => MsgOn,
          MsgSeverity => WARNING);

       VitalPathDelay01(
          OutSignal => Q(12),
          OutSignalName => "Q(12)",
          OutTemp => Qout(12),
          Paths => (
                    0 => ( CLK_dly'LAST_EVENT,
                           tpd_CLK_Q(12),
                           TRUE)
                    ),
          GlitchData => Q12_GlitchData,
          Mode =>OnEvent,
          XOn => XOn,
          MsgOn => MsgOn,
          MsgSeverity => WARNING);

       VitalPathDelay01(
          OutSignal => Q(13),
          OutSignalName => "Q(13)",
          OutTemp => Qout(13),
          Paths => (
                    0 => ( CLK_dly'LAST_EVENT,
                           tpd_CLK_Q(13),
                           TRUE)
                    ),
          GlitchData => Q13_GlitchData,
          Mode =>OnEvent,
          XOn => XOn,
          MsgOn => MsgOn,
          MsgSeverity => WARNING);

       VitalPathDelay01(
          OutSignal => Q(14),
          OutSignalName => "Q(14)",
          OutTemp => Qout(14),
          Paths => (
                    0 => ( CLK_dly'LAST_EVENT,
                           tpd_CLK_Q(14),
                           TRUE)
                    ),
          GlitchData => Q14_GlitchData,
          Mode =>OnEvent,
          XOn => XOn,
          MsgOn => MsgOn,
          MsgSeverity => WARNING);

       VitalPathDelay01(
          OutSignal => Q(15),
          OutSignalName => "Q(15)",
          OutTemp => Qout(15),
          Paths => (
                    0 => ( CLK_dly'LAST_EVENT,
                           tpd_CLK_Q(15),
                           TRUE)
                    ),
          GlitchData => Q15_GlitchData,
          Mode =>OnEvent,
          XOn => XOn,
          MsgOn => MsgOn,
          MsgSeverity => WARNING);

end process;
End Behavioral;
