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

wire rst,f1,f2,f3,f4,f5;
wire clkOrb, sel, testIO;
wire RqFast, RqSlow, RqTemp, RqSlow1Hz;
wire clk4_8MHz, clk5MHz;
wire [5:0]cycle;
wire [6:0] tempAddr;
wire [8:0] LCB_rq_addr1, LCB_rq_addr2, LCB_rq_addr3, LCB_rq_addr4, LCB_rq_addr5, fastAddr;
wire [7:0]  LCB_rq_data1, LCB_rq_data2, LCB_rq_data3, LCB_rq_data4, LCB_rq_data5, LCBdata, tempData;
wire [7:0] txData;
wire [2:0] switch1, switch2;
wire [10:0] RdAddr;
wire [10:0] WrAddr;
reg [11:0] OrbData;
wire RE, ack, rqRom;
wire WE;
wire SW, test;
reg [10:0] RdAddr1;
reg [10:0] RdAddr2;
reg [10:0] WrAddr1;
reg [10:0] WrAddr2;
reg RE1, RE2, WE1, WE2;
wire WEfast1, WEfast2, WEslow1, WEslow2;
wire [11:0] MemData1;
wire [11:0] MemData2;
wire [11:0] orbWord;
wire [11:0] fastWord1, fastWord2, slowWord1, slowWord2;
wire testpin2016, testpin1984;
wire [7:0] DataFromLCB1, DataFromLCB2, DataFromLCB3, DataFromLCB4, DataFromLCB5;
wire ValRX1, ValRX2, ValRX3, ValRX4, ValRX5, testVal1, testVal2;
wire [5:0] adrCycle;
wire [10:0] FastAddr1, FastAddr2, SlowAddr1, SlowAddr2;
wire testSlow1, testSlow2;
reg [1:0] syncRE1;
reg [1:0] syncRE2;
reg [1:0] syncWE1;
reg [1:0] syncWE2;
wire [10:0] addrRamGr1,addrRamGr2;
wire [7:0] iUART1, iUART2, iUART3, iUART4, iUART5, oUART1, oUART2, oUART3, oUART4, oUART5;
wire [4:0] WAdr1, WAdr2, WAdr3, WAdr4, WAdr5, RAdr1, RAdr2, RAdr3, RAdr4, RAdr5;
wire RD1, RD2, RD3, RD4, RD5, WR1, WR2, WR3, WR4, WR5;
wire done1, done2, done3, done4, done5, busy;
wire [10:0] iTempAddr, oTempAddr;
wire [6:0] swTemp;
wire [11:0] tempWord;
wire WEtemp;
wire [11:0] fData1, fData2, oFastData1, oFastData2;
wire [11:0] sData1, sData2,oSlowData1, oSlowData2;
wire fVal1, fVal2, sVal1, sVal2;
wire rqF1, rqF2, rqS1, rqS2, fDone1, fDone2, sDone1, sDone2;
wire [4:0] oTestF1, oTestF2;
wire oTestS1, oTestS2;

