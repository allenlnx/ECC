/*******************************
module name : ff_adder
author : wu cheng 
describe: 
version:1.0  
*********************************/
module ff_adder(
				   a,
				   b,
				  
				   c);
				  
				  

input     [162:0]    a;
input     [162:0]    b;

output  [162:0]    c;

wire    [162:0]    c;

/*******************internal via *********************/


/*******************procedure ***************************/

assign c[162:0] = a[162:0] ^ b[162:0];
	   

endmodule
