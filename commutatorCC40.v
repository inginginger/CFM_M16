module commutatorCC40(
	input clk,
	input rst,
	input WE,
	input [10:0] sAddr,
	input [11:0] sData,
	output reg req,
	output reg ena
	
);

reg[26:0] globalCnt;
reg[6:0] cnt1sec;
reg sign;
reg[4:0] pause;
reg once;
reg [2:0] syncWE;
reg [2:0] state;

localparam IDLE = 0, DTCTADDR = 1, DTCTDATA = 2, CNT = 3;

always@(posedge clk or negedge rst) 
	if(~rst)
		syncWE <= 3'd0;
	else 
		syncWE <= {syncWE[1:0], WE};
		
wire dtctWE = !syncWE[2] & syncWE[1];

always@(posedge clk or negedge rst) begin
	if(~rst) begin
		sign <= 1'b0;
		cnt1sec <= 7'd0;
		globalCnt <= 27'd0;
		req <= 1'b0;
		pause <= 5'd0;
		ena <= 1'b0;
		once <= 1'b0;
		state <= 3'd0;
	end else begin
		case(state)
			IDLE: if(dtctWE == 1'b1)
				state <= DTCTADDR;
			DTCTADDR: if(sAddr == 11'd511)
				state <= DTCTDATA;
			else 
				state <= IDLE;
			DTCTDATA: if((sData >= 12'd0) && (sData < 12'd60))
				state <= CNT;
			else
				state <= IDLE;
				
			CNT: begin
				if(globalCnt == 27'd79999999) begin
					globalCnt <= 27'd0;
					cnt1sec <= cnt1sec + 1'b1;
					if(cnt1sec == 7'd119 && once == 1'b0) begin
						once <= 1'b1;
						req <= 1'b1;
						sign <= sign + 1'b1;
						cnt1sec <= 7'd0;
						state <= IDLE;
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
		endcase
	end
end

endmodule
