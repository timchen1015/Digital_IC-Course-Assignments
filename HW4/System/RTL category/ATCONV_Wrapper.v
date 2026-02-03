`timescale 1ns/10ps
`include "./include/define.v"

module ATCONV_Wrapper(
    input		                        bus_clk  ,
    input		                        bus_rst  ,
    input signed  [`BUS_DATA_BITS-1:0]  RDATA_M  ,
    input 	      					 	RLAST_M  ,
    input 	      					 	WREADY_M ,
    input 	      					 	RREADY_M ,
    output reg    [`BUS_ID_BITS  -1:0]  ID_M	 ,
    output reg    [`BUS_ADDR_BITS-1:0]  ADDR_M	 ,
    output reg    [`BUS_DATA_BITS-1:0]  WDATA_M  ,
    output        [`BUS_LEN_BITS -1:0]  BLEN_M   ,
    output 						 	    WLAST_M  ,
    output reg						    WVALID_M ,
    output reg  					    RVALID_M ,
    output                              done   
);

`timescale 1ns/10ps

	reg [11:0]iaddr;
	reg ROM_rd;
	reg [11:0]layer0_A;

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

	reg signed [15:0]max_pixel;
	reg signed [15:0] max_pixel_round;
	reg signed [15:0]kernel;

	reg [5:0]state, nextstate;
    parameter [5:0] START = 6'd0, IDLE1 = 6'd1, 
    WAIT1 = 6'd2, CONV1 = 6'd3, WAIT2 = 6'd4, CONV2 = 6'd5, WAIT3 = 6'd6, CONV3 = 6'd7, 
    WAIT4 = 6'd8, CONV4 = 6'd9, WAIT5 = 6'd10, CONV5 = 6'd11, WAIT6 = 6'd12, CONV6 = 6'd13, 
    WAIT7 = 6'd14, CONV7 = 6'd15, WAIT8 = 6'd16, CONV8 = 6'd17, WAIT9 = 6'd18, CONV9 = 6'd19, 
    RELU = 6'd20, WAIT_WRITE0 = 6'd21, WRITE_L0 = 6'd22, IDLE2 = 6'd23, WAIT_POOL1 = 6'd24, 
    POOL1 = 6'd25, POOL2 = 6'd26, POOL3 = 6'd27, POOL4 = 6'd28, WAIT_WRITE1 = 6'd29, WRITE_L1 = 6'd30, DONE = 6'd31;

    always @(posedge bus_clk or posedge bus_rst) begin
		if(bus_rst) begin
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
			IDLE1: nextstate = WAIT1;
            WAIT1: begin
                if(RREADY_M == 1'b1) begin
                    nextstate = CONV1;
                end
                else begin
                    nextstate = WAIT1;
                end
            end
			CONV1: nextstate = WAIT2;
            WAIT2: begin
                if(RREADY_M == 1'b1) begin
                    nextstate = CONV2;
                end
                else begin
                    nextstate = WAIT2;
                end
            end
			CONV2: nextstate = WAIT3;
			WAIT3: begin
				if(RREADY_M == 1'b1) begin
					nextstate = CONV3;
				end
				else begin
					nextstate = WAIT3;
				end
			end
			CONV3: nextstate = WAIT4;
			WAIT4: begin
				if(RREADY_M == 1'b1) begin
					nextstate = CONV4;
				end
				else begin
					nextstate = WAIT4;
				end
			end
			CONV4: nextstate = WAIT5;
			WAIT5: begin
				if(RREADY_M == 1'b1) begin
					nextstate = CONV5;
				end
				else begin
					nextstate = WAIT5;
				end
			end
			CONV5: nextstate = WAIT6;
			WAIT6: begin
				if(RREADY_M == 1'b1) begin
					nextstate = CONV6;
				end
				else begin
					nextstate = WAIT6;
				end
			end
			CONV6: nextstate = WAIT7;
			WAIT7: begin
				if(RREADY_M == 1'b1) begin
					nextstate = CONV7;
				end
				else begin
					nextstate = WAIT7;
				end
			end
			CONV7: nextstate = WAIT8;
			WAIT8: begin
				if(RREADY_M == 1'b1) begin
					nextstate = CONV8;
				end
				else begin
					nextstate = WAIT8;
				end
			end
			CONV8: nextstate = WAIT9;
			WAIT9: begin
				if(RREADY_M == 1'b1) begin
					nextstate = CONV9;
				end
				else begin
					nextstate = WAIT9;
				end
			end
			CONV9: nextstate = RELU;
			RELU: nextstate = WAIT_WRITE0;
            WAIT_WRITE0: begin
                if(WREADY_M == 1'b1) begin
                    nextstate = WRITE_L0;
                end
                else begin
                    nextstate = WAIT_WRITE0;
                end
            end
			WRITE_L0: nextstate = (pos == {6'd63, 6'd63}) ? IDLE2 : IDLE1;
			IDLE2: nextstate = WAIT_POOL1;
            WAIT_POOL1: begin
                if(RREADY_M == 1'b1) begin
                    nextstate = POOL1;
                end
                else begin
                    nextstate = WAIT_POOL1;
                end
            end
			POOL1: nextstate = POOL2;
			POOL2: nextstate = POOL3;
			POOL3: nextstate = POOL4;
			POOL4: nextstate = WAIT_WRITE1;
            WAIT_WRITE1: begin
                if(WREADY_M == 1'b1) begin
                    nextstate = WRITE_L1;
                end
                else begin
                    nextstate = WAIT_WRITE1;
                end
            end
			WRITE_L1: nextstate = (pos == {6'd62, 6'd62}) ? DONE : IDLE2;
			DONE: nextstate = START;
			default: nextstate = START;
		endcase
	end

	//iaddr
	always @(posedge bus_clk or posedge bus_rst) begin
		if(bus_rst) begin
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
				default: iaddr <= iaddr;
			endcase
		end
	end 

	//pos
	always @(posedge bus_clk or posedge bus_rst) begin
		if(bus_rst) begin
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
	always @(posedge bus_clk or posedge bus_rst) begin
		if(bus_rst) begin
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
				IDLE1: product_sum <= 36'd0;
				default: product_sum <= product_sum;
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

	assign product = RDATA_M * kernel;
	wire signed [15:0] conv_result = {product_sum[35], product_sum[18:8], product_sum[7:4]};

	//layer0 address
	//need fix
	always @(*) begin
		case(state)
			WAIT_WRITE0: layer0_A <= pos;
			WRITE_L0: layer0_A <= pos;
			WAIT_POOL1: layer0_A <= pos;
			POOL1: layer0_A <= pos;
			POOL2: layer0_A <= pos;
			POOL3: layer0_A <= pos;
			POOL4: layer0_A <= pos;
			default: layer0_A <= 12'd0;
		endcase
	end

	//max pixel
	always @(posedge bus_clk or posedge bus_rst) begin
		if(bus_rst) begin
			max_pixel <= 16'd0;
		end
		else begin
			case(state)
				POOL1: max_pixel <= RDATA_M;
				POOL2: max_pixel <= (RDATA_M > max_pixel) ? RDATA_M : max_pixel;
				POOL3: max_pixel <= (RDATA_M > max_pixel) ? RDATA_M : max_pixel;
				POOL4: max_pixel <= (RDATA_M > max_pixel) ? RDATA_M : max_pixel;
				IDLE2: max_pixel <= 16'd0;
				default: max_pixel <= max_pixel;
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
	always @(posedge bus_clk or posedge bus_rst) begin
		if(bus_rst) begin
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
	wire [11:0] layer1_A;
	assign layer1_A = (state == WAIT_WRITE1 || state == WRITE_L1) ? max_count : 12'd0;

	//signal
    assign done = (state == DONE) ? 1'b1 : 1'b0;
	assign layer0_ceb = 1'b1;
	assign layer0_web = (state == WRITE_L0) ? 1'b0 : 1'b1;			//0 write, 1 read
	assign layer1_ceb = 1'b1;
	assign layer1_web = (state == WRITE_L1) ? 1'b0 : 1'b1;			//0 write, 1 read
	
	always @(posedge bus_clk or posedge bus_rst) begin
		case(state)
			START: ROM_rd <= 1'b1;
			WRITE_L0: ROM_rd <= 1'b1;
			CONV9: ROM_rd <= 1'b0; 
			default: ROM_rd <= ROM_rd;
		endcase
	end

    //VALID
    always @(*)begin
        case(state)
            WAIT1: RVALID_M = 1'b1;
            WAIT2: RVALID_M = 1'b1;
            WAIT3: RVALID_M = 1'b1;
            WAIT4: RVALID_M = 1'b1;
            WAIT5: RVALID_M = 1'b1;
            WAIT6: RVALID_M = 1'b1;
            WAIT7: RVALID_M = 1'b1;
            WAIT8: RVALID_M = 1'b1;
            WAIT9: RVALID_M = 1'b1;
            WAIT_POOL1: RVALID_M = 1'b1;
            default: RVALID_M = 1'b0;
        endcase
    end

    always @(*) begin
        case(state)
            WAIT_WRITE0: WVALID_M = 1'b1;
            WAIT_WRITE1: WVALID_M = 1'b1;
            default: WVALID_M = 1'b0;
        endcase
    end

	//Write data
	always @(*)begin
		case(state)
			WRITE_L0: WDATA_M = conv_result;
            WRITE_L1: WDATA_M = max_pixel_round;
            default: WDATA_M = 16'd0;
		endcase
	end
	
	//address
	always @(*) begin
		case(state)
			WAIT1: ADDR_M = iaddr;
			WAIT2: ADDR_M = iaddr;
			WAIT3: ADDR_M = iaddr;
			WAIT4: ADDR_M = iaddr;
			WAIT5: ADDR_M = iaddr;
			WAIT6: ADDR_M = iaddr;
			WAIT7: ADDR_M = iaddr;
			WAIT8: ADDR_M = iaddr;
			WAIT9: ADDR_M = iaddr;
			WRITE_L0: ADDR_M = layer0_A;
			WAIT_POOL1: ADDR_M = layer0_A;
			POOL1: ADDR_M = layer0_A;
			POOL2: ADDR_M = layer0_A;
			POOL3: ADDR_M = layer0_A;
			POOL4: ADDR_M = layer0_A;
			WAIT_WRITE0: ADDR_M = layer0_A;
			WRITE_L1: ADDR_M = layer1_A;
			WAIT_WRITE1: ADDR_M = layer1_A;
			WRITE_L1: ADDR_M = layer1_A;
			default: ADDR_M = 12'd0;
		endcase
	end

	//ID
	always @(*) begin
		case(state)
			WAIT1: ID_M = 2'b00;
			CONV1: ID_M = 2'b00;
			WAIT2: ID_M = 2'b00;
			CONV2: ID_M = 2'b00;
			WAIT3: ID_M = 2'b00;
			CONV3: ID_M = 2'b00;
			WAIT4: ID_M = 2'b00;
			CONV4: ID_M = 2'b00;
			WAIT5: ID_M = 2'b00;
			CONV5: ID_M = 2'b00;
			WAIT6: ID_M = 2'b00;
			CONV6: ID_M = 2'b00;
			WAIT7: ID_M = 2'b00;
			CONV7: ID_M = 2'b00;
			WAIT8: ID_M = 2'b00;
			CONV8: ID_M = 2'b00;
			WAIT9: ID_M = 2'b00;
			CONV9: ID_M = 2'b00;
			RELU: ID_M = 2'b00;
			WAIT_WRITE0: ID_M = 2'b01;
			WRITE_L0: ID_M = 2'b01;
			WAIT_POOL1: ID_M = 2'b01;
			POOL1: ID_M = 2'b01;
			POOL2: ID_M = 2'b01;
			POOL3: ID_M = 2'b01;
			POOL4: ID_M = 2'b01;
			WAIT_WRITE1: ID_M = 2'b10;
			WRITE_L1: ID_M = 2'b10;
			default: ID_M = 2'd0;
		endcase
	end

	assign WLAST_M  = (state == WRITE_L0 || state == WRITE_L1) ? 1'b1 : 1'b0;
	assign BLEN_M = 1;
	








    

endmodule
