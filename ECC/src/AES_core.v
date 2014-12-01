`timescale 1ns/100ps
module AES_core(
	i_load_key	,
	i_load_state	,
	i_start_AES	,
	decry		,
	i_key		,
	i_state		,
	o_done_AES	,
	o_result_AES	,
	clk		,
	rst_n			);

input			i_load_key	;
input			i_load_state	;
input			i_start_AES	;
input			decry		;
input	[127:0]		i_key		;
input	[127:0]		i_state		;
output			o_done_AES	;
output	[127:0]		o_result_AES	;
input			clk		;
input			rst_n		;
                
  
  //-------------------------------- controller module
  reg [4:0] step;
  reg [3:0] round;             

  reg clk_mix_ctrl,  clk_key_ctrl,  clk_ss_ctrl;
  wire  clk_mix,   clk_key,        clk_ss;
  wire mode;
  reg	[1:0]	 AESstate, nextstate	;              
  parameter IDLE=2'b00,LOAD=2'b01,CALCULATE=2'b11,DONE=2'b10;

 always @ (posedge clk or negedge rst_n)
   if (!rst_n) AESstate <= IDLE ;
   else   AESstate <= nextstate ;
   
 always @ (*)
   case(AESstate)
   IDLE: if(i_load_key||i_load_state)  nextstate=LOAD;
         else nextstate=AESstate;
   LOAD: if(i_start_AES) nextstate=CALCULATE;
         else nextstate=AESstate;
   CALCULATE:if(o_done_AES) nextstate=DONE;
            else nextstate=AESstate;
   DONE: if(i_load_key||i_load_state) nextstate=LOAD;
         else nextstate=AESstate;
   default: nextstate=IDLE;
   endcase
   
  always @ (posedge clk or negedge rst_n)
    if (!rst_n) step<=5'b0;
    else case(AESstate)
     IDLE: step<=5'b0;
     LOAD: if(i_start_AES) step<=5'b10100;
           else step<=5'b10101;
     CALCULATE:  case(step)
           5'b10100: step<=5'b11100;
           5'b11100: step<=5'b11000;
           5'b11000: step<=5'b10000;         
           5'b10000: if(round==5'ha) step<=5'b10101;
                     else step<=5'b10001;
           5'b10001: step<=5'b10011;
           5'b10011: step<=5'b10010;
           5'b10010: step<=5'b00000;
           5'b00000: step<=5'b00001;
           5'b00001: step<=5'b00011;
           5'b00011: step<=5'b00010;
           5'b00010: step<=5'b00100;
           5'b00100: step<=5'b00101;
           5'b00101: step<=5'b00111;
           5'b00111: step<=5'b00110;
           5'b00110: step<=5'b01100;
           5'b01100: step<=5'b01101;
           5'b01101: step<=5'b01111;
           5'b01111: step<=5'b01110;
           5'b01110: step<=5'b01000;
           5'b01000: step<=5'b01001;
           5'b01001: step<=5'b01011;
           5'b01011: step<=5'b01010;
           5'b01010: step<=5'b10000;
           5'b10101: step<=5'b10101;
           default: step<=5'b10100;
           endcase                
     DONE: step<=5'b10101;
     endcase        
   
              
  always @ (posedge clk or negedge rst_n)
    if (!rst_n) round<=4'b0;
    else if(i_start_AES) round<=4'b0; 
         else if(step==5'b10001) round<=round+1;
              else round<=round;
 
    assign mode=decry&!step[4];
    assign o_done_AES=!i_start_AES&round[3]&round[1]&step[4]&step[2]; 
     
     always @ (negedge clk or negedge rst_n)
     if(!rst_n)
        clk_key_ctrl = 1'b0;
      else clk_key_ctrl =!(step[3]|step[2])|i_load_key;
	      
     assign clk_key =clk_key_ctrl&clk ; 

     always @ (negedge clk or negedge rst_n)
     if(!rst_n)
        clk_mix_ctrl = 1'b0;
	    else clk_mix_ctrl=!step[4]&AESstate[1]&AESstate[0];
     assign clk_mix =clk_mix_ctrl&clk ;
      
     always @ (negedge clk or negedge rst_n)
     if(!rst_n)
       clk_ss_ctrl = 1'b0;
	    else clk_ss_ctrl=!(step[1]|step[0])|i_load_state;
    assign clk_ss =clk_ss_ctrl&clk ;
      
  //-------------------------------- sbox
  wire [3:0] ah, al, ah_inv, al_inv;
  wire [7:0] state,substate;
  wire [3:0] d1, d2, d3, d_inv, d;
  reg [7:0] state_i,key_i;
                     
    assign state=step[4]?key_i:state_i;     
             
    assign al[0]=mode?(!(state[6]^state[1]^state[0]^state[4])):(state[4]^state[6]^state[0]^state[5]);   
    assign al[1]=mode?(!(state[6]^state[3]^state[0]^state[7]^state[4]^state[1])):(state[1]^state[2]);
    assign al[2]=mode?(state[3]^state[0]^state[4]^state[1]):(state[1]^state[7]);
    assign al[3]=mode?(!(state[7]^state[4]^state[6]^state[3])):(state[2]^state[4]);
    assign ah[0]=mode?(state[6]^state[1]^state[5]^state[0]^state[7]^state[4]^state[2]):(state[4]^state[6]^state[5]);
    assign ah[1]=mode?(state[3]^state[4]^state[6]^state[5]):(state[1]^state[7]^state[4]^state[6]);
    assign ah[2]=mode?(!(state[6]^state[4]^state[5]^state[0])):(state[5]^state[7]^state[2]^state[3]);
    assign ah[3]=mode?(state[7]^state[2]^state[6]^state[1]):(state[5]^state[7]);
    
   assign d1[0]=ah[1]^ah[2];      
   assign d1[1]=ah[0];
   assign d1[2]=ah[0]^ah[1]^ah[3];
   assign d1[3]=ah[1]^ah[0];

   assign d2[0]=(ah[0]&al[0])^(ah[3]&al[1])^(ah[2]&al[2])^(ah[1]&al[3]);
   assign d2[1]=(ah[1]&al[0])^((ah[0]^ah[3])&al[1])^((ah[2]^ah[3])&al[2])^((ah[1]^ah[2])&al[3]);
   assign d2[2]=(ah[2]&al[0])^(ah[1]&al[1])^((ah[0]^ah[3])&al[2])^((ah[2]^ah[3])&al[3]);
   assign d2[3]=(ah[3]&al[0])^(ah[2]&al[1])^(ah[1]&al[2])^((ah[0]^ah[3])&al[3]); 

   assign d3[0]=al[0]^al[2];
   assign d3[1]=al[2];
   assign d3[2]=al[1]^al[3];
   assign d3[3]=al[3];

    assign d_inv[0]=d1[0]^d2[0]^d3[0];
    assign d_inv[1]=d1[1]^d2[1]^d3[1];
    assign d_inv[2]=d1[2]^d2[2]^d3[2];
    assign d_inv[3]=d1[3]^d2[3]^d3[3];
    
    assign d[0]=d_inv[1]^d_inv[2]^d_inv[3]^(d_inv[1]&d_inv[2]&d_inv[3])^d_inv[0]^(d_inv[0]&d_inv[2])^(d_inv[1]&d_inv[2])^(d_inv[0]&d_inv[1]&d_inv[2]);
    assign d[1]=(d_inv[0]&d_inv[1])^(d_inv[0]&d_inv[2])^(d_inv[1]&d_inv[2])^d_inv[3]^(d_inv[1]&d_inv[3])^(d_inv[0]&d_inv[1]&d_inv[3]);
    assign d[2]=(d_inv[0]&d_inv[1])^d_inv[2]^(d_inv[0]&d_inv[2])^d_inv[3]^(d_inv[0]&d_inv[3])^(d_inv[0]&d_inv[2]&d_inv[3]);
    assign d[3]=d_inv[1]^d_inv[2]^d_inv[3]^(d_inv[1]&d_inv[2]&d_inv[3])^(d_inv[0]&d_inv[3])^(d_inv[1]&d_inv[3])^(d_inv[2]&d_inv[3]);
    
    assign ah_inv[0]=(ah[0]&d[0])^(ah[3]&d[1])^(ah[2]&d[2])^(ah[1]&d[3]);   
    assign ah_inv[1]=(ah[1]&d[0])^((ah[0]^ah[3])&d[1])^((ah[2]^ah[3])&d[2])^((ah[1]^ah[2])&d[3]);
    assign ah_inv[2]=(ah[2]&d[0])^(ah[1]&d[1])^((ah[0]^ah[3])&d[2])^((ah[2]^ah[3])&d[3]);
    assign ah_inv[3]=(ah[3]&d[0])^(ah[2]&d[1])^(ah[1]&d[2])^((ah[0]^ah[3])&d[3]);
    
    assign al_inv[0]=(d[0]&(ah[0]^al[0]))^(d[3]&(ah[1]^al[1]))^(d[2]&(ah[2]^al[2]))^(d[1]&(ah[3]^al[3]));
    assign al_inv[1]=(d[1]&(ah[0]^al[0]))^((d[0]^d[3])&(ah[1]^al[1]))^((d[2]^d[3])&(ah[2]^al[2]))^((d[1]^d[2])&(ah[3]^al[3]));
    assign al_inv[2]=(d[2]&(ah[0]^al[0]))^(d[1]&(ah[1]^al[1]))^((d[0]^d[3])&(ah[2]^al[2]))^((d[2]^d[3])&(ah[3]^al[3]));
    assign al_inv[3]=(d[3]&(ah[0]^al[0]))^(d[2]&(ah[1]^al[1]))^(d[1]&(ah[2]^al[2]))^((d[0]^d[3])&(ah[3]^al[3]));
              
    assign substate[0]=mode?(al_inv[0]^ah_inv[0]):(!(ah_inv[0]^ah_inv[1]^al_inv[2]^ah_inv[3]^al_inv[0]));
    assign substate[1]=mode?(ah_inv[0]^ah_inv[1]^ah_inv[3]):(!(ah_inv[0]^ah_inv[1]^al_inv[2]^al_inv[1]^ah_inv[3]^al_inv[3]^al_inv[0]));
    assign substate[2]=mode?(al_inv[1]^ah_inv[3]^ah_inv[0]^ah_inv[1]):(ah_inv[0]^ah_inv[1]^al_inv[3]^al_inv[0]);
    assign substate[3]=mode?(ah_inv[0]^ah_inv[1]^al_inv[1]^ah_inv[2]):(ah_inv[0]^al_inv[2]^ah_inv[3]^ah_inv[2]^al_inv[0]);
    assign substate[4]=mode?(al_inv[1]^ah_inv[3]^ah_inv[0]^ah_inv[1]^al_inv[3]):(ah_inv[3]^al_inv[3]^ah_inv[0]^al_inv[1]^ah_inv[2]^al_inv[0]);
    assign substate[5]=mode?(ah_inv[0]^ah_inv[1]^al_inv[2]):(!(ah_inv[0]^ah_inv[1]^al_inv[2]^al_inv[1]^ah_inv[3]^al_inv[3]^ah_inv[2]));
    assign substate[6]=mode?(al_inv[1]^ah_inv[3]^al_inv[2]^al_inv[3]^ah_inv[0]):(!(ah_inv[2]^ah_inv[3]^ah_inv[0]));
    assign substate[7]=mode?(ah_inv[0]^ah_inv[1]^al_inv[2]^ah_inv[3]):(ah_inv[0]^al_inv[2]^ah_inv[3]^al_inv[1]^ah_inv[2]);
               
 //-------------------------------- mixcolumn module
  reg [7:0] d0_out,d1_out,d2_out,d3_out;
  wire [7:0] d_in02,d_in03,d_in08,d_in0c;
  wire [7:0] d_in;
  reg [7:0] key_out_de;
  
  assign d_in=substate^key_out_de;
  
  assign d_in02=step[4]?8'b0:{d_in[6],d_in[5],d_in[4],d_in[3]^d_in[7],d_in[2]^d_in[7],d_in[1],d_in[0]^d_in[7],d_in[7]};
  assign d_in03=step[4]?8'b0:d_in02^d_in;
  assign d_in08=(decry&!step[4])?{d_in[4],
                       d_in[3]^d_in[7],
                       d_in[2]^d_in[6]^d_in[7],
                       d_in[1]^d_in[5]^d_in[6],
                       d_in[0]^d_in[5]^d_in[7],
                       d_in[6]^d_in[7],
                       d_in[5]^d_in[6],
                       d_in[5]}:8'b0;
  assign d_in0c=(decry&!step[4])?{d_in[4]^d_in[5],
                       d_in[3]^d_in[4]^d_in[7],
                       d_in[2]^d_in[3]^d_in[6],
                       d_in[1]^d_in[2]^d_in[5]^d_in[7],
                       d_in[0]^d_in[1]^d_in[5]^d_in[6]^d_in[7],
                       d_in[0]^d_in[6],
                       d_in[5]^d_in[7],
                       d_in[5]^d_in[6]}:8'b0;
  
  always @(posedge clk_mix or negedge rst_n)
    if(!rst_n) begin 
               d3_out<=8'b0;
               d2_out<=8'b0;
               d1_out<=8'b0;
               d0_out<=8'b0;
               end
    else   if(round==4'b1010)
                case(step[1:0])
                2'b00: d0_out<=d_in;
                2'b01: d1_out<=d_in;
                2'b11: d2_out<=d_in;
                2'b10: d3_out<=d_in;
                endcase
              else  if(!(step[1]|step[0])) begin
                      d3_out<=d_in02^d_in0c;
                      d2_out<=d_in03^d_in08;
                      d1_out<=d_in^d_in0c;
                      d0_out<=d_in^d_in08; 
                      end
                else begin 
                    d3_out<=d_in02^d_in0c^d0_out;
                    d2_out<=d_in03^d_in08^d3_out;
                    d1_out<=d_in^d_in0c^d2_out;
                    d0_out<=d_in^d_in08^d1_out;
                   end
                      
               
  //-------------------------------- state_sch module           
     reg [31:0] statemem0,statemem1,statemem2,statemem3; 
     wire [31:0] key_out_en;         
              
  always @ (posedge clk_ss or negedge rst_n)
   if (!rst_n) begin statemem0<=32'b0;
                     statemem1<=32'b0;
                     statemem2<=32'b0;
                     statemem3<=32'b0;  end
   else if(i_load_state)  {statemem0,statemem1,statemem2,statemem3}<=i_state;
        else if(decry) 
               case(step) 
           5'b10100: statemem0<=statemem0^key_out_en;
           5'b11100: statemem1<=statemem1^key_out_en;
           5'b11000: statemem2<=statemem2^key_out_en;
           5'b10000: if(round==4'b0) statemem3<=statemem3^key_out_en; 
                     else statemem3<={d0_out,d1_out,d2_out,d3_out};    
           5'b00000: if(AESstate==CALCULATE)
                    begin
                           statemem0[23:0]<={statemem3[23:16],statemem2[15:8],statemem1[7:0]};
                           statemem1[23:0]<={statemem0[23:16],statemem3[15:8],statemem2[7:0]};
                           statemem2[23:0]<={statemem1[23:16],statemem0[15:8],statemem3[7:0]};
                           statemem3[23:0]<={statemem2[23:16],statemem1[15:8],statemem0[7:0]};  
                    end
           5'b00100: statemem0<={d0_out,d1_out,d2_out,d3_out};
           5'b01100: statemem1<={d0_out,d1_out,d2_out,d3_out};
           5'b01000: statemem2<={d0_out,d1_out,d2_out,d3_out}; 
                endcase
           else case(step)
           5'b10100: statemem0<=statemem0^key_out_en;
           5'b11100: statemem1<=statemem1^key_out_en;
           5'b11000: statemem2<=statemem2^key_out_en;
           5'b10000: if(round==4'b0) statemem3<=statemem3^key_out_en;
                     else statemem3<={d0_out,d1_out,d2_out,d3_out}^key_out_en;
           5'b00000: if(AESstate==CALCULATE)
                     begin 
                           statemem0[23:0]<={statemem1[23:16],statemem2[15:8],statemem3[7:0]};
                           statemem1[23:0]<={statemem2[23:16],statemem3[15:8],statemem0[7:0]};
                           statemem2[23:0]<={statemem3[23:16],statemem0[15:8],statemem1[7:0]};
                           statemem3[23:0]<={statemem0[23:16],statemem1[15:8],statemem2[7:0]};  
                     end
           5'b00100: statemem0<={d0_out,d1_out,d2_out,d3_out}^key_out_en;
           5'b01100: statemem1<={d0_out,d1_out,d2_out,d3_out}^key_out_en;
           5'b01000: statemem2<={d0_out,d1_out,d2_out,d3_out}^key_out_en;
                endcase
         
   always @ (*)
    if(step[4]) state_i=8'b0;
    else case(step[3:0])
    4'b0000: state_i=statemem0[31:24];
    4'b0001: state_i=statemem0[23:16];
    4'b0011: state_i=statemem0[15:8];
    4'b0010: state_i=statemem0[7:0]; 
    4'b0100: state_i=statemem1[31:24];
    4'b0101: state_i=statemem1[23:16];
    4'b0111: state_i=statemem1[15:8];
    4'b0110: state_i=statemem1[7:0];
    4'b1100: state_i=statemem2[31:24];
    4'b1101: state_i=statemem2[23:16];
    4'b1111: state_i=statemem2[15:8];
    4'b1110: state_i=statemem2[7:0];  
    4'b1000: state_i=statemem3[31:24];
    4'b1001: state_i=statemem3[23:16];
    4'b1011: state_i=statemem3[15:8];
    4'b1010: state_i=statemem3[7:0];  
    default: state_i=8'b0;
    endcase   
                
    assign o_result_AES={statemem0,statemem1,statemem2,statemem3};
        
    //------------------------------------------ keyexpansion module  
   reg [31:0] key_word3,key_word2,key_word1,key_word0;
   reg [7:0] rcon;
   
   always @ (*)
    if(step[4]&!step[3]&!step[2]) case(step[1:0])
    2'b00: if(decry) key_i=key_word3[31:24]^key_word2[31:24];
                else key_i=key_word3[31:24];
    2'b01: key_i=key_word3[7:0];
    2'b11: key_i=key_word3[15:8];
    2'b10: key_i=key_word3[23:16];
           endcase
    else key_i=8'b0;
   
   always @(posedge clk_key or negedge rst_n)
    if(!rst_n) {key_word3,key_word2,key_word1,key_word0}<=128'b0;
    else  if(i_load_key) {key_word0,key_word1,key_word2,key_word3}<=i_key;
         else if(decry) case(step)             
                   5'b10000: if(round==4'ha) {key_word0,key_word1,key_word2,key_word3}<={key_word0,key_word1,key_word2,key_word3};
                             else begin 
                                   key_word2<=key_word2^key_word1;
                                   key_word3<=key_word3^key_word2;
                                   key_word1<=key_word1^key_word0;                                     
                                   key_word0[7:0]<=key_word0[7:0]^substate;
                                     end
                   5'b10001: key_word0[15:8]<=key_word0[15:8]^substate;
                   5'b10011: key_word0[23:16]<=key_word0[23:16]^substate;
                   5'b10010: key_word0[31:24]<=key_word0[31:24]^substate^rcon;
                        endcase
              else case(step)
                   5'b10000: if(round==4'ha) {key_word0,key_word1,key_word2,key_word3}<={key_word0,key_word1,key_word2,key_word3};
                             else key_word0[7:0]<=key_word0[7:0]^substate; 
                   5'b10001: key_word0[15:8]<=key_word0[15:8]^substate;
                   5'b10011: key_word0[23:16]<=key_word0[23:16]^substate;
                   5'b10010: key_word0[31:24]<=key_word0[31:24]^substate^rcon;
                   5'b00001: key_word1<=key_word1^key_word0;
                   5'b00011: key_word2<=key_word2^key_word1;
                   5'b00010: key_word3<=key_word3^key_word2;
                 endcase
    
    assign key_out_en=!(step[1]|step[0])?(
                                       step[3]?(step[2]?key_word1:key_word2):
                                               (step[2]?key_word0:key_word3)
                                       ):32'b0;
     
   always @ (*)
    if(step[4]|!decry) key_out_de=8'b0;  
    else case(step[3:0])
    4'b0000: key_out_de=key_word0[31:24];
    4'b0001: key_out_de=key_word0[23:16];
    4'b0011: key_out_de=key_word0[15:8];
    4'b0010: key_out_de=key_word0[7:0]; 
    4'b0100: key_out_de=key_word1[31:24];
    4'b0101: key_out_de=key_word1[23:16];
    4'b0111: key_out_de=key_word1[15:8];
    4'b0110: key_out_de=key_word1[7:0];  
    4'b1100: key_out_de=key_word2[31:24];
    4'b1101: key_out_de=key_word2[23:16];
    4'b1111: key_out_de=key_word2[15:8];
    4'b1110: key_out_de=key_word2[7:0];  
    4'b1000: key_out_de=key_word3[31:24];
    4'b1001: key_out_de=key_word3[23:16];
    4'b1011: key_out_de=key_word3[15:8];
    4'b1010: key_out_de=key_word3[7:0];  
    default: key_out_de=8'b0;
    endcase     
                
   always @ (*) 
    if(decry) case(round)
       4'h0: rcon<=8'h00;
       4'h1: rcon<=8'h36;
       4'h2: rcon<=8'h1b;
       4'h3: rcon<=8'h80;
       4'h4: rcon<=8'h40;
       4'h5: rcon<=8'h20;
       4'h6: rcon<=8'h10;
       4'h7: rcon<=8'h08;
       4'h8: rcon<=8'h04;
       4'h9: rcon<=8'h02;
       4'ha: rcon<=8'h01;
       4'hb: rcon<=8'h00;  
       default: rcon<=8'h0;
        endcase
    else case(round) 
       4'h0: rcon<=8'h00;
       4'h1: rcon<=8'h01;
       4'h2: rcon<=8'h02;
       4'h3: rcon<=8'h04;
       4'h4: rcon<=8'h08;
       4'h5: rcon<=8'h10;
       4'h6: rcon<=8'h20;
       4'h7: rcon<=8'h40;
       4'h8: rcon<=8'h80;
       4'h9: rcon<=8'h1b;
       4'ha: rcon<=8'h36;
       4'hb: rcon<=8'h00;  
       default: rcon<=8'h0;
         endcase
               
               
  endmodule
