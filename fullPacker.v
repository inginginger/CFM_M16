module fullPacker(
	input clk,
	input rst,
	input doneF1,
	input doneF2,
	input doneS1,
	input doneS2,
	input emptyF1,
	input emptyF2,
	input emptyS1,
	input emptyS2,
	input [10:0] sAddr1,
	input [10:0] sAddr2,
	input[4:0] usedwF1,
	input[4:0] usedwF2,
	input usedwS1,
	input usedwS2,
	input[11:0] fData1,
	input[11:0] fData2,
	input[11:0] sData1,
	input[11:0] sData2,
	input SW,
	output reg rAckF1,
	output reg rAckS1,
	output reg rAckF2,
	output reg rAckS2,
	output reg[10:0] wAddr,
	output reg[11:0] orbWord, 
	output reg WE
);

wire[3:0] doneBus;
reg[4:0] rom1 [15:0];
reg[4:0] rom2 [14:0];
reg[3:0] cntWord1;
reg[3:0] cntWord2;
reg[4:0] state;
reg[10:0] wAddrF1;
reg[10:0] wAddrF2;
reg[5:0] cntPack1;
reg[5:0] cntPack2;
reg [2:0] cntS1, cntS2, cntF1, cntF2;
reg [4:0] pause;
reg oldSW;


