module commutAdr(
	input clk,
	input rst,
	input strob,
	output [4:0] wrAdr,
	output reg full,
	output reg WE
);

reg [1:0] syncStr;
reg [1:0] state;
reg [4:0] cntWrd;
reg [4:0] cntWE;

localparam IDLE = 2'd0, CNTWRD = 2'd1, WRSET = 2'd2, WAIT = 2'd3;

assign wrAdr = cntWrd;

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
				if(syncStr[1])
					state <= CNTWRD;
			end
			CNTWRD: begin
				cntWrd <= cntWrd + 1'b1;
				if(cntWrd == 5'd19) begin
					cntWrd <= 5'd0;
					full <= 1'b1;
				end
				state <= WRSET;
			end
			WRSET: begin
				full <= 1'b0;
				cntWE <= cntWE + 1'b1;
				if(cntWE == 5'd29)
					WE <= 1'b1;
				else if(cntWE == 5'd31) begin
					WE <= 1'b0;
					cntWE <= 5'd0;
					state <= WAIT;
				end
			end
			WAIT: begin
				if(~syncStr[1])
					state <= IDLE;
			end
		endcase
	end
end
endmodule