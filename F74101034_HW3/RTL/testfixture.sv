`timescale 1ns/10ps
`define CYCLE     26                // Modify your clock period here
`define End_CYCLE  100000          // Modify cycle times once your design need more cycle times!
`define P2                        // Modify to test different pattern

module testfixture;

reg   clk ;
reg   rst ;
reg fir_valid;
reg [15:0]fir_d;// 8 integer + 8 fraction
wire  fft_valid;
wire done;
wire [15:0] fft_d0, fft_d1, fft_d2, fft_d3, fft_d4, fft_d5, fft_d6, fft_d7, fft_d8;
wire [15:0] fft_d9, fft_d10, fft_d11, fft_d12, fft_d13, fft_d14, fft_d15;

reg [15:0] fir_mem [0:1023];
reg [15:0] fftr_mem [0:1023];
reg [15:0] ffti_mem [0:1023];

`ifdef P2
    initial $readmemh("./dat/Pattern2_FIR.dat", fir_mem);
	initial $readmemh("./dat/Golden2_FFT_real.dat", fftr_mem);
	initial $readmemh("./dat/Golden2_FFT_imag.dat", ffti_mem);
`else
    initial $readmemh("./dat/Pattern1_FIR.dat", fir_mem);
	initial $readmemh("./dat/Golden1_FFT_real.dat", fftr_mem);
	initial $readmemh("./dat/Golden1_FFT_imag.dat", ffti_mem);
`endif

integer i, j ,k ,k_, l;
integer total_fail,real_temp_fail,imag_temp_fail,total_correct,cycleCount;
reg flag;

FFT top(.clk(clk), .rst(rst), .fir_d(fir_d), .fir_valid(fir_valid), .fft_valid(fft_valid), .done(done),
	.fft_d0(fft_d0), .fft_d1(fft_d1), .fft_d2(fft_d2), .fft_d3(fft_d3), .fft_d4(fft_d4), .fft_d5(fft_d5), .fft_d6(fft_d6), .fft_d7(fft_d7),
	.fft_d8(fft_d8), .fft_d9(fft_d9), .fft_d10(fft_d10), .fft_d11(fft_d11), .fft_d12(fft_d12), .fft_d13(fft_d13), .fft_d14(fft_d14), .fft_d15(fft_d15));


initial begin
   clk = 1'b0;
   rst = 1'b0; 
   i = 0;   
   j = 0;  
   k = 0;
   k_ = 0;
   l = 0;
   total_fail = 0;
   real_temp_fail = 0;
   imag_temp_fail = 0;
   total_correct = 0;
   flag = 0;
   cycleCount = 0;
end

always begin #(`CYCLE/2) clk = ~clk; end

initial begin
	#(`CYCLE*0.5)		rst = 1'b1;	fir_valid = 1'b0;
	#(`CYCLE*2);		rst = 1'b0;
	#(1);		        fir_valid = 1'b1;
	#(`CYCLE*1024);		fir_valid = 1'b0;
end

// data input & ready
always@(negedge clk ) begin
	if (fir_valid) begin
		if (i >= 1024 )
			fir_d <= 0;
		else begin
			fir_d <= fir_mem[i];
			i <= i + 1;
		end
	end
end

always @(posedge clk) begin cycleCount <= cycleCount + 1; end

//============================================================================================================
//============================================================================================================
//============================================================================================================
// FFT data output verify

reg [15:0] fft_rec [0:15];
always@(*) begin
fft_rec[0] = fft_d0;
fft_rec[1] = fft_d1;
fft_rec[2] = fft_d2;
fft_rec[3] = fft_d3;
fft_rec[4] = fft_d4;
fft_rec[5] = fft_d5;
fft_rec[6] = fft_d6;
fft_rec[7] = fft_d7;
fft_rec[8] = fft_d8;
fft_rec[9] = fft_d9;
fft_rec[10] = fft_d10;
fft_rec[11] = fft_d11;
fft_rec[12] = fft_d12;
fft_rec[13] = fft_d13;
fft_rec[14] = fft_d14;
fft_rec[15] = fft_d15;
end

reg [15:0] fft_cmp_r , fft_cmp_r1 , fft_cmp_r2 , fft_cmp_r3 ,fft_cmp_i , fft_cmp_i1 , fft_cmp_i2 , fft_cmp_i3 ;
reg [15:0] fft_cmp_r4 , fft_cmp_r5 , fft_cmp_r6, fft_cmp_r7, fft_cmp_i4 , fft_cmp_i5 , fft_cmp_i6, fft_cmp_i7 ;
reg [15:0] fftr_ver, ffti_ver;
reg [15:0] fftr_ver_, ffti_ver_;
reg [15:0] fft_cmp;

reg fftr_verify, ffti_verify;

