module OrbPacker(
input clk,
input rst,
input [7:0] iData,
input strob,
input req,
input SW,
output reg test,
output reg [11:0] orbWord,
output  reg WE,
output  reg [10:0] WrAddr,
output reg test1,
output reg test2
);

reg [1:0] syncStr;
reg [1:0] syncSW;
reg [4:0] cntWrd;
reg [5:0] cntPack;
reg [1:0] state;
reg [3:0] cntAddr;
reg oldSW;
reg [4:0] cntWE;

localparam IDLE = 2'd0, WESET = 2'd1, WAIT = 2'd2;

always@(posedge clk)
begin
syncStr <= {syncStr[0], strob};
syncSW <= {syncSW[0], SW};
end

always@(posedge clk or negedge rst)
begin
	if(~rst) begin
		orbWord <= 12'd0;
		WE <= 1'd0;
		WrAddr <= 11'd0;
		cntWrd <= 5'd0;
		cntPack <= 6'd0;
		state <= 2'd0;
		cntAddr <= 4'd0;
		oldSW <= 1'b0;
		test <= 1'b0;
		cntWE <= 5'd0;
		test1 <= 1'b0;
		test2 <= 1'b0;
	end
	else begin
		if(syncSW[1] != oldSW) begin
			cntAddr <= 4'd0;
			cntPack <= 6'd0;
			cntWrd <= 5'd0;
			test <= 1'b1;
			cntWE <= 5'd0;
		end
		else test <= 1'b0;
		oldSW <= syncSW[1];
		
		case(state)
			IDLE: begin
				if(syncStr[1]) begin
					cntWrd <= cntWrd + 1'b1;
					case(cntWrd)
						0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15: begin
							orbWord <= {1'b0, iData, 3'd0};
							WrAddr <= (cntAddr << 1) + (cntPack << 5);
							cntAddr <= cntAddr + 1'b1;
							state <= WESET;
						end
						16, 17, 18: state <= WAIT;
						19: begin
							cntPack <= cntPack + 1'b1;
							cntWrd <= 5'd0;		
							state <= WAIT;				
						end
					endcase					
				end
			end
			WESET: begin
				cntWE <= cntWE + 1'b1;
				if(cntWE == 5'd30)
					WE <= 1'b1;
				else if(cntWE == 5'd31) begin
					cntWE <= 5'd0;
					state <= WAIT;
				end
			end
			WAIT: begin
				if(WrAddr == 11'd2016)
					test1 <= 1'b1;
				else if(WrAddr == 11'd0)
					test2 <= 1'b1;
				else begin
					test1 <= 1'b0;
					test2 <= 1'b0;
				end
				if(~syncStr[1]) begin
					WE <= 1'b0;
					state <= IDLE;
				end
			end
		endcase
	end
end

endmodule
