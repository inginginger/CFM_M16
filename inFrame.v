module inFrame(
	input clk,
	input rst,
	input [10:0] fAddr1,
	input [10:0] fAddr2,
	input [11:0] fWord1,
	input [11:0] fWord2,
	input fWE1,
	input fWE2,
	input [10:0] sAddr1,
	input [10:0] sAddr2,
	input [11:0] sWord1,
	input [11:0] sWord2,
	input sWE1,
	input sWE2,
	input [10:0] tAddr,
	input [11:0] tWord,
	input tWE,
	input SW,
	input RE,
	input [10:0] rAddr,
	input [11:0] memDat1,
	input [11:0] memDat2,
	input val1,
	input val2,
	output reg valRx,
	output reg RE1,
	output reg RE2,
	output reg WE1,
	output reg WE2,
	output reg [11:0] orbData,
	output reg [11:0] orbWord,
	output reg [10:0] wAddr1,
	output reg [10:0] wAddr2,
	output reg [10:0] rAddr1,
	output reg [10:0] rAddr2
	
);

reg [1:0] syncSW;
reg [10:0] wAddr;
reg WE;

always@(posedge clk) begin
	syncSW <= {syncSW[0], SW};
end

always@(posedge clk or negedge rst) begin
	if(~rst) begin
		valRx <= 1'b0;
		orbData <= 12'd0;
		rAddr1 <= 11'd0;
		wAddr1 <= 11'd0;
		RE1 <= 1'b0;
		WE1 <= 1'b0;
		rAddr2 <= 11'd0;
		wAddr2 <= 11'd0;
		RE2 <= 1'b0;
		wAddr <= 11'd0;
		orbWord <= 12'd0;
		WE <= 1'b0;
	end else begin
		valRx <= val1 | val2;
		WE <= fWE1 | fWE2 | sWE1 | sWE2 | tWE;
		
		if(SW == 1'b0) begin
			orbData <= memDat1;
			rAddr1 <= rAddr + 1'b1;
			wAddr2 <= wAddr;
			RE1 <= RE;
			WE2 <= WE;
			rAddr2 <= 11'hx;
			wAddr1 <= 11'hx;
			RE2 <= 1'hx;
			WE1 <= 1'hx;
		end else begin
			orbData <= memDat2;
			rAddr1 <= 11'hx;
			wAddr2 <= 11'hx;
			RE1 <= 1'hx;
			WE2 <= 1'hx;
			rAddr2 <= rAddr + 1'b1;
			wAddr1 <= wAddr;
			RE2 <= RE;
			WE1 <= WE;
		end
		
		if(fWE1 == 1'b1) begin
			wAddr <= fAddr1;
			orbWord <= fWord1;
		end else if (fWE2 == 1'b1) begin
			wAddr <= fAddr2;
			orbWord <= fWord2;
		end else if(sWE1 == 1'b1) begin
			wAddr <= sAddr1;
			orbWord <= sWord1;
		end else if(sWE2 == 1'b1) begin
			wAddr <= sAddr2;
			orbWord <= sWord2;
		end else if(tWE == 1'b1) begin
			wAddr <= tAddr;
			orbWord <= tWord;
		end else begin
			wAddr <= 11'h0;
			orbWord <= 12'd0;
		end
	end
end

endmodule
