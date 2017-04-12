module answerLCS(
	input clk,
	input rst,
	input req,
	input [2:0] sel,
	input [8:0] addrLCS,
	input [7:0] dataTemp,
	input [7:0] dataLCS,
	output [7:0] dataTx,
	output [6:0] addrTemp
	);
	
reg [1:0] syncRq;
reg [4:0] waitTime;
reg [4:0] shift;
reg [1:0] cntTemp;
reg [5:0] pause;
reg [6:0] cntRq;
reg [2:0] state;
reg [3:0] cnt;
reg ena;

localparam IDLE = 0, WAITINGFOR = 1, CHECK = 2, DELAY = 3, WAIT = 4;

assign addrTemp = sel + (shift << 2);
assign dataTx = (cntRq == 7'd122) ? dataTemp : dataLCS;

always@(posedge clk or negedge rst) 
	if(~rst)
		syncRq <= 2'd0;
	else 
		syncRq <= {syncRq[0], req};
		
always@(posedge clk or negedge rst) begin
	if(~rst) begin
		state <= 3'd0;
		cntTemp <= 2'd0;
		cntRq <= 7'd0;
		pause <= 6'd0;
		shift <= 5'd0;
		cnt <= 4'd0;
		ena <= 1'b0;
	end else begin
		
		case(state)
			IDLE: if(syncRq[1]) begin
				cntRq <= cntRq + 1'b1;
				state <= CHECK;
			end
			CHECK: begin
				if(cntRq == 7'd123) begin
					shift <= shift + 1'b1;
				end 
				state <= WAIT;		
			end
			WAIT: if(~syncRq[1])
				state <= IDLE;
		endcase
	end
end
endmodule