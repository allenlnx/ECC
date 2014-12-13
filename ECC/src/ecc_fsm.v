/*******************************
module name : ECC FSM
author : Wu Cheng
describe: ECC FSM designed according to Montgomery Ladder Algorithm
version:1.2 
*********************************/
module ecc_fsm (
            clk,
            rst_n,
			   k,
			   ecc_start,
			   m_done,
			   m_start,
			   reg_select,
			   select_x,
			   select_xab,
			   select_z,
			   select_zab,
			   ss,
			   st,
			   sy,
			   ecc_done);
				  
input                clk;
input                rst_n;
input      [162:0]   k;
input                ecc_start;
input                m_done;


output                m_start;
output     [2:0]      reg_select;

output                select_x;
output                select_xab;
output                select_z;
output                select_zab;

output                ss;
output                st;
output                sy;
output                ecc_done;

reg                   m_start;

reg                   select_x;
reg                   select_xab;
reg                   select_z;
reg                   select_zab;

reg                   ss;
reg                   st;
reg                   sy;
reg                   ecc_done;


/*******************internal via *********************/
wire               ki;
reg     [4:0]      processor_state,next_state;
reg                step_done;
reg     [7:0]      ecc_count;
reg     [2:0]      reg_select;
reg                real_ecc_start;
/*******************procedure ***************************/
assign ki = k[ecc_count];
always @(posedge clk or negedge rst_n)
if(!rst_n)
  begin
    ecc_count<=8'b1010_0010;
    real_ecc_start<=1'b0;
  end
else if((ecc_count == 8'b0000_0000)&&(processor_state == 5'd22))//stop the FSM 
         real_ecc_start <= 1'b0;
     else if(ecc_done)
              ecc_count<=8'b1010_0010;
          else if(ecc_start && !real_ecc_start)//deleting the zeros at the beginning 
                    if(!ki)
                         ecc_count<=ecc_count-1'b1;
                    else
                         begin
                           ecc_count<=ecc_count-1'b1;
                           real_ecc_start <= 1'b1;
                         end
               else  
                    begin
                      if(step_done && real_ecc_start)
                        ecc_count<=ecc_count-1'b1;
	                   else
	                      ecc_count<=ecc_count;
                    end

always @(posedge clk or negedge rst_n)
if(!rst_n)
  ecc_done<=0;
else if((ecc_count == 8'b0000_0000)&&(processor_state == 5'd22))
  ecc_done<=1;
else 
  ecc_done<=0;

always @(posedge clk or negedge rst_n)
if(!rst_n)
  begin
  step_done <= 0;
   select_x <= 0;
   select_xab <= 0;
	select_z <= 0;
	select_zab <= 0;
	ss<=0;
	st<=0;
	sy<=0;
	reg_select<=0;
	m_start<=0;
  end
