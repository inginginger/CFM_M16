module OrbM16(
	input clk100MHz,
	input clk80MHz,
	output orbFrame,
	output doubleOrbData,
	output ValRX,
	
output test1,
output test2,
output test3,
output test4,
	input UART_RX1,
	output UART_TX1,        // serial transmitted data
	output UART_dTX1,       // rs485 TX dir controller 
	output UART_dRX1,        // rs485 RX dir controller
	input UART_RX2,
	output UART_TX2,        // serial transmitted data
	output UART_dTX2,       // rs485 TX dir controller 
	output UART_dRX2,        // rs485 RX dir controller
	input UART_RX3,
	output UART_TX3,        // serial transmitted data
	output UART_dTX3,       // rs485 TX dir controller 
	output UART_dRX3,        // rs485 RX dir controller
	input UART_RX4,
	output UART_TX4,        // serial transmitted data
	output UART_dTX4,       // rs485 TX dir controller 
	output UART_dRX4,        // rs485 RX dir controller
	input UART_RX5,
	output UART_TX5,        // serial transmitted data
	output UART_dTX5,       // rs485 TX dir controller 
	output UART_dRX5        // rs485 RX dir controller
);

wire rst;
wire clkOrb;
wire LCBreq1, LCBreq2, LCBreq3, LCBreq4, LCBreq5;
wire clk4_8MHz;
wire [5:0]cycle;
wire [8:0] LCB_rq_addr1, LCB_rq_addr2, LCB_rq_addr3, LCB_rq_addr4, LCB_rq_addr5;
wire [7:0] LCB_rq_data1, LCB_rq_data2, LCB_rq_data3, LCB_rq_data4, LCB_rq_data5;
wire [4:0] switch;
wire [10:0] RdAddr;
wire [10:0] WrAddr;
wire [11:0] OrbData;
wire RE, WE;
wire SW, test;
wire [10:0] RdAddr1;
wire [10:0] RdAddr2;
wire [10:0] WrAddr1;
wire [10:0] WrAddr2;
wire RE1, RE2, WE1, WE2;
wire [11:0] MemData1;
wire [11:0] MemData2;
//wire [7:0] DataFromLCB;
wire [11:0] orbWord;
wire testpin2016, testpin1984;
wire [7:0] DataFromLCB1, DataFromLCB2, DataFromLCB3, DataFromLCB4, DataFromLCB5;
wire ValRX1, ValRX2, ValRX3, ValRX4, ValRX5, testVal1, testVal2;

assign doubleOrbData = orbFrame;//дублирование на контакт, который выводит кадр на стенде
assign test1 = UART_dTX1;//testVal1;
assign test2 = UART_dTX2;//testVal2;//SW;//0;//WE2;
assign test3 = testpin1984;//WrAddr[1];
assign test4 = testpin2016;//RE2;//0;//WE2;

reg [1:0] syncRE1;
reg [1:0] syncRE2;
reg [1:0] syncWE1;
reg [1:0] syncWE2;

always@(posedge clk80MHz)
begin
	syncWE1 <= {syncWE1[0], WE1};
	syncWE2 <= {syncWE2[0], WE2};
end

always@(posedge clk100MHz)
begin
	syncRE1 <= {syncRE1[0], RE1};
	syncRE2 <= {syncRE2[0], RE2};
end

