/*
	Ivan I. Ovchinnikov
	last upd.: 2016.02.10
*/

module clkDiv100
(
	input reset,
	input iClkIN,			// whatever clock
	output reg Outdiv2,			// divided by 2 
	output reg Outdiv4,			// divided by 4
	output reg Outdiv8,			// divided by 8
	output reg Outdiv16			// divided by 16
);

reg [3:0] clk=0;

always @(negedge iClkIN or negedge reset)
if (~reset) begin
	clk <= 4'b0;
end
else begin
	clk<=clk+1'b1;				// always count 4-digit binary: 0..15
end

always @(posedge iClkIN or negedge reset) begin
	if (~reset) begin
		Outdiv2<=1'b0;
		Outdiv4<=1'b0;
		Outdiv8<=1'b0;
		Outdiv16<=1'b0;
	end else begin
		Outdiv2 <= clk[0];	// syncronous outputs
		Outdiv4 <= clk[1];
		Outdiv8 <= clk[2];//!!!
		Outdiv16 <= clk[3];
	end
end
endmodule 