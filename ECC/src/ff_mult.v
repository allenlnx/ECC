/***********************************************
module name : ff_mult
author : wu cheng
describe : Digit-Serial Most-Significant-Digit-First Multiplier
version : 1.1
***********************************************/
module ff_mult(
               clk,
               rst_n,
					a,
					b,
					start,
					p,
					done);
					
					
input  clk,rst_n,start;
input  [162:0]  a,b;

output [162:0]  p;
output  done;

//reg [162:0]  p;

/*******************internal via *********************/
reg [5:0] s;
reg [162:0] p;
reg done;
reg d0,d1,d2,d3;
wire [165:0] g;
wire [162:0] c;
/*******************procedure ***************************/
always @(posedge clk or negedge rst_n)
if(!rst_n)
  s<=6'b0;
else if(!start)
  s<=6'b0;
else if(start)
  s<=s+1;
  
/* 
always @(posedge clk or negedge rst_n)
if(!rst_n)
  p<=163'b0;
else if(done)
  p<=163'b0;
else if(start)
  p<=c;
*/
always @(posedge clk or negedge rst_n or negedge start)
begin
if(!rst_n)
  begin
     p <= 163'b0;
     done <= 1'b0;
     d0<=1'b0;
     d1<=1'b0;
     d2<=1'b0;
     d3<=1'b0;
  end 
