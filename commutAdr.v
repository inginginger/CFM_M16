module commutAdr(
	input clk,
	input rst,
	input strob,
	output [4:0] rdAdr,
	output reg full,
	output reg WE
);

reg [1:0] syncStr;
reg [1:0] state;
reg [4:0] cntWrd;
reg [3:0] cntWE;

localparam IDLE = 3'd0, CNTWRD = 3'd1, WRSET = 3'd2, FULLSET = 3'd3, WAIT = 3'd4;

assign rdAdr = cntWrd;

always@(posedge clk)
	syncStr <= {syncStr[0], strob};

always@(posedge clk or negedge rst)
begin
	if(~rst) begin
		full <= 1'b0;
		state <= 2'd0;
		cntWrd <= 5'd0;
		cntWE <= 4'd0;
		WE <= 1'b0;
	end
	else begin
		case(state)
			IDLE: begin
				full <= 1'b0;
				if(syncStr[1])
					state <= CNTWRD;
			end
			CNTWRD: begin
				cntWrd <= cntWrd + 1'b1;
				if(cntWrd == 5'd19) begin
					cntWrd <= 5'd0;
					state <= FULLSET;
				end
				state <= WRSET;
			end
			WRSET: begin
				cntWE <= cntWE + 1'b1;
				if(cntWE == 4'd13)
					WE <= 1'b1;
				else if(cntWE == 4'd15) begin
					cntWE <= 4'd0;
					state <= WAIT;
				end
			end
			FULLSET: begin
				full <= 1'b1;
				state <= WAIT;
			end
			WAIT: begin
				WE <= 1'b0;
				if(~syncStr[1])
					state <= IDLE;
			end
		endcase
	end
end
endmodule