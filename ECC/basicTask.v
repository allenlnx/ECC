// this is a basic reader file
`define EEPROM_PATH T_top.tag.\eeint1/eeprom
include "a.v";

task powerofftag ;
begin 
	$display ("PowerOffTag") ;
	#1ns	POR = 1'b0 ;           //reset 
	->RST	;						//trigger mark
	#1us	POR = 1'b1 ;
end
endtask

task init_mode ;
input [15:0] mode ;
begin
	query_group = 1'b1 ;
	q=4'd3	;
//	trext =1'b0 	;
	repeat (2)
		begin 
		issue_query	;
		i = 0 ;
		while (response==1'b0 &&i<=8)
			begin
	      		issue_queryrep	;
	      		i=i+1		;
	      		end
	      	end
	if (response ==1'b0 )	$stop 	;
	$fdisplay ( rfile, "receive data ") ;
	commu_in ;     
	handle = data_in[199:199-15] ;
	$fdisplay ( rfile, "TEST1 Query RN16: %h", handle) ; 
	query_group =1'b0 ;
	
	issue_testwrite(0,0,mode) ;	//mode 

	$fdisplay (rfile, "mode has been modified to be %b", mode) ;
end
endtask	
	
/*task write_memory ;
integer ofile ;
integer i ;
begin
	$fdisplay (rfile, "begin to write the memory to rom file") ;
	ofile = $fopen ("ee0.rom") ;
	//$fdisplay (rfile, "column 0") ;
	i=0 ;
	repeat (20)
		begin 
		$fdisplay (ofile, "%B", T_top.tag.eeprom.byte_0_mem[i]) ;
	//	$fdisplay (rfile, "%B", T_top.tag.eeprom.byte_0_mem[i]) ;
		i=i+1	;
		end
	$fclose (ofile) ;
	ofile = $fopen ("ee1.rom") ;
	//$fdisplay (rfile, "column 1") ;
	i=0 ;
	repeat (20)
		begin 
		$fdisplay (ofile, "%B", T_top.tag.eeprom.byte_1_mem[i]) ;
		$fdisplay (rfile, "%B", T_top.tag.eeprom.byte_1_mem[i]) ;
		i=i+1	;
		end	
	$fclose (ofile) ;
	ofile = $fopen ("ee2.rom") ;
	$fdisplay (rfile, "column 2") ;
	i=0 ;
	repeat (20)
		begin 
		$fdisplay (ofile, "%B", T_top.tag.eeprom.byte_2_mem[i]) ;
		$fdisplay (rfile, "%B", T_top.tag.eeprom.byte_2_mem[i]) ;
		i=i+1	;
		end	
	$fclose (ofile) ;
	ofile = $fopen ("ee3.rom") ;
	$fdisplay (rfile, "column 3") ;
	i=0 ;
	repeat (20)
		begin 
		$fdisplay (ofile, "%B", T_top.tag.eeprom.byte_3_mem[i]) ;
		$fdisplay (rfile, "%B", T_top.tag.eeprom.byte_3_mem[i]) ;
		i=i+1	;
		end	
	$fclose (ofile) ;
end
endtask*/

task commu_in ;
integer i ;
      begin
      data_in = 200'b0 ;
      #Period ack = 1'b1 ;
      #Period ack = 1'b0 ;
      #Period ack = 1'b1 ;
      #Period ack = 1'b0 ;
      #Period num_in = db_in ;
      $fdisplay (rfile, "num of back data is %d(dec)",num_in) ;
//      $display ("num of back data is %d(dec)",num_in) ;
      if ( num_in != 8'hff)
            begin
            for ( i = 0 ; {i,3'b000} <num_in ; i = i+1 )
                  begin
                  ack = 1'b1 ;
                  #Period ack = 1'b0 ;
                  #Period 
                  if (num_in=={i,3'b000}+8'd1)
                     data_in =  {db_in[0],data_in[199:1]} ;
                  else
                     data_in = {db_in, data_in[199:8]} ;
                  end
            #(Period) ;
            $display ("received from tag %h",data_in) ;
            end
      else
            ;
      end
endtask

task commu_out ;
      input [7:0] num_out_byte ;
      input [7:0] num_out ;
      input [255:0] data_out ;
integer i ;
begin
      db_out = 8'h00 ;
      ack = 1'b1 ;
      #Period ack =1'b0 ;
//      #Period ack = 1'b1 ;
      db_out = num_out ;
      for ( i = 0 ; i < num_out_byte ; i = i+1 )
            begin
            #Period ack = 1'b1 ;
            #Period ack = 1'b0 ;
            db_out = {data_out[0],  data_out[1], data_out[2], data_out[3], data_out[4], data_out[5], data_out[6], data_out[7] } ;
            data_out = {8'h00, data_out[255:8]} ;
            end
      #Period ack = 1'b1 ;
      #Period ack = 1'b0 ;
      wait (challenge_eof) ;
end
endtask



task judge_T1 ;
	integer counter ;
	reg done ;
	
	begin 
		counter = 0 ;
		done = 1'b0 ;
		while (done==1'b0)
			begin
			@(posedge clk) counter = counter + 1 ;
				if (mod==1'b1 && counter<`t1_min)
					begin 
					$fdisplay ( rfile, "%t ERROR: T1 violation, too short, %d < %d",$time, counter,`t1_min) ;
					#(30*Period) $stop ;
					end
				else if (mod==1'b1 && (counter>=`t1_min && counter<=`t1_max || write_group==1'b1|| authen_t_group==1'b1|| authen_r_group==1'b1) ) 
					begin
					response_cn = response_cn + 1 ;
					$fdisplay ( rfile, "%t T1 get %d times, %d",$time, response_cn,counter) ;
					response = 1'b1 ;
					wait (response_eof) ; // Getting rx data
					done = 1'b1 ;
					end
				else if ( counter>`t1_max && (query_group==1'b0||q==0) && write_group==1'b0 && authen_t_group==1'b0 &&authen_r_group==1'b0)
					begin
					$fdisplay ( rfile, "%t ERROR: T1 violation, %d",$time, counter) ;  //VIOLATION
					#1000000	$stop ;
					end
				else if (counter>`t1_max && query_group==1'b1)
					begin
					response = 1'b0 ;
					done = 1'b1 ;
					end
			end
	end
endtask

task wait_T2 ;
integer counter ;
begin
counter = 0 ;
while (counter <`t1_max)
	@(posedge clk) counter = counter + 1 ;
end
endtask

task report_error ;

			begin
			$fdisplay ( rfile, "ERROR") ;
			$stop ;
			end
endtask



/*task TEA;
input [127:0] key ;
input [127:0]  plaintext ;	

reg [31:0] key0;
reg [31:0] key1;
reg [31:0] key2;
reg [31:0] key3;
reg [31:0] y;
reg [31:0] z;
integer i;
reg [31:0] sum;
integer temp ;

begin
	$fdisplay (rfile,"plaintext to be issued is %h",plaintext) ;
	{key3,key2,key1,key0}=key ;
	{z,y}=plaintext ;
	sum=DELTA;
	for(i=0;i<32;i=i+1)
	begin
//	#1	y=y+(((z<<5)+key0)^(z+sum)^((z>>4)+key1));
//	#1	z=z+(((y<<5)+key2)^(y+sum)^((y>>4)+key3));
//	$fdisplay (rfile,"%h, %h, %h",((z<<4) + key0 ),(z+sum),((z>>5) + key1));
	#10	y = y + ( ((z<<4)+key0)^(z+sum)^((z>>5)+key1) ) ;
	#10	z = z + ( ((y<<4)+key2)^(y+sum)^((y>>5)+key3) ) ;
	#10	sum=sum+DELTA;
	end
	ciphertext={z,y};
	$fdisplay (rfile,"ciphertext to be issued is %h",ciphertext) ;
//	d0=y;
//	d1=z;
end
endtask*/


task issue_select ;
begin
	$fdisplay (rfile,"Interrogator issues Select target=%h action=%h membank=%h pointer=%h length=%h",target,action,membank,pointer,Length)	;
	$display ("Interrogator issues Select target=%h action=%h membank=%h pointer=%h length=%h",target,action,membank,pointer,Length)	;
	commu_out (8'd5,8'd36,{4'b1010,Target,action,membank,pointer,Length,Mask,4'b0})	; //Select 
end
endtask

task issue_query ;
begin
	$fdisplay (rfile, "Interrogator issues Query dr=%h, trext=%h, Sel=%b, session=%b,q=%h",dr, trext,Sel,session, q) ;
	$display ("Interrogator issues Query dr=%h, trext=%h, Sel=%b, session=%b,q=%h",dr, trext,Sel,session, q) ;
	commu_out ( 8'd3,8'd17,{4'b1000,dr,m,trext,Sel,session,target,q,7'b0}) ; //Query 
	judge_T1 ;
	wait_T2 ;
end
endtask

task issue_queryadjust ;
begin
	$fdisplay (rfile, "Interrogator issues QueryAdjust") ;
	$display ("Interrogator issues QueryAdjust") ;
	commu_out ( 8'd2,8'd9,{4'b1001,session2,3'b011,7'b0}) ; //QueryAdjust  Q=Q-1;
	judge_T1 ;
	wait_T2 ;
end
endtask

task issue_queryrep ;
begin
	$fdisplay (rfile, "Interrogator issues QueryRep") ;
	$display ("Interrogator issues QueryRep") ;
	commu_out ( 8'd1,8'd4,{2'b00,session2,4'h0}) ; //QueryRep
	judge_T1 ;
	wait_T2 ;
end
endtask

task issue_ack	;
begin
	$fdisplay (rfile, "Interrogator issues Ack handle=%h",handle) ;
	$display ("Interrogator issues Ack handle=%h",handle) ;
	commu_out (8'd3,8'd18,{2'b01,handle,6'b0}) ;             //   send out ACK cmd;
	judge_T1 ;
	wait_T2 ;
	$display ( "The PC-EPC is ") ;
	commu_in ;
	$fdisplay ( rfile, "PC %b",data_in[199:184]) ;
	$fdisplay ( rfile, "EPC %h",data_in[183:120]) ;               //16*8
	$display ( "PC %b",data_in[199:184]) ;
	$display ( "EPC %h",data_in[183:120]) ;               //16*8
	//$fdisplay ( rfile, "CRC_16 %h",data_in[88:73]) ;
		//if (data_in[199:184]!=PC)			  report_error ;                    //check pc;
		//if (data_in[183:168]!=EPC)	    report_error ;                //check epc; 
		//if (data_in[167:152]!=CRC_16)	  report_error ;            //check crc_16;
end
endtask

task issue_lock	;
begin
	write_group=1;
	$fdisplay (rfile, "Interrogator issues Lock handle = %h, payload= %h write_group = %h",handle,payload,write_group);
	$display ("Interrogator issues Lock handle = %h, payload= %h write_group = %h",handle,payload,write_group);
	commu_out(8'd6,8'd44,{8'b11000101,payload,handle,4'b0})	;
	judge_T1;
	wait_T2	;
	commu_in ;                               // tag backscatter tea({Rn_r(high 48 bit),rn_t},k2)
	$fdisplay ( rfile, "handle %h",data_in[199:184]) ;
	write_group=0;
end
endtask

task issue_access	;
begin
	$fdisplay(rfile,"Interrogator issues Access handle= %h , psw = %h ",handle,access_pass);
	$display("Interrogator issues Access handle= %h , psw = %h xoe = %h",handle,access_pass,access_pass^handle);
	commu_out(8'd5,8'd40,{8'b1100_0110,access_pass^handle,handle})	;
	judge_T1	;
	wait_T2		;
	commu_in;
	handle = data_in[199:199-15] ; 
	$display("Access handle : %h",handle)	;
	$fdisplay ( rfile, "Access handle: %h", handle) ;
end
endtask
	 

task issue_reqrn ;
begin
	$fdisplay (rfile, "Interrogator issues Req_RN handle=%h",handle) ;                                                                           
	$display ("Interrogator issues Req_RN handle=%h",handle) ;                                                                           
	commu_out(8'd3,8'd24,{8'b1100_0001,handle}); //               send out Req_RN cmd;
	judge_T1 ;
	wait_T2 ;
	commu_in ;
	handle = data_in[199:199-15] ; 
	$fdisplay ( rfile, "Req_RN handle: %h", handle) ;
	$display ("Req_RN handle: %h", handle) ;
end
endtask

task issue_read ;
 input [1:0] 	bank;
 input	[7:0]	addr;
 input [7:0] 	len;
integer i ;
begin
	$fdisplay (rfile, "Interrogator issues Read bank=%b,addr=%h,len=%h,handle=%h",bank,addr,len,handle) ; 
	$display ( "Interrogator issues Read bank=%b,addr=%h,len=%h,handle=%h",bank,addr,len,handle) ; 
	commu_out (8'd6,8'd42,{8'b11000010,bank,addr,len,handle,6'b0});                //send out read cmd
	//commu_out (8'd6,8'd42,{8'b10010101,2'b11,8'h3d,8'h4d,16'h094c,6'b0});    //for encrytion
	judge_T1 ;
	wait_T2 ;
	commu_in ;
	data_in = data_in<<1 ;
	if ((num_in==49||num_in==50)&&len!=1)
		begin
		$fdisplay (rfile, "invalid read with mode&flag: %h",data_in[199:184]);
		data_in=data_in<<16 ;
		$fdisplay (rfile, "handle is %h",data_in[199:184]) ;
		if (data_in[199:184]!=handle) report_error;
		data_in=data_in<<16 ;
		$fdisplay (rfile, "CRC is %h",data_in[199:184]) ;
		end
	else 
		begin
		i=0;
		$fdisplay (rfile, "Received raw data: %h", data_in) ;
		while (i<len)
			begin
			$fdisplay ( rfile, "Read Bank: %h Addr: %2h data: %h",bank,addr+i*16,data_in[199:184]) ;
			data_in = data_in<<16;
			i=i+1;
			end
		$fdisplay (rfile, "handle is %h",data_in[199:184]) ;
		if (data_in[199:184]!=handle) report_error;
		data_in=data_in<<16 ;
		$fdisplay (rfile, "CRC is %h",data_in[199:184]) ;
		end
	
end
endtask

task issue_write ;
input [1:0] 	bank ;
input [7:0] 	wordptr ;
input [15:0] data_write;
begin
	write_group=1;
	$fdisplay (rfile, "Interrogator issues write cmd bank=%b, wordptr=%h, data=%h, handle=%h ",bank,wordptr,data_write,handle) ;    
	$display ( "Interrogator issues write cmd bank=%b, wordptr=%h, data=%h, handle=%h ",bank,wordptr,data_write,handle) ;    
	commu_out ( 8'd7,8'd50,{8'b11000011,bank,wordptr,data_write,handle,6'b0}) ;    
	judge_T1 ;
	wait_T2 ;                                                 
	commu_in ;
	data_in = data_in<<1 ;                              
	$fdisplay (rfile, "Received raw data: %h", data_in) ;
	$fdisplay ( rfile, "handle %h",data_in[199:184]) ;
	if (data_in[199:184]!=handle) report_error;
	data_in = data_in<<16 ;
	$fdisplay (rfile, "CRC is %h",data_in[199:184]) ;
	$display ( "handle %h",data_in[199:184]) ;
	write_group=0;
end
endtask	

task issue_testread ;
 input [1:0] 	bank;
 input [7:0] 	addr;
 input [7:0] 	len;
begin
	$fdisplay (rfile, "Interrogator issues Read bank=%b,addr=%h,len=%h,handle=789a",bank,addr,len) ; 
	$display ( "Interrogator issues Read bank=%b,addr=%h,len=%h,handle=789a",bank,addr,len) ; 
	commu_out (8'd6,8'd42,{8'b1101_1010,bank,addr,len,16'h789a,6'b0});                //send out read cmd
	judge_T1 ;
	wait_T2 ;
	commu_in ;
	$display ( "handle %h",data_in[199:184]) ;
end
endtask

task issue_testwrite ;
input [1:0] 	bank ;
input [7:0] 	wordptr ;
input [15:0]	data ;
begin
	write_group=1;
	$fdisplay (rfile, "Interrogator issues test1 cmd: BlockWrite bank=%b, wordptr=%h, data=%h, handle=789a ",bank,wordptr,data) ;    
	$display ( "Interrogator issues test1 cmd: BlockWrite bank=%b, wordptr=%h, data=%h, handle=789a ",bank,wordptr,data) ;
	commu_out ( 8'd7,8'd50,{8'b1100_1000,bank,wordptr,data,16'h789a,6'b0}) ;   
	judge_T1 ;
	wait_T2 ;                                                 
	commu_in ;                               
	$fdisplay ( rfile, "handle %h",data_in[199:184]) ;
	write_group=0;
end
endtask



//-----------------------------------------------------------------------------------------//
//----------------------- Tasks for Bimod Tag authentication, by lhzhu --------------------//
//-----------------------------------------------------------------------------------------//
task issue_Crypto_Authenticate ;
begin
	$fdisplay (rfile, "Interrogator issues Crypto_Authenticate Nr=313198a2e0370734") ;    
	$display ("Interrogator issues Crypto_Authenticate Nr=313198a2e0370734") ;    
	commu_out ( 8'd13,8'd99,{8'b11011011,1'b0,1'b1,1'b1,8'b01000000,64'h313198a2e0370734,handle,5'b0}) ;    // send out Authen_T; 

	judge_T1 ;
	wait_T2 ;      

	commu_in ;                               // tag backscatter AES{Nr,Nt}
	commu_out ( 8'd21,8'd163,{8'b11011011,1'b1,1'b1,1'b1,8'b01000000,128'h77B11EE22B0E78DA349ABDA92B4AA14B,handle,5'b0}) ;	

	judge_T1 ;
	wait_T2 ; 

	commu_in ;
	if(handle==data_in[199:199-15]) $display ("Authenticate Success") ;
	else $display ("Authenticate Failure") ;    

end
endtask         

task issue_Crypto_En ;
begin
	$fdisplay (rfile, "Interrogator issues Crypto_En") ;    
	$display ("Interrogator issues Crypto_En") ;    
	commu_out ( 8'd6,8'd43,{8'b11011100,(16'b1111111111111111)^handle,3'b0,handle,5'b0}) ;    // send out Crypto_En_1st; 
	$fdisplay (rfile, "1st Crypto_PSW = 1111111111111111 ") ;
	$display ("1st Crypto_PSW = 1111111111111111 ") ;

	judge_T1 ;
	wait_T2 ;      

	commu_in ;                               // tag backscatter handle
	if(handle==data_in[199:199-15]) $display ("Crypto_En 1st Success") ;
	else $display ("Crypto_En 1st Failure") ;

	commu_out ( 8'd6,8'd43,{8'b11011100,(16'b0000000000000000)^handle,3'b0,handle,5'b0}) ;
	$fdisplay (rfile, "2nd Crypto_PSW = 0000000000000000 ") ;
	$display ("2nd Crypto_PSW = 0000000000000000 ") ;

	judge_T1 ;
	wait_T2 ; 
  
	commu_in ;	
	if(handle==data_in[199:199-15]) $display ("Crypto_En 2nd Success") ;
	else $display ("Crypto_En 2nd Failure") ;
end
endtask         


//-----------------------------------------------------------------------------------------//
//------------------------ Tasks for AES authentication, by xshen -------------------------//
//-----------------------------------------------------------------------------------------//
/*task issue_requid	;
begin
	$fdisplay (rfile, "Interrogator issues Req_UID handle=%h",handle) ;              
	commu_out ( 3,8'd24,{8'b1100_1001,handle}) ;    // send out Req_UID; 
	judge_T1 ;
	wait_T2 ;
	commu_in ; 	
	UID = data_in[199:72] ;
	Nt = data_in[71:8];
	$fdisplay (rfile, "Interrogator get UID=%h, Nt=%h",UID,Nt) ;
end
endtask

task issue_Authen_Tag ;
begin
	$fdisplay (rfile, "Interrogator issues Authen_T Nt=%h Ns=%h",Nt,Ns) ;    
	$invAES(Nt[63:32],Nt[31:0],Ns[63:32],Ns[31:0],Key_de[127:96],Key_de[95:64],Key_de[63:32],Key_de[31:0],
	        Nt_Ns_c[127:96],Nt_Ns_c[95:64],Nt_Ns_c[63:32],Nt_Ns_c[31:0]);
	commu_out ( 8'd19,8'd152,{8'b1100_1010,Nt_Ns_c, handle}) ;    // send out Authen_T; 
	judge_T1 ;
	wait_T2 ;                                               
	commu_in ;                               // tag backscatter AES{Ns,Nt}
	Ns_Nt_c=data_in[199:72] ;
	handle = data_in[71:71-15] ;
	$invAES(Ns_Nt_c[127:96],Ns_Nt_c[95:64],Ns_Nt_c[63:32],Ns_Nt_c[31:0],
	        Key_de[127:96],Key_de[95:64],Key_de[63:32],Key_de[31:0],
	        Ns_Nt[127:96],Ns_Nt[95:64],Ns_Nt[63:32],Ns_Nt[31:0]);
	$fdisplay (rfile, "Interrogator get Ns_Nt=%h",Ns_Nt) ;
	if(Ns_Nt[127:64]==Ns) $fdisplay (rfile, "Tag is valid") ;
	else $fdisplay (rfile, "Tag is unvalid") ;
end
endtask         

task issue_Update ;
begin
  //$invAES(Rt[63:32],Rt[31:0],Rr2[63:32],Rr2[31:0],Key_de[127:96],Key_de[95:64],Key_de[63:32],Key_de[31:0],
  //     Rt_Rr2_c[127:96],Rt_Rr2_c[95:64],Rt_Rr2_c[63:32],Rt_Rr2_c[31:0]); 
	write_group=1;
	$fdisplay (rfile, "Interrogator issues Update Key_c=%h ",Key_c) ;  
	commu_out ( 8'd19,9'd152,{8'b1100_1011,Key_c,handle}) ;    // send out Update; 
	judge_T1 ;
	wait_T2 ;                                                   
	commu_in ;                               // tag backscatter rn16 for athen_success
	data_in = data_in<<1 ; 
	handle = data_in[199:199-15] ;
	$fdisplay ( rfile, "handle %h",data_in[199:184]) ;
	write_group=0;
end
endtask    


task issue_Update_Key ;
begin
  $invAES(key_update[127:96],key_update[95:64],key_update[63:32],key_update[31:0],Key_de[127:96],Key_de[95:64],Key_de[63:32],Key_de[31:0],
       key_c[127:96],key_c[95:64],key_c[63:32],key_c[31:0]); 
	$fdisplay (rfile, "Interrogator issues Update_Key handle=%h key_c=%h",handle,key_c) ;  
	commu_out ( 8'd19,8'd152,{8'b1100_1100,key_c,handle}) ;    // send out Update_Key; 
	judge_T1 ;
	wait_T2 ;                                                   
	commu_in ;                               // tag backscatter rn16 for update key
	handle = data_in[199:199-15] ;
end
endtask */
