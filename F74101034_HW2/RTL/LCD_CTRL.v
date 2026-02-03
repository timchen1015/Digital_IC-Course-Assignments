module LCD_CTRL(
	input 	   	  clk	   ,
	input 		  rst	   ,
	input 	[3:0] cmd      , 
	input 		  cmd_valid,
	input 	[7:0] IROM_Q   ,
	output 		  IROM_rd  , 
	output  [5:0] IROM_A   ,
	output 		  IRAM_ceb ,
	output 		  IRAM_web ,
	output  reg [7:0] IRAM_D   ,
	output  reg [5:0] IRAM_A   ,
	input 	[7:0] IRAM_Q   ,
	output 		  busy	   ,
	output 		  done
);

parameter [3:0] wrtie_cmd 		= 4'd0,
				shiftup_cmd 	= 4'd1,
				shiftdown_cmd 	= 4'd2,
				shiftleft_cmd 	= 4'd3,
				shiftright_cmd 	= 4'd4,
				max_cmd 		= 4'd5,
				min_cmd 		= 4'd6,
				avg_cmd 		= 4'd7;

parameter [3:0] GET_MEMORY = 4'd0, IDLE = 4'd1, MIN = 4'd2, MAX = 4'd3, AVG = 4'd4, REPLACE = 4'd5, WRITE = 4'd6, WRITE_DONE = 4'd7, DONE = 4'd8;
reg [3:0] state, next_state;
reg [2:0] write_X, write_Y, origin_X, origin_Y, replace_X, replace_Y;
reg[7:0] temp_memory[7:0][7:0];		//8x8 memory
reg [7:0] replace_value;

//FSM
always @(posedge clk or posedge rst) begin
	if(rst) begin
		state <= GET_MEMORY;
	end
	else begin
		state <= next_state;
	end
end

//next state logic
always @(*) begin
	case(state)
		GET_MEMORY: begin
			if(write_X == 3'd7 && write_Y == 3'd7) next_state = IDLE;
			else next_state = GET_MEMORY;
		end
		IDLE: begin
			if(cmd_valid) begin
				case(cmd)
					wrtie_cmd: next_state = WRITE;
					max_cmd: next_state = MAX;
					min_cmd: next_state = MIN;
					avg_cmd: next_state = AVG;
					default: next_state = IDLE;		//shift operation
				endcase
			end 
			else next_state = IDLE;
		end
		WRITE: begin
			if(write_X == 3'd7 && write_Y == 3'd7) next_state = WRITE_DONE;
			else next_state = WRITE;
		end
		MIN: begin
			if(replace_X == (origin_X + 3'd1) && replace_Y ==  (origin_Y + 3'd1)) next_state = REPLACE;
			else next_state = MIN;
		end
		MAX: begin
			if(replace_X == (origin_X + 3'd1) && replace_Y ==  (origin_Y + 3'd1)) next_state = REPLACE;
			else next_state = MAX;
		end
		AVG: begin
			if(replace_X == (origin_X + 3'd1) && replace_Y ==  (origin_Y + 3'd1)) next_state = REPLACE;
			else next_state = AVG;
		end
		REPLACE: begin
			if(replace_X == (origin_X + 3'd1) && replace_Y ==  (origin_Y + 3'd1)) next_state = IDLE;
			else next_state = REPLACE;
		end
		WRITE_DONE: next_state = DONE;
		DONE: next_state = DONE;
		default: next_state = IDLE;
	endcase
end

