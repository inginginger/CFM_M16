module UART_RX
	(
		input clk, 
		input reset,
		input RX,
		input rstTx,
		output reg [7:0]oData,
		output oValid
	);

	reg rx_act;
	reg Valid;
	reg [3:0]place;
	reg [7:0]data;
	reg [3:0]strtcnt;
	reg [4:0]stepcnt;
	reg [3:0]delay;

	assign oValid = Valid;
	
	reg [1:0] syncRX;
	reg [1:0] syncRST;
	wire iRX;
	assign iRX = syncRX[1];

	always @ (posedge clk) begin
		syncRX <= {syncRX[0], RX };
		syncRST <= {syncRST[0], rstTx};
	end
	
	
	always@(posedge clk or negedge reset)
	begin
	if (~reset) begin
		place <= 4'd0;
		data <= 8'd0;
		strtcnt <= 4'd0;
		stepcnt <= 5'd0;
		delay <= 4'd0;
		rx_act <= 1'b0;
		oData <= 8'd0;
		Valid <= 1'b0;
	end else begin
		
		
		if(syncRST[1] == 1'b1) begin
			rx_act <= 1'b0;
		end
		
		if(~rx_act) begin
			if(~iRX) begin
				if (strtcnt == 5'd7) begin
					rx_act <= 1'b1;
					strtcnt <= 4'd0;
				end else begin
					strtcnt <= strtcnt + 1'b1;
				end
			end else begin
				data <= 8'd0;
			end
		end
		else begin
			if (stepcnt == 5'd15) begin
				if (place == 4'd8) begin
					if (iRX) begin
						Valid <= 1'b1;
						oData <= data;
					end else begin
						data <= 8'b0;
					end
					place <= 4'd0;
					rx_act <= 1'b0;
				end else begin
					data[place] <= iRX;
					place <= place + 1'b1;
				end
					stepcnt <= 5'd0;
			end else begin
				stepcnt <= stepcnt + 1'b1;
			end
		end
		if (Valid) begin
			delay <= delay + 1'b1;
			if (delay == 4'd2) begin 
				delay <= 4'd0; 
				Valid <= 1'b0; 
			end  
		end
		/*if (rx_act) begin
			if (stepcnt == 5'd15) begin
				if (place == 4'd8) begin
					if (iRX) begin
						Valid <= 1'b1;
						oData <= data;
					end else begin
						data <= 8'b0;
					end
					place <= 4'd0;
					rx_act <= 1'b0;
				end else begin
					data[place] <= iRX;
					place <= place + 1'b1;
				end
					stepcnt <= 5'd0;
			end else begin
				stepcnt <= stepcnt + 1'b1;
			end
		end else begin
			if ((~rx_act)&&(~iRX)) begin
				if (strtcnt == 5'd7) begin
					rx_act <= 1'b1;
					strtcnt <= 4'd0;
				end else begin
					strtcnt <= strtcnt + 1'b1;
				end
			end
			else begin
				data <= 8'd0;
			end
		end*/
		
	end
	end

endmodule
