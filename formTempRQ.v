module formTempRQ(
	input clk,
	input rst,
	input SW,
	input [7:0] LCB,
	input [7:0] temp,
	input [8:0] LCB_rq_addr1,
	output reg [8:0] fastAddr,
	output reg [6:0] tempAddr,
	output [7:0] LCB_rq_data,
	output reg tempFull
);

reg [6:0] cntSW;
reg [1:0] Rq4Bytes;
reg [4:0] cntTemp;
reg [7:0] shiftByte, pause;
reg [1:0] st;
reg [1:0] syncSW;
reg[4:0] cnt;

localparam IDLE = 0, CNT = 1, TEMP = 2, WAIT = 3;

assign LCB_rq_data = ((LCB_rq_addr1 >= 9'd184) && (LCB_rq_addr1 <= 9'd187)) ? temp : LCB;

always@(posedge clk)
	syncSW <= {syncSW[0], SW};

always@(posedge clk or negedge rst) begin

	if(~rst) begin
		fastAddr <= 9'd0;
		tempAddr <= 7'd0;
		cntSW <= 7'd0;
		Rq4Bytes <= 2'd0;
		cntTemp <= 5'd0;
		shiftByte <= 8'd0;
		st <= 2'd0;
		//LCB_rq_data <= 8'd0;
		tempFull <= 1'b0;
		cnt <= 5'd0;
		pause <= 8'd0;
	end else 
		case(st)
			IDLE: begin
				fastAddr <= LCB_rq_addr1;
				//LCB_rq_data <= LCB;
				if(syncSW[1]) begin
					st <= CNT;
				end
			end

			CNT: begin
				fastAddr <= LCB_rq_addr1;
				//LCB_rq_data <= LCB;
				if(LCB_rq_addr1 == 9'd256) begin
					st <= WAIT;
					tempFull <= 1'b0;
				end
				if(cntSW == 7'd0 && LCB_rq_addr1 == 9'd188) begin
					st <= TEMP;
				end
			end
			
			TEMP: begin
				//LCB_rq_data <= temp;
				if(tempFull == 1'b0) begin
					
					case(LCB_rq_addr1)
					9'd184: begin
						cnt <= cnt + 1'b1;
						case(cnt)
							20: begin
								tempAddr <= 0 + (shiftByte << 2);
								cnt <= 0;
							end
						endcase
					end
					9'd185: begin
						cnt <= cnt + 1'b1;
						case(cnt)
							20: begin
								tempAddr <= 1 + (shiftByte << 2);
								cnt <= 0;
							end
						endcase
					end
					9'd186: begin
						cnt <= cnt + 1'b1;
						case(cnt)
							20: begin
								tempAddr <= 2 + (shiftByte << 2);
								cnt <= 0;
							end
						endcase
					end
					9'd187: begin
						cnt <= cnt + 1'b1;
						case(cnt)
							20: begin
								tempAddr <= 3 + (shiftByte << 2);
								cnt <= 0;
							end
						endcase	
					end
					9'd189: begin
						cnt <= cnt + 1'b1;
						case(cnt)
							19: begin
								shiftByte <= shiftByte + 1'b1;
								tempFull <= 1'b1;
							end
							20: begin
								st <= CNT;
								cnt <= 0;
							end
						endcase
					
						
					end
				endcase			
				end
			end

			WAIT: begin
				if(~syncSW[1]) begin
					st <= IDLE;
					cntSW <= cntSW + 1'b1;
				end
			end
		endcase
end
endmodule
