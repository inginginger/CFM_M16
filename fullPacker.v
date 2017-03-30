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
	input[4:0] usedwF1,
	input[3:0] usedwF2,
	input[7:0] fData1,
	input[7:0] fData2,
	input[7:0] sData1,
	input[7:0] sData2,
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
reg[10:0] wAddrS1;
reg[10:0] wAddrS2;
reg[11:0] orbWordF1;
reg[11:0] orbWordF2;
reg[11:0] orbWordS1;
reg[11:0] orbWordS2;
reg[5:0] cntPack1;
reg[5:0] cntPack2;


assign doneBus[0] = (usedwF1 == 16) ? 1 : 0;
assign doneBus[1] = (usedwF2 == 15) ? 1 : 0;
assign doneBus[2] = doneS1;
assign doneBus[3] = doneS2;

localparam IDLE = 0, SETF1 = 1, RACKF1 = 2, CLRACKF1 = 3, 
SETF2 = 4, RACKF2 = 5, CLRACKF2 = 6, SETS1 = 7, RACKS1 = 8, 
CLRACKS1 = 9, SETS2 = 10, RACKS2 = 11, CLRACKS2 = 12,
STARTF1 = 13, STARTS1 = 14, STARTF2 = 15, STARTS2 = 16; 

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
		orbWordF1 <= 12'd0;
		orbWordF2 <= 12'd0;
		orbWordS1 <= 12'd0;
		orbWordS2 <= 12'd0;
		wAddrF1 <= 11'd0;
		wAddrF2 <= 11'd0;
		wAddrS1 <= 11'd0;
		wAddrS2 <= 11'd0;
		rAckF1 <= 1'b0;
		rAckF2 <= 1'b0;
		rAckS1 <= 1'b0;
		rAckS2 <= 1'b0;
		wAddr <= 11'd0;
		orbWord <= 12'd0;
		WE <= 1'b0;
	end else begin
		case(state)
			IDLE: //if(doneBus != 4'd0) begin
				case(doneBus)
					1: state <= STARTF1;
					2: state <= STARTF2;
					default: state <= IDLE;
				endcase
			//end
			STARTF1: begin
				orbWordF1 <= {1'b0, fData1, 3'd0};
				wAddrF1 <= rom1[cntWord1] + (cntPack1 << 5);
				state <= SETF1;
			end
			SETF1: begin
				cntWord1 <= cntWord1 + 1'b1;
				if(cntWord1 == 4'd15) begin
					cntPack1 <= cntPack1 + 1'b1;
					cntWord1 <= 4'b0;
				end
				wAddr <= wAddrF1;
				orbWord <= orbWordF1;
				WE <= 1'b1;
				state <= RACKF1;
			end
			RACKF1: begin
				WE <= 1'b0;
				rAckF1 <= 1'b1;
				state <= CLRACKF1;
			end
			CLRACKF1: begin
				rAckF1 <= 1'b0;
				if(usedwF1 == 1) begin//emptyF2 == 1'b1) begin
					state <= IDLE;
					//doneBus[1] <= 1'b0;
				end else
					state <= STARTF1;
			end
			STARTF2: begin
				orbWordF2 <= {1'b0, fData2, 3'd0};
				wAddrF2 <= rom2[cntWord2] + (cntPack2 << 5);
				state <= SETF2;
			end
			SETF2: begin
				cntWord2 <= cntWord2 + 1'b1;
				if(cntWord2 == 4'd14) begin
					cntPack2 <= cntPack2 + 1'b1;
					cntWord2 <= 4'b0;
				end
				wAddr <= wAddrF2;
				orbWord <= orbWordF2;
				WE <= 1'b1;
				state <= RACKF2;
			end
			RACKF2: begin
				WE <= 1'b0;
				rAckF2 <= 1'b1;
				state <= CLRACKF2;
			end
			CLRACKF2: begin
				rAckF2 <= 1'b0;
				if(usedwF2 == 1) begin//emptyF2 == 1'b1) begin
					state <= IDLE;
					//doneBus[1] <= 1'b0;
				end else
					state <= STARTF2;
			end
		endcase
	end
end

endmodule
