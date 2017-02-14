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
	output  [6:0] addrTemp
	);
	
	reg [1:0] syncSW;
	reg [1:0] syncReq;
	reg [1:0] syncEdge;
	reg [2:0] state;
	reg [1:0] cntTemp;
	reg [2:0] shiftByte;
	reg enTemp;
	reg [3:0] cnt;
	
	assign dataTx = (enTemp == 1'b1) ? dataTemp : dataLCS;
	assign addrTemp = (cntTemp - 1)  + (shiftByte << 2);
	
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
			shiftByte <= 3'd0;
			enTemp <= 1'b0;
			cnt <= 4'd0;
		end else begin
			case(state)
				IDLE: begin
					if(req) begin	//если приняли запрос на данные
						ack <= 1'b1;		//формируем подтверждение
						state <= CHECK;
					end
				end
				/*EDGE: begin
					if(syncEdge[1]) begin
						state <= CHECK;
					end
				end*/
				CHECK: begin
					if(syncSW[1] && (addrLCS == 184 || addrLCS == 185	//если переключились памяти для записи кадра
						|| addrLCS == 186 || addrLCS == 187)) begin	//и все быстрые параметры уже в кадре
						enTemp <= 1'b1;
						state <= DELAY;
						ack <= 1'b0;
						cntTemp <= cntTemp + 1'b1;
						if(cntTemp == 2'd3) begin
							//ack <= 1'b0;
							shiftByte <= shiftByte + 1'b1;
							
						/*end else begin
							state <= WAITEDGE;*/
						end
						//state <= IDLE;
					end else begin
						ack <= 1'b0;
						enTemp <= 1'b0;									//отдаем данные ялк
						state <= DELAY;
					end	
					
								
				end
				DELAY: begin
					cnt <= cnt + 1'b1;
					if(cnt == 4'd9) begin
						cnt <= 4'd0;
						state<= WAIT;
					end
				end
				/*WAITEDGE: begin
					if(~syncEdge[1]) begin
						state <= IDLE;
					end
				end*/
				WAIT: begin
					if(~req) begin
						state <= IDLE;
						
					end
				end
			endcase
		end
	end
endmodule