else if (start == 1'b0)
  begin 
     done <= 1'b0;
  //   p <= 163'b0;
  end
else case (s)
  6'd42:   begin   p <= p;   end
  6'd41:   begin   p <= c;   done <= 1'b1;end
  6'd40:   begin   d0 <= b[0];   d1 <= b[1];   d2 <= b[2];   d3 <= b[3];   p <= c;end
  6'd39:   begin   d0 <= b[4];   d1 <= b[5];   d2 <= b[6];   d3 <= b[7];   p <= c;end
  6'd38:   begin   d0 <= b[8];   d1 <= b[9];   d2 <= b[10];  d3 <= b[11];  p <= c;end 
  6'd37:   begin   d0 <= b[12];  d1 <= b[13];  d2 <= b[14];  d3 <= b[15];  p <= c;end
  6'd36:   begin   d0 <= b[16];  d1 <= b[17];  d2 <= b[18];  d3 <= b[19];  p <= c;end 
  6'd35:   begin   d0 <= b[20];  d1 <= b[21];  d2 <= b[22];  d3 <= b[23];  p <= c;end
  6'd34:   begin   d0 <= b[24];  d1 <= b[25];  d2 <= b[26];  d3 <= b[27];  p <= c;end 
  6'd33:   begin   d0 <= b[28];  d1 <= b[29];  d2 <= b[30];  d3 <= b[31];  p <= c;end
  6'd32:   begin   d0 <= b[32];  d1 <= b[33];  d2 <= b[34];  d3 <= b[35];  p <= c;end 
  6'd31:   begin   d0 <= b[36];  d1 <= b[37];  d2 <= b[38];  d3 <= b[39];  p <= c;end
  6'd30:  begin   d0 <= b[40];  d1 <= b[41];  d2 <= b[42];  d3 <= b[43];  p <= c;end 
  6'd29:  begin   d0 <= b[44];  d1 <= b[45];  d2 <= b[46];  d3 <= b[47];  p <= c;end
  6'd28:  begin   d0 <= b[48];  d1 <= b[49];  d2 <= b[50];  d3 <= b[51];  p <= c;end 
  6'd27:  begin   d0 <= b[52];  d1 <= b[53];  d2 <= b[54];  d3 <= b[55];  p <= c;end
  6'd26:  begin   d0 <= b[56];  d1 <= b[57];  d2 <= b[58];  d3 <= b[59];  p <= c;end 
  6'd25:  begin   d0 <= b[60];  d1 <= b[61];  d2 <= b[62];  d3 <= b[63];  p <= c;end
  6'd24:  begin   d0 <= b[64];  d1 <= b[65];  d2 <= b[66];  d3 <= b[67];  p <= c;end 
  6'd23:  begin   d0 <= b[68];  d1 <= b[69];  d2 <= b[70];  d3 <= b[71];  p <= c;end
  6'd22:  begin   d0 <= b[72];  d1 <= b[73];  d2 <= b[74];  d3 <= b[75];  p <= c;end 
  6'd21:  begin   d0 <= b[76];  d1 <= b[77];  d2 <= b[78];  d3 <= b[79];  p <= c;end
  6'd20:  begin   d0 <= b[80];  d1 <= b[81];  d2 <= b[82];  d3 <= b[83];  p <= c;end 
  6'd19:  begin   d0 <= b[84];  d1 <= b[85];  d2 <= b[86];  d3 <= b[87];  p <= c;end
  6'd18:  begin   d0 <= b[88];  d1 <= b[89];  d2 <= b[90];  d3 <= b[91];  p <= c;end 
  6'd17:  begin   d0 <= b[92];  d1 <= b[93];  d2 <= b[94];  d3 <= b[95];  p <= c;end
  6'd16:  begin   d0 <= b[96];  d1 <= b[97];  d2 <= b[98];  d3 <= b[99];  p <= c;end 
  6'd15:  begin   d0 <= b[100]; d1 <= b[101]; d2 <= b[102]; d3 <= b[103]; p <= c;end
  6'd14:  begin   d0 <= b[104]; d1 <= b[105]; d2 <= b[106]; d3 <= b[107]; p <= c;end
  6'd13:  begin   d0 <= b[108]; d1 <= b[109]; d2 <= b[110]; d3 <= b[111]; p <= c;end
  6'd12:  begin   d0 <= b[112]; d1 <= b[113]; d2 <= b[114]; d3 <= b[115]; p <= c;end
  6'd11:  begin   d0 <= b[116]; d1 <= b[117]; d2 <= b[118]; d3 <= b[119]; p <= c;end
  6'd10:  begin   d0 <= b[120]; d1 <= b[121]; d2 <= b[122]; d3 <= b[123]; p <= c;end
  6'd9:  begin   d0 <= b[124]; d1 <= b[125]; d2 <= b[126]; d3 <= b[127]; p <= c;end
  6'd8:  begin   d0 <= b[128]; d1 <= b[129]; d2 <= b[130]; d3 <= b[131]; p <= c;end
  6'd7:  begin   d0 <= b[132]; d1 <= b[133]; d2 <= b[134]; d3 <= b[135]; p <= c;end
  6'd6:  begin   d0 <= b[136]; d1 <= b[137]; d2 <= b[138]; d3 <= b[139]; p <= c;end
  6'd5:  begin   d0 <= b[140]; d1 <= b[141]; d2 <= b[142]; d3 <= b[143]; p <= c;end
  6'd4:  begin   d0 <= b[144]; d1 <= b[145]; d2 <= b[146]; d3 <= b[147]; p <= c;end
  6'd3:  begin   d0 <= b[148]; d1 <= b[149]; d2 <= b[150]; d3 <= b[151]; p <= c;end
  6'd2:  begin   d0 <= b[152]; d1 <= b[153]; d2 <= b[154]; d3 <= b[155]; p <= c;end
  6'd1:  begin   d0 <= b[156]; d1 <= b[157]; d2 <= b[158]; d3 <= b[159]; p <= c;end
  6'd0:  begin   d0 <= b[160]; d1 <= b[161]; d2 <= b[162]; d3 <= 0;      p <= 163'b0;end
  default:begin   d0 <= 0; d1 <= 0; d2 <= 0; d3 <= 0;    p <= 163'b0;end
endcase
end
  
  
 assign g[0] = d0 && a[0];
 assign g[1] = (d0 && a[1]) ^ (d1 && a[0]);
 assign g[2] = (d0 && a[2]) ^ (d1 && a[1]) ^ (d2 && a[0]); 
 assign g[3] = (d0 && a[3]) ^ (d1 && a[2]) ^ (d2 && a[1]) ^ (d3 && a[0]); 
 assign g[4] = (d0 && a[4]) ^ (d1 && a[3]) ^ (d2 && a[2]) ^ (d3 && a[1]); 
 assign g[5] = (d0 && a[5]) ^ (d1 && a[4]) ^ (d2 && a[3]) ^ (d3 && a[2]); 
 assign g[6] = (d0 && a[6]) ^ (d1 && a[5]) ^ (d2 && a[4]) ^ (d3 && a[3]);
 assign g[7] = (d0 && a[7]) ^ (d1 && a[6]) ^ (d2 && a[5]) ^ (d3 && a[4]);
 assign g[8] = (d0 && a[8]) ^ (d1 && a[7]) ^ (d2 && a[6]) ^ (d3 && a[5]);
 assign g[9] = (d0 && a[9]) ^ (d1 && a[8]) ^ (d2 && a[7]) ^ (d3 && a[6]);
 assign g[10] = (d0 && a[10]) ^ (d1 && a[9]) ^ (d2 && a[8]) ^ (d3 && a[7]);
 assign g[11] = (d0 && a[11]) ^ (d1 && a[10]) ^ (d2 && a[9]) ^ (d3 && a[8]);
 assign g[12] = (d0 && a[12]) ^ (d1 && a[11]) ^ (d2 && a[10]) ^ (d3 && a[9]);
 assign g[13] = (d0 && a[13]) ^ (d1 && a[12]) ^ (d2 && a[11]) ^ (d3 && a[10]);
 assign g[14] = (d0 && a[14]) ^ (d1 && a[13]) ^ (d2 && a[12]) ^ (d3 && a[11]);
 assign g[15] = (d0 && a[15]) ^ (d1 && a[14]) ^ (d2 && a[13]) ^ (d3 && a[12]);
 assign g[16] = (d0 && a[16]) ^ (d1 && a[15]) ^ (d2 && a[14]) ^ (d3 && a[13]);
 assign g[17] = (d0 && a[17]) ^ (d1 && a[16]) ^ (d2 && a[15]) ^ (d3 && a[14]);
 assign g[18] = (d0 && a[18]) ^ (d1 && a[17]) ^ (d2 && a[16]) ^ (d3 && a[15]);
 assign g[19] = (d0 && a[19]) ^ (d1 && a[18]) ^ (d2 && a[17]) ^ (d3 && a[16]);
 assign g[20] = (d0 && a[20]) ^ (d1 && a[19]) ^ (d2 && a[18]) ^ (d3 && a[17]);
 assign g[21] = (d0 && a[21]) ^ (d1 && a[20]) ^ (d2 && a[19]) ^ (d3 && a[18]);
 assign g[22] = (d0 && a[22]) ^ (d1 && a[21]) ^ (d2 && a[20]) ^ (d3 && a[19]);
 assign g[23] = (d0 && a[23]) ^ (d1 && a[22]) ^ (d2 && a[21]) ^ (d3 && a[20]);
 assign g[24] = (d0 && a[24]) ^ (d1 && a[23]) ^ (d2 && a[22]) ^ (d3 && a[21]);
 assign g[25] = (d0 && a[25]) ^ (d1 && a[24]) ^ (d2 && a[23]) ^ (d3 && a[22]);
 assign g[26] = (d0 && a[26]) ^ (d1 && a[25]) ^ (d2 && a[24]) ^ (d3 && a[23]);
 assign g[27] = (d0 && a[27]) ^ (d1 && a[26]) ^ (d2 && a[25]) ^ (d3 && a[24]);
 assign g[28] = (d0 && a[28]) ^ (d1 && a[27]) ^ (d2 && a[26]) ^ (d3 && a[25]);
 assign g[29] = (d0 && a[29]) ^ (d1 && a[28]) ^ (d2 && a[27]) ^ (d3 && a[26]);
 assign g[30] = (d0 && a[30]) ^ (d1 && a[29]) ^ (d2 && a[28]) ^ (d3 && a[27]);
 assign g[31] = (d0 && a[31]) ^ (d1 && a[30]) ^ (d2 && a[29]) ^ (d3 && a[28]);
 assign g[32] = (d0 && a[32]) ^ (d1 && a[31]) ^ (d2 && a[30]) ^ (d3 && a[29]);
 assign g[33] = (d0 && a[33]) ^ (d1 && a[32]) ^ (d2 && a[31]) ^ (d3 && a[30]);
 assign g[34] = (d0 && a[34]) ^ (d1 && a[33]) ^ (d2 && a[32]) ^ (d3 && a[31]);
 assign g[35] = (d0 && a[35]) ^ (d1 && a[34]) ^ (d2 && a[33]) ^ (d3 && a[32]);
 assign g[36] = (d0 && a[36]) ^ (d1 && a[35]) ^ (d2 && a[34]) ^ (d3 && a[33]);
 assign g[37] = (d0 && a[37]) ^ (d1 && a[36]) ^ (d2 && a[35]) ^ (d3 && a[34]);
 assign g[38] = (d0 && a[38]) ^ (d1 && a[37]) ^ (d2 && a[36]) ^ (d3 && a[35]);
 assign g[39] = (d0 && a[39]) ^ (d1 && a[38]) ^ (d2 && a[37]) ^ (d3 && a[36]);
 assign g[40] = (d0 && a[40]) ^ (d1 && a[39]) ^ (d2 && a[38]) ^ (d3 && a[37]);
 assign g[41] = (d0 && a[41]) ^ (d1 && a[40]) ^ (d2 && a[39]) ^ (d3 && a[38]);
 assign g[42] = (d0 && a[42]) ^ (d1 && a[41]) ^ (d2 && a[40]) ^ (d3 && a[39]);
 assign g[43] = (d0 && a[43]) ^ (d1 && a[42]) ^ (d2 && a[41]) ^ (d3 && a[40]);
 assign g[44] = (d0 && a[44]) ^ (d1 && a[43]) ^ (d2 && a[42]) ^ (d3 && a[41]);
 assign g[45] = (d0 && a[45]) ^ (d1 && a[44]) ^ (d2 && a[43]) ^ (d3 && a[42]);
 assign g[46] = (d0 && a[46]) ^ (d1 && a[45]) ^ (d2 && a[44]) ^ (d3 && a[43]);
 assign g[47] = (d0 && a[47]) ^ (d1 && a[46]) ^ (d2 && a[45]) ^ (d3 && a[44]);
 assign g[48] = (d0 && a[48]) ^ (d1 && a[47]) ^ (d2 && a[46]) ^ (d3 && a[45]);
 assign g[49] = (d0 && a[49]) ^ (d1 && a[48]) ^ (d2 && a[47]) ^ (d3 && a[46]);
 assign g[50] = (d0 && a[50]) ^ (d1 && a[49]) ^ (d2 && a[48]) ^ (d3 && a[47]);
 assign g[51] = (d0 && a[51]) ^ (d1 && a[50]) ^ (d2 && a[49]) ^ (d3 && a[48]);
 assign g[52] = (d0 && a[52]) ^ (d1 && a[51]) ^ (d2 && a[50]) ^ (d3 && a[49]);
 assign g[53] = (d0 && a[53]) ^ (d1 && a[52]) ^ (d2 && a[51]) ^ (d3 && a[50]);
 assign g[54] = (d0 && a[54]) ^ (d1 && a[53]) ^ (d2 && a[52]) ^ (d3 && a[51]);
 assign g[55] = (d0 && a[55]) ^ (d1 && a[54]) ^ (d2 && a[53]) ^ (d3 && a[52]);
 assign g[56] = (d0 && a[56]) ^ (d1 && a[55]) ^ (d2 && a[54]) ^ (d3 && a[53]);
 assign g[57] = (d0 && a[57]) ^ (d1 && a[56]) ^ (d2 && a[55]) ^ (d3 && a[54]);
 assign g[58] = (d0 && a[58]) ^ (d1 && a[57]) ^ (d2 && a[56]) ^ (d3 && a[55]);
 assign g[59] = (d0 && a[59]) ^ (d1 && a[58]) ^ (d2 && a[57]) ^ (d3 && a[56]);
 assign g[60] = (d0 && a[60]) ^ (d1 && a[59]) ^ (d2 && a[58]) ^ (d3 && a[57]);
 assign g[61] = (d0 && a[61]) ^ (d1 && a[60]) ^ (d2 && a[59]) ^ (d3 && a[58]);
 assign g[62] = (d0 && a[62]) ^ (d1 && a[61]) ^ (d2 && a[60]) ^ (d3 && a[59]);
 assign g[63] = (d0 && a[63]) ^ (d1 && a[62]) ^ (d2 && a[61]) ^ (d3 && a[60]);
 assign g[64] = (d0 && a[64]) ^ (d1 && a[63]) ^ (d2 && a[62]) ^ (d3 && a[61]);
 assign g[65] = (d0 && a[65]) ^ (d1 && a[64]) ^ (d2 && a[63]) ^ (d3 && a[62]);
 assign g[66] = (d0 && a[66]) ^ (d1 && a[65]) ^ (d2 && a[64]) ^ (d3 && a[63]);
 assign g[67] = (d0 && a[67]) ^ (d1 && a[66]) ^ (d2 && a[65]) ^ (d3 && a[64]);
 assign g[68] = (d0 && a[68]) ^ (d1 && a[67]) ^ (d2 && a[66]) ^ (d3 && a[65]);
 assign g[69] = (d0 && a[69]) ^ (d1 && a[68]) ^ (d2 && a[67]) ^ (d3 && a[66]);
 assign g[70] = (d0 && a[70]) ^ (d1 && a[69]) ^ (d2 && a[68]) ^ (d3 && a[67]);
 assign g[71] = (d0 && a[71]) ^ (d1 && a[70]) ^ (d2 && a[69]) ^ (d3 && a[68]);
 assign g[72] = (d0 && a[72]) ^ (d1 && a[71]) ^ (d2 && a[70]) ^ (d3 && a[69]);
 assign g[73] = (d0 && a[73]) ^ (d1 && a[72]) ^ (d2 && a[71]) ^ (d3 && a[70]);
 assign g[74] = (d0 && a[74]) ^ (d1 && a[73]) ^ (d2 && a[72]) ^ (d3 && a[71]);
 assign g[75] = (d0 && a[75]) ^ (d1 && a[74]) ^ (d2 && a[73]) ^ (d3 && a[72]);
 assign g[76] = (d0 && a[76]) ^ (d1 && a[75]) ^ (d2 && a[74]) ^ (d3 && a[73]);
 assign g[77] = (d0 && a[77]) ^ (d1 && a[76]) ^ (d2 && a[75]) ^ (d3 && a[74]);
 assign g[78] = (d0 && a[78]) ^ (d1 && a[77]) ^ (d2 && a[76]) ^ (d3 && a[75]);
 assign g[79] = (d0 && a[79]) ^ (d1 && a[78]) ^ (d2 && a[77]) ^ (d3 && a[76]);
 assign g[80] = (d0 && a[80]) ^ (d1 && a[79]) ^ (d2 && a[78]) ^ (d3 && a[77]);
 assign g[81] = (d0 && a[81]) ^ (d1 && a[80]) ^ (d2 && a[79]) ^ (d3 && a[78]);
 assign g[82] = (d0 && a[82]) ^ (d1 && a[81]) ^ (d2 && a[80]) ^ (d3 && a[79]);
 assign g[83] = (d0 && a[83]) ^ (d1 && a[82]) ^ (d2 && a[81]) ^ (d3 && a[80]);
 assign g[84] = (d0 && a[84]) ^ (d1 && a[83]) ^ (d2 && a[82]) ^ (d3 && a[81]);
 assign g[85] = (d0 && a[85]) ^ (d1 && a[84]) ^ (d2 && a[83]) ^ (d3 && a[82]);
 assign g[86] = (d0 && a[86]) ^ (d1 && a[85]) ^ (d2 && a[84]) ^ (d3 && a[83]);
 assign g[87] = (d0 && a[87]) ^ (d1 && a[86]) ^ (d2 && a[85]) ^ (d3 && a[84]);
 assign g[88] = (d0 && a[88]) ^ (d1 && a[87]) ^ (d2 && a[86]) ^ (d3 && a[85]);
 assign g[89] = (d0 && a[89]) ^ (d1 && a[88]) ^ (d2 && a[87]) ^ (d3 && a[86]);
 assign g[90] = (d0 && a[90]) ^ (d1 && a[89]) ^ (d2 && a[88]) ^ (d3 && a[87]);
 assign g[91] = (d0 && a[91]) ^ (d1 && a[90]) ^ (d2 && a[89]) ^ (d3 && a[88]);
 assign g[92] = (d0 && a[92]) ^ (d1 && a[91]) ^ (d2 && a[90]) ^ (d3 && a[89]);
 assign g[93] = (d0 && a[93]) ^ (d1 && a[92]) ^ (d2 && a[91]) ^ (d3 && a[90]);
 assign g[94] = (d0 && a[94]) ^ (d1 && a[93]) ^ (d2 && a[92]) ^ (d3 && a[91]);
 assign g[95] = (d0 && a[95]) ^ (d1 && a[94]) ^ (d2 && a[93]) ^ (d3 && a[92]);
 assign g[96] = (d0 && a[96]) ^ (d1 && a[95]) ^ (d2 && a[94]) ^ (d3 && a[93]);
 assign g[97] = (d0 && a[97]) ^ (d1 && a[96]) ^ (d2 && a[95]) ^ (d3 && a[94]);
 assign g[98] = (d0 && a[98]) ^ (d1 && a[97]) ^ (d2 && a[96]) ^ (d3 && a[95]);
 assign g[99] = (d0 && a[99]) ^ (d1 && a[98]) ^ (d2 && a[97]) ^ (d3 && a[96]);
 assign g[100] = (d0 && a[100]) ^ (d1 && a[99]) ^ (d2 && a[98]) ^ (d3 && a[97]);
 assign g[101] = (d0 && a[101]) ^ (d1 && a[100]) ^ (d2 && a[99]) ^ (d3 && a[98]);
 assign g[102] = (d0 && a[102]) ^ (d1 && a[101]) ^ (d2 && a[100]) ^ (d3 && a[99]);
 assign g[103] = (d0 && a[103]) ^ (d1 && a[102]) ^ (d2 && a[101]) ^ (d3 && a[100]);
 assign g[104] = (d0 && a[104]) ^ (d1 && a[103]) ^ (d2 && a[102]) ^ (d3 && a[101]);
 assign g[105] = (d0 && a[105]) ^ (d1 && a[104]) ^ (d2 && a[103]) ^ (d3 && a[102]);
 assign g[106] = (d0 && a[106]) ^ (d1 && a[105]) ^ (d2 && a[104]) ^ (d3 && a[103]);
 assign g[107] = (d0 && a[107]) ^ (d1 && a[106]) ^ (d2 && a[105]) ^ (d3 && a[104]);
 assign g[108] = (d0 && a[108]) ^ (d1 && a[107]) ^ (d2 && a[106]) ^ (d3 && a[105]);
 assign g[109] = (d0 && a[109]) ^ (d1 && a[108]) ^ (d2 && a[107]) ^ (d3 && a[106]);
 assign g[110] = (d0 && a[110]) ^ (d1 && a[109]) ^ (d2 && a[108]) ^ (d3 && a[107]);
 assign g[111] = (d0 && a[111]) ^ (d1 && a[110]) ^ (d2 && a[109]) ^ (d3 && a[108]);
 assign g[112] = (d0 && a[112]) ^ (d1 && a[111]) ^ (d2 && a[110]) ^ (d3 && a[109]);
 assign g[113] = (d0 && a[113]) ^ (d1 && a[112]) ^ (d2 && a[111]) ^ (d3 && a[110]);
 assign g[114] = (d0 && a[114]) ^ (d1 && a[113]) ^ (d2 && a[112]) ^ (d3 && a[111]);
 assign g[115] = (d0 && a[115]) ^ (d1 && a[114]) ^ (d2 && a[113]) ^ (d3 && a[112]);
 assign g[116] = (d0 && a[116]) ^ (d1 && a[115]) ^ (d2 && a[114]) ^ (d3 && a[113]);
 assign g[117] = (d0 && a[117]) ^ (d1 && a[116]) ^ (d2 && a[115]) ^ (d3 && a[114]);
 assign g[118] = (d0 && a[118]) ^ (d1 && a[117]) ^ (d2 && a[116]) ^ (d3 && a[115]);
 assign g[119] = (d0 && a[119]) ^ (d1 && a[118]) ^ (d2 && a[117]) ^ (d3 && a[116]);
 assign g[120] = (d0 && a[120]) ^ (d1 && a[119]) ^ (d2 && a[118]) ^ (d3 && a[117]);
 assign g[121] = (d0 && a[121]) ^ (d1 && a[120]) ^ (d2 && a[119]) ^ (d3 && a[118]);
 assign g[122] = (d0 && a[122]) ^ (d1 && a[121]) ^ (d2 && a[120]) ^ (d3 && a[119]);
 assign g[123] = (d0 && a[123]) ^ (d1 && a[122]) ^ (d2 && a[121]) ^ (d3 && a[120]);
 assign g[124] = (d0 && a[124]) ^ (d1 && a[123]) ^ (d2 && a[122]) ^ (d3 && a[121]);
 assign g[125] = (d0 && a[125]) ^ (d1 && a[124]) ^ (d2 && a[123]) ^ (d3 && a[122]);
 assign g[126] = (d0 && a[126]) ^ (d1 && a[125]) ^ (d2 && a[124]) ^ (d3 && a[123]);
 assign g[127] = (d0 && a[127]) ^ (d1 && a[126]) ^ (d2 && a[125]) ^ (d3 && a[124]);
 assign g[128] = (d0 && a[128]) ^ (d1 && a[127]) ^ (d2 && a[126]) ^ (d3 && a[125]);
 assign g[129] = (d0 && a[129]) ^ (d1 && a[128]) ^ (d2 && a[127]) ^ (d3 && a[126]);
 assign g[130] = (d0 && a[130]) ^ (d1 && a[129]) ^ (d2 && a[128]) ^ (d3 && a[127]);
 assign g[131] = (d0 && a[131]) ^ (d1 && a[130]) ^ (d2 && a[129]) ^ (d3 && a[128]);
 assign g[132] = (d0 && a[132]) ^ (d1 && a[131]) ^ (d2 && a[130]) ^ (d3 && a[129]);
 assign g[133] = (d0 && a[133]) ^ (d1 && a[132]) ^ (d2 && a[131]) ^ (d3 && a[130]);
 assign g[134] = (d0 && a[134]) ^ (d1 && a[133]) ^ (d2 && a[132]) ^ (d3 && a[131]);
 assign g[135] = (d0 && a[135]) ^ (d1 && a[134]) ^ (d2 && a[133]) ^ (d3 && a[132]);
 assign g[136] = (d0 && a[136]) ^ (d1 && a[135]) ^ (d2 && a[134]) ^ (d3 && a[133]);
 assign g[137] = (d0 && a[137]) ^ (d1 && a[136]) ^ (d2 && a[135]) ^ (d3 && a[134]);
 assign g[138] = (d0 && a[138]) ^ (d1 && a[137]) ^ (d2 && a[136]) ^ (d3 && a[135]);
 assign g[139] = (d0 && a[139]) ^ (d1 && a[138]) ^ (d2 && a[137]) ^ (d3 && a[136]);
 assign g[140] = (d0 && a[140]) ^ (d1 && a[139]) ^ (d2 && a[138]) ^ (d3 && a[137]);
 assign g[141] = (d0 && a[141]) ^ (d1 && a[140]) ^ (d2 && a[139]) ^ (d3 && a[138]);
 assign g[142] = (d0 && a[142]) ^ (d1 && a[141]) ^ (d2 && a[140]) ^ (d3 && a[139]);
 assign g[143] = (d0 && a[143]) ^ (d1 && a[142]) ^ (d2 && a[141]) ^ (d3 && a[140]);
 assign g[144] = (d0 && a[144]) ^ (d1 && a[143]) ^ (d2 && a[142]) ^ (d3 && a[141]);
 assign g[145] = (d0 && a[145]) ^ (d1 && a[144]) ^ (d2 && a[143]) ^ (d3 && a[142]);
 assign g[146] = (d0 && a[146]) ^ (d1 && a[145]) ^ (d2 && a[144]) ^ (d3 && a[143]);
 assign g[147] = (d0 && a[147]) ^ (d1 && a[146]) ^ (d2 && a[145]) ^ (d3 && a[144]);
 assign g[148] = (d0 && a[148]) ^ (d1 && a[147]) ^ (d2 && a[146]) ^ (d3 && a[145]);
 assign g[149] = (d0 && a[149]) ^ (d1 && a[148]) ^ (d2 && a[147]) ^ (d3 && a[146]);
 assign g[150] = (d0 && a[150]) ^ (d1 && a[149]) ^ (d2 && a[148]) ^ (d3 && a[147]);
 assign g[151] = (d0 && a[151]) ^ (d1 && a[150]) ^ (d2 && a[149]) ^ (d3 && a[148]);
 assign g[152] = (d0 && a[152]) ^ (d1 && a[151]) ^ (d2 && a[150]) ^ (d3 && a[149]);
 assign g[153] = (d0 && a[153]) ^ (d1 && a[152]) ^ (d2 && a[151]) ^ (d3 && a[150]);
 assign g[154] = (d0 && a[154]) ^ (d1 && a[153]) ^ (d2 && a[152]) ^ (d3 && a[151]);
 assign g[155] = (d0 && a[155]) ^ (d1 && a[154]) ^ (d2 && a[153]) ^ (d3 && a[152]);
 assign g[156] = (d0 && a[156]) ^ (d1 && a[155]) ^ (d2 && a[154]) ^ (d3 && a[153]);
 assign g[157] = (d0 && a[157]) ^ (d1 && a[156]) ^ (d2 && a[155]) ^ (d3 && a[154]);
 assign g[158] = (d0 && a[158]) ^ (d1 && a[157]) ^ (d2 && a[156]) ^ (d3 && a[155]);
 assign g[159] = (d0 && a[159]) ^ (d1 && a[158]) ^ (d2 && a[157]) ^ (d3 && a[156]);
 assign g[160] = (d0 && a[160]) ^ (d1 && a[159]) ^ (d2 && a[158]) ^ (d3 && a[157]);
 assign g[161] = (d0 && a[161]) ^ (d1 && a[160]) ^ (d2 && a[159]) ^ (d3 && a[158]);
 assign g[162] = (d0 && a[162]) ^ (d1 && a[161]) ^ (d2 && a[160]) ^ (d3 && a[159]);
 assign g[163] = (d1 && a[162]) ^ (d2 && a[161]) ^ (d3 && a[160]);
 assign g[164] = (d2 && a[162]) ^ (d3 && a[161]);
 assign g[165] = (d3 && a[162]);

 

 assign c[0] = g[0] ^ g[163] ^ p[159];
 assign c[1] = g[1] ^ g[164] ^ p[160];
 assign c[2] = g[2] ^ g[165] ^ p[161];
 assign c[3] = g[3] ^ g[163] ^ p[159] ^ p[162];
 assign c[4] = g[4] ^ g[164] ^ p[0] ^ p[160];
 assign c[5] = g[5] ^ g[165] ^ p[1] ^ p[161];
 assign c[6] = g[6] ^ g[163] ^ p[2] ^ p[159] ^ p[162];
 assign c[7] = g[7] ^ g[163] ^ g[164] ^ p[3] ^ p[159] ^ p[160];
 assign c[8] = g[8] ^ g[164] ^ g[165] ^ p[4] ^ p[160] ^ p[161];
 assign c[9] = g[9] ^ g[165] ^ p[5] ^ p[161] ^ p[162];
 assign c[10] = g[10] ^ p[6]^ p[162];
 assign c[11] = g[11] ^ p[7];
 assign c[12] = g[12] ^ p[8];
 assign c[13] = g[13] ^ p[9];
 assign c[14] = g[14] ^ p[10];
 assign c[15] = g[15] ^ p[11];
 assign c[16] = g[16] ^ p[12];
 assign c[17] = g[17] ^ p[13];
 assign c[18] = g[18] ^ p[14];
 assign c[19] = g[19] ^ p[15];
 assign c[20] = g[20] ^ p[16];
 assign c[21] = g[21] ^ p[17];
 assign c[22] = g[22] ^ p[18];
 assign c[23] = g[23] ^ p[19];
 assign c[24] = g[24] ^ p[20];
 assign c[25] = g[25] ^ p[21];
 assign c[26] = g[26] ^ p[22];
 assign c[27] = g[27] ^ p[23];
 assign c[28] = g[28] ^ p[24];
 assign c[29] = g[29] ^ p[25];
 assign c[30] = g[30] ^ p[26];
 assign c[31] = g[31] ^ p[27];
 assign c[32] = g[32] ^ p[28];
 assign c[33] = g[33] ^ p[29];
 assign c[34] = g[34] ^ p[30];
 assign c[35] = g[35] ^ p[31];
 assign c[36] = g[36] ^ p[32];
 assign c[37] = g[37] ^ p[33];
 assign c[38] = g[38] ^ p[34];
 assign c[39] = g[39] ^ p[35];
 assign c[40] = g[40] ^ p[36];
 assign c[41] = g[41] ^ p[37];
 assign c[42] = g[42] ^ p[38];
 assign c[43] = g[43] ^ p[39];
 assign c[44] = g[44] ^ p[40];
 assign c[45] = g[45] ^ p[41];
 assign c[46] = g[46] ^ p[42];
 assign c[47] = g[47] ^ p[43];
 assign c[48] = g[48] ^ p[44];
 assign c[49] = g[49] ^ p[45];
 assign c[50] = g[50] ^ p[46];
 assign c[51] = g[51] ^ p[47];
 assign c[52] = g[52] ^ p[48];
 assign c[53] = g[53] ^ p[49];
 assign c[54] = g[54] ^ p[50];
 assign c[55] = g[55] ^ p[51];
 assign c[56] = g[56] ^ p[52];
 assign c[57] = g[57] ^ p[53];
 assign c[58] = g[58] ^ p[54];
 assign c[59] = g[59] ^ p[55];
 assign c[60] = g[60] ^ p[56];
 assign c[61] = g[61] ^ p[57];
 assign c[62] = g[62] ^ p[58];
 assign c[63] = g[63] ^ p[59];
 assign c[64] = g[64] ^ p[60];
 assign c[65] = g[65] ^ p[61];
 assign c[66] = g[66] ^ p[62];
 assign c[67] = g[67] ^ p[63];
 assign c[68] = g[68] ^ p[64];
 assign c[69] = g[69] ^ p[65];
 assign c[70] = g[70] ^ p[66];
 assign c[71] = g[71] ^ p[67];
 assign c[72] = g[72] ^ p[68];
 assign c[73] = g[73] ^ p[69];
 assign c[74] = g[74] ^ p[70];
 assign c[75] = g[75] ^ p[71];
 assign c[76] = g[76] ^ p[72];
 assign c[77] = g[77] ^ p[73];
 assign c[78] = g[78] ^ p[74];
 assign c[79] = g[79] ^ p[75];
 assign c[80] = g[80] ^ p[76];
 assign c[81] = g[81] ^ p[77];
 assign c[82] = g[82] ^ p[78];
 assign c[83] = g[83] ^ p[79];
 assign c[84] = g[84] ^ p[80];
 assign c[85] = g[85] ^ p[81];
 assign c[86] = g[86] ^ p[82];
 assign c[87] = g[87] ^ p[83];
 assign c[88] = g[88] ^ p[84];
 assign c[89] = g[89] ^ p[85];
 assign c[90] = g[90] ^ p[86];
 assign c[91] = g[91] ^ p[87];
 assign c[92] = g[92] ^ p[88];
 assign c[93] = g[93] ^ p[89];
 assign c[94] = g[94] ^ p[90];
 assign c[95] = g[95] ^ p[91];
 assign c[96] = g[96] ^ p[92];
 assign c[97] = g[97] ^ p[93];
 assign c[98] = g[98] ^ p[94];
 assign c[99] = g[99] ^ p[95];
 assign c[100] = g[100] ^ p[96];
 assign c[101] = g[101] ^ p[97];
 assign c[102] = g[102] ^ p[98];
 assign c[103] = g[103] ^ p[99];
 assign c[104] = g[104] ^ p[100];
 assign c[105] = g[105] ^ p[101];
 assign c[106] = g[106] ^ p[102];
 assign c[107] = g[107] ^ p[103];
 assign c[108] = g[108] ^ p[104];
 assign c[109] = g[109] ^ p[105];
 assign c[110] = g[110] ^ p[106];
 assign c[111] = g[111] ^ p[107];
 assign c[112] = g[112] ^ p[108];
 assign c[113] = g[113] ^ p[109];
 assign c[114] = g[114] ^ p[110];
 assign c[115] = g[115] ^ p[111];
 assign c[116] = g[116] ^ p[112];
 assign c[117] = g[117] ^ p[113];
 assign c[118] = g[118] ^ p[114];
 assign c[119] = g[119] ^ p[115];
 assign c[120] = g[120] ^ p[116];
 assign c[121] = g[121] ^ p[117];
 assign c[122] = g[122] ^ p[118];
 assign c[123] = g[123] ^ p[119];
 assign c[124] = g[124] ^ p[120];
 assign c[125] = g[125] ^ p[121];
 assign c[126] = g[126] ^ p[122];
 assign c[127] = g[127] ^ p[123];
 assign c[128] = g[128] ^ p[124];
 assign c[129] = g[129] ^ p[125];
 assign c[130] = g[130] ^ p[126];
 assign c[131] = g[131] ^ p[127];
 assign c[132] = g[132] ^ p[128];
 assign c[133] = g[133] ^ p[129];
 assign c[134] = g[134] ^ p[130];
 assign c[135] = g[135] ^ p[131];
 assign c[136] = g[136] ^ p[132];
 assign c[137] = g[137] ^ p[133];
 assign c[138] = g[138] ^ p[134];
 assign c[139] = g[139] ^ p[135];
 assign c[140] = g[140] ^ p[136];
 assign c[141] = g[141] ^ p[137];
 assign c[142] = g[142] ^ p[138];
 assign c[143] = g[143] ^ p[139];
 assign c[144] = g[144] ^ p[140];
 assign c[145] = g[145] ^ p[141];
 assign c[146] = g[146] ^ p[142];
 assign c[147] = g[147] ^ p[143];
 assign c[148] = g[148] ^ p[144];
 assign c[149] = g[149] ^ p[145];
 assign c[150] = g[150] ^ p[146];
 assign c[151] = g[151] ^ p[147];
 assign c[152] = g[152] ^ p[148];
 assign c[153] = g[153] ^ p[149];
 assign c[154] = g[154] ^ p[150];
 assign c[155] = g[155] ^ p[151];
 assign c[156] = g[156] ^ p[152];
 assign c[157] = g[157] ^ p[153];
 assign c[158] = g[158] ^ p[154];
 assign c[159] = g[159] ^ p[155];
 assign c[160] = g[160] ^ p[156];
 assign c[161] = g[161] ^ p[157];
 assign c[162] = g[162] ^ p[158];  
  
endmodule
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
 