//originX, originY
always @(posedge clk or rst) begin
	if(rst) begin
		origin_X <= 3'd4;
		origin_Y <= 3'd4;
	end
	else begin
		if(state == IDLE) begin
			case(cmd) 
				shiftup_cmd: begin
					if(origin_Y > 3'd2) origin_Y <= origin_Y - 3'd1;
				end
				shiftdown_cmd: begin
					if(origin_Y < 3'd6) origin_Y <= origin_Y + 3'd1;
				end
				shiftleft_cmd: begin
					if(origin_X > 3'd2) origin_X <= origin_X - 3'd1;
				end
				shiftright_cmd: begin
					if(origin_X < 3'd6) origin_X <= origin_X + 3'd1;
				end
			endcase
		end	
	end
end

//ReplaceX, ReplaceY, replace_value, temp_sum
reg [10:0] temp_sum;
always @(posedge clk or posedge rst) begin
	if(rst) begin
		replace_X <= 3'd2;
		replace_Y <= 3'd2;
		replace_value <= 8'd0;
		temp_sum <= 11'd0;
	end
	else begin
		case(state)
			IDLE: begin
				replace_X <= origin_X - 3'd2;
				replace_Y <= origin_Y - 3'd2;
				replace_value <= temp_memory[origin_X - 3'd2][origin_Y - 3'd2];
				temp_sum <= 11'd0;
			end
			MIN: begin
				//replace value
				if(replace_value > temp_memory[replace_X][replace_Y]) replace_value <= temp_memory[replace_X][replace_Y];
				//x, y
				if(replace_X == (origin_X + 3'd1) && replace_Y ==  (origin_Y + 3'd1)) begin
					replace_X <= origin_X - 3'd2;
					replace_Y <= origin_Y - 3'd2;
				end
				else if(replace_X == (origin_X + 3'd1)) begin
					replace_X <= origin_X - 3'd2;
					replace_Y <= replace_Y + 3'd1;
				end
				else replace_X <= replace_X + 3'd1;
			end
			MAX: begin
				//replace value
				if(replace_value < temp_memory[replace_X][replace_Y]) replace_value <= temp_memory[replace_X][replace_Y];
				//x, y
				if(replace_X == (origin_X + 3'd1) && replace_Y ==  (origin_Y + 3'd1)) begin
					replace_X <= origin_X - 3'd2;
					replace_Y <= origin_Y - 3'd2;
				end
				else if(replace_X == (origin_X + 3'd1)) begin
					replace_X <= origin_X - 3'd2;
					replace_Y <= replace_Y + 3'd1;
				end
				else replace_X <= replace_X + 3'd1;
			end
			AVG: begin
				//replace value
				temp_sum <= temp_sum + temp_memory[replace_X][replace_Y];
				if(replace_X == (origin_X + 3'd1) && replace_Y ==  (origin_Y + 3'd1)) begin
					replace_X <= origin_X - 3'd2;
					replace_Y <= origin_Y - 3'd2;
					replace_value <= (temp_sum + temp_memory[replace_X][replace_Y] >> 4);
					temp_sum <= 11'd0;
				end
				else if(replace_X == (origin_X + 3'd1)) begin
					replace_X <= origin_X - 3'd2;
					replace_Y <= replace_Y + 3'd1;
				end
				else replace_X <= replace_X + 3'd1;
			end
			REPLACE: begin
				if(replace_X == (origin_X + 3'd1) && replace_Y ==  (origin_Y + 3'd1)) begin
					replace_X <= origin_X - 3'd2;
					replace_Y <= origin_Y - 3'd2;
				end
				else if(replace_X == (origin_X + 3'd1)) begin
					replace_X <= origin_X - 3'd2;
					replace_Y <= replace_Y + 3'd1;
				end
				else replace_X <= replace_X + 3'd1;				
			end
		endcase
	end
end

//WriteX, WriteY
always @(posedge clk or posedge rst) begin
	if(rst) begin
		write_X <= 3'd0;
		write_Y <= 3'd0;
	end
	else begin
		case(state)
			GET_MEMORY, WRITE: begin
				if(write_X == 3'd7 && write_Y == 3'd7) begin
					write_X <= 3'd0;
					write_Y <= 3'd0;
				end
				else if(write_X == 3'd7) begin
					write_X <= 3'd0;
					write_Y <= write_Y + 3'd1;
				end
				else write_X <= write_X + 3'd1;
			end
			REPLACE: begin				
				temp_memory[replace_X][replace_Y] <= replace_value;
			end
			default: begin
				write_X <= 3'd0;
				write_Y <= 3'd0;
			end
		endcase
	end
end

integer i, j;
//Memory
always @(posedge clk or posedge rst) begin
	if(rst) begin
		for(i = 0; i < 8; i = i + 1) begin
			for(j = 0; j < 8; j = j + 1) begin
				temp_memory[i][j] <= 8'd0;
			end
		end
	end
	else begin
		case(state)
			GET_MEMORY: begin
				temp_memory[write_X][write_Y] <= IROM_Q;
			end
			REPLACE: begin
				//temp_memory[Write_X][write_Y] <= 
			end
		endcase
	end
end

assign IROM_A = (state == GET_MEMORY) ? (write_Y << 3) + write_X : 6'd0;
assign IROM_rd = (state == GET_MEMORY) ? 1'b1 : 1'b0;
assign busy = (state == IDLE || state == DONE) ? 1'b0 : 1'b1;
assign done = (state == DONE) ? 1'b1 : 1'b0;

assign IRAM_ceb = (state == WRITE || WRITE_DONE) ? 1'b1 : 1'b0;
assign IRAM_web = (state == WRITE || WRITE_DONE) ? 1'b0 : 1'b1;			//0: wrtite, 1: read




//Write 
always @(posedge clk or posedge rst) begin
	if(rst) begin
		IRAM_A <= 6'd0;
		IRAM_D <= 8'd0;
	end
	else begin
		if(state == WRITE) begin
			IRAM_A <= (write_Y << 3) + write_X;
			IRAM_D <= temp_memory[write_X][write_Y];
		end
		else begin
			IRAM_A <= 6'd0;
			IRAM_D <= 8'd0;
		end
	end
end






endmodule