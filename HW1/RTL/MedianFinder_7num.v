module MedianFinder_7num(
    input  	[3:0]  	num1  , 
	input  	[3:0]  	num2  , 
	input  	[3:0]  	num3  , 
	input  	[3:0]  	num4  , 
	input  	[3:0]  	num5  , 
	input  	[3:0]  	num6  , 
	input  	[3:0]  	num7  ,  
    output 	[3:0] 	median  
);

wire [3:0]min1, min2, min3, max1, max2, max3;
wire [3:0]temp_max, temp_min, in1, in2, in3, in4, min, max;
Comparator2 C1(.A(num1), .B(num2), .min(min1), .max(max1));
Comparator2 C2(.A(num3), .B(num4), .min(min2), .max(max2));
Comparator2 C3(.A(num5), .B(num6), .min(min3), .max(max3));
Comparator2 C4(.A(max1), .B(max2), .min(in1), .max(temp_max));
Comparator2 C5(.A(max3), .B(temp_max), .min(in2), .max(max));
Comparator2 C6(.A(min1), .B(min2), .min(temp_min), .max(in3));
Comparator2 C7(.A(min3), .B(temp_min), .min(min), .max(in4));

MedianFinder_5num M5(.num1(in1), .num2(in2), .num3(in3), .num4(in4), .num5(num7), .median(median));

endmodule
