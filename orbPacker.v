module OrbPacker(
input clk,
input rst,
input done,
input [5:0] cycle,
input [7:0] RqData,
input [7:0] iData1,
input [7:0] iData2,
input [7:0] iData3,
input [7:0] iData4,
input [7:0] iData5,
input [10:0] slowAddr,
input strob1,
input strob2,
input strob3,
input strob4,
input strob5,
input req,
input SW,
output reg SlowRcv,
output reg test,
output reg [11:0] orbWord,
output WE,
output reg [10:0] WrAddr,
output reg testWE,
output reg test1,
output reg test2

);

reg [1:0] syncStr1;
reg [1:0] syncStr2;
reg [1:0] syncSW;
reg [4:0] cntWrd1;
reg [4:0] cntWrd2;
reg [4:0] cntWrdSlow;
reg [5:0] cntPack1;
reg [5:0] cntPack2;
reg [1:0] state1;
reg [1:0] state2;
reg [1:0] stateslow;
reg [3:0] cntAddr1;
reg [3:0] cntAddr2;
reg oldSW;
reg [4:0] cntWE1;
reg [4:0] cntWE2;
reg [5:0] cntWEslow;
reg [10:0] WrAddr1;
reg [10:0] WrAddr2;
reg WE1, WE2, WEslow;
reg [11:0] orbWord1,orbWord2;
reg [7:0] tmp17;

reg [10:0] AddrSlow;
reg [11:0] orbWordSlow;

//assign WrAddr = WrAddr1 | WrAddr2;
//assign WE = WE1 | WE2;

localparam IDLE1 = 2'd0, WESET1 = 2'd1, WAIT1 = 2'd2;
localparam IDLE2 = 2'd0, WESET2 = 2'd1, WAIT2 = 2'd2;
localparam IDLESLOW = 2'd0, WESLOW = 2'd1, WAITSLOW = 2'd2;

assign WE = WE1 | WE2 | WEslow;

always@(posedge clk)
begin
syncStr1 <= {syncStr1[0], strob1};
syncStr2 <= {syncStr2[0], strob2};
syncSW <= {syncSW[0], SW};
end

