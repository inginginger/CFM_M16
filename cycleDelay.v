module cycleDelay(
input slowRcv,
input [5:0]cycle,
input rst,
output reg [5:0] adr);

always@(posedge slowRcv or negedge rst)
begin
	if(~rst)
		adr <= 0;
	else
		adr <= cycle;
end
endmodule