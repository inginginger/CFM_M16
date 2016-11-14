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
wire RqFast, RqSlow;
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
wire [5:0] adrCycle;
assign doubleOrbData = orbFrame;//дублирование на контакт, который выводит кадр на стенде
assign test1 = ValRX1;//UART_dTX1;//testVal1;
assign test2 = ValRX2;//UART_dTX2;//testVal2;//SW;//0;//WE2;
assign test3 = testpin1984;//WrAddr[1];
assign test4 = testpin2016;//RE2;//0;//WE2;

reg [1:0] syncRE1;
reg [1:0] syncRE2;
reg [1:0] syncWE1;
reg [1:0] syncWE2;
wire [10:0] addrRamGr;
wire [7:0] iUART1, iUART2, iUART3, iUART4, iUART5, oUART1, oUART2, oUART3, oUART4, oUART5;
wire [4:0] WAdr1, WAdr2, WAdr3, WAdr4, WAdr5, RAdr1, RAdr2, RAdr3, RAdr4, RAdr5;
wire RD1, RD2, RD3, RD4, RD5, WR1, WR2, WR3, WR4, WR5;
wire done1, done2, done3, done4, done5;

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
assign ValRX = ValRX1 | ValRX2 | ValRX3 | ValRX4 | ValRX5;

globalReset instRST(
	.clk(clk80MHz),				// 40 MHz
	.rst(rst)			// global enable
);

clkDiv21 instClkDiv21(
    .rst(rst),
	.clk100MHz(clk100MHz),
    .oClk(clk4_8MHz)
    );

clkDiv100 instClkDiv100(
	.reset(rst),
	.iClkIN(clk100MHz),			// whatever clock
	.Outdiv8(clkOrb)			// divided by 8
);	

UART_RX instRX1(
	.clk(clk80MHz),
	.reset(rst),
	.RX(UART_RX1),
	.oValid(ValRX1),
	.oData(iUART1)
);

UART_RX instRX2(
	.clk(clk80MHz),
	.reset(rst),
	.RX(UART_RX2),
	.oValid(ValRX2),
	.oData(iUART2)
);

UART_RX instRX3(
	.clk(clk80MHz),
	.reset(rst),
	.RX(UART_RX3),
	.oValid(ValRX3),
	.oData(iUART3)
);

UART_RX instRX4(
	.clk(clk80MHz),
	.reset(rst),
	.RX(UART_RX4),
	.oValid(ValRX4),
	.oData(iUART4)
);

UART_RX instRX5(
	.clk(clk80MHz),
	.reset(rst),
	.RX(UART_RX5),
	.oValid(ValRX5),
	.oData(iUART5)
);

ramUART instRam1(
	.clock(clk80MHz),
	.data(iUART1),
	.rdaddress(RAdr1),
	.rden(RD1),
	.wraddress(WAdr1),
	.wren(WR1),
	.q(oUART1)
);

ramUART instRam2(
	.clock(clk80MHz),
	.data(iUART2),
	.rdaddress(RAdr2),
	.rden(RD2),
	.wraddress(WAdr2),
	.wren(WR2),
	.q(oUART2)
);

ramUART instRam3(
	.clock(clk80MHz),
	.data(iUART3),
	.rdaddress(RAdr3),
	.rden(RD3),
	.wraddress(WAdr3),
	.wren(WR3),
	.q(oUART3)
);

ramUART instRam4(
	.clock(clk80MHz),
	.data(iUART4),
	.rdaddress(RAdr4),
	.rden(RD4),
	.wraddress(WAdr4),
	.wren(WR4),
	.q(oUART4)
);

ramUART instRam5(
	.clock(clk80MHz),
	.data(iUART5),
	.rdaddress(RAdr5),
	.rden(RD5),
	.wraddress(WAdr5),
	.wren(WR5),
	.q(oUART5)
);

