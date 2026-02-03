module MedianFinder_3num(
    input  [3:0]    num1    , 
    input  [3:0]    num2    , 
    input  [3:0]    num3    ,  
    output [3:0]    median  
);

wire [3:0] temp_min, temp_max, temp_max2, min, max;
Comparator2 com1(.A(num1), .B(num2), .min(temp_min), .max(temp_max));
Comparator2 com2(.A(num3), .B(temp_min), .min(min), .max(temp_max2));
Comparator2 com3(.A(temp_max), .B(temp_max2), .min(median), .max(max));

endmodule
