module cntVal(
	input clk80MHz,
	input rst,
	input ValRX1,
	input ValRX2,
	output reg EN1,
	output reg EN2);
	
reg [1:0] syncVal1;
reg [1:0] syncVal2;

reg [1:0] val1, val2;
reg [7:0] cnt1, cnt2;
reg [4:0] cntVal1, cntVal2;

always@(posedge clk80MHz)
begin
	syncVal1 <= {syncVal1[0], ValRX1};
	syncVal2 <= {syncVal2[0], ValRX2};
end

always@(posedge clk80MHz or negedge rst)
begin
	if(~rst) begin
		EN1 <= 1'b0;
		EN2 <= 1'b0;
		val1 <= 2'd0;
		val2 <= 2'd0;
		cnt1 <= 8'd0;
		cnt2 <= 8'd0;
		cntVal1 <= 5'd0;
		cntVal2 <= 5'd0;
	end
	else begin
		case(val1)
			0: if(syncVal1[1])
				val1 <= 1;
			1: begin
				if(cntVal1 == 5'd19) begin
					cntVal1 <= 5'd0;
					EN1 <= 1'b1;
				end
				else
					cntVal1 <= cntVal1 + 1'b1;
				val1 <= 2;
			end
			2: if(~syncVal1[1]) begin
					if(cnt1 == 8'd255) begin
						EN1 <= 1'b0;
						val1 <= 0;
					end
					else
						cnt1 <= cnt1 + 1'b1;
			end
		endcase
		case(val2)
			0: if(syncVal2[1])
				val2 <= 1;
			1: begin
				if(cntVal2 == 5'd19) begin
					cntVal2 <= 5'd0;
					EN2 <= 1'b1;
				end
				else
					cntVal2 <= cntVal2 + 1'b1;
				val2 <= 2;
			end
			2: if(~syncVal2[1]) begin
					if(cnt2 == 8'd255) begin
						EN2 <= 1'b0;
						val2 <= 0;
					end
					else
						cnt2 <= cnt2 + 1'b1;
			end
		endcase
	end
end
endmodule
