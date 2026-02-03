`timescale 1ns/10ps
`include "../include/define.v"

module ROM_Wrapper(
	input     						bus_clk ,
	input     						bus_rst ,
	input      [`BUS_ADDR_BITS-1:0] ADDR_S  ,
	input      [`BUS_LEN_BITS -1:0] BLEN_S  ,
	input     						RVALID_S,
	output 	   [`BUS_DATA_BITS-1:0] RDATA_S ,
	output 	   						RLAST_S ,
	output 	  						RREADY_S,
	output 							ROM_rd  ,
	output reg [`BUS_ADDR_BITS-1:0] ROM_A  	,
	input 	   [`BUS_DATA_BITS-1:0] ROM_Q 
);
	parameter IDLE = 2'd0, HANDSHAKE = 2'd1, READ = 2'd2;
	reg [1:0] state, next_state;

	always @(posedge bus_clk or posedge bus_rst) begin
		if(bus_rst) begin
			state <= IDLE;
		end
		else begin
			state <= next_state;
		end
	end
	always @(*) begin
		case(state)
			IDLE: begin
				if(RVALID_S == 1'b1) next_state = HANDSHAKE;
				else next_state = IDLE;
			end
			HANDSHAKE: next_state = READ;
			READ: next_state = IDLE;
			default: next_state = IDLE;
		endcase
	end

	assign RDATA_S = (state == READ) ? ROM_Q : 16'd0;
	assign RLAST_S = (state == READ) ? 1'b1 : 1'b0;
	//assign ROM_A = ADDR_S;
	assign ROM_rd = (state == READ || state == HANDSHAKE) ? 1'b1 : 1'b0;
	assign RREADY_S = (state == HANDSHAKE) ? 1'b1 : 1'b0;

	always @(posedge bus_clk or posedge bus_rst) begin
		if(bus_rst) begin
			ROM_A <= 12'd0;
		end
		else begin
			case(state)
				IDLE: ROM_A <= 12'd0;
				HANDSHAKE: ROM_A <= ADDR_S;
				default: ROM_A <= ROM_A;
			endcase
		end
	end


	
endmodule