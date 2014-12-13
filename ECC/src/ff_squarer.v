/***********************************************
module name : ff_squarer
author : wu cheng
describe : Finite Field Squarer
version : 1.0
***********************************************/
module ff_squarer(  a,					

					c);
					

input   [162:0]	   a;


output  [162:0]    c;
/*******************internal via *********************/


/*******************procedure ***************************/
assign c[0] = a[0] ^ a[160];
assign c[1] = a[82] ^ a[162] ^ a[160];
assign c[2] = a[1] ^ a[161];
assign c[3] = a[83] ^ a[161] ^ a[160];
assign c[4] = a[2] ^ a[160] ^ a[82];
assign c[5] = a[84] ^ a[162] ^ a[161];
assign c[6] = a[3] ^ a[161] ^ a[83] ^ a[160];
assign c[7] = a[85] ^ a[82];
assign c[8] = a[4] ^ a[84] ^ a[161] ^ a[160] ^ a[82];
assign c[9] = a[86] ^ a[83];
assign c[10] = a[5] ^ a[85] ^ a[162] ^ a[161] ^ a[83];
assign c[11] = a[87] ^ a[84];
assign c[12] = a[6] ^ a[86] ^ a[162] ^ a[84];
assign c[13] = a[88] ^ a[85];
 
assign c[14] = a[7] ^ a[87] ^ a[85];
 
assign c[15] = a[89] ^ a[86];
 
assign c[16] = a[8] ^ a[88] ^ a[86];
 
assign c[17] = a[90] ^ a[87];
 
assign c[18] = a[9] ^ a[89] ^ a[87];
 
assign c[19] = a[91] ^ a[88];
 
assign c[20] = a[10] ^ a[90] ^ a[88];
 
assign c[21] = a[92] ^ a[89];
 
assign c[22] = a[11] ^ a[91] ^ a[89];
 
assign c[23] = a[93] ^ a[90];
 
assign c[24] = a[12] ^ a[92] ^ a[90];
 
assign c[25] = a[94] ^ a[91];
 
assign c[26] = a[13] ^ a[93] ^ a[91];
 
assign c[27] = a[95] ^ a[92];
 
assign c[28] = a[14] ^ a[94] ^ a[92];
 
assign c[29] = a[96] ^ a[93];
 
assign c[30] = a[15] ^ a[95] ^ a[93];
 
assign c[31] = a[97] ^ a[94];
 
assign c[32] = a[16] ^ a[96] ^ a[94];
 
assign c[33] = a[98] ^ a[95];
 
assign c[34] = a[17] ^ a[97] ^ a[95];
 
assign c[35] = a[99] ^ a[96];
 
assign c[36] = a[18] ^ a[98] ^ a[96];
 
assign c[37] = a[100] ^ a[97];
 
assign c[38] = a[19] ^ a[99] ^ a[97];
 
assign c[39] = a[101] ^ a[98];
 
assign c[40] = a[20] ^ a[100] ^ a[98];
 
assign c[41] = a[102] ^ a[99];
 
assign c[42] = a[21] ^ a[101] ^ a[99];
 
assign c[43] = a[103] ^ a[100];
 
assign c[44] = a[22] ^ a[102] ^ a[100];
 
assign c[45] = a[104] ^ a[101];
 
assign c[46] = a[23] ^ a[103] ^ a[101];
 
assign c[47] = a[105] ^ a[102];
 
assign c[48] = a[24] ^ a[104] ^ a[102];
 
assign c[49] = a[106] ^ a[103];
 
assign c[50] = a[25] ^ a[105] ^ a[103];
 
assign c[51] = a[107] ^ a[104];
 
assign c[52] = a[26] ^ a[106] ^ a[104];
 
assign c[53] = a[108] ^ a[105];
 
assign c[54] = a[27] ^ a[107] ^ a[105];
 
assign c[55] = a[109] ^ a[106];
 
assign c[56] = a[28] ^ a[108] ^ a[106];
 
assign c[57] = a[110] ^ a[107];
 
assign c[58] = a[29] ^ a[109] ^ a[107];
 
assign c[59] = a[111] ^ a[108];
 
assign c[60] = a[30] ^ a[110] ^ a[108];
 
assign c[61] = a[112] ^ a[109];
 
assign c[62] = a[31] ^ a[111] ^ a[109];
 
assign c[63] = a[113] ^ a[110];
 
assign c[64] = a[32] ^ a[112] ^ a[110];
 
assign c[65] = a[114] ^ a[111];
 
assign c[66] = a[33] ^ a[113] ^ a[111];
 
assign c[67] = a[115] ^ a[112];
 
assign c[68] = a[34] ^ a[114] ^ a[112];
 
assign c[69] = a[116] ^ a[113];
 
assign c[70] = a[35] ^ a[115] ^ a[113];
 
assign c[71] = a[117] ^ a[114];
 
assign c[72] = a[36] ^ a[116] ^ a[114];
 
assign c[73] = a[118] ^ a[115];
 
assign c[74] = a[37] ^ a[117] ^ a[115];
 
assign c[75] = a[119] ^ a[116];
 
assign c[76] = a[38] ^ a[118] ^ a[116];
 
assign c[77] = a[120] ^ a[117];
 
