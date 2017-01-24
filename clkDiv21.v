module clkDiv21(
input clk100MHz,
input clk80MHz,
input rst,
output oClk4_8,
output oClk5);

reg [4:0] cntdiv;
reg [3:0] clkcnt;

assign oClk4_8 = (cntdiv < 5'd10)?1'b1:1'b0;//הוכטעוכü קאסעמעû טח 100לדצ ג 4.8 ךדצ
assign oClk5 = (clkcnt < 4'd8)?1'b1:1'b0;

always@(posedge clk100MHz or negedge rst)
begin
	if(~rst) begin
		cntdiv <= 5'b0;
	end
	else begin
		if(cntdiv == 5'd20) begin
			cntdiv <= 5'b0;
		end
		else begin
			cntdiv <= cntdiv + 1'b1;
		end
	end
end

always@(posedge clk80MHz or negedge rst)
begin
	if(~rst) begin
		clkcnt <= 4'd0;
	end
	else begin
		if(clkcnt <= 4'd15) begin
			clkcnt <= clkcnt + 1'b1;
		end
	end
end
endmodule