module writer
#(
  parameter BYTES = 5'd16
)
(
	input clk,
	input rst,
	input rstTx,
	input[7:0] iData,
	input strob,
	input [10:0] sAddr,
	output[11:0] fData,
	output[11:0] sData,
	output reg fVal,
	output reg sVal
);

reg[2:0] syncStrob;
reg[1:0] syncRst;
reg[4:0] cntWord;
reg[11:0] fBuf;
reg[11:0] sBuf;
reg[7:0] tmp;

assign fData = fBuf;
assign sData = sBuf;

always@(posedge clk or negedge rst) begin
	if(~rst) begin
		syncRst <= 2'd0;
		syncStrob <= 3'd0;
	end else begin
		syncRst <= {syncRst[0], rstTx};
		syncStrob <= {syncStrob[1:0], strob};
	end
end

wire dtctStrob = !syncStrob[2] & syncStrob[1];//детектирование фронта сигнала валидности данных от приемника уарт
wire dtctRst = !syncRst[1] & syncRst[0];//детектирование фронта сигнала сброса передатчика, который срабатывает, когда отправлен запрос в ялк

always@(posedge clk or negedge rst) begin
	if(~rst) begin
		cntWord <= 5'd0;
		fBuf <= 12'd0;
		sBuf <= 12'd0;
		fVal <= 1'b0;
		sVal <= 1'b0;
		tmp <= 8'd0;
	end else begin
		if(dtctRst) begin
			cntWord <= 5'd0;
			fBuf <= 12'd0;
			sBuf <= 12'd0;
			fVal <= 1'b0;
			sVal <= 1'b0;
			tmp <= 8'd0;
		end
		if(dtctStrob == 1)begin//по фронту сигнала валидности данных
			cntWord <= cntWord + 1'b1;//считаем количество параметров
			if(cntWord < BYTES) begin
				fBuf <= {1'b0, iData, 3'd0};//пишем 12-разрядный быстрый параметр
				fVal <= 1'b1;//выставляем сигнал валидности быстрого параметра
			end else if(cntWord == 5'd16) begin//медленный параметр собираем из 16 и 17 слов
				if(sAddr!= 11'd0)
					tmp <= iData;
			end else if(cntWord == 5'd17)begin
				if(sAddr!= 11'd0) begin
					sBuf <= {1'b0, iData[1:0], tmp, 1'b0};//пишем медленный параметр
					sVal <= 1'b1;//выставляем для него сигнал валидности
				end
				cntWord <= 5'd0;//обнуляем счетчик параметров
			end else begin
				tmp <= 8'd0;
				sBuf <= 12'd0;
				fBuf <= 12'd0;
			end
		end else begin
			sVal <= 1'b0;
			fVal <= 1'b0;
		end					
	end
end
endmodule
