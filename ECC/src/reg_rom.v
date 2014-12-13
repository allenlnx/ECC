module reg_rom (
    Q,
    CLK,
    CEN,
    A,
	rst_n
        )	;
				
   output [15:0]            Q;
   input 					rst_n;
   input                    CLK;
   input                    CEN;
   input [5:0]              A;
   reg [15:0]				Q;
   reg [15:0]			register[63:0]	;

   always@ (posedge CLK or negedge rst_n)
	if(!rst_n)
		begin
			register [0] <= 'hdcdc;
			register [1] <= 'h34b2;
			register [2] <= 'h8faa;
			register [3] <= 'h0000;
			register [4] <= 'hffff;
			register [5] <= 'h0000;
			register [6] <= 'hffff;
			register [7] <= 'hffff;
			register [8] <= 'hffff;
			register [9] <= 'hffff;
			register [10] <= 'hffff;
			register [11] <= 'hffff;
			register [12] <= 'hffff;
			register [13] <= 'hffff;
			register [14] <= 'hffff;
			register [15] <= 'hffff;
			register [16] <= 'h78f6;
			register [17] <= 'h1800;
			register [18] <= 'h1111;
			register [19] <= 'h2222;
			register [20] <= 'h3333;
			register [21] <= 'hffff;
			register [22] <= 'hffff;
			register [23] <= 'hffff;
			register [24] <= 'hffff;
			register [25] <= 'hffff;
			register [26] <= 'hffff;
			register [27] <= 'hffff;
			register [28] <= 'hffff;
			register [29] <= 'hffff;
			register [30] <= 'hffff;
			register [31] <= 'hffff;
			register [32] <= 'h1800;
			register [33] <= 'h1111;
			register [34] <= 'h2222;
			register [35] <= 'h3333;
			register [36] <= 'hffff;
			register [37] <= 'hffff;
			register [38] <= 'hffff;
			register [39] <= 'hffff;
			register [40] <= 'hffff;
			register [41] <= 'hffff;
			register [42] <= 'hffff;
			register [43] <= 'hffff;
			register [44] <= 'hffff;
			register [45] <= 'hffff;
			register [46] <= 'hffff;
			register [47] <= 'hffff;
			register [48] <= 'h2b7e;
			register [49] <= 'h1516;
			register [50] <= 'h28ae;
			register [51] <= 'hd2a6;
			register [52] <= 'habf7;
			register [53] <= 'h1588;
			register [54] <= 'h09cf;
			register [55] <= 'h4f3c;
			register [56] <= 'hd014;
			register [57] <= 'hf9a8;
			register [58] <= 'hc9ee;
			register [59] <= 'h2589;
			register [60] <= 'he13f;
			register [61] <= 'h0cc8;
			register [62] <= 'hb663;
			register [63] <= 'h0ca6;

			Q				<= 'd0;
		end
	else if(!CEN)
	Q <= register[A];
	else
	Q <= Q;

endmodule