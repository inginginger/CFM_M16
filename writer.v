module writer
#(
  parameter BYTES = 5'd16
)
(
	input clk,
	input rst,
	input[7:0] iData,
	input strob,
	input [10:0] sAddr,
	output[11:0] fData,
	output[11:0] sData,
	output reg fVal,
	output reg sVal
);

reg[1:0] syncStrob;
reg[4:0] cntWord;
reg[11:0] fBuf;
reg[11:0] sBuf;
reg[7:0] tmp;

assign fData = fBuf;
assign sData = sBuf;

always@(posedge clk or negedge rst) begin
	if(~rst)
		syncStrob <= 2'd0;
	else
		syncStrob <= {syncStrob[0], strob};
end

wire dtctStrob = !syncStrob[1] & syncStrob[0];

always@(posedge clk or negedge rst) begin
	if(~rst) begin
		cntWord <= 5'd0;
		fBuf <= 12'd0;
		sBuf <= 12'd0;
		fVal <= 1'b0;
		sVal <= 1'b0;
		tmp <= 8'd0;
	end else begin
		if(dtctStrob == 1)begin
			cntWord <= cntWord + 1'b1;
			if(cntWord < BYTES) begin
				fBuf <= {1'b0, iData, 3'd0};
				fVal <= 1'b1;
			end else if(cntWord == 5'd16) begin
				if(sAddr!= 11'd0)
					tmp <= iData;
			end else if(cntWord == 5'd17)begin
				if(sAddr!= 11'd0) begin
					sBuf <= {1'b0, iData[1:0], tmp, 1'b0};
					sVal <= 1'b1;
				end
				cntWord <= 5'd0;
			end else begin
				tmp <= 8'd0;
				sBuf <= 12'd0;
				fBuf <= 12'd0;
			end
		end else begin
			sVal <= 1'b0;
			fVal <= 1'b0;
		end					
	end
end
endmodule
