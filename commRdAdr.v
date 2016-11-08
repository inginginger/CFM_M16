module commRdAdr(
	input clk,
	input rst,
	input strob,
	output reg RD,
	output [4:0] RdAdr
	);
	

localparam IDLE = 0, CNT = 1, RDSET = 2, WAIT = 3;
	
reg [1:0] syncStr;
reg full;
reg [1:0] uart;
reg [4:0] cnt;
reg [3:0] cntRD;

assign RdAdr = (cnt < 20)? cnt : 5'hZ;

always@(posedge clk)
begin
	syncStr <= {syncStr[0], strob};
end

always@(posedge clk or negedge rst)
begin
	if(~rst) begin
		uart <= 2'd0;
		cnt <= 5'd0;
		cntRD <= 4'd0;
	end
	else begin
		case(uart)
			IDLE: begin
				if(syncStr[1])
					uart <= RDSET;
			end
			RDSET: begin
				cntRD <= cntRD + 1'b1;
				if(cntRD == 4'd13)
					RD <= 1'b1;
				else if(cntRD == 4'd15) begin
					RD <= 1'b0;
					cntRD <= 4'd0;
					uart <= CNT;
				end
			end
			CNT: begin
				cnt <= cnt + 1'b1;
				if(cnt == 5'd19) begin
					cnt <= 5'd0;
					full <= 1'b1;
					uart <= WAIT;
				end
				else uart <= RDSET;
			end
			WAIT: begin
				full <= 1'b0;
				if(~syncStr[1])
					uart <= IDLE;
			end
		endcase
	end
end
endmodule
