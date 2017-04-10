module newUart
#(
  parameter BYTES = 5'd4
)
(
  input reset,          // global reset and enable signal
  input clk,            // actual needed baudrate (tested on 4,8 MHz)
  input RQ,            // start transfer signal
  input ack, 
  input [5:0]cycle,
  input [7:0]data,
  output reg [8:0]addr,
  output reg full,
  output reg tx,          // serial transmitted data
  output reg dirTX,        // rs485 TX dir controller 
  output reg dirRX,        // rs485 RX dir controller
  output reg [2:0]switch,  // memory switcher
  output reg rqRom
);

localparam WAIT=0, MEGAWAIT=1, DIRON=2, TX=3, DIROFF=4, RQROM = 5;

reg [2:0] state;
reg [3:0] serialize;
reg [4:0] delay;
reg [1:0] rqsync;
reg [1:0] syncAck;

always@(posedge clk or negedge reset) begin			// double d-flipflop to avoid metastability
	if(~reset)  begin
		rqsync <= 2'd0;
		syncAck <= 2'd0;
	end else begin
		rqsync <= { rqsync[0],  RQ };	// start signal from other clock domain
		syncAck <= {syncAck[0], ack};
	end
end

always@(posedge clk or negedge reset)
begin
if (~reset) begin					// global asyncronous reset, initial values
	state <= 1'b0;
	serialize <= 0;
	delay <= 1'b0;
	tx <= 1'b1;
	switch <= 0;
	full <= 1'b0;
	dirTX <= 1'b0;
	dirRX <= 1'b0;
	rqRom <= 1'b0;
end else begin						// main circuit
	case (state)					// state machine
		WAIT: begin					// waiting for transfer request
			full <= 1'b0;
			if (rqsync[1]) begin 
				state <= DIRON;		// just move on
			end
		end
		DIRON: begin 				// set the DIR pins to high level with a tiny delay
			delay <= delay + 1'b1;	// count while in this state
			if (delay == 0) begin 
				dirRX <= 1; 
			end
			if (delay == 15) begin 
				dirTX <= 1; 
			end
			if (delay == 30) begin 
				state <= RQROM; 
			end	// proceed to next state
			switch <= 0; 
		end
		RQROM: begin	
			rqRom <= 1'b1;
			if(syncAck[1] == 1'b1) begin
				rqRom <= 1'b0;
				addr <= (switch + (cycle << 2));
				state <= TX;
			end
		end
		TX: begin					// the transfer
			serialize <= serialize + 1'b1;		// count while in this state
			case (serialize)					// make a sequence while here
				0: begin 
					tx <= 0;  		// startbit
					delay <= 0;		// reset previous counter
				end
				1,2,3,4,5,6,7,8: tx <= data[(serialize - 1)];	// transmit every bit of data
				9: begin 
					tx <= 1;		// stopbit
					switch <= switch + 1'b1;	// switch memory
				end
				10: begin
					serialize <= 0; // reset sequencer
					if (switch == BYTES) begin 
						
						state <= DIROFF; 
					end else	// if completed transfer proceed to next state 
						state <= RQROM;
				end	
			endcase
		end
		DIROFF: begin				// set the DIR pins to low level with a tiny delay
			delay <= delay + 1'b1;	// count while in this state
			if (delay == 0) begin 
				dirTX <= 0; 
			end
			if (delay == 4) begin 
				dirRX <= 0; 
				state <= MEGAWAIT; 
				full <= 1'b1; 
			end	// proceed to next state
		end
		MEGAWAIT: begin			// checking the low level of request signal
			delay <= 0;				// reset previous counter
			if (~rqsync[1]) begin 
				state <= WAIT; // just move on
			end
		end
	endcase 
end
end
endmodule
