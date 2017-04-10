module answerLCS(
	input clk,
	input edgeTx,
	input rst,
	input SW, 
	input [8:0] addrLCS,
	input req,
	input [7:0] dataTemp,
	input [7:0] dataLCS,
	output reg ack,
	output  [7:0] dataTx,
	output  [6:0] addrTemp,
	output test
	);
	
	reg [1:0] syncSW;
	reg [1:0] syncReq;
	reg [1:0] syncEdge;
	reg [2:0] state;
	reg [1:0] cntTemp;
	reg [4:0] shiftByte;
	reg enTemp;
	reg [3:0] cnt;
	assign test = enTemp;
	assign addrTemp = (enTemp == 1'b0)? 7'd0 :(cntTemp  + (shiftByte << 2'd2));
	assign dataTx = (enTemp == 1'b0) ? dataLCS : dataTemp;
	
	localparam IDLE = 0, EDGE = 1, CHECK = 2, WAIT = 3, DELAY = 4;

	always@(posedge edgeTx) begin
		syncSW <= {syncSW[0], SW};
		syncReq <= {syncReq[0], req};
		//syncEdge <= {syncEdge[0], edgeTx};
	end

	always@(posedge edgeTx or negedge rst) begin
		if(~rst) begin
			ack <= 1'b0;
			state <= 3'd0;
			cntTemp <= 2'd0;
			shiftByte <= 5'd0;
			enTemp <= 1'b0;
			cnt <= 4'd0;
		end else begin
			case(state)
				IDLE: begin
					if(req) begin	//���� ������� ������ �� ������
						state <= CHECK;
					end
				end

				CHECK: begin
					if(syncSW[1] && (addrLCS == 240 || addrLCS == 241
						|| addrLCS == 242 || addrLCS == 243)) begin	
						enTemp <= 1'b1;
						cntTemp <= cntTemp + 1'b1;
						if(cntTemp == 2'd3) begin
							shiftByte <= shiftByte + 1'b1;	
						end
						state <= DELAY;
						
					end else begin
						enTemp <= 1'b0;									//������ ������ ���
						state <= DELAY;
					end	
												
				end
				
				DELAY: begin
					ack <= 1'b1;		
					cnt <= cnt + 1'b1;
					if(cnt == 4'd9) begin
						cnt <= 4'd0;
						state <= WAIT;
					end
				end

				WAIT: begin
					ack <= 1'b0;
					if(~req) begin
						if(cntTemp == 2'd0)
							enTemp <= 1'b0;
						state <= IDLE;
						
					end
				end
			endcase
		end
	end
endmodule