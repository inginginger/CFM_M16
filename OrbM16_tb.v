`timescale 1 ns/1 ns

module OrbM16_tb();

	// Wires and variables to connect to UUT (unit under test)
	reg clk100MHz;
	reg clk80MHz;
	wire orbFrame;
	wire doubleOrbData;
	wire ValRX;
	
	wire test1;
	wire test2;
	wire test3;
	wire test4;

	
	
	
	//reg rst;
	//reg clkOrb;
	//reg LCBreq; 
	reg clk4_8MHz;
	//reg [8:0] LCB_rq_addr;
	wire UART_TX;          // serial transmitted data
	reg UART_RX;
	wire UART_dTX;        // rs485 TX dir controller 
	wire UART_dRX;        // rs485 RX dir controller
	//reg [7:0] LCB_rq_data;
	//reg  [5:0] cycle;
	//reg  [4:0] switch;
	//local variables
	reg [7:0] data [0:19];
	reg [7:0] cntmas[0:31];
	reg [2:0] i = 0;
	reg [4:0] j = 0;
	reg [4:0] q = 0;
	reg [4:0] k = 0;
	reg [7:0] nowdata = 0;
	
	// Instantiate UUT
	OrbM16 M16frame(.clk100MHz(clk100MHz), .clk80MHz(clk80MHz), .UART_RX(UART_RX), /*.clk4_8MHz(clk4_8MHz),*/ .doubleOrbData(doubleOrbData),.ValRX(ValRX),.test1(test1), .test2(test2), .test3(test3), .test4(test4), .UART_TX(UART_TX), .UART_dTX(UART_dTX), .UART_dRX(UART_dRX));

	// Clock definition
	initial begin
		clk100MHz = 0;
		forever #10 clk100MHz = ~clk100MHz;
	end
	initial begin
		clk80MHz = 0;
		forever #12.5 clk80MHz = ~clk80MHz;
    end
    initial begin
		clk4_8MHz = 0;
		forever #210 clk4_8MHz = ~clk4_8MHz;
	end
    
	
	initial begin
		data[0] = 0;
		data[1] = 100;
		data[2] = 150;
		data[3] = 200;
		data[4] = 250;
		data[5] = 300;
		data[6] = 350;
		data[7] = 400;
		data[8] = 450;
		data[9] = 500;
		data[10] = 550;
		data[11] = 600;
		data[12] = 650;
		data[13] = 700;
		data[14] = 750;
		data[15] = 800;
		data[16] = 850;
		data[17] = 900;
		data[18] = 950;
		data[19] = 1000;
	end
	initial begin
		//for(k=0; k < 32; k=k+1'b1)
		//cntmas[k] = k << 3;
		cntmas[0] = 0;
		cntmas[1] = 8;
		cntmas[2] = 16;
		cntmas[3] = 24;
		cntmas[4] = 32;
		cntmas[5] = 40;
		cntmas[6] = 48;
		cntmas[7] = 56;
		cntmas[8] = 64;
		cntmas[9] = 72;
		cntmas[10] = 80;
		cntmas[11] = 88;
		cntmas[12] = 96;
		cntmas[13] = 104;
		cntmas[14] = 112;
		cntmas[15] = 120;
		cntmas[16] = 128;
		cntmas[17] = 136;
		cntmas[18] = 144;
		cntmas[19] = 152;
		cntmas[20] = 160;
		cntmas[21] = 168;
		cntmas[22] = 176;
		cntmas[23] = 184;
		cntmas[24] = 192;
		cntmas[25] = 200;
		cntmas[26] = 208;
		cntmas[27] = 216;
		cntmas[28] = 224;
		cntmas[29] = 232;
		cntmas[30] = 240;
		cntmas[31] = 248;
	end
	initial begin						// Main
		repeat (30)@(posedge clk80MHz);
		UART_RX = 1;
		repeat (160) begin					// 5 times
			j=0;
			wait(UART_dRX == 1);
			wait(UART_dRX == 0);

			repeat (30)@(posedge clk4_8MHz);
			repeat (20) begin				// 20 bytes
				repeat(10)@(posedge clk4_8MHz);
				UART_RX = 0;
				repeat (8)					// 8 bit
				begin
					nowdata = cntmas[q];
					@(posedge clk4_8MHz)
					if(j == 0)
						UART_RX = cntmas[q][i];
					else
						UART_RX=data[j][i];
					i=i+1;
				end
				@(posedge clk4_8MHz);
				UART_RX = 1;
				
				j=j+1;
			end
			q = q+1;
		end
		$stop;
	end
	
endmodule
