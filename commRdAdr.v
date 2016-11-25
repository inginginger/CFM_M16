module commRdAdr(
	input clk,
	input rst,
	input strob1,
	input strob2,
	input strob3,
	input strob4,
	input strob5,
	output reg RD1,
	output reg RD2,
	output reg RD3,
	output reg RD4,
	output reg RD5,
	output reg busy,
	output [4:0] RdAdr1,
	output [4:0] RdAdr2,
	output [4:0] RdAdr3,
	output [4:0] RdAdr4,
	output [4:0] RdAdr5
	);
	

localparam IDLE1 = 0, CNT1 = 1, RDSET1 = 2, WAIT1 = 3;
localparam IDLE2 = 0, WAITDONE2 = 1, CNT2 = 2, RDSET2 = 3, WAIT2 = 4, PAUSE2 = 5;
localparam IDLE3 = 0, WAITDONE3 = 1, CNT3 = 2, RDSET3 = 3, WAIT3 = 4;
localparam IDLE4 = 0, WAITDONE4 = 1, CNT4 = 2, RDSET4 = 3, WAIT4 = 4;
localparam IDLE5 = 0, WAITDONE5 = 1, CNT5 = 2, RDSET5 = 3, WAIT5 = 4;
	
reg [1:0] syncStr1, syncStr2, syncStr3, syncStr4, syncStr5;
reg done1uart, done2uart, done3uart, done4uart;
reg [1:0] uart1;
reg [2:0] uart2, uart3, uart4, uart5;
reg [4:0] cnt1, cnt2, cnt3, cnt4, cnt5;
reg [5:0] cntRD1, cntRD2, cntRD3, cntRD4, cntRD5;
reg [5:0] pause;

assign RdAdr1 = (cnt1 < 18)? cnt1 : 5'hZ;
assign RdAdr2 = (cnt2 < 18)? cnt2 : 5'hZ;
assign RdAdr3 = (cnt3 < 18)? cnt3 : 5'hZ;
assign RdAdr4 = (cnt4 < 18)? cnt4 : 5'hZ;
assign RdAdr5 = (cnt5 < 18)? cnt5 : 5'hZ;

always@(posedge clk)
begin
	syncStr1 <= {syncStr1[0], strob1};
	syncStr2 <= {syncStr2[0], strob2};
	syncStr3 <= {syncStr3[0], strob3};
	syncStr4 <= {syncStr4[0], strob4};
	syncStr5 <= {syncStr5[0], strob5};
end

