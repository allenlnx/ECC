/*******************************
module name : Registor File
author : wu cheng
describe:define a register array freshing one value at a time
version:1.1  
*********************************/
module reg_file  (     clk,
                       rst_n,
				           s,
				           reg_select,
				           xa,
				           xb,
				           za,
				           zb,
				           zc);
				  
				  
input                clk;
input                rst_n;
input      [162:0]   s;
input        [2:0]   reg_select;

output     [162:0]    xa;
output     [162:0]    xb;
output     [162:0]    za;
output     [162:0]    zb;
output     [162:0]    zc;


reg     [162:0]    xa;
reg     [162:0]    xb;
reg     [162:0]    za;
reg     [162:0]    zb;
reg     [162:0]    zc;

/*******************internal via *********************/

/*******************procedure ***************************/
always @(posedge clk or negedge rst_n)
if(!rst_n)
begin
   xa<=0;
   xb<=0;
   za<=163'b1;
   zb<=0;
   zc<=0;
end
else
begin
case (reg_select)
3'b001:
   begin
     xa<=s;
     xb<=xb;
     za<=za;
     zb<=zb;
     zc<=zc;
   end
3'b010:
   begin
     xa<=xa;
     xb<=s;
     za<=za;
     zb<=zb;
     zc<=zc;
   end
3'b011:
   begin
     xa<=xa;
     xb<=xb;
     za<=s;
     zb<=zb;
     zc<=zc;
   end
3'b100:
   begin
     xa<=xa;
     xb<=xb;
     za<=za;
     zb<=s;
     zc<=zc;
   end
3'b101:
   begin
     xa<=xa;
     xb<=xb;
     za<=za;
     zb<=zb;
     zc<=s;
   end
3'b110://swap
  begin
    xa<=xb;
    xb<=xa;
    za<=zb;
    zb<=za;
    zc<=0;
  end
3'b111://clear temp register
  begin
    xa<=xa;
    xb<=xb;
    za<=za;
    zb<=zb;
    zc<=0;
  end
default:
   begin
     xa<=xa;
     xb<=xb;
     za<=za;
     zb<=zb;
     zc<=zc;
   end  
endcase
end


endmodule
