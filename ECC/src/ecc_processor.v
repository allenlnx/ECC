/*******************************
module name : ecc_processor
author : wu cheng 
describe: top module
version:1.1 
*********************************/
module ecc_processor(clk,
                    rst_n,
				    ecc_start,
				    g,
				//    c,
				    k,
				   // t,				   
				    ecc_outxa,
				    ecc_outza,
				    ecc_done);
				  
				  
input                clk;
input                rst_n;
input      [162:0]   g;
//input      [162:0]   c;
input      [162:0]   k;
//input      [162:0]   t;
input                ecc_start;

output     [175:0]    ecc_outxa;
//output     [162:0]    ecc_outxb;
output     [175:0]    ecc_outza;
//output     [162:0]    ecc_outzb;
//output     [162:0]    ecc_outzc;
output                ecc_done;


/*******************internal via *********************/

wire        [2:0]   reg_select;
wire      [162:0]   alu_z,alu_x,zc,zb,za,xb,xa,alu_out;
wire                ss,st,sy;
wire                m_start,m_done;
wire                select_x,select_xab;
wire                select_z,select_zab;
//wire                select_xzswap;
/*******************procedure ***************************/
assign ecc_outxa = {13'd0,xa};
//assign ecc_outxb = xb;
assign ecc_outza = {13'd0,za};
//assign ecc_outzb = zb;
//assign ecc_outzc = zc;

reg_file  reg_file  ( 
               .clk(clk),
               .rst_n(rst_n),
				   .s(alu_out),
				   .reg_select(reg_select),	   
				   .xa(xa),
				   .xb(xb),
				   .za(za),
				   .zb(zb),
				   .zc(zc));
				   
				   
				   
alu       alu(
            .clk(clk),
            .rst_n(rst_n),
			   .a(alu_x),
			   .b(alu_z),
			   .ss(ss),
			   .st(st),
			   .sy(sy),
			   .m_start(m_start),	  
			   .y(alu_out),
			   .m_done(m_done));


alu_in_mux alu_in_mux( 
               .xa(xa),
			      .xb(xb),
	       		   .g(g),
	       		//   .c(c),
			      .za(za),
			      .zb(zb),
			      .zc(zc),   
			      .select_x(select_x),
			      .select_xab(select_xab),
			    //  .select_xcg(select_xcg),
			      .select_z(select_z),
			      .select_zab(select_zab),
			      .alu_x(alu_x),
			      .alu_z(alu_z));

ecc_fsm fsm(   
            .clk(clk),
            .rst_n(rst_n),
			   .k(k),
			   .ecc_start(ecc_start),
			   .m_done(m_done),		   			   
			   .m_start(m_start),
			   .reg_select(reg_select),
			   .select_x(select_x),
			   .select_xab(select_xab),
			  // .select_xcg(select_xcg),
			   .select_z(select_z),	  
			   .select_zab(select_zab),
			   .ss(ss),
			   .st(st),
			   .sy(sy),
			   .ecc_done(ecc_done));
			  		   
	endmodule
