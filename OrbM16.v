module OrbM16(
	input clk100MHz,
	input clk80MHz,
	output orbFrame,
	output doubleOrbData,
	
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
	output UART_dRX2        // rs485 RX dir controller
);

wire rst;
wire clkOrb;
wire LCBreq1, LCBreq2;
wire clk4_8MHz;
wire [5:0]cycle;
wire [8:0] LCB_rq_addr1, LCB_rq_addr2;
wire [7:0] LCB_rq_data1, LCB_rq_data2;
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
wire [7:0] DataFromLCB;
wire [11:0] orbWord;
wire testpin2016, testpin1984;
wire [7:0] DataFromLCB1, DataFromLCB2;
wire ValRX1, ValRX2, lenWE;

assign doubleOrbData = orbFrame;//дублирование на контакт, который выводит кадр на стенде
assign test1 = WE1;
assign test2 = test;//SW;//0;//WE2;
assign test3 = lenWE;//WrAddr[1];
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
//assign ValRX = ValRX1 | ValRX2;

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

OrbPacker inst6(
	.clk(clk80MHz),
	.rst(rst),
	.iData1(DataFromLCB1),
	.strob1(ValRX1),
	.iData2(DataFromLCB2),
	.strob2(ValRX2),
	.SW(SW),
	.test(test),
	//.req,
	.orbWord(orbWord),
	.WE(WE),
	.WrAddr(WrAddr),
	.testWE(lenWE),
	.test1(testpin2016),
	.test2(testpin1984)
);

ramM16 inst7(
	.clock(clk80MHz),
	.data(orbWord),
	.rdaddress(RdAddr1),
	.rden(syncRE1[1]),
	.wraddress(WrAddr1),
	.wren(syncWE1[1]),
	.q(MemData1));
	
ramM16 inst8(
	.clock(clk80MHz),
	.data(orbWord),
	.rdaddress(RdAddr2),
	.rden(syncRE2[1]),
	.wraddress(WrAddr2),
	.wren(syncWE2[1]),
	.q(MemData2));

M16 inst9(
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

UARTTXBIG inst10(
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
defparam inst10.BYTES = 5'd4;

UARTTXBIG inst11(
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
defparam inst11.BYTES = 5'd4;

ReqROM inst12(
  .address(LCB_rq_addr1),
  .inclock(clk80MHz),
  .outclock(clk80MHz),
  .q(LCB_rq_data1)
);

ReqROM inst13(
  .address(LCB_rq_addr2),
  .inclock(clk80MHz),
  .outclock(clk80MHz),
  .q(LCB_rq_data2)
);
endmodule
