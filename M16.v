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
	output reg RqSlow,
	output reg RqFast,
	output reg sel,
	output reg Min,
	output [6:0] swTemp
);

reg [3:0]cntBit;
reg [10:0]cntWrd;
//reg [11:0] cntAddr;
reg [4:0]cntPhr, cntGrp;
reg [6:0]cntFrm;
reg cntMem;
reg [11:0]outWord;
reg [2:0]seq;
reg [11:0] cntRqFast;
reg [15:0] cntRqSlow;
reg [2:0] cntTemp;
reg [8:0] cntMin;

assign swTemp = (cntTemp << 6) + cycle;

always@(negedge reset or posedge iClkOrb)begin
	if(~reset)begin
		outWord <= 12'd0;
		oAddr <= 11'd0;
		oRdEn <= 1'd0;
		oSwitch <= 1'd0;
		oOrbit <= 1'd0;
		oParallel <= 12'd0;
		oVal <= 1'd0;
		cntBit <= 4'd0;
		cntFrm <= 7'd0;
		cntGrp <= 5'd0;
		cntPhr <= 5'd0;
		cntWrd <= 11'd0;
		seq <= 3'd0;
		cycle <= 6'd0;
		RqFast <= 1'd0;
		RqSlow <= 1'd0;
		cntRqFast <= 12'd0;
		cntRqSlow <= 16'd0;
		sel <= 1'b0;
		cntTemp <= 3'd0;
		Min <= 1'b0;
		cntMin <= 9'd0;
	end else begin
		seq <= seq + 1'b1;
		case(seq)
			0: begin
				oOrbit <= outWord[4'd11-cntBit];
				if (cntBit == 4'd0) begin
					oParallel <= outWord;
					oVal <= 1'b1;
				end 
				else begin 
					oVal <= 1'b0;
				end
			end
			1: begin
				if (cntBit == 4'd11) begin
					oAddr <= cntWrd+1'b1;
					outWord <= 12'b0;
				end 
				else if(cntBit == 4'd0) begin
					oRdEn <= 1'b1;
				end
				cntBit <= cntBit + 1'b1;
			end
			2: begin
				oRdEn <= 1'd0;
				if (cntBit == 4'd12) begin
					cntBit <= 4'd0;
					outWord <= iWord;
					cntWrd <= cntWrd + 1'b1;
					if (cntWrd == 11'd2047) begin
						oSwitch <= ~oSwitch;
						cntGrp <= cntGrp + 1'b1;
						if (cntGrp == 31) begin
							cntGrp <= 5'd0;
						end
						cntFrm <= cntFrm + 1'b1;
						if (cntFrm == 127) begin
							cntFrm <= 7'd0;
						end
					end
					cntPhr <= cntPhr + 1'b1;
					if (cntPhr == 31) begin
						cntPhr <= 5'd0;
					end
				end
			end
			3: begin
				
				seq <= 0;
				if (cntBit == 4'd0) begin
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
		cntRqFast <= cntRqFast + 1'b1;
		case (cntRqFast)
			0: RqFast <= 1'd1;
			20: RqFast <= 1'd0;
			1530: begin
				cycle <= cycle + 1'b1;
				if(cycle == 6'd63) begin
					cntTemp <= cntTemp + 1'b1;
					if(cntTemp == 3'd7) begin
						sel <= 1'b1;
					end
				end
				else if(cycle == 6'd0) begin
					sel <= 1'b0;
				end
			end
			1535:  begin 
				cntRqFast <= 11'd0;
			end
		endcase
		cntRqSlow <= cntRqSlow + 1'b1;
		case (cntRqSlow)
			0: begin 
				RqSlow <= 1'd1;
			end
			1970: begin
				
				cntMin <= cntMin + 1'b1;
				if(cntMin == 9'd511)
					Min <= 1'b1;
			end
			2000: begin
				Min <= 1'b0;
			end
			2048: begin
				RqSlow <= 1'd0;
			end
			24575: cntRqSlow <= 16'd0;
		endcase
	end
end
endmodule
