module commutatorCC40(
	input clk,
	input rst,
	input WE,
	input [10:0] sAddr,
	input [11:0] sData,
	input [2:0] numBytes,
	output reg req,
	output reg ena,
	output reg [7:0] oData
);

reg[26:0] globalCnt;
reg[6:0] cnt1sec;
reg sign;
reg[4:0] pause;
reg once;
reg [2:0] syncWE;
reg [2:0] syncReq;
reg [2:0] state;
reg [7:0] mem [0:3];

localparam IDLE = 0, DTCTADDR = 1, DTCTDATA = 2, CNT = 3;

always@(posedge clk or negedge rst) 
	if(~rst) begin
		syncWE <= 3'd0;
		syncReq <= 3'd0;
	end else begin
		syncWE <= {syncWE[1:0], WE};
		syncReq <= {syncReq[1:0], req};
	end
		
wire dtctWE = !syncWE[2] & syncWE[1];//детектирование фронта сигнала

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
			IDLE: begin
				if(dtctWE == 1'b1)//если нашли фронт сигнала записи
					state <= DTCTADDR;
			end
			DTCTADDR: if(sAddr == 11'd511)//если нашли адрес вкл цки
				state <= DTCTDATA;
			else begin
				state <= IDLE;
				req <= 1'b0;
			end
			DTCTDATA: if((sData >= 12'd0) && (sData < 12'd60))//если видим обрыв в данных
				state <= CNT;
			else
				state <= IDLE;
				
			CNT: begin
				if(globalCnt == 27'd79999999) begin//отсчитываем 1 сек
					globalCnt <= 27'd0;
					cnt1sec <= cnt1sec + 1'b1;
					if(cnt1sec == 7'd119 && once == 1'b0) begin//один единственный раз считаем до 120 сек
						once <= 1'b1;
						req <= 1'b1;//сигнал разрешения отправки команды на як-40
						sign <= sign + 1'b1;//сигнал, меняющий код команды для як-40
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



always@(posedge clk or negedge rst) begin
	if(~rst) begin
		mem[0] <= 0;
		mem[1] <= 0;
		mem[2] <= 0;
		mem[3] <= 0;
		oData <= 8'd0;
	end else begin
		oData <= mem[numBytes];
		if(req == 1'b1) begin
			mem[0] <= 50;
			if (sign == 1'b1) begin
				mem[1] <= 21;
				mem[3] <= 3;
			end else begin
				mem[1] <= 22;
				mem[3] <= 46;
			end
			mem[2] <= 0;
		end /*else begin
			mem[0] <= 0;
			mem[1] <= 0;
			mem[2] <= 0;
			mem[3] <= 0;
		end*/
	end
end

endmodule