assign OrbData = (SW == 1'b0)?MemData1:MemData2;
//assign DataFromLCB = (SW == 1'b0)?DataFromLCB2:DataFromLCB1;
assign RdAddr1= (SW == 1'b0)?(RdAddr+1'b1):11'hx;
assign WrAddr2 = (SW == 1'b0)?WrAddr:11'hx;
assign RE1 = (SW == 1'b0)?RE:1'hx;
assign WE2 = (SW == 1'b0)?WE:1'hx;
assign RdAddr2= (SW == 1'b1)?(RdAddr+1'b1):11'hx;
assign WrAddr1 = (SW == 1'b1)?WrAddr:11'hx;
assign RE2 = (SW == 1'b1)?RE:1'hx;
assign WE1 = (SW == 1'b1)?WE:1'hx;
assign ValRX = ValRX1 | ValRX2;

globalReset inst1(
	.clk(clk80MHz),				// 40 MHz
	.rst(rst)			// global enable
);

clkDiv21 inst2(
    .rst(rst),
	.clk100MHz(clk100MHz),
    .oClk(clk4_8MHz)
    );

clkDiv100 inst3(
	.reset(rst),
	.iClkIN(clk100MHz),			// whatever clock
	.Outdiv8(clkOrb)			// divided by 8
);	

UART_RX inst4(
	.clk(clk80MHz),
	.reset(rst),
	.RX(UART_RX1),
	.oValid(ValRX1),
	.oData(DataFromLCB1)
);

UART_RX inst5(
	.clk(clk80MHz),
	.reset(rst),
	.RX(UART_RX2),
	.oValid(ValRX2),
	.oData(DataFromLCB2)
);

UART_RX inst6(
	.clk(clk80MHz),
	.reset(rst),
	.RX(UART_RX3),
	.oValid(ValRX3),
	.oData(DataFromLCB3)
);

UART_RX inst7(
	.clk(clk80MHz),
	.reset(rst),
	.RX(UART_RX4),
	.oValid(ValRX4),
	.oData(DataFromLCB4)
);

UART_RX inst8(
	.clk(clk80MHz),
	.reset(rst),
	.RX(UART_RX5),
	.oValid(ValRX5),
	.oData(DataFromLCB5)
);

ramUART inst9(
	.clock(clk80MHz),
	.data(iUART1),
	.rdaddress(RAdr1),
	.rden(RD1),
	.wraddress(WAdr1),
	.wren(WR1),
	.q(oUART1)
);

commutAdr inst10(
	.clk(clk80MHz),
	.rst(rst),
	.strob(ValRX1),
	.rdAdr(RAdr1),
	.full(done1)
);

commutAdr inst11(
	.clk(clk80MHz),
	.rst(rst),
	.strob(ValRX2),
	.rdAdr(RAdr2),
	.full(done2)
);
commutAdr inst12(
	.clk(clk80MHz),
	.rst(rst),
	.strob(ValRX3),
	.rdAdr(RAdr3),
	.full(done3)
);

commutAdr inst13(
	.clk(clk80MHz),
	.rst(rst),
	.strob(ValRX4),
	.rdAdr(RAdr4),
	.full(done4)
);

commutAdr inst14(
	.clk(clk80MHz),
	.rst(rst),
	.strob(ValRX5),
	.rdAdr(RAdr5),
	.full(done5)
);

OrbPacker inst15(
	.clk(clk80MHz),
	.rst(rst),
	.iData1(DataFromLCB1),
	.strob1(ValRX1),
	.iData2(DataFromLCB2),
	.strob2(ValRX2),
	.iData3(DataFromLCB3),
	.strob3(ValRX3),
	.iData4(DataFromLCB4),
	.strob4(ValRX4),
	.iData5(DataFromLCB5),
	.strob5(ValRX5),
	.SW(SW),
	.test(test),
	.test00(testVal1),
	.test01(testVal2),
	//.req,
	.orbWord(orbWord),
	.WE(WE),
	.WrAddr(WrAddr),
	.test1(testpin2016),
	.test2(testpin1984)
);

ramM16 inst16(
	.clock(clk80MHz),
	.data(orbWord),
	.rdaddress(RdAddr1),
	.rden(syncRE1[1]),
	.wraddress(WrAddr1),
	.wren(syncWE1[1]),
	.q(MemData1));
	
ramM16 inst17(
	.clock(clk80MHz),
	.data(orbWord),
	.rdaddress(RdAddr2),
	.rden(syncRE2[1]),
	.wraddress(WrAddr2),
	.wren(syncWE2[1]),
	.q(MemData2));

M16 inst18(
	.reset(rst), 
	.iClkOrb(clkOrb), //100MHz/8
	.iWord(OrbData),
	.oAddr(RdAddr),
	.oRdEn(RE),
	.oSwitch(SW),
	.oLCB_rq1(LCBreq1),      // start transfer signal
	.oLCB_rq2(LCBreq2),
	.cycle(cycle),
	.oOrbit(orbFrame)
);

UARTTXBIG inst19(
  .reset(rst),          // global reset and enable signal
  .clk(clk4_8MHz),            // actual needed baudrate
  .RQ(LCBreq1),
  .cycle(cycle + 1'b1),  // number of the request (from m8) + shift, to give LCB time to respond
  .data(LCB_rq_data1),      // data to transmit (from ROM)
  .addr(LCB_rq_addr1),      // address to read (to ROM)
  .tx(UART_TX1),          // serial transmitted data
  .dirTX(UART_dTX1),        // rs485 TX dir controller 
  .dirRX(UART_dRX1),        // rs485 RX dir controller
  .switch(switch)
);
defparam inst19.BYTES = 5'd4;

UARTTXBIG inst20(
  .reset(rst),          // global reset and enable signal
  .clk(clk4_8MHz),            // actual needed baudrate
  .RQ(LCBreq2),
  .cycle(cycle + 1'b1),  // number of the request (from m8) + shift, to give LCB time to respond
  .data(LCB_rq_data2),      // data to transmit (from ROM)
  .addr(LCB_rq_addr2),      // address to read (to ROM)
  .tx(UART_TX2),          // serial transmitted data
  .dirTX(UART_dTX2),        // rs485 TX dir controller 
  .dirRX(UART_dRX2),        // rs485 RX dir controller
  .switch(switch)
);
defparam inst20.BYTES = 5'd4;

UARTTXBIG inst21(
  .reset(rst),          // global reset and enable signal
  .clk(clk4_8MHz),            // actual needed baudrate
  .RQ(LCBreq3),
  .cycle(cycle + 1'b1),  // number of the request (from m8) + shift, to give LCB time to respond
  .data(LCB_rq_data3),      // data to transmit (from ROM)
  .addr(LCB_rq_addr3),      // address to read (to ROM)
  .tx(UART_TX3),          // serial transmitted data
  .dirTX(UART_dTX3),        // rs485 TX dir controller 
  .dirRX(UART_dRX3),        // rs485 RX dir controller
  .switch(switch)
);
defparam inst21.BYTES = 5'd4;

UARTTXBIG inst22(
  .reset(rst),          // global reset and enable signal
  .clk(clk4_8MHz),            // actual needed baudrate
  .RQ(LCBreq4),
  .cycle(cycle + 1'b1),  // number of the request (from m8) + shift, to give LCB time to respond
  .data(LCB_rq_data4),      // data to transmit (from ROM)
  .addr(LCB_rq_addr4),      // address to read (to ROM)
  .tx(UART_TX4),          // serial transmitted data
  .dirTX(UART_dTX4),        // rs485 TX dir controller 
  .dirRX(UART_dRX4),        // rs485 RX dir controller
  .switch(switch)
);
defparam inst22.BYTES = 5'd4;

UARTTXBIG inst23(
  .reset(rst),          // global reset and enable signal
  .clk(clk4_8MHz),            // actual needed baudrate
  .RQ(LCBreq5),
  .cycle(cycle + 1'b1),  // number of the request (from m8) + shift, to give LCB time to respond
  .data(LCB_rq_data5),      // data to transmit (from ROM)
  .addr(LCB_rq_addr5),      // address to read (to ROM)
  .tx(UART_TX5),          // serial transmitted data
  .dirTX(UART_dTX5),        // rs485 TX dir controller 
  .dirRX(UART_dRX5),        // rs485 RX dir controller
  .switch(switch)
);
defparam inst23.BYTES = 5'd4;

ReqROM inst24(
  .address(LCB_rq_addr1),
  .inclock(clk80MHz),
  .outclock(clk80MHz),
  .q(LCB_rq_data1)
);

ReqROM inst25(
  .address(LCB_rq_addr2),
  .inclock(clk80MHz),
  .outclock(clk80MHz),
  .q(LCB_rq_data2)
);

ReqROM inst26(
  .address(LCB_rq_addr3),
  .inclock(clk80MHz),
  .outclock(clk80MHz),
  .q(LCB_rq_data3)
);

ReqROM inst27(
  .address(LCB_rq_addr4),
  .inclock(clk80MHz),
  .outclock(clk80MHz),
  .q(LCB_rq_data4)
);

ReqROM inst28(
  .address(LCB_rq_addr5),
  .inclock(clk80MHz),
  .outclock(clk80MHz),
  .q(LCB_rq_data5)
);
endmodule
