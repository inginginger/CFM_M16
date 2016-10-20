module clkDiv21(
input clk100MHz,
input rst,
output oClk);

reg [4:0] cntdiv;

assign oClk = (cntdiv < 5'd10)?1'b1:1'b0;//הוכטעוכü קאסעמעû טח 100לדצ ג 4.8 ךדצ

always@(posedge clk100MHz or negedge rst)
begin
	if(~rst)
		cntdiv <= 5'b0;
	else begin
		if(cntdiv == 5'd20)
			cntdiv <= 5'b0;
		else
			cntdiv <= cntdiv + 1'b1;
	end
end
endmodule