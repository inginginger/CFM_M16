module commutAdr(
	input clk,
	input rst,
	input strob,
	output [4:0] wrAdr,
	output reg full,
	output reg WE
);

reg [1:0] syncStr;
reg [2:0] state;
reg [4:0] cntWrd;
reg [5:0] cntWE;
reg [5:0] pause;

localparam IDLE = 3'd0, CNTWRD = 3'd1, WRSET = 3'd2, PAUSE = 3'd3, WAIT = 3'd4;

assign wrAdr = (cntWrd > 0 && cntWrd <= 18) ? (cntWrd - 1'b1) : 5'hZ;

always@(posedge clk)
	syncStr <= {syncStr[0], strob};

always@(posedge clk or negedge rst)
begin
	if(~rst) begin
		full <= 1'b0;
		state <= 3'd0;
		cntWrd <= 5'd0;
		cntWE <= 6'd0;
		WE <= 1'b0;
		pause <= 6'd0;
	end
	else begin
		case(state)
			IDLE: begin				
				if(syncStr[1]) begin
					state <= CNTWRD;
					full <= 1'b0;
				end
			end
			CNTWRD: begin
				cntWrd <= cntWrd + 1'b1;
				state <= WRSET;
			end
			WRSET: begin
				cntWE <= cntWE + 1'b1;
				if(cntWE == 6'd42)
					WE <= 1'b1;
				else if(cntWE == 6'd46)
					WE <= 1'b0;
				else if(cntWE == 6'd63) begin
					cntWE <= 6'd0;
					if(cntWrd == 5'd18) begin
						state <= PAUSE;
						full <= 1'b1;
					end
					else 
						state <= WAIT;
				end
			end
			PAUSE: begin
				pause <= pause + 1'b1;
				if(pause == 6'd63) begin
					cntWrd <= 5'd0;
					state <= WAIT;
					pause <= 6'd0;
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