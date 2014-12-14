module ECC(
	input			clk,
	input			rst_n,
	input			ecc_start,
	input	[162:0]	g,
	input	[162:0]	k,
	output 	[175:0]	o_ecc_outxa,
	output 	[175:0]	o_ecc_outza,
	output reg 		ecc_done
	);
	
reg[162:0] ecc_outxa;
reg[162:0] ecc_outza;

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