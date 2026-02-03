`include "MedianFinder_3num.v"
module MedianFinder_5num(
    input  [3:0] 	num1  , 
	input  [3:0] 	num2  , 
	input  [3:0] 	num3  , 
	input  [3:0] 	num4  , 
	input  [3:0] 	num5  ,  
    output [3:0] 	median  
);
wire [3:0]min1, min2, max1, max2, temp_max, temp_min, min, max;
Comparator2 com1(.A(num1), .B(num2), .min(min1), .max(max1));
Comparator2 com2(.A(num3), .B(num4), .min(min2), .max(max2));
Comparator2 com3(.A(min1), .B(min2), .min(min), .max(temp_max));
Comparator2 com4(.A(max1), .B(max2), .min(temp_min), .max(max));
MedianFinder_3num M3(.num1(temp_min), .num2(temp_max), .num3(num5), .median(median));

endmodule
