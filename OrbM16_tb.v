`timescale 10 ps/10 ps


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
	wire UART_TX1;          // serial transmitted data
	reg UART_RX1;
	wire UART_dTX1;        // rs485 TX dir controller 
	wire UART_dRX1;        // rs485 RX dir controller
	wire UART_TX2;          // serial transmitted data
	reg UART_RX2;
	wire UART_dTX2;        // rs485 TX dir controller 
	wire UART_dRX2;        // rs485 RX dir controller
	wire UART_TX3;          // serial transmitted data
	reg UART_RX3;
	wire UART_dTX3;        // rs485 TX dir controller 
	wire UART_dRX3;        // rs485 RX dir controller
	wire UART_TX4;          // serial transmitted data
	reg UART_RX4;
	wire UART_dTX4;        // rs485 TX dir controller 
	wire UART_dRX4;        // rs485 RX dir controller
	wire UART_TX5;          // serial transmitted data
	reg UART_RX5;
	wire UART_dTX5;        // rs485 TX dir controller 
	wire UART_dRX5;        // rs485 RX dir controller
	//reg [7:0] LCB_rq_data;
	//reg  [5:0] cycle;
	//reg  [4:0] switch;
	//local variables
	reg [7:0] data [0:19];
	reg [7:0] cntmas[0:255];
	reg [2:0] i = 0, p = 0, s = 0, z = 0, c = 0;
	reg [4:0] j = 0, k = 0, n = 0, y = 0, b = 0;
	reg [7:0] q = 0, m = 0, x = 0, a = 0, d = 0;
	reg [7:0] nowdata = 0;
	
	// Instantiate UUT
	OrbM16 M16frame(.clk100MHz(clk100MHz), .clk80MHz(clk80MHz), .UART_RX1(UART_RX1), .UART_RX2(UART_RX2), .UART_RX3(UART_RX3), .UART_RX4(UART_RX4), .UART_RX5(UART_RX5),/*.clk4_8MHz(clk4_8MHz),*/ .doubleOrbData(doubleOrbData),.ValRX(ValRX),.test1(test1), .test2(test2), .test3(test3), .test4(test4), .UART_TX1(UART_TX1), .UART_TX2(UART_TX2), .UART_TX3(UART_TX3), .UART_TX4(UART_TX4), .UART_TX5(UART_TX5), .UART_dTX1(UART_dTX1), .UART_dTX2(UART_dTX2), .UART_dTX3(UART_dTX3), .UART_dTX4(UART_dTX4), .UART_dTX5(UART_dTX5), .UART_dRX1(UART_dRX1), .UART_dRX2(UART_dRX2), .UART_dRX3(UART_dRX3), .UART_dRX4(UART_dRX4), .UART_dRX5(UART_dRX5));

	// Clock definition
	initial begin
		clk100MHz = 0;
		forever #500 clk100MHz = ~clk100MHz;
	end
	initial begin
		clk80MHz = 0;
		forever #625 clk80MHz = ~clk80MHz;
    end
    initial begin
		clk4_8MHz = 0;
		forever #10416 clk4_8MHz = ~clk4_8MHz;
	end
    
	
	initial begin
		data[0] = 0;
		data[1] = 10;
		data[2] = 20;
		data[3] = 30;
		data[4] = 40;
		data[5] = 50;
		data[6] = 60;
		data[7] = 70;
		data[8] = 80;
		data[9] = 90;
		data[10] = 100;
		data[11] = 110;
		data[12] = 120;
		data[13] = 130;
		data[14] = 140;
		data[15] = 150;
		data[16] = 160;
		data[17] = 170;
	end
	initial begin
		//for(k=0; k < 32; k=k+1'b1)
		//cntmas[k] = k << 3;
		cntmas[ 0 ] =  0 ;
cntmas[ 1 ] =  1 ;
cntmas[ 2 ] =  2 ;
cntmas[ 3 ] =  3 ;
cntmas[ 4 ] =  4 ;
cntmas[ 5 ] =  5 ;
cntmas[ 6 ] =  6 ;
cntmas[ 7 ] =  7 ;
cntmas[ 8 ] =  8 ;
cntmas[ 9 ] =  9 ;
cntmas[ 10 ] =  10 ;
cntmas[ 11 ] =  11 ;
cntmas[ 12 ] =  12 ;
cntmas[ 13 ] =  13 ;
cntmas[ 14 ] =  14 ;
cntmas[ 15 ] =  15 ;
cntmas[ 16 ] =  16 ;
cntmas[ 17 ] =  17 ;
cntmas[ 18 ] =  18 ;
cntmas[ 19 ] =  19 ;
cntmas[ 20 ] =  20 ;
cntmas[ 21 ] =  21 ;
cntmas[ 22 ] =  22 ;
cntmas[ 23 ] =  23 ;
cntmas[ 24 ] =  24 ;
cntmas[ 25 ] =  25 ;
cntmas[ 26 ] =  26 ;
cntmas[ 27 ] =  27 ;
cntmas[ 28 ] =  28 ;
cntmas[ 29 ] =  29 ;
cntmas[ 30 ] =  30 ;
cntmas[ 31 ] =  31 ;
cntmas[ 32 ] =  32 ;
cntmas[ 33 ] =  33 ;
cntmas[ 34 ] =  34 ;
cntmas[ 35 ] =  35 ;
cntmas[ 36 ] =  36 ;
cntmas[ 37 ] =  37 ;
cntmas[ 38 ] =  38 ;
cntmas[ 39 ] =  39 ;
cntmas[ 40 ] =  40 ;
cntmas[ 41 ] =  41 ;
cntmas[ 42 ] =  42 ;
cntmas[ 43 ] =  43 ;
cntmas[ 44 ] =  44 ;
cntmas[ 45 ] =  45 ;
cntmas[ 46 ] =  46 ;
cntmas[ 47 ] =  47 ;
cntmas[ 48 ] =  48 ;
cntmas[ 49 ] =  49 ;
cntmas[ 50 ] =  50 ;
cntmas[ 51 ] =  51 ;
cntmas[ 52 ] =  52 ;
cntmas[ 53 ] =  53 ;
cntmas[ 54 ] =  54 ;
cntmas[ 55 ] =  55 ;
cntmas[ 56 ] =  56 ;
cntmas[ 57 ] =  57 ;
cntmas[ 58 ] =  58 ;
cntmas[ 59 ] =  59 ;
cntmas[ 60 ] =  60 ;
cntmas[ 61 ] =  61 ;
cntmas[ 62 ] =  62 ;
cntmas[ 63 ] =  63 ;
cntmas[ 64 ] =  64 ;
cntmas[ 65 ] =  65 ;
cntmas[ 66 ] =  66 ;
cntmas[ 67 ] =  67 ;
cntmas[ 68 ] =  68 ;
cntmas[ 69 ] =  69 ;
cntmas[ 70 ] =  70 ;
cntmas[ 71 ] =  71 ;
cntmas[ 72 ] =  72 ;
cntmas[ 73 ] =  73 ;
cntmas[ 74 ] =  74 ;
cntmas[ 75 ] =  75 ;
cntmas[ 76 ] =  76 ;
cntmas[ 77 ] =  77 ;
cntmas[ 78 ] =  78 ;
cntmas[ 79 ] =  79 ;
cntmas[ 80 ] =  80 ;
cntmas[ 81 ] =  81 ;
cntmas[ 82 ] =  82 ;
cntmas[ 83 ] =  83 ;
cntmas[ 84 ] =  84 ;
cntmas[ 85 ] =  85 ;
cntmas[ 86 ] =  86 ;
cntmas[ 87 ] =  87 ;
cntmas[ 88 ] =  88 ;
cntmas[ 89 ] =  89 ;
cntmas[ 90 ] =  90 ;
cntmas[ 91 ] =  91 ;
cntmas[ 92 ] =  92 ;
cntmas[ 93 ] =  93 ;
cntmas[ 94 ] =  94 ;
cntmas[ 95 ] =  95 ;
cntmas[ 96 ] =  96 ;
cntmas[ 97 ] =  97 ;
cntmas[ 98 ] =  98 ;
cntmas[ 99 ] =  99 ;
cntmas[ 100 ] =  100 ;
cntmas[ 101 ] =  101 ;
cntmas[ 102 ] =  102 ;
cntmas[ 103 ] =  103 ;
cntmas[ 104 ] =  104 ;
cntmas[ 105 ] =  105 ;
cntmas[ 106 ] =  106 ;
cntmas[ 107 ] =  107 ;
cntmas[ 108 ] =  108 ;
cntmas[ 109 ] =  109 ;
cntmas[ 110 ] =  110 ;
cntmas[ 111 ] =  111 ;
cntmas[ 112 ] =  112 ;
cntmas[ 113 ] =  113 ;
cntmas[ 114 ] =  114 ;
cntmas[ 115 ] =  115 ;
cntmas[ 116 ] =  116 ;
cntmas[ 117 ] =  117 ;
cntmas[ 118 ] =  118 ;
cntmas[ 119 ] =  119 ;
cntmas[ 120 ] =  120 ;
cntmas[ 121 ] =  121 ;
cntmas[ 122 ] =  122 ;
cntmas[ 123 ] =  123 ;
cntmas[ 124 ] =  124 ;
cntmas[ 125 ] =  125 ;
cntmas[ 126 ] =  126 ;
cntmas[ 127 ] =  127 ;
cntmas[ 128 ] =  128 ;
cntmas[ 129 ] =  129 ;
cntmas[ 130 ] =  130 ;
cntmas[ 131 ] =  131 ;
cntmas[ 132 ] =  132 ;
cntmas[ 133 ] =  133 ;
cntmas[ 134 ] =  134 ;
cntmas[ 135 ] =  135 ;
cntmas[ 136 ] =  136 ;
cntmas[ 137 ] =  137 ;
cntmas[ 138 ] =  138 ;
cntmas[ 139 ] =  139 ;
cntmas[ 140 ] =  140 ;
cntmas[ 141 ] =  141 ;
cntmas[ 142 ] =  142 ;
cntmas[ 143 ] =  143 ;
cntmas[ 144 ] =  144 ;
cntmas[ 145 ] =  145 ;
cntmas[ 146 ] =  146 ;
cntmas[ 147 ] =  147 ;
cntmas[ 148 ] =  148 ;
cntmas[ 149 ] =  149 ;
cntmas[ 150 ] =  150 ;
cntmas[ 151 ] =  151 ;
cntmas[ 152 ] =  152 ;
cntmas[ 153 ] =  153 ;
cntmas[ 154 ] =  154 ;
cntmas[ 155 ] =  155 ;
cntmas[ 156 ] =  156 ;
cntmas[ 157 ] =  157 ;
cntmas[ 158 ] =  158 ;
cntmas[ 159 ] =  159 ;
cntmas[ 160 ] =  160 ;
cntmas[ 161 ] =  161 ;
cntmas[ 162 ] =  162 ;
cntmas[ 163 ] =  163 ;
cntmas[ 164 ] =  164 ;
cntmas[ 165 ] =  165 ;
cntmas[ 166 ] =  166 ;
cntmas[ 167 ] =  167 ;
cntmas[ 168 ] =  168 ;
cntmas[ 169 ] =  169 ;
cntmas[ 170 ] =  170 ;
cntmas[ 171 ] =  171 ;
cntmas[ 172 ] =  172 ;
cntmas[ 173 ] =  173 ;
cntmas[ 174 ] =  174 ;
cntmas[ 175 ] =  175 ;
cntmas[ 176 ] =  176 ;
cntmas[ 177 ] =  177 ;
cntmas[ 178 ] =  178 ;
cntmas[ 179 ] =  179 ;
cntmas[ 180 ] =  180 ;
cntmas[ 181 ] =  181 ;
cntmas[ 182 ] =  182 ;
cntmas[ 183 ] =  183 ;
cntmas[ 184 ] =  184 ;
cntmas[ 185 ] =  185 ;
cntmas[ 186 ] =  186 ;
cntmas[ 187 ] =  187 ;
cntmas[ 188 ] =  188 ;
cntmas[ 189 ] =  189 ;
cntmas[ 190 ] =  190 ;
cntmas[ 191 ] =  191 ;
cntmas[ 192 ] =  192 ;
cntmas[ 193 ] =  193 ;
cntmas[ 194 ] =  194 ;
cntmas[ 195 ] =  195 ;
cntmas[ 196 ] =  196 ;
cntmas[ 197 ] =  197 ;
cntmas[ 198 ] =  198 ;
cntmas[ 199 ] =  199 ;
cntmas[ 200 ] =  200 ;
cntmas[ 201 ] =  201 ;
cntmas[ 202 ] =  202 ;
cntmas[ 203 ] =  203 ;
cntmas[ 204 ] =  204 ;
cntmas[ 205 ] =  205 ;
cntmas[ 206 ] =  206 ;
cntmas[ 207 ] =  207 ;
cntmas[ 208 ] =  208 ;
cntmas[ 209 ] =  209 ;
cntmas[ 210 ] =  210 ;
cntmas[ 211 ] =  211 ;
cntmas[ 212 ] =  212 ;
cntmas[ 213 ] =  213 ;
cntmas[ 214 ] =  214 ;
cntmas[ 215 ] =  215 ;
cntmas[ 216 ] =  216 ;
cntmas[ 217 ] =  217 ;
cntmas[ 218 ] =  218 ;
cntmas[ 219 ] =  219 ;
cntmas[ 220 ] =  220 ;
cntmas[ 221 ] =  221 ;
cntmas[ 222 ] =  222 ;
cntmas[ 223 ] =  223 ;
cntmas[ 224 ] =  224 ;
cntmas[ 225 ] =  225 ;
cntmas[ 226 ] =  226 ;
cntmas[ 227 ] =  227 ;
cntmas[ 228 ] =  228 ;
cntmas[ 229 ] =  229 ;
cntmas[ 230 ] =  230 ;
cntmas[ 231 ] =  231 ;
cntmas[ 232 ] =  232 ;
cntmas[ 233 ] =  233 ;
cntmas[ 234 ] =  234 ;
cntmas[ 235 ] =  235 ;
cntmas[ 236 ] =  236 ;
cntmas[ 237 ] =  237 ;
cntmas[ 238 ] =  238 ;
cntmas[ 239 ] =  239 ;
cntmas[ 240 ] =  240 ;
cntmas[ 241 ] =  241 ;
cntmas[ 242 ] =  242 ;
cntmas[ 243 ] =  243 ;
cntmas[ 244 ] =  244 ;
cntmas[ 245 ] =  245 ;
cntmas[ 246 ] =  246 ;
cntmas[ 247 ] =  247 ;
cntmas[ 248 ] =  248 ;
cntmas[ 249 ] =  249 ;
cntmas[ 250 ] =  250 ;
cntmas[ 251 ] =  251 ;
cntmas[ 252 ] =  252 ;
cntmas[ 253 ] =  253 ;
cntmas[ 254 ] =  254 ;
cntmas[ 255 ] =  255 ;
		
		
	end
	initial begin						// Main
		repeat (30)@(posedge clk80MHz);
		UART_RX1 = 1;
		repeat (8192) begin					// 5 times
			j=0;
			wait(UART_dRX1 == 1);
			wait(UART_dRX1 == 0);

			repeat (30)@(posedge clk4_8MHz);
			repeat (18) begin				// 18 bytes
				repeat(1)@(posedge clk4_8MHz);
				UART_RX1 = 0;
				repeat (8)					// 8 bit
				begin
					nowdata = cntmas[q];
					@(posedge clk4_8MHz)
					if(j == 0)
						UART_RX1 = cntmas[q][i];
					else
						UART_RX1=data[j][i];
					i=i+1;
				end
				@(posedge clk4_8MHz);
				UART_RX1 = 1;
				
				j=j+1;
			end
			q = q+1;
		end
	end
	initial begin						// Main
		repeat (30)@(posedge clk80MHz);
		UART_RX2 = 1;
		repeat (8192) begin					// 5 times
			k=0;
			wait(UART_dRX2 == 1);
			wait(UART_dRX2 == 0);

			repeat (30)@(posedge clk4_8MHz);
			repeat (18) begin				// 18 bytes
				repeat(1)@(posedge clk4_8MHz);
				UART_RX2 = 0;
				repeat (8)					// 8 bit
				begin
					nowdata = cntmas[q];
					@(posedge clk4_8MHz)
					if(k == 0)
						UART_RX2 = cntmas[m][p]+1;
					else
						UART_RX2=data[k][p]+1;
					p=p+1;
				end
				@(posedge clk4_8MHz);
				UART_RX2 = 1;
				
				k=k+1;
			end
			m = m+1;
		end
	end
	initial begin						// Main
		repeat (30)@(posedge clk80MHz);
		UART_RX3 = 1;
		repeat (8192) begin					// 5 times
			n=0;
			wait(UART_dRX3 == 1);
			wait(UART_dRX3 == 0);

			repeat (30)@(posedge clk4_8MHz);
			repeat (18) begin				// 18 bytes
				repeat(1)@(posedge clk4_8MHz);
				UART_RX3 = 0;
				repeat (8)					// 8 bit
				begin
					nowdata = cntmas[q];
					@(posedge clk4_8MHz)
					if(n == 0)
						UART_RX3 = cntmas[x][s];
					else
						UART_RX3=data[n][s];
					s=s+1;
				end
				@(posedge clk4_8MHz);
				UART_RX3 = 1;
				
				n=n+1;
			end
			x = x+1;
		end
	end
	initial begin						// Main
		repeat (30)@(posedge clk80MHz);
		UART_RX4 = 1;
		repeat (8192) begin					// 5 times
			y=0;
			wait(UART_dRX4 == 1);
			wait(UART_dRX4 == 0);

			repeat (30)@(posedge clk4_8MHz);
			repeat (18) begin				// 18 bytes
				repeat(1)@(posedge clk4_8MHz);
				UART_RX4 = 0;
				repeat (8)					// 8 bit
				begin
					nowdata = cntmas[q];
					@(posedge clk4_8MHz)
					if(j == 0)
						UART_RX4 = cntmas[a][z];
					else
						UART_RX4=data[y][z];
					z=z+1;
				end
				@(posedge clk4_8MHz);
				UART_RX4 = 1;
				
				y=y+1;
			end
			a = a+1;
		end
	end
	initial begin						// Main
		repeat (30)@(posedge clk80MHz);
		UART_RX5 = 1;
		repeat (8192) begin					// 5 times
			b=0;
			wait(UART_dRX5 == 1);
			wait(UART_dRX5 == 0);

			repeat (30)@(posedge clk4_8MHz);
			repeat (18) begin				// 18 bytes
				repeat(1)@(posedge clk4_8MHz);
				UART_RX5 = 0;
				repeat (8)					// 8 bit
				begin
					nowdata = cntmas[q];
					@(posedge clk4_8MHz)
					if(b == 0)
						UART_RX5 = cntmas[d][c];
					else
						UART_RX5=data[b][c];
					c=c+1;
				end
				@(posedge clk4_8MHz);
				UART_RX5 = 1;
				
				b=b+1;
			end
			d = d+1;
		end
		//$stop;
	end
	
endmodule