commutAdr instWrAdr1(
	.clk(clk80MHz),
	.rst(rst),
	.strob(ValRX1),
	.wrAdr(WAdr1),
	.full(done1),
	.WE(WR1)
);

commutAdr instWrAdr2(
	.clk(clk80MHz),
	.rst(rst),
	.strob(ValRX2),
	.wrAdr(WAdr2),
	.full(done2),
	.WE(WR2)
);
commutAdr instWrAdr3(
	.clk(clk80MHz),
	.rst(rst),
	.strob(ValRX3),
	.wrAdr(WAdr3),
	.full(done3),
	.WE(WR3)
);

commutAdr instWrAdr4(
	.clk(clk80MHz),
	.rst(rst),
	.strob(ValRX4),
	.wrAdr(WAdr4),
	.full(done4),
	.WE(WR4)
);

commutAdr instWrAdr5(
	.clk(clk80MHz),
	.rst(rst),
	.strob(ValRX5),
	.wrAdr(WAdr5),
	.full(done5),
	.WE(WR5)
);

commRdAdr instRdAdr1(
	.clk(clk80MHz),
	.rst(rst),
	.strob1(done1),
	.strob2(done2),
	.strob3(done3),
	.strob4(done4),
	.strob5(done5),
	.RD1(RD1),
	.RD2(RD2),
	.RD3(RD3),
	.RD4(RD4),
	.RD5(RD5),
	.RdAdr1(RAdr1),
	.RdAdr2(RAdr2),
	.RdAdr3(RAdr3),
	.RdAdr4(RAdr4),
	.RdAdr5(RAdr5)
);	

OrbPacker instPACKER(
	.clk(clk80MHz),
	.rst(rst),
	.cycle(cycle),
	.slowAddr(addrRamGr),
	.RqData(LCB_rq_data1),
	.iData1(oUART1),
	.strob1(RD1),
	.iData2(oUART2),
	.strob2(RD2),
	.iData3(oUART3),
	.strob3(RD3),
	.iData4(oUART4),
	.strob4(RD4),
	.iData5(oUART5),
	.strob5(RD5),
	.SW(SW),
	.test(test),
	.orbWord(orbWord),
	.WE(WE),
	.WrAddr(WrAddr),
	.test1(testpin2016),
	.test2(testpin1984)
);

ramM16 instRamM16_1(
	.clock(clk80MHz),
	.data(orbWord),
	.rdaddress(RdAddr1),
	.rden(syncRE1[1]),
	.wraddress(WrAddr1),
	.wren(syncWE1[1]),
	.q(MemData1));
	
ramM16 instRamM16_2(
	.clock(clk80MHz),
	.data(orbWord),
	.rdaddress(RdAddr2),
	.rden(syncRE2[1]),
	.wraddress(WrAddr2),
	.wren(syncWE2[1]),
	.q(MemData2));

M16 instM16(
	.reset(rst), 
	.iClkOrb(clkOrb), //100MHz/8
	.iWord(OrbData),
	.oAddr(RdAddr),
	.oRdEn(RE),
	.oSwitch(SW),
	.RqSlow(RqSlow),      // start transfer signal
	.RqFast(RqFast),
	.cycle(cycle),
	.oOrbit(orbFrame)
);

