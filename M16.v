module M16(
	input reset, 
	input iClkOrb, //100MHz/8
	input [11:0]iWord,//слова от ялк
	output reg [10:0]oAddr,
	output reg oRdEn,
	output reg oSwitch,
	output reg oOrbit,//выходной кадр
	output reg [11:0]oParallel,
	output reg oVal,
	output reg [5:0] cycle,
	output reg oLCB_rq
);

reg [3:0]cntBit;
reg [10:0]cntWrd;
//reg [11:0] cntAddr;
reg [4:0]cntPhr, cntGrp;
reg [6:0]cntFrm;
reg cntMem;
reg [11:0]outWord;
reg [2:0]seq;
reg [11:0] cntLCBrq;

//assign oSwitch = cntAddr[11];

always@(negedge reset or posedge iClkOrb)begin
	if(~reset)begin
		outWord <= 0;
		oAddr <= 0;
		oRdEn <= 0;
		oSwitch <= 0;
		oOrbit <= 0;
		oParallel <= 0;
		oVal <= 0;
		cntBit <= 0;
		cntFrm <= 0;
		cntGrp <= 0;
		cntPhr <= 0;
		cntWrd <= 0;
		seq <= 0;
		cycle <= 0;
		oLCB_rq <= 0;
		cntLCBrq <= 0;
		//cntAddr <= 0;
	end else begin
		seq <= seq + 1'b1;
		case(seq)
			0: begin
				oOrbit <= outWord[11-cntBit];
				if (cntBit == 0) begin
					oParallel <= outWord;
					oVal <= 1;
				end else oVal <= 0;
			end
			1: begin
				if (cntBit == 11) begin
					oAddr <= cntWrd+1'b1;
					outWord <= 12'b0;
				end else if(cntBit == 0)
					oRdEn <= 1;
				cntBit <= cntBit + 1'b1;
			end
			2: begin
				oRdEn <= 0;
				if (cntBit == 12) begin
					cntBit <= 0;
					outWord <= iWord;
					cntWrd <= cntWrd + 1'b1;
					//cntAddr <= cntAddr + 1'b1;
					if (cntWrd == 2047) begin
						//cntWrd <= 0;
						oSwitch <= ~oSwitch;
						cntGrp <= cntGrp + 1'b1;
						if (cntGrp == 31) cntGrp <= 0;
						cntFrm <= cntFrm + 1'b1;
						if (cntFrm == 127) cntFrm <= 0;
					end
					cntPhr <= cntPhr + 1'b1;
					if (cntPhr == 31) cntPhr <= 0;
				end
			end
			3: begin
				
				seq <= 0;
				if (cntBit == 0) begin
					case (cntPhr)
						2,4,6,8,18,24,26,30: outWord <= outWord | 12'b100000000000;
					endcase
					case (cntGrp)
						31: begin
							case (cntWrd)
								1808, 1936, 1968, 2032: outWord <= outWord | 12'b100000000000;
							endcase
						end
						default: begin
							case (cntWrd)
								1840, 1872, 1904, 2000: outWord <= outWord | 12'b100000000000;
							endcase
						end
					endcase
					case (cntFrm)
						0: begin
							case (cntWrd)
								240: outWord <= outWord | 12'b100000000000;
							endcase
						end
					endcase
				end
			end			
		endcase
		cntLCBrq <= cntLCBrq + 1'b1;
		case (cntLCBrq)
			0: oLCB_rq <= 1;
			20: oLCB_rq <= 0;
			1500: cycle <= cycle + 1'b1;
			1535: cntLCBrq <= 0;
		endcase
	end
end
endmodule
