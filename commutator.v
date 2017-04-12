module commutator(
	input clk,
	input rst,
	input [7:0] dataTemp,
	input [7:0] dataLCS,
	input req,
	output [7:0] dataTx,
	output [6:0] addrTemp
	);
	
reg[1:0] syncRq;

always@(posedge clk or negedge rst) 
	if(~rst)
		syncRq <= 2'd0;
	else 
		syncRq <= {syncRq[0], req};

reg[2:0] state;
reg[1:0] cntTemp;
reg[6:0] cntRq;
reg[4:0] shift;
reg[3:0] cnt;
reg ena;
reg [4:0] pause;

assign addrTemp = (ena == 1'b1) ? cntTemp + (shift << 2) : 7'd0;
assign dataTx = (ena == 1'b1) ? dataTemp : dataLCS;

localparam IDLE = 0, CHECK = 1, DELAY = 2, WAIT = 3, PAUSE = 4;
		
always@(posedge clk or negedge rst) begin
	if(~rst) begin
		state <= 3'd0;
		cntTemp <= 2'd0;
		cntRq <= 7'd0;
		shift <= 5'd0;
		cnt <= 4'd0;
		ena <= 1'b0;
		pause <= 5'd0;
	end else begin
		case(state)
			IDLE: if(syncRq[1]) begin
				cntRq <= cntRq + 1'b1;
				state <= PAUSE;
			end
			PAUSE: begin
				pause <= pause + 1'b1;
				if(pause == 5'd30) begin
					pause <= 5'd0;
					state <= CHECK;
				end
			end
			CHECK: begin
				if(cntRq == 7'd127) begin
					ena <= 1'b1;
					if(cntTemp == 2'd3) begin
						shift <= shift + 1'b1;
						state <= WAIT;
					end else begin
						state <= DELAY;
						cntTemp <= cntTemp + 1'b1;
					end
				end else begin
					ena <= 1'b0;
					state <= WAIT;
				end					
			end
			DELAY: begin
				cnt <= cnt+ 1'b1;
				if(cnt == 4'd11) begin
					cnt <= 4'd0;
					state <= CHECK;
				end
			end
			WAIT: if(~syncRq[1])
				state <= IDLE;
		endcase
	end
end
endmodule