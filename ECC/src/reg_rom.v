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
			register [0] <= 'b1101110011011100;
			register [1] <= 'b0011010010110010;
			register [2] <= 'b1000111110101010;
			register [3] <= 'b0000000000000000;
			register [4] <= 'b1111111111111111;
			register [5] <= 'b0000000000000000;
			register [6] <= 'b1111111111111111;
			register [7] <= 'b1111111111111111;
			register [8] <= 'b1111111111111111;
			register [9] <= 'b1111111111111111;
			register [10] <= 'b1111111111111111;
			register [11] <= 'b1111111111111111;
			register [12] <= 'b1111111111111111;
			register [13] <= 'b1111111111111111;
			register [14] <= 'b1111111111111111;
			register [15] <= 'b1111111111111111;
			register [16] <= 'b0111100011110110;
			register [17] <= 'b0001100000000000;
			register [18] <= 'b0001000100010001;
			register [19] <= 'b0010001000100010;
			register [20] <= 'b0011001100110011;
			register [21] <= 'b1111111111111111;
			register [22] <= 'b1111111111111111;
			register [23] <= 'b1111111111111111;
			register [24] <= 'b1111111111111111;
			register [25] <= 'b1111111111111111;
			register [26] <= 'b1111111111111111;
			register [27] <= 'b1111111111111111;
			register [28] <= 'b1111111111111111;
			register [29] <= 'b1111111111111111;
			register [30] <= 'b1111111111111111;
			register [31] <= 'b1111111111111111;
			register [32] <= 'b0001100000000000;
			register [33] <= 'b0001000100010001;
			register [34] <= 'b0010001000100010;
			register [35] <= 'b0011001100110011;
			register [36] <= 'b1111111111111111;
			register [37] <= 'b1111111111111111;
			register [38] <= 'b1111111111111111;
			register [39] <= 'b1111111111111111;
			register [40] <= 'b1111111111111111;
			register [41] <= 'b1111111111111111;
			register [42] <= 'b1111111111111111;
			register [43] <= 'b1111111111111111;
			register [44] <= 'b1111111111111111;
			register [45] <= 'b1111111111111111;
			register [46] <= 'b1111111111111111;
			register [47] <= 'b1111111111111111;
			register [48] <= 'b0010101101111110;
			register [49] <= 'b0001010100010110;
			register [50] <= 'b0010100010101110;
			register [51] <= 'b1101001010100110;
			register [52] <= 'b1010101111110111;
			register [53] <= 'b0001010110001000;
			register [54] <= 'b0000100111001111;
			register [55] <= 'b0100111100111100;
			register [56] <= 'b1101000000010100;
			register [57] <= 'b1111100110101000;
			register [58] <= 'b1100100111101110;
			register [59] <= 'b0010010110001001;
			register [60] <= 'b1110000100111111;
			register [61] <= 'b0000110011001000;
			register [62] <= 'b1011011001100011;
			register [63] <= 'b0000110010100110;

			Q				<= 'd0;
		end
	else if(!CEN)
	Q <= register[A];
	else
	Q <= Q;

endmodule