module commutatorCC40(
	input clk,
	input rst,
	input [10:0] sAddr,
	input [11:0] sData,
	output reg req
	
);

reg[26:0] globalCnt;
reg[4:0] cnt1sec;
reg sign;
reg[4:0] pause;
reg ena;
reg once;

always@(posedge clk or negedge rst) begin
	if(~rst) begin
		sign <= 1'b0;
		cnt1sec <= 5'd0;
		globalCnt <= 27'd0;
		req <= 1'b0;
		pause <= 5'd0;
		ena <= 1'b0;
		once <= 1'b0;
	end else begin
		if(sAddr == 11'd511) begin
			//if(sData >= 12'd0 && sData < 12'd60)
				ena <= 1'b1;
		end
		if(sData >= 12'd0 && sData < 12'd60)
			req <= 1'b1;
		if(ena == 1'b1)begin
			if(globalCnt == 27'd79999999) begin
				globalCnt <= 27'd0;
				cnt1sec <= cnt1sec + 1'b1;
				if(cnt1sec == 5'd2 && once == 1'b0) begin
					ena <= 1'b0;
					once <= 1'b1;
					//req <= 1'b1;
					sign <= sign + 1'b1;
					cnt1sec <= 5'd0;
				end 
			end else begin
				pause <= pause + 1'b1;
				if(pause == 5'd19)begin
					pause <= 5'd0;
					req <= 1'b0;
				end
				globalCnt <= globalCnt + 1'b1;
			end
		end
	end
end

endmodule