always@(posedge clk or negedge rst)
begin
	if(~rst) begin
		busy <= 1'b0;
		uart1 <= 2'd0;
		uart2 <= 3'd0;
		uart3 <= 3'd0;
		uart4 <= 3'd0;
		uart5 <= 3'd0;
		cnt1 <= 5'd0;
		cnt2 <= 5'd0;
		cnt3 <= 5'd0;
		cnt4 <= 5'd0;
		cnt5 <= 5'd0;
		cntRD1 <= 6'd0;
		cntRD2 <= 6'd0;
		cntRD3 <= 6'd0;
		cntRD4 <= 6'd0;
		cntRD5 <= 6'd0;
		RD1 <= 1'b0;
		RD2 <= 1'b0;
		RD3 <= 1'b0;
		RD4 <= 1'b0;
		RD5 <= 1'b0;
	end
	else begin
		case(uart1)
			IDLE1: begin
				if(syncStr1[1])begin
					uart1 <= RDSET1;
					busy <= 1'b1;
				end
				//else busy <= 1'b0;
			end
			RDSET1: begin
				cntRD1 <= cntRD1 + 1'b1;
				if(cntRD1 == 6'd40)
					RD1 <= 1'b1;
				else if( cntRD1 == 6'd44)
					RD1 <= 1'b0;
				else if(cntRD1 == 6'd63) begin
					cntRD1 <= 6'd0;
					uart1 <= CNT1;
				end
			end
			CNT1: begin
				cnt1 <= cnt1 + 1'b1;
				if(cnt1 == 5'd17) begin
					cnt1 <= 5'd0;
					busy <= 1'b0;
					done1uart <= 1'b1;
					uart1 <= WAIT1;
				end
				else uart1 <= RDSET1;
			end
			WAIT1: begin
				done1uart <= 1'b0;
				if(~syncStr1[1])
					uart1 <= IDLE1;
			end
		endcase
		
		case(uart2)
			IDLE2: begin
				if(syncStr2[1])
					uart2 <= WAITDONE2;
			end
			WAITDONE2: begin
				if (busy <= 1'b0)
					uart2 <= RDSET2;
			end
			RDSET2: begin
				cntRD2 <= cntRD2 + 1'b1;
				if(cntRD2 == 6'd40)
					RD2 <= 1'b1;
				else if( cntRD2 == 6'd44)
					RD2 <= 1'b0;
				else if(cntRD2 == 6'd63) begin
					cntRD2 <= 6'd0;
					uart2 <= CNT2;
				end
			end
			CNT2: begin
				cnt2 <= cnt2 + 1'b1;
				if(cnt2 == 5'd17) begin
					cnt2 <= 5'd0;
					done2uart <= 1'b1;
					uart2 <= WAIT2;
				end
				else
					uart2 <= RDSET2;
			end
			WAIT2: begin
				done2uart <= 1'b0;
				if(~syncStr2[1])
					uart2 <= IDLE2;
			end
		endcase
		
		case(uart3)
			IDLE3: begin
				if(syncStr3[1])
					uart3 <= WAITDONE3;
			end
			WAITDONE3: begin
				if (done2uart == 1)
					uart3 <= RDSET3;
			end
			RDSET3: begin
				cntRD3 <= cntRD3 + 1'b1;
				if(cntRD3 == 6'd40)
					RD3 <= 1'b1;
				else if( cntRD3 == 6'd44)
					RD3 <= 1'b0;
				else if(cntRD3 == 6'd63) begin
					cntRD3 <= 6'd0;
					uart3 <= CNT3;
				end
			end
			CNT3: begin
				cnt3 <= cnt3 + 1'b1;
				if(cnt3 == 5'd17) begin
					cnt3 <= 5'd0;
					done3uart <= 1'b1;
					uart3 <= WAIT3;
				end
				else uart3 <= RDSET3;
			end
			WAIT3: begin
				done3uart <= 1'b0;
				if(~syncStr3[1])
					uart3 <= IDLE3;
			end
		endcase
		
		case(uart4)
			IDLE4: begin
				if(syncStr4[1])
					uart4 <= WAITDONE3;
			end
			WAITDONE4: begin
				if (done3uart == 1)
					uart4 <= RDSET4;
			end
			RDSET4: begin
				cntRD4 <= cntRD4 + 1'b1;
				if(cntRD4 == 6'd40)
					RD4 <= 1'b1;
				else if( cntRD4 == 6'd44)
					RD4 <= 1'b0;
				else if(cntRD4 == 6'd63) begin
					cntRD4 <= 6'd0;
					uart4 <= CNT4;
				end
			end
			CNT4: begin
				cnt4 <= cnt4 + 1'b1;
				if(cnt4 == 5'd17) begin
					cnt4 <= 5'd0;
					done4uart <= 1'b1;
					uart4 <= WAIT4;
				end
				else uart4 <= RDSET4;
			end
			WAIT4: begin
				done4uart <= 1'b0;
				if(~syncStr4[1])
					uart4 <= IDLE4;
			end
		endcase
		
		case(uart5)
			IDLE5: begin
				if(syncStr5[1])
					uart5 <= WAITDONE5;
			end
			WAITDONE5: begin
				if (done4uart == 1)
					uart5 <= RDSET5;
			end
			RDSET5: begin
				cntRD5 <= cntRD5 + 1'b1;
				if(cntRD5 == 6'd40)
					RD5 <= 1'b1;
				else if( cntRD5 == 6'd44)
					RD5 <= 1'b0;
				else if(cntRD5 == 6'd63) begin
					cntRD5 <= 6'd0;
					uart5 <= CNT5;
				end
			end
			CNT5: begin
				cnt5 <= cnt5 + 1'b1;
				if(cnt5 == 5'd17) begin
					cnt5 <= 5'd0;
					uart5 <= WAIT5;
				end
				else uart5 <= RDSET5;
			end
			WAIT5: begin
				if(~syncStr5[1])
					uart5 <= IDLE5;
			end
		endcase
	end
end
endmodule
