module fromTempRQ(
	input clk,
	input rst,
	input rqRom,
	input [8:0] LCSaddr,
	input [7:0] LCSdata,
	input [7:0] tempData,
	input SW,
	output reg [7:0] data,
	output reg ack,
	output reg [6:0] tempAddr
);

reg [1:0] syncSW;
reg [1:0] syncRqRom;
reg [2:0] state;
reg [1:0] cntTemp;
reg [2:0] shByte;

localparam IDLE = 0, CHECK = 1, RQ = 2, ADDR = 3;

always@(posedge clk) begin
	syncRqRom <= {syncRqRom[0], rqRom};
	syncSW <= {syncSW[0], SW};
end

always@(posedge clk) begin
	if(~rst) begin
		data <= 8'd0;
		ack <= 1'b0;
		tempAddr <= 7'd0;
		state <= 3'd0;
		cntTemp <= 2'd0;
		shByte <= 3'd0;
	end else begin
		data <= LCSdata;
		case(state)
			IDLE: begin
				if(syncSW[1]) begin
					state <= RQ;
				end
			end
			
			CHECK: begin
				if(LCSaddr == 9'd184 || LCSaddr == 9'd185 || 
					LCSaddr == 9'd186 || LCSaddr == 9'd187) begin
						state <= RQ;
				end
				ack <= 1'b0;
				data <= LCSdata;
			end
			
			RQ: begin
				if(syncRqRom[1]) begin
					ack <= 1'b1;
					state <= CHECK;
				end
			end
			
			ADDR: begin
				tempAddr <= cntTemp + (shByte << 2);
				data <= tempData;
				cntTemp <= cntTemp + 1'b1;
				if(cntTemp == 2'd3) begin
					shByte <= shByte + 1'b1;
					state <= IDLE;
				end
				
				state <= CHECK;
			end
			
		endcase
	end
end
endmodule