assign iTempAddr  = (swTemp == 7'd110) ? 11'd1215 : 11'd0;
//assign ValRx = ValRX1;

//assign WE = WEfast1 | WEfast2/* | WEslow1 | WEslow2;// | WEtemp*/;
assign doubleOrbData = orbFrame;//aoaee?iaaiea ia eiioaeo, eioi?ue auaiaeo eaa? ia noaiaa
assign test1 = (oTestF1 == 16) ? 1 : 0;//WE;//ValRX1;//UART_dTX1;//testVal1;
assign test2 = (oTestF2 == 15) ? 1 : 0;//ValRX;//testIO;//UART_dTX2;//testVal2;//SW;//0;//WE2;
assign test3 = oTestS1;//WE;//busy;//WE;//testpin1984;//WrAddr[1];
assign test4 = oTestS2;//WR1;//testpin2016;//RE2;//0;//WE2;

/*assign WrAddr = (WEfast1 == 1'b1)? FastAddr1:((WEfast2 == 1'b1)? FastAddr2:((WEslow1 == 1'b1)? SlowAddr1: ((WEslow2 == 1'b1) ? SlowAddr2 : ((WEtemp == 1'b1) ? oTempAddr :11'hZ))));
assign orbWord = (WEfast1 == 1'b1)? fastWord1:((WEfast2 == 1'b1)? fastWord2:((WEslow1 == 1'b1)? slowWord1: ((WEslow2 == 1'b1) ? slowWord2 : ((WEtemp == 1'b1) ? tempWord :12'hZ))));
*/

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

/*always@(posedge clk80MHz) begin
	if(WEfast1 == 1'b1) begin
		WrAddr <= FastAddr1;
		orbWord <= fastWord1;
	end else
	if(WEfast2 == 1'b1) begin
		WrAddr <= FastAddr2;
		orbWord <= fastWord2;*/
	/*end else
	if(WEslow1 == 1'b1) begin
		WrAddr <= SlowAddr1;
		orbWord <= slowWord1;
	end else
	if(WEslow2 == 1'b1) begin
		WrAddr <= SlowAddr2;
		orbWord <= slowWord2;*/
	/*end else begin
		WrAddr <= 0;
		orbWord <= 0;
	end*/
	/*if(WEtemp == 1'b1) begin
		WrAddr <= oTempAddr;
		orbWord <= tempWord;
	end*/
	//WE <= WEfast1 | WEfast2 | WEslow1 | WEslow2;// | WEtemp;
	//ValRX <= ValRX1 | ValRX2 | ValRX3 | ValRX4 | ValRX5;

//end

always@(*) begin
	if(~SW) begin
		OrbData = MemData1;
		RdAddr1 = RdAddr + 1'b1;
		WrAddr2 = WrAddr;
		RE1 = RE;
		WE2 = WE;
		RdAddr2 = 11'hx;
		WrAddr1 = 11'hx;
		RE2 = 1'hx;
		WE1 = 1'hx;
	end else begin
		OrbData = MemData2;
		RdAddr2 = RdAddr + 1'b1;
		WrAddr1 = WrAddr;
		RE2 = RE;
		WE1 = WE;
		RdAddr1 = 11'hx;
		WrAddr2 = 11'hx;
		RE1 = 1'hx;
		WE2 = 1'hx;
	end

end

assign ValRX = ValRX1 | ValRX2/* | ValRX3 | ValRX4 | ValRX5*/;

globalReset instRST(
	.clk(clk80MHz),				// 40 MHz
	.rst(rst)			// global enable
);

clkDiv21 instClkDiv21(
    .rst(rst),
	.clk100MHz(clk100MHz),
	.clk80MHz(clk80MHz),
    .oClk4_8(clk4_8MHz),
    .oClk5(clk5MHz)
    );

clkDiv100 instClkDiv100(
	.reset(rst),
	.iClkIN(clk100MHz),			// whatever clock
	.Outdiv8(clkOrb)			// divided by 8
);	


uartRx instRX1(
	.clk(clk80MHz),
	.rstTx(f1),
	.rst(rst),
	.rx(UART_RX1),
	.oValid(ValRX1),
	.oData(iUART1)
);

uartRx instRX2(
	.clk(clk80MHz),
	.rstTx(f2),
	.rst(rst),
	.rx(UART_RX2),
	.oValid(ValRX2),
	.oData(iUART2)
);

writer instWrUart1(
	.clk(clk80MHz),
	.rst(rst),
	.iData(iUART1),
	.strob(ValRX1),
	.sAddr(addrRamGr1),
	.fData(fData1),
	.sData(sData1),
	.fVal(fVal1),
	.sVal(sVal1)
);
defparam instWrUart1.BYTES = 5'd16;

writer instWrUart2(
	.clk(clk80MHz),
	.rst(rst),
	.iData(iUART2),
	.strob(ValRX2),
	.sAddr(addrRamGr2),
	.fData(fData2),
	.sData(sData2),
	.fVal(fVal2),
	.sVal(sVal2)
);
defparam instWrUart2.BYTES = 5'd15;


fifoF1 instFastFifo1(
	.clock(clk80MHz),
	.data(fData1),
	.rdreq(rqF1),
	.sclr(1'b0),
	.wrreq(fVal1),
	.q(oFastData1),
	.usedw(oTestF1));
	
fifoS instSlowFifo1(
	.clock(clk80MHz),
	.data(sData1),
	.rdreq(rqS1),//from FullPacker
	.sclr(1'b0),
	.wrreq(sVal1),//valid
	.q(oSlowData1),//oData
	.usedw(oTestS1));

fifoF1 instFastFifo2(
	.clock(clk80MHz),
	.data(fData2),
	.rdreq(rqF2),
	.sclr(1'b0),
	.wrreq(fVal2),
	.q(oFastData2),
	.usedw(oTestF2));
	
fifoS instSlowFifo2(
	.clock(clk80MHz),
	.data(sData2),
	.rdreq(rqS2),//from FullPacker
	.sclr(1'b0),
	.wrreq(sVal2),//valid
	.q(oSlowData2),//oData
	.usedw(oTestS2));

fullPacker instPackerFull(
	.clk(clk80MHz),
	.rst(rst),
	.usedwF1(oTestF1),
	.usedwF2(oTestF2),
	.usedwS1(oTestS1),
	.usedwS2(oTestS2),
	.sAddr1(addrRamGr1),
	.sAddr2(addrRamGr2),
	.fData1(oFastData1),
	.fData2(oFastData2),
	.sData1(oSlowData1),
	.sData2(oSlowData2),
	.rAckF1(rqF1),
	.rAckS1(rqS1),
	.rAckF2(rqF2),
	.rAckS2(rqS2),
	.wAddr(WrAddr),
	.orbWord(orbWord),
	.WE(WE),
	.SW(SW)
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


wire rstWr1, rstWr2;


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
	.RqFast(RqFast),
	.cycle(cycle),
	.oOrbit(orbFrame),
	.swTemp(swTemp)
);
wire [2:0] swsel;

assign swsel = switch1;

UARTTXBIG instTX1(
  .reset(rst),          // global reset and enable signal
  .full(f1),
  .clk(clk4_8MHz),            // actual needed baudrate
  .RQ(RqFast),
  .cycle(cycle),  // number of the request (from m8) + shift, to give LCB time to respond
  .data(txData),      // data to transmit (from ROM)
  .addr(LCB_rq_addr1),      // address to read (to ROM)
  .tx(UART_TX1),          // serial transmitted data
  .dirTX(UART_dTX1),        // rs485 TX dir controller 
  .dirRX(UART_dRX1),        // rs485 RX dir controller
  .switch(switch1)
);
defparam instTX1.BYTES = 5'd4;


UARTTXBIG instTX2(
  .reset(rst),          // global reset and enable signal
  .full(f2),
  .clk(clk4_8MHz),            // actual needed baudrate
  .RQ(RqFast),
  .cycle(cycle),  // number of the request (from m8) + shift, to give LCB time to respond
  .data(LCB_rq_data2),      // data to transmit (from ROM)
  .addr(LCB_rq_addr2),      // address to read (to ROM)
  .tx(UART_TX2),          // serial transmitted data
  .dirTX(UART_dTX2),        // rs485 TX dir controller 
  .dirRX(UART_dRX2),        // rs485 RX dir controller
  .switch(switch2)
);
defparam instTX2.BYTES = 5'd4;

answerLCS instTempRQ(
	.clk(clk4_8MHz),
	.rst(rst),
	.req(RqFast),
	.dataLCS(LCB_rq_data1),
	.dataTemp(tempData),
	.dataTx(txData),
	.sel(swsel),
	.addrTemp(tempAddr)
);

romRqAdr instRomAdr1(
	.address({SW,cycle}),
	.inclock(clk80MHz),
	.outclock(clk80MHz),
	.q(addrRamGr1)
);
romRqAdr2 instRomAdr2(
	.address(cycle),
	.inclock(clk80MHz),
	.outclock(clk80MHz),
	.q(addrRamGr2)
);

reqMem instRqMem1(
  .address(LCB_rq_addr1),
  .inclock(clk80MHz),
  .outclock(clk80MHz),
  .q(LCB_rq_data1)
);

tempROM instRQtemp(
  .address(tempAddr),
  .inclock(clk80MHz),
  .outclock(clk80MHz),
  .q(tempData)
);

reqMem instRqMem2(
  .address(LCB_rq_addr2),
  .inclock(clk80MHz),
  .outclock(clk80MHz),
  .q(LCB_rq_data2)
);

endmodule
