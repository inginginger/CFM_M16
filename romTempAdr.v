// megafunction wizard: %ROM: 1-PORT%
// GENERATION: STANDARD
// VERSION: WM1.0
// MODULE: lpm_rom 

// ============================================================
// File Name: romTempAdr.v
// Megafunction Name(s):
// 			lpm_rom
//
// Simulation Library Files(s):
// 			lpm
// ============================================================
// ************************************************************
// THIS IS A WIZARD-GENERATED FILE. DO NOT EDIT THIS FILE!
//
// 9.0 Build 184 04/29/2009 SP 1 SJ Web Edition
// ************************************************************


//Copyright (C) 1991-2009 Altera Corporation
//Your use of Altera Corporation's design tools, logic functions 
//and other software and tools, and its AMPP partner logic 
//functions, and any output files from any of the foregoing 
//(including device programming or simulation files), and any 
//associated documentation or information are expressly subject 
//to the terms and conditions of the Altera Program License 
//Subscription Agreement, Altera MegaCore Function License 
//Agreement, or other applicable license agreement, including, 
//without limitation, that your use is for the sole purpose of 
//programming logic devices manufactured by Altera and sold by 
//Altera or its authorized distributors.  Please refer to the 
//applicable agreement for further details.


// synopsys translate_off
`timescale 1 ps / 1 ps
// synopsys translate_on
module romTempAdr (
	address,
	inclock,
	outclock,
	q);

	input	[6:0]  address;
	input	  inclock;
	input	  outclock;
	output	[10:0]  q;

	wire [10:0] sub_wire0;
	wire [10:0] q = sub_wire0[10:0];

	lpm_rom	lpm_rom_component (
				.outclock (outclock),
				.address (address),
				.inclock (inclock),
				.q (sub_wire0),
				.memenab (1'b1));
	defparam
		lpm_rom_component.intended_device_family = "FLEX10KE",
		lpm_rom_component.lpm_address_control = "REGISTERED",
`ifdef NO_PLI
		lpm_rom_component.lpm_file = "tempAddr.rif"
`else
		lpm_rom_component.lpm_file = "tempAddr.hex"
`endif
,
		lpm_rom_component.lpm_outdata = "REGISTERED",
		lpm_rom_component.lpm_type = "LPM_ROM",
		lpm_rom_component.lpm_width = 11,
		lpm_rom_component.lpm_widthad = 7;


endmodule

// ============================================================
// CNX file retrieval info
// ============================================================
// Retrieval info: PRIVATE: ADDRESSSTALL_A NUMERIC "0"
// Retrieval info: PRIVATE: AclrAddr NUMERIC "0"
// Retrieval info: PRIVATE: AclrByte NUMERIC "0"
// Retrieval info: PRIVATE: AclrOutput NUMERIC "0"
// Retrieval info: PRIVATE: BYTE_ENABLE NUMERIC "0"
// Retrieval info: PRIVATE: BYTE_SIZE NUMERIC "8"
// Retrieval info: PRIVATE: BlankMemory NUMERIC "0"
// Retrieval info: PRIVATE: CLOCK_ENABLE_INPUT_A NUMERIC "0"
// Retrieval info: PRIVATE: CLOCK_ENABLE_OUTPUT_A NUMERIC "0"
// Retrieval info: PRIVATE: Clken NUMERIC "0"
// Retrieval info: PRIVATE: IMPLEMENT_IN_LES NUMERIC "0"
// Retrieval info: PRIVATE: INIT_FILE_LAYOUT STRING "PORT_A"
// Retrieval info: PRIVATE: INIT_TO_SIM_X NUMERIC "0"
// Retrieval info: PRIVATE: INTENDED_DEVICE_FAMILY STRING "FLEX10KE"
// Retrieval info: PRIVATE: JTAG_ENABLED NUMERIC "0"
// Retrieval info: PRIVATE: JTAG_ID STRING "NONE"
// Retrieval info: PRIVATE: MAXIMUM_DEPTH NUMERIC "0"
// Retrieval info: PRIVATE: MIFfilename STRING "tempAddr.hex"
// Retrieval info: PRIVATE: NUMWORDS_A NUMERIC "128"
// Retrieval info: PRIVATE: OutputRegistered NUMERIC "1"
// Retrieval info: PRIVATE: RAM_BLOCK_TYPE NUMERIC "0"
// Retrieval info: PRIVATE: RegAdd NUMERIC "1"
// Retrieval info: PRIVATE: RegAddr NUMERIC "1"
// Retrieval info: PRIVATE: RegOutput NUMERIC "1"
// Retrieval info: PRIVATE: SYNTH_WRAPPER_GEN_POSTFIX STRING "0"
// Retrieval info: PRIVATE: SingleClock NUMERIC "0"
// Retrieval info: PRIVATE: UseDQRAM NUMERIC "0"
// Retrieval info: PRIVATE: WidthAddr NUMERIC "7"
// Retrieval info: PRIVATE: WidthData NUMERIC "11"
// Retrieval info: PRIVATE: rden NUMERIC "0"
// Retrieval info: CONSTANT: INTENDED_DEVICE_FAMILY STRING "FLEX10KE"
// Retrieval info: CONSTANT: LPM_ADDRESS_CONTROL STRING "REGISTERED"
// Retrieval info: CONSTANT: LPM_FILE STRING "tempAddr.hex"
// Retrieval info: CONSTANT: LPM_OUTDATA STRING "REGISTERED"
// Retrieval info: CONSTANT: LPM_TYPE STRING "LPM_ROM"
// Retrieval info: CONSTANT: LPM_WIDTH NUMERIC "11"
// Retrieval info: CONSTANT: LPM_WIDTHAD NUMERIC "7"
// Retrieval info: USED_PORT: address 0 0 7 0 INPUT NODEFVAL address[6..0]
// Retrieval info: USED_PORT: inclock 0 0 0 0 INPUT NODEFVAL inclock
// Retrieval info: USED_PORT: outclock 0 0 0 0 INPUT NODEFVAL outclock
// Retrieval info: USED_PORT: q 0 0 11 0 OUTPUT NODEFVAL q[10..0]
// Retrieval info: CONNECT: @address 0 0 7 0 address 0 0 7 0
// Retrieval info: CONNECT: q 0 0 11 0 @q 0 0 11 0
// Retrieval info: CONNECT: @inclock 0 0 0 0 inclock 0 0 0 0
// Retrieval info: CONNECT: @outclock 0 0 0 0 outclock 0 0 0 0
// Retrieval info: LIBRARY: lpm lpm.lpm_components.all
// Retrieval info: GEN_FILE: TYPE_NORMAL romTempAdr.v TRUE
// Retrieval info: GEN_FILE: TYPE_NORMAL romTempAdr.inc FALSE
// Retrieval info: GEN_FILE: TYPE_NORMAL romTempAdr.cmp TRUE
// Retrieval info: GEN_FILE: TYPE_NORMAL romTempAdr.bsf TRUE FALSE
// Retrieval info: GEN_FILE: TYPE_NORMAL romTempAdr_inst.v TRUE
// Retrieval info: GEN_FILE: TYPE_NORMAL romTempAdr_bb.v TRUE
// Retrieval info: LIB_FILE: lpm