else 
  begin
     case (processor_state)
	 5'd0:  begin
               select_x<=0;
               select_xab<=0;
	            select_z<=0;
	            select_zab<=0;           
	            ss<=0;
	            st<=0;
	            sy<=0;
				   reg_select<=3'b000;
				   m_start<=0;
             end
     5'd17:begin//x1=x
               select_x<=0;
               select_xab<=0;
	            //select_xcg<=0;
	            select_z<=1;
	            select_zab<=0;
	            ss<=0;
	            st<=1;
	            sy<=0;
				   reg_select<=3'b001;
				   m_start<=0;
             end
   5'd1:begin//z2=x1*x1
               select_x<=1;
               select_xab<=1;
	            //select_xcg<=0;
	            select_z<=0;
	            select_zab<=0;
	            ss<=1;
	            st<=0;
	            sy<=1;
				   reg_select<=3'b100;
				   m_start<=0;
             end
   5'd2:begin//x2=z2*z2
               select_x<=0;
               select_xab<=0;
	            //select_xcg<=0;
	            select_z<=1;
	            select_zab<=0;
	            ss<=0;
	            st<=0;
	            sy<=1;
				   reg_select<=3'b010;
				   m_start<=0;
             end
   5'd3:begin//x2=x2+z1
               select_x<=1; 
               select_xab<=0;
	            //select_xcg<=0;
	            select_z<=1;
	            select_zab<=1;
	            ss<=0;
	            st<=1;
	            sy<=0;
				   reg_select<=3'b010;
				   m_start<=0;
             end
	 
	 5'd20:begin//swap
	       select_x<=0; 
          select_xab<=0;
          select_z<=0;
          select_zab<=0;
          ss<=0;
          st<=0;
          sy<=0;
	       if(!ki)
	           reg_select<=3'b110;
	       else
	           reg_select<=3'b111;
	         
	 end	 
	 5'd4:   begin//x1=x1*z2
               select_x<=1;
               select_xab<=1;
	            //select_xcg<=0;
	            select_z<=1;
	            select_zab<=0;
	            //select_zct<=0;
	            //select_xzswap<=0;
	            ss<=0;
	            st<=0;
	            sy<=0;
				if(m_done)
				  begin
				    m_start<=0;
				    reg_select<=3'b001;
				  end
				else
				  begin
				    m_start<=1;
				    reg_select<=0;
				  end
             end
	 5'd5:   begin//z1=z1*x2
               select_x<=1;
               select_xab<=0;
	            //select_xcg<=0;
	            select_z<=1;
	            select_zab<=1;
	            //select_zct<=0;
	            //select_xzswap<=1;
	            ss<=0;
	            st<=0;
	            sy<=0;
				if(m_done)
				  begin
				    m_start<=0;
				    reg_select<=3'b011;
				  end
				else
				  begin
				    m_start<=1;
				    reg_select<=0;
				  end
             end
	 5'd6:   begin//x2=x2*x2
               select_x<=1;
               select_xab<=0;
	            //select_xcg<=0;
	            select_z<=0; 
	            select_zab<=0;
	            //select_zct<=0;
	            //select_xzswap<=0;
	            ss<=1;
	            st<=0;
	            sy<=1;
				   reg_select<=3'b010;
				   m_start<=0;
             end
	 5'd7:   begin//z3=z2*z2
               select_x<=0; 
               select_xab<=0;
	            //select_xcg<=0;
	            select_z<=1;
	            select_zab<=0;
	            //select_zct<=0;
	            //select_xzswap<=0;
	            ss<=0;
	            st<=0;
	            sy<=1;
				   reg_select<=3'b101;
				   m_start<=0;
            end
	 5'd9:   begin//z2=z3*x2
               select_x<=1; 
               select_xab<=0;
	            //select_xcg<=0;
	            select_z<=0;
	            select_zab<=0;
	            //select_zct<=0;
	            //select_xzswap<=1;
	            ss<=0;
	            st<=0;
	            sy<=0;
				if(m_done)
				  begin
				    m_start<=0;
				    reg_select<=3'b100;
				  end
				else
				  begin
				    m_start<=1;
				    reg_select<=0;
				  end
             end
   5'd10:   begin//x2=x2+z3
               select_x<=1;
               select_xab<=0;
	            //select_xcg<=0;
	            select_z<=0;
	            select_zab<=0;
	            //select_zct<=1;
	            //select_xzswap<=0;
	            ss<=0;
	            st<=1;
	            sy<=0;
				   reg_select<=3'b010;
				   m_start<=0;
             end        
	 5'd11:  begin//x2=x2*x2
               select_x<=1;
               select_xab<=0;
	            //select_xcg<=0;
	            select_z<=0;
	            select_zab<=0;
	            //select_zct<=0;
	            //select_xzswap<=0;
	            ss<=1;
	            st<=0;
	            sy<=1;
				   reg_select<=3'b010;
				   m_start<=0;
             end
	 
	 5'd12:  begin//z3=x1*z1
               select_x<=1; 
               select_xab<=1;
	            //select_xcg<=0;
	            select_z<=1;
	            select_zab<=1;
	            //select_zct<=0;
	            //select_xzswap<=0;
	            ss<=0;
	            st<=0;
	            sy<=0;
				if(m_done)
				  begin
				    m_start<=0;
				    reg_select<=3'b101;
				  end
				else
				  begin
				    m_start<=1;
				    reg_select<=0;
				  end
             end
   5'd13:  begin//z1=x1+z1
               select_x<=1;
               select_xab<=1;
	            //select_xcg<=0;
	            select_z<=1;
	            select_zab<=1;
	            //select_zct<=0;
	            //select_xzswap<=0;
	            ss<=0;
	            st<=1;
	            sy<=0;
				   reg_select<=3'b011;
				   m_start<=0;
             end          
	 5'd14:  begin//z1=z1*z1
               select_x<=0; 
               select_xab<=0;
	            //select_xcg<=0;
	            select_z<=1;
	            select_zab<=1;
	            //select_zct<=0;
	            //select_xzswap<=0;
	            ss<=0;
	            st<=0;
	            sy<=1;
				   reg_select<=3'b011;
				   m_start<=0;
             end
	 5'd15:  begin//x1=z1*x
               select_x<=0; 
               select_xab<=0;
	            //select_xcg<=0;
	            select_z<=1;
	            select_zab<=1;
	            //select_zct<=0;
	            //select_xzswap<=1;
	            ss<=0;
	            st<=0;
	            sy<=0;
				if(m_done)
				  begin
				    m_start<=0;
				    reg_select<=3'b001;
				  end
				else
				  begin
				    m_start<=1;
				    reg_select<=0;
				  end
             end
	 5'd16:  begin//x1=x1+z3
               select_x<=1; 
               select_xab<=1;
	            //select_xcg<=0;
	            select_z<=0;
	            select_zab<=0;
	            //select_zct<=1;
	            //select_xzswap<=0;
	            ss<=0;
	            st<=1;
	            sy<=0;
				   reg_select<=3'b001;
				   m_start<=0;
             end
  
  5'd21:begin
         select_x<=0; 
         select_xab<=0;
         select_z<=0;
         select_zab<=0;
         ss<=0;
         st<=0;
         sy<=0;
         if(!ki)
	           reg_select<=3'b110;
	       else
	           reg_select<=3'b111;
	           
	       step_done <= 1'b1;
	       end
	5'd22: begin
	    select_x<=0; 
       select_xab<=0;
       select_z<=0;
       select_zab<=0;
       ss<=0;
       st<=0;
       sy<=0;
    reg_select<=3'b111;
    step_done <= 1'b0;
  end
	 default:  begin
               select_x<=3'b000;
               select_xab<=0;
	            select_z<=3'b000;
	            select_zab<=0;
	            ss<=0;
	            st<=0;
	            sy<=0;
				   reg_select<=3'b000;
				   m_start<=0;
             end
	endcase
  end
 