always@(posedge clk or negedge rst)
begin
	if(~rst) begin
		SlowRcv <= 0;
		orbWordSlow <= 12'd0;
		orbWord1 <= 12'd0;
		orbWord2 <= 12'd0;
		WE1 <= 1'd0;
		WE2 <= 1'd0;
		WrAddr1 <= 11'd0;
		WrAddr2 <= 11'd0;
		cntWrd1 <= 5'd0;
		cntWrd2 <= 5'd0;
		cntWrdSlow <= 5'd0;
		cntPack1 <= 6'd0;
		cntPack2 <= 6'd0;
		state1 <= 2'd0;
		state2 <= 2'd0;
		stateslow <= 2'd0;
		cntAddr1 <= 4'd0;
		cntAddr2 <= 4'd0;
		oldSW <= 1'b0;
		test <= 1'b0;
		cntWE1 <= 5'd0;
		cntWE2 <= 5'd0;
		cntWEslow <= 6'd0;
		test1 <= 1'b0;
		test2 <= 1'b0;
		testWE <= 1'b0;
		tmp17 <= 8'd0;
		WEslow <= 1'b0;
		AddrSlow <= 11'd0;
	end
	else begin
		if(syncSW[1] != oldSW) begin
			cntAddr1 <= 4'd0;
			cntAddr2 <= 4'd0;
			cntPack1 <= 6'd0;
			cntPack2 <= 6'd0;
			cntWrd1 <= 5'd0;
			cntWrd2 <= 5'd0;
			cntWrdSlow <= 5'd0;
			test <= 1'b1;
			cntWE1 <= 5'd0;
			cntWE2 <= 5'd0;
			cntWEslow <= 6'd0;
		end
		else test <= 1'b0;
		oldSW <= syncSW[1];
		
		if(WE1 == 1'b1) begin
			WrAddr <= WrAddr1;
			orbWord <= orbWord1;
		end
		else if(WE2 == 1'b1) begin
			WrAddr <= WrAddr2;
			orbWord <= orbWord2;
		end
		else if(WEslow == 1'b1) begin
			WrAddr <= AddrSlow;
			orbWord <= orbWord1;
		end
		
		case(state1)
			IDLE1: begin
				if(syncStr1[1]) begin
					cntWrd1 <= cntWrd1 + 1'b1;
					case(cntWrd1)
						0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15: begin
							orbWord1 <= {1'b0, iData1, 3'd0};
							WrAddr1 <= (cntAddr1 << 1) + (cntPack1 << 5);
							cntAddr1 <= cntAddr1 + 1'b1;
							state1 <= WESET1;
						end
						16, 17, 18: state1 <= WAIT1;
						19: begin
							cntPack1 <= cntPack1 + 1'b1;
							cntWrd1 <= 5'd0;		
							state1 <= WAIT1;				
						end
					endcase					
				end
			end
			WESET1: begin
				cntWE1 <= cntWE1 + 1'b1;
				if(cntWE1 == 5'd13)
					WE1 <= 1'b1;
				else if(cntWE1 == 5'd16)
					WE1 <= 1'b0;
				else if(cntWE1 == 5'd31) begin
					cntWE1 <= 5'd0;
					state1 <= WAIT1;
				end
			end
			WAIT1: begin
				if(WrAddr1 == 11'd2016)
					test1 <= 1'b1;
				else if(WrAddr1 == 11'd0)
					test2 <= 1'b1;
				else begin
					test1 <= 1'b0;
					test2 <= 1'b0;
				end
				if(~syncStr1[1]) begin
					testWE <= 1'b0;
					state1 <= IDLE1;
				end
			end
		endcase
		
		
		case(state2)
			IDLE2: begin
				if(syncStr2[1]) begin
					cntWrd2 <= cntWrd2 + 1'b1;
					case(cntWrd2)
						0,1,2,3,4,5,6,7,8,9,10,11,12,13,14: begin
							orbWord2 <= {1'b0, iData2, 3'd0};
							WrAddr2 <= ((cntAddr2 << 1) + 1'b1) + (cntPack2 << 5);
							cntAddr2 <= cntAddr2 + 1'b1;
							if(cntAddr2 == 4'd14)
								cntAddr2 <= 4'd0;
							state2 <= WESET2;
						end
						15, 16, 17, 18: state2 <= WAIT2;
						19: begin
							cntPack2 <= cntPack2 + 1'b1;
							cntWrd2 <= 5'd0;		
							state2 <= WAIT2;				
						end
					endcase					
				end
			end
			WESET2: begin
				cntWE2 <= cntWE2 + 1'b1;
				if(cntWE2 == 5'd13)
					WE2 <= 1'b1;
				else if(cntWE2 == 5'd16)
					WE2 <= 1'b0;
				else if(cntWE2 == 5'd31) begin
					cntWE2 <= 5'd0;
					state2 <= WAIT2;
				end
			end
			WAIT2: begin
				if(~syncStr2[1]) begin
					state2 <= IDLE2;
				end
			end
		endcase	
		if(cntWrd1 == 5'd16)
			tmp17 <= iData1;
		else if(cntWrd1 == 5'd17) begin
			orbWord1 <= {1'b0, tmp17, iData1[7:6], 1'b0};
			AddrSlow <= slowAddr;
			cntWEslow <= cntWEslow + 1'b1;
				if(cntWEslow == 6'd13)
					WEslow <= 1'b1;
				else if(cntWEslow == 6'd16)
					WEslow <= 1'b0;
				else if(cntWEslow == 6'd63)
					cntWEslow <= 6'd0;
		end
		else WEslow <= 1'b0;
			
	end
end

endmodule
