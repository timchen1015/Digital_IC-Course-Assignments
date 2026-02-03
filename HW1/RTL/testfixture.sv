module testfixture;

    reg [3:0] A, B, num1, num2, num3, num4, num5, num6, num7;
    wire [3:0] min, max, median3, median5, median7;
    integer file_comp, file3, file5, file7, error_comp, error_3, error_5, error_7;
    integer i, scan_result;
    reg [3:0] expected_median, expected_min, expected_max;

    Comparator2 uut2(
        .A      (A)  ,
        .B      (B)  ,
        .min    (min),
        .max    (max)
    );

    MedianFinder_3num uut3 (
        .num1   (num1)   , 
        .num2   (num2)   , 
        .num3   (num3)   ,  
        .median (median3)
    );

    MedianFinder_5num uut5 (
        .num1   (num1)   , 
        .num2   (num2)   , 
        .num3   (num3)   , 
        .num4   (num4)   , 
        .num5   (num5)   , 
        .median (median5)
    );

    MedianFinder_7num uut7 (
        .num1   (num1)   , 
        .num2   (num2)   , 
        .num3   (num3)   , 
        .num4   (num4)   , 
        .num5   (num5)   , 
        .num6   (num6)   ,
        .num7   (num7)   ,
        .median (median7)
    );

    initial begin
        error_comp = 0;
        error_3 = 0;
        error_5 = 0;
        error_7 = 0;

        file_comp = $fopen("./dat/golden_comp.dat", "r");
        file3 = $fopen("./dat/golden_3num.dat", "r");
        file5 = $fopen("./dat/golden_5num.dat", "r");
        file7 = $fopen("./dat/golden_7num.dat", "r");

        if (file_comp == 0 || file3 == 0 || file5 == 0 || file7 == 0) begin
            $display("Error: Failed to open one or more golden data files.");
            $finish;
        end

        for (i = 0; i < 100; i = i + 1) begin
            scan_result = $fscanf(file_comp, "%d %d %d %d\n", A, B, expected_min, expected_max);
            #10;
            if (min == expected_min && max == expected_max) begin
                // $display("Test3 %0d Passed! Median: %0d (Expected: %0d)", i, median3, expected_median);
            end 
            else begin
                if(min != expected_min && max != expected_max) begin
                    $display("Stage1: %0d Failed! Min: %0d  (Expected: %0d) Max: %0d (Expected: %0d)", i, min, expected_min, max, expected_max);
                end
                else if(min != expected_min && max == expected_max) begin
                    $display("Stage1: %0d Failed! Min: %0d (Expected: %0d) Max: Pass", i, min, expected_min);
                end
                else if(min == expected_min && max != expected_max) begin
                    $display("Stage1: %0d Failed! Min: Pass                Max: %0d (Expected: %0d)", i, max, expected_max);
                end
                
                error_comp = error_comp + 1;
            end
        end
        for (i = 0; i < 100; i = i + 1) begin
            scan_result = $fscanf(file3, "%d %d %d %d\n", num1, num2, num3, expected_median);
            #10;
            if (median3 == expected_median) begin
                // $display("Test3 %0d Passed! Median: %0d (Expected: %0d)", i, median3, expected_median);
            end 
            else begin
                $display("Stage2: %0d Failed! Median: %0d (Expected: %0d)", i, median3, expected_median);
                error_3 = error_3 + 1;
            end
        end
        for (i = 0; i < 100; i = i + 1) begin
            scan_result = $fscanf(file5, "%d %d %d %d %d %d\n", num1, num2, num3, num4, num5, expected_median);
            #10;
            if (median5 == expected_median) begin
                // $display("Test5 %0d Passed! Median: %0d (Expected: %0d)", i, median5, expected_median);
                
            end 
            else begin
                $display("Stage3: %0d Failed! Median: %0d (Expected: %0d)", i, median5, expected_median);
                error_5 = error_5 + 1;
            end
        end
        for (i = 0; i < 1000; i = i + 1) begin
            scan_result = $fscanf(file7, "%d %d %d %d %d %d %d %d\n", num1, num2, num3, num4, num5, num6, num7, expected_median);
            #10;
            if (median7 == expected_median) begin
                // $display("Test7 %0d Passed! Median: %0d (Expected: %0d)", i, median7, expected_median);
            end 
            else begin
                $display("Stage4: %0d Failed! Median: %0d (Expected: %0d)", i, median7, expected_median);
                error_7 = error_7 + 1;
            end
        end
    
        $fclose(file_comp);
        $fclose(file3);
        $fclose(file5);
        $fclose(file7);

        if(error_comp != 0) begin
            $display("-------------------   There are %4d errors in Comparator2 !   -------------------\n", error_comp);
        end
        else begin
            $display("-------------              Stage1: Comparator2 Pass !                -------------\n");
        end
        if(error_3 != 0) begin
            $display("-------------------There are %4d errors in MedianFinder_3num !-------------------\n", error_3);
        end
        else begin
            $display("-------------              Stage2: MedianFinder_3num Pass !          -------------\n");
        end
        if(error_5 != 0) begin
            $display("-------------------There are %4d errors in MedianFinder_5num !-------------------\n", error_5);
        end
        else begin
            $display("-------------              Stage3: MedianFinder_5num Pass !          -------------\n");
        end
        if(error_7 != 0) begin
            $display("-------------------There are %4d errors in MedianFinder_7num !-------------------\n", error_7);
        end
        else begin
            $display("-------------              Stage4: MedianFinder_7num Pass !          -------------\n");
        end

        if(error_comp==0&error_3==0&error_5==0&error_7==0)begin
            $display("                   //////////////////////////               ");
            $display("                   /                        /       |\__|\  ");
            $display("                   /  Congratulations !!    /      / O.O  | ");
            $display("                   /                        /    /_____   | ");
            $display("                   /  Simulation PASS !!    /   /^ ^ ^ \\  |");
            $display("                   /                        /  |^ ^ ^ ^ |w| ");
            $display("                   //////////////////////////   \\m___m__|_|");
            $display("\n");
        end
        else begin
            $display("                   //////////////////////////               ");
            $display("                   /                        /       |\__|\  ");
            $display("                   /  OOPS !!               /      / X.X  | ");
            $display("                   /                        /    /_____   | ");
            $display("                   /  Simulation Failed !!  /   /^ ^ ^ \\  |");
            $display("                   /                        /  |^ ^ ^ ^ |w| ");
            $display("                   //////////////////////////   \\m___m__|_|");
            $display("\n");
        end
        $finish;
    end
endmodule
