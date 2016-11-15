module SlowPacker(
input clk,
input rst,
input [7:0] iData,
input [10:0] addrRam,
input strob,
input SW,
output reg test,
output reg [11:0] orbWord,
output reg WE,
output reg [10:0] WrAddr

);

reg [1:0] syncStr;
reg [1:0] syncSW;
reg [4:0] cntWrd;
reg [1:0] state;
reg oldSW;
reg [4:0] cntWE;
reg [7:0] tmp17;


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
		state <= 2'd0;
		oldSW <= 1'b0;
		test <= 1'b0;
		cntWE <= 5'd0;
		tmp17 <= 8'd0;
	end
	else begin
		if(syncSW[1] != oldSW) begin
			cntWrd <= 5'd0;
			test <= 1'b1;
			cntWE <= 5'd0;
		end
		else test <= 1'b0;
		oldSW <= syncSW[1];
		
		case(state)
			IDLE: 
				if(syncStr[1]) begin
					cntWrd <= cntWrd + 1'b1;
					case(cntWrd)
						0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15: begin
							state <= WAIT;
						end
						16: begin
							tmp17 <= iData;
							state <= WAIT;
						end
						17: begin
							orbWord <= {1'b0, tmp17, iData[7:6], 1'b0};
							WrAddr <= addrRam;
							state <= WESET;
						end
						18: state <= WAIT;
						19: begin
							cntWrd <= 5'd0;		
							state <= WAIT;				
						end
					endcase					
				end
			
			WESET: begin
				cntWE <= cntWE + 1'b1;
				if(cntWE == 5'd30)
					WE <= 1'b1;
				else if(cntWE == 5'd31) begin
					state <= WAIT;
				end
			end
			WAIT: 
				if(~syncStr[1]) begin
					WE <= 1'b0;
					state <= IDLE;
				end
		endcase

	end
end
endmodule