module uartRx(
	input clk,
	input rst,
	input rstTx,
	input rx,
	output reg oValid,
	output reg [7:0] oData,
	output reg test);
	
	reg [1:0] syncRx;
	reg [1:0] syncRstTx;
	
	reg rxAct;
	reg [2:0] cntStrt;
	reg [4:0] cntStep;
	reg [3:0] cntPlace;
	reg[1:0] delay;
	reg [7:0] data;
	reg [3:0] state;
	
	localparam STARTSEARCH = 0, RECEIVER = 1, STOPSEARCH = 2, VALIDHOLD = 3;
	
	
	
	always@(posedge clk)
	begin
		syncRx <= {syncRx[0], rx};
		syncRstTx <= {syncRstTx[0], rstTx};
	end
		
	always@(posedge clk)
	begin
		if(~rst) begin
			oValid <= 1'b0;
			oData <= 8'b0;
			state <= 4'b0;
			rxAct <= 1'b0;
			cntStrt <= 3'b0;
			cntStep <= 5'd0;
			cntPlace <= 4'd0;
			data <= 8'd0;
			delay <= 2'd0;
		end
		else begin
			if(syncRstTx[1]) begin
				rxAct <= 1'b0;
			end
			case(state)
				STARTSEARCH: begin
					if(~rxAct && ~syncRx[1]) begin//если передача неактивна и на приемной линии ноль
						cntStrt <= cntStrt + 1'b1;
						if(cntStrt == 3'd7) begin//отсчитываем середину стартового бита
							rxAct <= 1'b1;
							state <= RECEIVER;
						end
					end
					else begin
						data <= 8'd0;
					end
				end	
				RECEIVER: begin
					if(rxAct == 1'b1) begin//если передача активна
						cntStep <= cntStep + 1'b1;
						if(cntStep == 5'd16) begin
							cntPlace <= cntPlace + 1'b1;
							cntStep <= 5'd0;
							if(cntPlace == 4'd8) begin//приняли данные
								state <= STOPSEARCH;
								cntPlace <= 4'd0;
							end
							else begin
								data[cntPlace] <= syncRx[1];//записываем входящие данные в буфер
								test = syncRx[1];
							end
						end
					end
				end
				STOPSEARCH: begin
					if(syncRx[1]) begin
						oValid <= 1'b1;
						oData <= data;//считываем данные из буфера
						state <= VALIDHOLD;
					end
					else begin
						data <= 8'd0;
					end
					rxAct <= 1'b0;
				end	
				VALIDHOLD: begin
					if(oValid == 1'b1) begin
						delay <= delay + 1'b1;
						if(delay == 2'd2) begin
							oValid <= 1'b0;
							delay <= 2'd0;
							state <= STARTSEARCH;
						end
					end
				end
			endcase
		end
	end
endmodule

	