always @(posedge clk or negedge rst_n)
if(!rst_n)
  processor_state <= 0;
else
  processor_state <= next_state;

always @(*)
begin
case(processor_state)
   5'd0: if(real_ecc_start)
	         next_state = 17;
			   else
			     next_state = 0;
	 5'd17:  next_state = 1;	 
	 5'd1:   next_state = 2;
	 5'd2:   next_state = 3;
	 5'd3:   next_state = 20;
	 5'd20:  next_state = 4;
			 
	 5'd4:   if(m_done)
	            next_state = 5;
		     else
			    next_state = 4;
	 5'd5:   if(m_done)
	            next_state = 6;
		     else
			    next_state = 5;
	 5'd6:   next_state = 7;
	 5'd7:   next_state = 9;
	 5'd9:   if(m_done)
	            next_state = 10;
		     else
			    next_state = 9;
	 5'd10:  next_state = 11;
	 5'd11:  next_state = 12;
	 
	 5'd12:  if(m_done)
	            next_state = 13;
		     else
			    next_state = 12;
	 5'd13:  next_state = 14;
	 5'd14:  next_state = 15;
	 5'd15:  if(m_done)
	            next_state = 16;
		     else
			    next_state = 15;
	 5'd16:  
			    next_state = 21;
   5'd21:
          next_state = 22;
   5'd22:
          if(ecc_count == 0)
            next_state = 0;
          else
            next_state = 20;
	 default:  next_state = 0;
	endcase
  end
 

endmodule

			  
