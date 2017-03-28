module commutAdr(
	input clk,
	input rst,
	input rstWr,
	input strob,
	output [4:0] wrAdr,
	output reg full,
	output reg WE
);

reg [1:0] syncStr;
reg [2:0] syncRstWr;
reg [1:0] state;
reg [4:0] cntWrd;
reg [5:0] cntWE;

localparam IDLE = 2'd0, CNTWRD = 2'd1, WRSET = 2'd2, WAIT = 2'd3;

assign wrAdr = (cntWrd > 0 && cntWrd <= 18) ? (cntWrd - 1'b1) : 5'hZ;

always@(posedge clk or negedge rst) begin
	if(~rst) begin
		syncRstWr <= 3'd0;
		syncStr <= 2'd0;
	end else begin 
		syncStr <= {syncStr[0], strob};
		syncRstWr <= {syncRstWr[1:0], rstWr};
	end
end

wire dtctRst = !syncRstWr[2] & syncRstWr[1];

always@(posedge clk or negedge rst)
begin
	if(~rst) begin
		full <= 1'b0;
		state <= 2'd0;
		cntWrd <= 5'd0;
		cntWE <= 6'd0;
		WE <= 1'b0;
	end
	else begin
		if(dtctRst == 1'b1)
			full <= 1'b0;
		case(state)
			IDLE: begin				
				if(syncStr[1]) begin
					state <= CNTWRD;
					//full <= 1'b0;
				end
			end
			CNTWRD: begin
				cntWrd <= cntWrd + 1'b1;
				state <= WRSET;
			end
			WRSET: begin
				cntWE <= cntWE + 1'b1;
				if(cntWE == 6'd42) begin
					WE <= 1'b1;
				end
				else if(cntWE == 6'd46) begin
					WE <= 1'b0;
				end
				else if(cntWE == 6'd63) begin
					cntWE <= 6'd0;
					if(cntWrd == 5'd18) begin
						cntWrd <= 5'd0;
						full <= 1'b1;
					end
					state <= WAIT;
				end
			end
			WAIT: begin
				if(~syncStr[1]) begin
					state <= IDLE;
				end
			end
		endcase
	end
end
endmodule