assign doneBus[0] = (usedwF1 == 5'd16) ? 1'b1 : 1'b0;
assign doneBus[1] = (usedwF2 == 5'd15) ? 1'b1 : 1'b0;
assign doneBus[2] = (usedwS1 == 1'b1) ? 1'b1 : 1'b0;
assign doneBus[3] = (usedwS2 == 1'b1) ? 1'b1 : 1'b0;

localparam IDLE = 0, STARTF1 = 1, STARTS1 = 3, STARTF2 = 2, STARTS2 = 4, WAIT = 5; 

always@(posedge clk) begin
	rom1[0] <= 0;
	rom1[1] <= 4;
	rom1[2] <= 8;
	rom1[3] <= 12;
	rom1[4] <= 16;
	rom1[5] <= 20;
	rom1[6] <= 24;
	rom1[7] <= 28;
	rom1[8] <= 2;
	rom1[9] <= 6;
	rom1[10] <= 10;
	rom1[11] <= 14;
	rom1[12] <= 18;
	rom1[13] <= 22;
	rom1[14] <= 26;
	rom1[15] <= 30;
	rom2[0] <= 1;
	rom2[1] <= 5;
	rom2[2] <= 9;
	rom2[3] <= 13;
	rom2[4] <= 17;
	rom2[5] <= 21;
	rom2[6] <= 25;
	rom2[7] <= 29;
	rom2[8] <= 3;
	rom2[9] <= 7;
	rom2[10] <= 11;
	rom2[11] <= 15;
	rom2[12] <= 19;
	rom2[13] <= 23;
	rom2[14] <= 27;
	
end

/*always@(*) begin
	case(doneBus)
		1: begin
			wAddr = wAddrF1;
			orbWord = orbWordF1;
		end
		2: begin
			wAddr = wAddrF2;
			orbWord = orbWordF2;
		end
		4: begin
			wAddr = wAddrS1;
			orbWord = orbWordS1;
		end
		8: begin
			wAddr = wAddrS2;
			orbWord = orbWordS2;
		end
		default: begin
			wAddr = 11'd0;
			orbWord = 12'd0;
		end
	endcase
end*/


always@(posedge clk or negedge rst) begin
	if(~rst) begin
		cntWord1 <= 4'd0;
		cntWord2 <= 4'd0;
		cntPack1 <= 6'd0;
		cntPack2 <= 6'd0;
		state <= 5'd0;
		wAddrF1 <= 11'd0;
		wAddrF2 <= 11'd0;
		rAckF1 <= 1'b0;
		rAckF2 <= 1'b0;
		rAckS1 <= 1'b0;
		rAckS2 <= 1'b0;
		wAddr <= 11'd0;
		orbWord <= 12'd0;
		WE <= 1'b0;
		cntS1 <= 3'd0;
		cntS2 <= 3'd0;
		cntF1 <= 3'd0;
		cntF2 <= 3'd0;
		pause <= 5'd0;
		oldSW <= 1'b0;
	end else begin
		if(SW != oldSW) begin
			state <= 5'd0;
			rAckS1 <= 1'b0;
			rAckS2 <= 1'b0;
			wAddr <= 11'd0;
			orbWord <= 12'd0;
			WE <= 1'b0;
		end
		oldSW <= SW;
		case(state)
			IDLE:  begin
				rAckS2 <= 1'b0;
				rAckS1 <= 1'b0;
				if(doneBus[0] == 1)
					state<= STARTF1;
				else if(doneBus[1] == 1)
					state <= STARTF2;
				else if(doneBus[2] == 1)
					state <= STARTS1;
				else if(doneBus[3] == 1)
					state <= STARTS2;
				else
					state <= IDLE;
			end
			STARTF1: begin
				cntF1 <= cntF1 + 1'b1;
				case(cntF1)
					0: begin
						wAddrF1 <= rom1[cntWord1] + (cntPack1 << 5);
					end
					1: begin
						cntWord1 <= cntWord1 + 1'b1;
						if(cntWord1 == 4'd15) begin
							cntPack1 <= cntPack1 + 1'b1;
							cntWord1 <= 4'd0;
						end
					end
					2: begin
						wAddr <= wAddrF1;
						orbWord <= fData1;
						rAckF1 <= 1'b1;
						
					end
					3: begin
						WE <= 1'b1;
						rAckF1 <= 1'b0;
					end
					4: begin						
						WE <= 1'b0;
						if(usedwF1 == 0) begin
							state <= WAIT;
						end else
							state <= STARTF1;
						cntF1 <= 3'd0;
					end
				endcase
			end
			STARTF2: begin
				cntF2 <= cntF2 + 1'b1;
				case(cntF2)
					0: begin
						wAddrF2 <= rom2[cntWord2] + (cntPack2 << 5);
					end
					1: begin
						cntWord2 <= cntWord2 + 1'b1;
						if(cntWord2 == 4'd14) begin
							cntPack2 <= cntPack2 + 1'b1;
							cntWord2 <= 4'd0;
						end
					end
					2: begin
						wAddr <= wAddrF2;
						orbWord <= fData2;
						rAckF2 <= 1'b1;
						
					end
					3: begin
						WE <= 1'b1;
						rAckF2 <= 1'b0;
					end
					4: begin						
						WE <= 1'b0;
						if(usedwF2 == 0) begin
							state <= WAIT;
						end else
							state <= STARTF2;
						cntF2 <= 3'd0;
					end
				endcase
			end
			WAIT: begin
				pause <= pause + 1'b1;
				if(pause == 5'd31) begin
					state <= IDLE;
					wAddr <= 11'd0;
					orbWord <= 12'd0;
				end
			end
			STARTS1: begin
				cntS1 <= cntS1 + 1'b1;
				case(cntS1)
					3: begin
						if(sAddr1 != 11'd0) begin
							wAddr <= sAddr1;
							orbWord <= sData1;
							rAckS1 <= 1'b1;
						end else begin
							cntS1 <= 0;
							rAckS1 <= 1'b1;
							wAddr <= 11'd0;
							state <= IDLE;
							/*wAddrS1 <= 11'd0;
							orbWordS1 <= 12'd0;
							orbWord <= 12'd0;
							wAddr <= 11'd0;*/
						end
					end
					4: begin
						rAckS1 <= 1'b0;
						WE <= 1'b1;
					end
					6: begin 
						WE <= 1'b0;
						
					end
					7: begin
						cntS1 <= 0;
						/*wAddrS1 <= 11'd0;
						orbWordS1 <= 12'd0;
						orbWord <= 12'd0;
						wAddr <= 11'd0;*/
						state <= WAIT;
					end
				endcase
			end
			STARTS2: begin
				cntS2 <= cntS2 + 1'b1;
				case(cntS2)
					3: begin
						if(sAddr2 != 11'd0) begin
							wAddr <= sAddr2;
							orbWord <= sData2;
							rAckS2 <= 1'b1;
						end else begin
							cntS2 <= 0;
							wAddr <= 11'd0;
							rAckS2 <= 1'b1;
							state <= IDLE;
							/*wAddrS1 <= 11'd0;
							orbWordS1 <= 12'd0;
							orbWord <= 12'd0;
							wAddr <= 11'd0;*/
						end
					end
					4: begin
						rAckS2 <= 1'b0;
						WE <= 1'b1;
					end
					6: begin 
						WE <= 1'b0;
						
					end
					7: begin
						cntS2 <= 0;
						/*wAddrS1 <= 11'd0;
						orbWordS1 <= 12'd0;
						orbWord <= 12'd0;
						wAddr <= 11'd0;*/
						state <= WAIT;
					end
				endcase
			end
		endcase
	end
end

endmodule
