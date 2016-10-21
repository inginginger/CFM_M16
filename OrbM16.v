module OrbM16(
	input clk100MHz,
	input clk80MHz,
	output orbFrame,
	//output rst,
	//output clkOrb,
	//output LCBreq, 
	//output clk4_8MHz,
	//output [8:0] LCB_rq_addr,
	output doubleOrbData,
	output ValRX,
	
output test1,
output test2,
output test3,
output test4,
	input UART_RX,
	output UART_TX,          // serial transmitted data
	output UART_dTX,        // rs485 TX dir controller 
	output UART_dRX        // rs485 RX dir controller
	//output [7:0] LCB_rq_data,
	//output [5:0]cycle,
    //output [4:0] switch
	);

wire rst;
wire clkOrb;
wire LCBreq;
wire clk4_8MHz;
wire [5:0]cycle;
wire [8:0] LCB_rq_addr;
wire [7:0] LCB_rq_data;
wire [4:0] switch;
wire [10:0] RdAddr;
wire [10:0] WrAddr;
reg [11:0] OrbData;
wire RE, WE;
wire SW, test;
reg [10:0] RdAddr1;
reg [10:0] RdAddr2;
reg [10:0] WrAddr1;
reg [10:0] WrAddr2;
reg RE1, RE2, WE1, WE2;
wire [11:0] MemData1;
wire [11:0] MemData2;
wire [7:0] DataFromLCB;
wire [11:0] orbWord;
wire testpin2016, testpin1984;

assign doubleOrbData = orbFrame;//дублирование на контакт, который выводит кадр на стенде
//assign DataFromLCB = (!SW)?MemData2:MemData1;
assign test1 = WE1;
assign test2 = test;//SW;//0;//WE2;
assign test3 = testpin1984;//WrAddr[1];
assign test4 = testpin2016;//RE2;//0;//WE2;

reg [1:0] syncRE;    
reg [1:0] syncSW;
reg [1:0] syncWE;
reg [1:0] syncRE1;
reg [1:0] syncRE2;
reg [1:0] syncWE1;
reg [1:0] syncWE2;

always@(posedge clk80MHz)
begin
	syncWE <= {syncWE[0], WE};
	syncWE1 <= {syncWE1[0], WE1};
	syncWE2 <= {syncWE2[0], WE2};
end

always@(posedge clk100MHz)
begin
	syncRE <= {syncRE[0], RE};
	syncSW <= {syncSW[0], SW};
	syncRE1 <= {syncRE1[0], RE1};
	syncRE2 <= {syncRE2[0], RE2};
end

always@(*)
begin
	case(syncSW[1])
		0: begin
			OrbData = MemData1;
			RdAddr1 = RdAddr + 1'b1;
			WrAddr2 = WrAddr;
			RE2 = 1'b0;
			RE1 = syncRE[1];
			//DataFromLCB = MemData2;
			
			WE1 = 1'b0;
			//RE2 = 1'b0;
			WE2 = syncWE[1];
			//RE1 = RE;
			
		end
		1: begin
			OrbData = MemData2;
			RdAddr2 = RdAddr + 1'b1;
			WrAddr1 = WrAddr;
			RE1 = 1'b0;
			RE2 = syncRE[1];
			//DataFromLCB = MemData1;
			
			
			WE2 = 1'b0;
			//RE1 = 1'b0;
			WE1 = syncWE[1];
			//RE2 = RE;
			
		end
	endcase
end

/*always@(posedge clkOrb)
case(SW)
		0: begin
			RE2 <= 1'b0;
			RE1 <= RE;
			
		end
		1: begin
			RE1 <= 1'b0;
			RE2 <= RE;
			
		end
	endcase
*/
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
	.RX(UART_RX),
	.oValid(ValRX),
	.oData(DataFromLCB)
);

OrbPacker inst5(
	.clk(clk80MHz),
	.rst(rst),
	.iData(DataFromLCB),
	.strob(ValRX),
	.SW(SW),
	.test(test),
	//.req,
	.orbWord(orbWord),
	.WE(WE),
	.WrAddr(WrAddr),
	.test1(testpin2016),
	.test2(testpin1984)
);

ramM16 inst6(
	.clock(clk80MHz),
	.data(orbWord),
	.rdaddress(RdAddr1),
	.rden(syncRE1[1]),
	.wraddress(WrAddr1),
	.wren(syncWE1[1]),
	.q(MemData1));
	
ramM16 inst7(
	.clock(clk80MHz),
	.data(orbWord),
	.rdaddress(RdAddr2),
	.rden(syncRE2[1]),
	.wraddress(WrAddr2),
	.wren(syncWE2[1]),
	.q(MemData2));

M16 inst8(
	.reset(rst), 
	.iClkOrb(clkOrb), //100MHz/8
	.iWord(OrbData),
	.oAddr(RdAddr),
	.oRdEn(RE),
	.oSwitch(SW),
	.oLCB_rq(LCBreq),      // start transfer signal
	.cycle(cycle),
	.oOrbit(orbFrame)
);

UARTTXBIG inst9(
  .reset(rst),          // global reset and enable signal
  .clk(clk4_8MHz),            // actual needed baudrate
  .RQ(LCBreq),
  .cycle(cycle + 1'b1),  // number of the request (from m8) + shift, to give LCB time to respond
  .data(LCB_rq_data),      // data to transmit (from ROM)
  .addr(LCB_rq_addr),      // address to read (to ROM)
  .tx(UART_TX),          // serial transmitted data
  .dirTX(UART_dTX),        // rs485 TX dir controller 
  .dirRX(UART_dRX),        // rs485 RX dir controller
  .switch(switch)
);
defparam inst9.BYTES = 5'd4;

ReqROM inst10(
  .address(LCB_rq_addr),
  .inclock(clk80MHz),
  .outclock(clk80MHz),
  .q(LCB_rq_data)
);
endmodule