always@(posedge clk) begin
	if (fft_valid) begin
		if(flag)begin
			imag_temp_fail = 0;
			for (l=0; l<=15; l=l+1) begin
				fft_cmp = fft_rec[l];
				ffti_ver_= ffti_mem[k]; ffti_ver = ffti_ver_;
				
				fft_cmp_i = fft_cmp;
				fft_cmp_i1 = fft_cmp_i-1; fft_cmp_i2 = fft_cmp_i; fft_cmp_i3 = fft_cmp_i+1;
				fft_cmp_i4 = fft_cmp_i-2; fft_cmp_i5 = fft_cmp_i+2; fft_cmp_i6 = fft_cmp_i-3; fft_cmp_i7 = fft_cmp_i+3;			

				ffti_verify = ((ffti_ver == fft_cmp_i2) || (ffti_ver == (fft_cmp_i3)) || (ffti_ver == (fft_cmp_i1)) || (ffti_ver == (fft_cmp_i4)) || (ffti_ver == (fft_cmp_i5)) || (ffti_ver == (fft_cmp_i6)) || (ffti_ver == (fft_cmp_i7)));
				
				if ((!ffti_verify) || (fft_cmp === 32'bx) || (fft_cmp === 32'bz)) begin
					$display("ERROR at FFT  ppoint number =%2d: The imaginary part is %8h != expectd %8h " ,k, fft_cmp, ffti_mem[k]);
					$display("-----------------------------------------------------");
					imag_temp_fail = imag_temp_fail + 1; 
				end
				else if ( l==15 ) begin
					if (imag_temp_fail==0) $display("FFT imag part on pattern %d ~ %d, PASS!!", (k-15), k);
				end
				if(ffti_verify)
					total_correct = total_correct + 1;
				k=k+1;
			end
			flag=0;
			total_fail = total_fail + imag_temp_fail;
		end	
		else begin
			real_temp_fail = 0;
			for (l=0; l<=15; l=l+1) begin
				fft_cmp = fft_rec[l];
				fftr_ver_= fftr_mem[k_]; fftr_ver = fftr_ver_;
				
				fft_cmp_r = fft_cmp; 
				fft_cmp_r1 = fft_cmp_r-1; fft_cmp_r2 = fft_cmp_r; fft_cmp_r3 = fft_cmp_r+1;
				fft_cmp_r4 = fft_cmp_r-2; fft_cmp_r5 = fft_cmp_r+2; fft_cmp_r6 = fft_cmp_r-3; fft_cmp_r7 = fft_cmp_r+3;	

				fftr_verify = ((fftr_ver == fft_cmp_r2) || (fftr_ver == (fft_cmp_r3)) || (fftr_ver == (fft_cmp_r1)) || (fftr_ver == (fft_cmp_r4)) || (fftr_ver == (fft_cmp_r5)) || (fftr_ver == (fft_cmp_r6)) || (fftr_ver == (fft_cmp_r7)));
				
				if ( (!fftr_verify) || (fft_cmp === 32'bx) || (fft_cmp === 32'bz)) begin
					$display("ERROR at FFT  ppoint number =%2d: The real part is %8h != expectd %8h " ,k_, fft_cmp, fftr_mem[k_]);
					$display("-----------------------------------------------------");
					real_temp_fail = real_temp_fail + 1; 
				end
				else if ( l==15 ) begin
					if (real_temp_fail==0) $display("FFT real part on pattern %d ~ %d, PASS!!", (k_-15), k_);
				end
				if(fftr_verify)
					total_correct = total_correct + 1;
				k_=k_+1;
			end
			flag=1;
			total_fail = total_fail + real_temp_fail;
		end
	end
end


// Terminate the simulation, FAIL
initial  begin
 #(`CYCLE * `End_CYCLE);
 $display("-----------------------------------------------------");
 $display("Error!!! Somethings' wrong with your code ...!!");
 $display("-------------------------FAIL------------------------");
 $display("-----------------------------------------------------"); 
 $finish;
end

// always@(*) begin
// 	if (total_fail >= `fft_fail_limit) begin
// 		$display("-----------------------------------------------------\n");
//  		$display("Error!!! There are more than %d errors for FFT output !", `fft_fail_limit);
//  		$display("-------------------------FAIL------------------------\n");
// 		$finish;
// 	end	
// end


// Terminate the simulation, PASS
initial begin
	wait(done);
    #(`CYCLE);     
    if (total_correct==2048) begin
        // $display("-----------------------------------------------------\n");
        // $display("Congratulations! All data have been generated successfully!\n");
        // $display("-------------------------PASS------------------------\n");
		$display("\n");
		$display("         _        "           );
		$display("     _.-(_)._     "           ); 
		$display("   .'________'.   "           );
		$display("  [____________]      Congratulations! All data have been generated successfully! ");
		$display("  /  / .\\/. \\  \\      Total use %1d cycles to complete simulation.", cycleCount);       
		$display("  |  \\__/\\__/  | "          );
		$display("  \\            /  "          );
		$display("  /'._  \\_/ _.'\\ "          );
		$display(" /_   `''''`   _\\ "          );
		$display("(__/    '|    \\ _|"          );
		$display("  |_____'|_____|  "           );
		$display("   '----------' "             );
    #(`CYCLE/2); $finish;
    end
    else begin
      	// $display("-----------------------------------------------------\n");
        // $display("Fail!! There are some error with your code!\n");
        // $display("-------------------------FAIL------------------------\n");
		$display("\n");
		$display("         _            "            );
		$display("     _.-(_)._         "            ); 
		$display("   .'________'.       "            );
		$display("  [____________]     Fail!! There are %1d error in test patterns.", total_fail);
		$display("  /  \\/   \\/   \\     Please check your design!!!        "     );
		$display("  |  /\\   /\\   |    "            );
		$display("  \\    ___     /     "            );
		$display("  /'._      _.'\\     "            );
		$display(" /_   `''''`   _\\    "            );
		$display("(__/    '|    \\ _|   "            );
		$display("  |_____'|_____|      "            );
		$display("   '----------'       "            );
    #(`CYCLE/2); $finish;
    end
end

endmodule
