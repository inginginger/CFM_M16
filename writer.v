module writer(
	input clk,
	input rst,
	input[7:0] iData,
	input strob,
	output[7:0] fData,
	output[7:0] sData,
	output reg fVal,
	output reg sVal
);

reg[1:0] syncStrob;
reg[4:0] cntWord;
reg[7:0] fBuf;
reg[7:0] sBuf;

assign fData = fBuf;
assign sData = sBuf;

always@(posedge clk or negedge rst) begin
	if(~rst)
		syncStrob <= 3'd0;
	else
		syncStrob <= {syncStrob[0], strob};
end

wire dtctStrob = !syncStrob[1] & syncStrob[0];

always@(posedge clk or negedge rst) begin
	if(~rst) begin
		cntWord <= 5'd0;
		fBuf <= 8'd0;
		sBuf <= 8'd0;
		fVal <= 1'b0;
		sVal <= 1'b0;
	end else begin
		if(dtctStrob == 1)begin
			cntWord <= cntWord + 1'b1;
			if(cntWord < 16) begin
				fBuf <= iData;
				fVal <= 1'b1;
			end else if(cntWord == 5'd16) begin
				sBuf <= iData;
				sVal <= 1'b1;
			end else if(cntWord == 5'd17)begin
				sBuf <= iData;
				sVal <= 1'b1;
				cntWord <= 5'd0;
			end else begin
				sBuf <= 8'd0;
				fBuf <= 8'd0;
			end
		end else begin
			sVal <= 1'b0;
			fVal <= 1'b0;
		end					
	end
end
endmodule