assign c[78] = a[39] ^ a[119] ^ a[117];
 
assign c[79] = a[121] ^ a[118];
 
assign c[80] = a[40] ^ a[120] ^ a[118];
 
assign c[81] = a[122] ^ a[119];
 
assign c[82] = a[41] ^ a[121] ^ a[119];
 
assign c[83] = a[123] ^ a[120];
 
assign c[84] = a[42] ^ a[122] ^ a[120];
 
assign c[85] = a[124] ^ a[121];
 
assign c[86] = a[43] ^ a[123] ^ a[121];
 
assign c[87] = a[125] ^ a[122];
 
assign c[88] = a[44] ^ a[124] ^ a[122];
 
assign c[89] = a[126] ^ a[123];
 
assign c[90] = a[45] ^ a[125] ^ a[123];
 
assign c[91] = a[127] ^ a[124];
 
assign c[92] = a[46] ^ a[126] ^ a[124];
 
assign c[93] = a[128] ^ a[125];
 
assign c[94] = a[47] ^ a[127] ^ a[125];
 
assign c[95] = a[129] ^ a[126];
 
assign c[96] = a[48] ^ a[128] ^ a[126];
 
assign c[97] = a[130] ^ a[127];
 
assign c[98] = a[49] ^ a[129] ^ a[127];
 
assign c[99] = a[131] ^ a[128];
 
assign c[100] = a[50] ^ a[130] ^ a[128];
 
assign c[101] = a[132] ^ a[129];
 
assign c[102] = a[51] ^ a[131] ^ a[129];
 
assign c[103] = a[133] ^ a[130];
 
assign c[104] = a[52] ^ a[132] ^ a[130];
 
assign c[105] = a[134] ^ a[131];
 
assign c[106] = a[53] ^ a[133] ^ a[131];
 
assign c[107] = a[135] ^ a[132];
 
assign c[108] = a[54] ^ a[134] ^ a[132];
 
assign c[109] = a[136] ^ a[133];
 
assign c[110] = a[55] ^ a[135] ^ a[133];
 
assign c[111] = a[137] ^ a[134];
 
assign c[112] = a[56] ^ a[136] ^ a[134];
 
assign c[113] = a[138] ^ a[135];
 
assign c[114] = a[57] ^ a[137] ^ a[135];
 
assign c[115] = a[139] ^ a[136];
 
assign c[116] = a[58] ^ a[138] ^ a[136];
 
assign c[117] = a[140] ^ a[137];
 
assign c[118] = a[59] ^ a[139] ^ a[137];
 
assign c[119] = a[141] ^ a[138];
 
assign c[120] = a[60] ^ a[140] ^ a[138];
 
assign c[121] = a[142] ^ a[139];
 
assign c[122] = a[61] ^ a[141] ^ a[139];
 
assign c[123] = a[143] ^ a[140];
 
assign c[124] = a[62] ^ a[142] ^ a[140];
 
assign c[125] = a[144] ^ a[141];
 
assign c[126] = a[63] ^ a[143] ^ a[141];
 
assign c[127] = a[145] ^ a[142];
 
assign c[128] = a[64] ^ a[144] ^ a[142];
 
assign c[129] = a[146] ^ a[143];
 
assign c[130] = a[65] ^ a[145] ^ a[143];
 
assign c[131] = a[147] ^ a[144];
 
assign c[132] = a[66] ^ a[146] ^ a[144];
 
assign c[133] = a[148] ^ a[145];
 
assign c[134] = a[67] ^ a[147] ^ a[145];
 
assign c[135] = a[149] ^ a[146];
 
assign c[136] = a[68] ^ a[148] ^ a[146];
 
assign c[137] = a[150] ^ a[147];
 
assign c[138] = a[69] ^ a[149] ^ a[147];
 
assign c[139] = a[151] ^ a[148];
 
assign c[140] = a[70] ^ a[150] ^ a[148];
 
assign c[141] = a[152] ^ a[149];
 
assign c[142] = a[71] ^ a[151] ^ a[149];
 
assign c[143] = a[153] ^ a[150];
 
assign c[144] = a[72] ^ a[152] ^ a[150];
 
assign c[145] = a[154] ^ a[151];
 
assign c[146] = a[73] ^ a[153] ^ a[151];
 
assign c[147] = a[155] ^ a[152];
 
assign c[148] = a[74] ^ a[154] ^ a[152];
 
assign c[149] = a[156] ^ a[153];
 
assign c[150] = a[75] ^ a[155] ^ a[153];
 
assign c[151] = a[157] ^ a[154];
 
assign c[152] = a[76] ^ a[156] ^ a[154];
 
assign c[153] = a[158] ^ a[155];
 
assign c[154] = a[77] ^ a[157] ^ a[155];
 
assign c[155] = a[159] ^ a[156];
 
assign c[156] = a[78] ^ a[158] ^ a[156];
 
assign c[157] = a[160] ^ a[157];
 
assign c[158] = a[79] ^ a[159] ^ a[157];
 
assign c[159] = a[161] ^ a[158];
 
assign c[160] = a[80] ^ a[160] ^ a[158];
 
assign c[161] = a[162] ^ a[159];
 
assign c[162] = a[81] ^ a[161] ^ a[159];


endmodule
