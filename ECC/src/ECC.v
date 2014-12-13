module ECC(
	clk,
	rst_n,
	ecc_start,
	g,
	k,
	o_ecc_outxa,
	o_ecc_outza,
	ecc_done);
	
input clk;
input rst_n;
input[162:0] g;
input[162:0] k;
input ecc_start;

output[175:0] o_ecc_outxa;
output[175:0] o_ecc_outza;
output ecc_done;

reg[162:0] ecc_outxa;
reg[162:0] ecc_outza;
reg ecc_done;

assign o_ecc_outxa = {13'b0,ecc_outxa};
assign o_ecc_outza = {13'b0,ecc_outza};

always@(posedge clk or negedge rst_n)
begin
	if(!rst_n)
	begin
		ecc_outxa <= 0;
		ecc_outza <= 0;
		ecc_done <= 0;
	end
	else
	begin
		if(ecc_start)
		begin
			ecc_outxa <= 162'ha1b2_c3d4;
			ecc_outza <= 162'he5f6_0789;
			ecc_done <= 1'd1;
		end
		else
		begin
			ecc_outxa <= 0;
			ecc_outza <= 0;
			ecc_done <= 0;
		end
	end
end

endmodule