UARTTXBIG instTX1(
  .reset(rst),          // global reset and enable signal
  .clk(clk4_8MHz),            // actual needed baudrate
  .RQ(RqFast),
  .cycle(cycle + 1'b1),  // number of the request (from m8) + shift, to give LCB time to respond
  .data(LCB_rq_data1),      // data to transmit (from ROM)
  .addr(LCB_rq_addr1),      // address to read (to ROM)
  .tx(UART_TX1),          // serial transmitted data
  .dirTX(UART_dTX1),        // rs485 TX dir controller 
  .dirRX(UART_dRX1),        // rs485 RX dir controller
  .switch(switch)
);
defparam instTX1.BYTES = 5'd4;

UARTTXBIG instTX2(
  .reset(rst),          // global reset and enable signal
  .clk(clk4_8MHz),            // actual needed baudrate
  .RQ(RqFast),
  .cycle(cycle + 1'b1),  // number of the request (from m8) + shift, to give LCB time to respond
  .data(LCB_rq_data2),      // data to transmit (from ROM)
  .addr(LCB_rq_addr2),      // address to read (to ROM)
  .tx(UART_TX2),          // serial transmitted data
  .dirTX(UART_dTX2),        // rs485 TX dir controller 
  .dirRX(UART_dRX2),        // rs485 RX dir controller
  .switch(switch)
);
defparam instTX2.BYTES = 5'd4;

UARTTXBIG instTX3(
  .reset(rst),          // global reset and enable signal
  .clk(clk4_8MHz),            // actual needed baudrate
  .RQ(RqFast),
  .cycle(cycle + 1'b1),  // number of the request (from m8) + shift, to give LCB time to respond
  .data(LCB_rq_data3),      // data to transmit (from ROM)
  .addr(LCB_rq_addr3),      // address to read (to ROM)
  .tx(UART_TX3),          // serial transmitted data
  .dirTX(UART_dTX3),        // rs485 TX dir controller 
  .dirRX(UART_dRX3),        // rs485 RX dir controller
  .switch(switch)
);
defparam instTX3.BYTES = 5'd4;

UARTTXBIG instTX4(
  .reset(rst),          // global reset and enable signal
  .clk(clk4_8MHz),            // actual needed baudrate
  .RQ(RqSlow),
  .cycle(cycle + 1'b1),  // number of the request (from m8) + shift, to give LCB time to respond
  .data(LCB_rq_data4),      // data to transmit (from ROM)
  .addr(LCB_rq_addr4),      // address to read (to ROM)
  .tx(UART_TX4),          // serial transmitted data
  .dirTX(UART_dTX4),        // rs485 TX dir controller 
  .dirRX(UART_dRX4),        // rs485 RX dir controller
  .switch(switch)
);
defparam instTX4.BYTES = 5'd4;

UARTTXBIG instTX5(
  .reset(rst),          // global reset and enable signal
  .clk(clk4_8MHz),            // actual needed baudrate
  .RQ(RqSlow),
  .cycle(cycle + 1'b1),  // number of the request (from m8) + shift, to give LCB time to respond
  .data(LCB_rq_data5),      // data to transmit (from ROM)
  .addr(LCB_rq_addr5),      // address to read (to ROM)
  .tx(UART_TX5),          // serial transmitted data
  .dirTX(UART_dTX5),        // rs485 TX dir controller 
  .dirRX(UART_dRX5),        // rs485 RX dir controller
  .switch(switch)
);
defparam instTX5.BYTES = 5'd4;



romRqAdr instRomAdr1(
	.address(cycle),
	.inclock(clk80MHz),
	.outclock(clk80MHz),
	.q(addrRamGr)
);

ReqROM instRQ1(
  .address(LCB_rq_addr1),
  .inclock(clk80MHz),
  .outclock(clk80MHz),
  .q(LCB_rq_data1)
);

ReqROM instRQ2(
  .address(LCB_rq_addr2),
  .inclock(clk80MHz),
  .outclock(clk80MHz),
  .q(LCB_rq_data2)
);

ReqROM instRQ3(
  .address(LCB_rq_addr3),
  .inclock(clk80MHz),
  .outclock(clk80MHz),
  .q(LCB_rq_data3)
);

ReqROM instRQ4(
  .address(LCB_rq_addr4),
  .inclock(clk80MHz),
  .outclock(clk80MHz),
  .q(LCB_rq_data4)
);

ReqROM instRQ5(
  .address(LCB_rq_addr5),
  .inclock(clk80MHz),
  .outclock(clk80MHz),
  .q(LCB_rq_data5)
);
endmodule
