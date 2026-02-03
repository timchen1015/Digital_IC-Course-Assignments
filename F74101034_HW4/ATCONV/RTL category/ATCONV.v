`timescale 1ns/10ps

module  ATCONV(
        input				clk       ,
        input				rst       ,
        output reg      	ROM_rd    ,
        output reg [11:0]	iaddr     ,
        input signed [15:0] idata     ,
        output          	layer0_ceb,
        output          	layer0_web,   
        output reg [11:0]   layer0_A  ,
        output reg [15:0]   layer0_D  ,
        input  [15:0]   	layer0_Q  ,
        output          	layer1_ceb,
        output          	layer1_web,
        output  [11:0]   	layer1_A  ,
        output  [15:0]   	layer1_D  ,
        input  [15:0]   	layer1_Q  ,
        output          	done        
);

	//kernel
	wire signed [15:0] kernel1 = 16'hFFFF;
	wire signed [15:0] kernel2 = 16'hFFFE;
	wire signed [15:0] kernel3 = 16'hFFFF;
	wire signed [15:0] kernel4 = 16'hFFFC;
	wire signed [15:0] kernel5 = 16'h0010;
	wire signed [15:0] kernel6 = 16'hFFFC;
	wire signed [15:0] kernel7 = 16'hFFFF;
	wire signed [15:0] kernel8 = 16'hFFFE;
	wire signed [15:0] kernel9 = 16'hFFFF;
    wire signed [15:0] bias = 16'hFFF4;

    //position
    reg [11:0]pos;
    wire [5:0]pos_row = pos[11:6];
    wire [5:0]pos_col = pos[5:0];

	wire signed [31:0] product; 									// [31]signed, [30:8]int, [7:0]float
	reg signed [35:0] product_sum;									// [35]signed, [34:8]int, [7:0]float

	reg signed [15:0] max_pixel;
	reg signed [15:0] max_pixel_round;
	reg signed [15:0] kernel;

	reg [4:0]state, nextstate;
	parameter [4:0] START = 5'd0, IDLE1 = 5'd1, 
	CONV1 = 5'd2, CONV2 = 5'd3, CONV3 = 5'd4, CONV4 = 5'd5, CONV5 = 5'd6, CONV6 = 5'd7, CONV7 = 5'd8, CONV8 = 5'd9, CONV9 = 5'd10, RELU = 5'd11, WRITE_L0 = 5'd12, 
	IDLE2 = 5'd13, POOL1 = 5'd14, POOL2 = 5'd15, POOL3 = 5'd16, POOL4 = 5'd17, WRITE_L1 = 5'd18, DONE = 5'd19;

    always @(posedge clk or posedge rst) begin
		if(rst) begin
			state <= START; 
		end
		else begin
			state <= nextstate;
		end
	end

	//nextstate logic
    always @(*) begin
		case(state)
			START: nextstate = IDLE1;
			IDLE1: nextstate = CONV1;
			CONV1: nextstate = CONV2;
			CONV2: nextstate = CONV3;
			CONV3: nextstate = CONV4;
			CONV4: nextstate = CONV5;
			CONV5: nextstate = CONV6;
			CONV6: nextstate = CONV7;
			CONV7: nextstate = CONV8;
			CONV8: nextstate = CONV9;
			CONV9: nextstate = RELU;
			RELU: nextstate = WRITE_L0;
			WRITE_L0: nextstate = (pos == {6'd63, 6'd63}) ? IDLE2 : IDLE1;
			IDLE2: nextstate = POOL1;
			POOL1: nextstate = POOL2;
			POOL2: nextstate = POOL3;
			POOL3: nextstate = POOL4;
			POOL4: nextstate = WRITE_L1;
			WRITE_L1: nextstate = (pos == {6'd62, 6'd62}) ? DONE : IDLE2;
			DONE: nextstate = START;
			default: nextstate = START;
		endcase
	end

	//iaddr
	always @(posedge clk or posedge rst) begin
		if(rst) begin
			iaddr <= 12'd0;
		end
		else begin
			case(state)
				IDLE1: begin
					if(pos_row <= 6'd1) begin
						iaddr[11:6] <= 6'd0;
					end
					else begin
						iaddr[11:6] <= pos_row - 6'd2;
					end
					if(pos_col <= 6'd1) begin
						iaddr[5:0] <= 6'd0;
					end
					else begin
						iaddr[5:0] <= pos_col - 6'd2;
					end	
				end
				CONV1: begin
					if(pos_row <= 6'd1) begin
						iaddr[11:6] <= 6'd0;
					end
					else begin
						iaddr[11:6] <= pos_row - 6'd2;
					end
					iaddr[5:0] <= pos_col;
				end
				CONV2: begin
					if(pos_row <= 6'd1) begin
						iaddr[11:6] <= 6'd0;
					end
					else begin
						iaddr[11:6] <= pos_row - 6'd2;
					end
					if(pos_col >= 6'd62) begin
						iaddr[5:0] <= 6'd63;
					end
					else begin
						iaddr[5:0] <= pos_col + 6'd2;
					end
				end
				CONV3: begin
					if(pos_col <= 6'd1) begin
						iaddr[5:0] <= 6'd0;
					end
					else begin
						iaddr[5:0] <= pos_col - 6'd2;
					end
					iaddr[11:6] <= pos_row;
				end
				CONV4: iaddr <= pos;
				CONV5: begin
					if(pos_col >= 6'd62) begin
						iaddr[5:0] <= 6'd63;
					end
					else begin
						iaddr[5:0] <= pos_col + 6'd2;
					end
					iaddr[11:6] <= pos_row;
				end
				CONV6: begin
					if(pos_row >= 6'd62) begin
						iaddr[11:6] <= 6'd63;
					end
					else begin
						iaddr[11:6] <= pos_row + 6'd2;
					end
					if(pos_col <= 6'd1) begin
						iaddr[5:0] <= 6'd0;
					end
					else begin
						iaddr[5:0] <= pos_col - 6'd2;
					end
				end
				CONV7: begin
					if(pos_row >= 6'd62) begin
						iaddr[11:6] <= 6'd63;
					end
					else begin
						iaddr[11:6] <= pos_row + 6'd2;
					end
					iaddr[5:0] <= pos_col;
				end
				CONV8: begin
					if(pos_row >= 6'd62) begin
						iaddr[11:6] <= 6'd63;
					end
					else begin
						iaddr[11:6] <= pos_row + 6'd2;
					end
					if(pos_col >= 6'd62) begin
						iaddr[5:0] <= 6'd63;
					end
					else begin
						iaddr[5:0] <= pos_col + 6'd2;
					end
				end
				default: iaddr <= 12'd0;
			endcase
		end
	end

	//pos
	always @(posedge clk or posedge rst) begin
		if(rst) begin
			pos <= 12'd0;
		end
		else begin
			case(state)
				WRITE_L0: begin
					if(pos == {6'd63, 6'd63}) pos <= 12'd0;
					else if(pos_col == 6'd63) pos <= {pos_row + 6'd1, 6'd0};
					else pos <= {pos_row, pos_col + 6'd1};
				end
				WRITE_L1:begin
					if(pos == {6'd62, 6'd62}) pos <= 12'd0;
					else if(pos_col == 6'd62) pos <= {pos_row + 6'd2, 6'd0};
					else pos <= {pos_row, pos_col + 6'd2};
				end
				default: pos <= pos;
			endcase
		end
	end

	//product_sum
	always @(posedge clk or posedge rst) begin
		if(rst) begin
			product_sum <= 36'd0;
		end
		else begin
			case(state) 
				CONV1: product_sum <= product + $signed({bias, 4'd0});					//signed extension		
				CONV2: product_sum <= product_sum + product;
				CONV3: product_sum <= product_sum + product;
				CONV4: product_sum <= product_sum + product;
				CONV5: product_sum <= product_sum + product;
				CONV6: product_sum <= product_sum + product;
				CONV7: product_sum <= product_sum + product;
				CONV8: product_sum <= product_sum + product;
				CONV9: product_sum <= product_sum + product;
				RELU: product_sum <= (product_sum[35]) ? 36'd0 : product_sum;
				default: product_sum <= 36'd0;
			endcase
		end
	end
	
	//kernel
	always @(*) begin
		case(state)
			CONV1: kernel <= kernel1;
			CONV2: kernel <= kernel2;
			CONV3: kernel <= kernel3;
			CONV4: kernel <= kernel4;
			CONV5: kernel <= kernel5;
			CONV6: kernel <= kernel6;
			CONV7: kernel <= kernel7;
			CONV8: kernel <= kernel8;
			CONV9: kernel <= kernel9;
			default: kernel <= 16'd0;
		endcase
	end

	assign product = idata * kernel;
	wire signed [15:0] conv_result = {product_sum[35], product_sum[18:8], product_sum[7:4]};

	//layer0 address
	always @(*) begin
		case(state)
			WRITE_L0: layer0_A <= pos;
			POOL1: layer0_A <= pos;
			POOL2: layer0_A <= {pos_row, pos_col + 6'd1};
			POOL3: layer0_A <= {pos_row + 6'd1, pos_col};
			POOL4: layer0_A <= {pos_row + 6'd1, pos_col + 6'd1};
			default: layer0_A <= 12'd0;
		endcase
	end
	//layer0 Data
	always @(*) begin
		case(state)
			WRITE_L0: layer0_D <= conv_result;
			default: layer0_D <= 16'd0;
		endcase
	end

	//max pixel
	always @(posedge clk or posedge rst) begin
		if(rst) begin
			max_pixel <= 16'd0;
		end
		else begin
			case(state)
				POOL1: max_pixel <= layer0_Q;
				POOL2: max_pixel <= (layer0_Q > max_pixel) ? layer0_Q : max_pixel;
				POOL3: max_pixel <= (layer0_Q > max_pixel) ? layer0_Q : max_pixel;
				POOL4: max_pixel <= (layer0_Q > max_pixel) ? layer0_Q : max_pixel;
				default: max_pixel <= 16'd0;
			endcase
		end
	end
	//max_pixel rounding
	always @(*)begin
		if(state == WRITE_L1) begin
			if(max_pixel[3:0] != 4'd0) max_pixel_round = max_pixel + 16'd16;
			else max_pixel_round = max_pixel;

			max_pixel_round[3:0] = 4'd0;
		end
		else begin
			max_pixel_round = 16'd0;
		end
	end

	//max_count
	reg [11:0] max_count;
	always @(posedge clk or posedge rst) begin
		if(rst) begin
			max_count <= 12'd0;
		end
		else begin
			case(state)
				WRITE_L1: begin
					if(pos == {6'd62, 6'd62}) max_count <= 12'd0;
					else max_count <= max_count + 12'd1;
				end
				default: max_count <= max_count;
			endcase
		end
	end
	//layer1 address
	assign layer1_A = (state == WRITE_L1) ? max_count : 12'd0;
	//layer1 Data
	assign layer1_D = (state == WRITE_L1) ? max_pixel_round : 16'd0;

	//signal
    assign done = (state == DONE) ? 1'b1 : 1'b0;
	assign layer0_ceb = 1'b1;
	assign layer0_web = (state == WRITE_L0) ? 1'b0 : 1'b1;			//0 write, 1 read
	assign layer1_ceb = 1'b1;
	assign layer1_web = (state == WRITE_L1) ? 1'b0 : 1'b1;			//0 write, 1 read
	
	always @(posedge clk or posedge rst) begin
		if(rst) begin
			ROM_rd <= 1'b0;
		end
		case(state)
			START: ROM_rd <= 1'b1;
			IDLE1: ROM_rd <= 1'b1;
			WRITE_L0: ROM_rd <= 1'b1;
			WRITE_L0: ROM_rd <= 1'b0; 
			default: ROM_rd <= ROM_rd;
		endcase
	end



endmodule
