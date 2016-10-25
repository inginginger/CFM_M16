/*
	Ivan I. Ovchinnikov
	last upd.: 2016.02.20
*/

module globalReset			// to use this: set the initial for (~reset) and main circuit for (reset)
#(
	parameter clockFreq = 32'd80000000,
	parameter delayInSec = 1
)
(
	input clk,				// 40 MHz
	output reg rst			// global enable
);
reg [31:0] count = 32'd0;

always@(posedge clk)
begin
	if (count > 8'd62/*clockFreq*delayInSec*/) rst <= 1'b1;		// on fpga start count 62 clocks and set global enable
	else begin rst <= 1'b0; count <= count + 1'b1; end		// while count set enabe to low level
end
endmodule