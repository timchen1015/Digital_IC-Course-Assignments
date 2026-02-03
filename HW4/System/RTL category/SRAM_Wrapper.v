`timescale 1ns/10ps
`include "../include/define.v"

module SRAM_Wrapper(
	input 	   						bus_clk ,
	input 	   						bus_rst ,
	input      [`BUS_ADDR_BITS-1:0] ADDR_S  ,
	input      [`BUS_DATA_BITS-1:0] WDATA_S ,
	input      [`BUS_LEN_BITS -1:0] BLEN_S  ,
	input      						WLAST_S ,
	input      						WVALID_S,
	input      						RVALID_S,
	output     [`BUS_DATA_BITS-1:0] RDATA_S ,
	output     						RLAST_S ,
	output     						WREADY_S,
	output     						RREADY_S,
	output 	   [`BUS_DATA_BITS-1:0] SRAM_D  ,
	output reg [`BUS_ADDR_BITS-1:0] SRAM_A  ,
	input	   [`BUS_DATA_BITS-1:0] SRAM_Q  ,
	output							SRAM_ceb,
	output							SRAM_web		
);
	parameter IDLE = 3'd0, HANDSHAKE_READ = 3'd1, HANDSHAKE_WRITE = 3'd2, READ1 = 3'd3, READ2 = 3'd4, READ3 = 3'd5, READ4 = 3'd6, WRITE = 3'd7;
	reg [2:0] state, next_state;
	
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
				if(WVALID_S == 1'b1) next_state = HANDSHAKE_WRITE;
				else if(RVALID_S == 1'b1) next_state = HANDSHAKE_READ;
				else next_state = IDLE;
			end
			HANDSHAKE_WRITE: next_state = WRITE;
			HANDSHAKE_READ: next_state = READ1;
			WRITE: next_state = IDLE;
			READ1: next_state = READ2;
			READ2: next_state = READ3;
			READ3: next_state = READ4;
			READ4: next_state = IDLE;
			default: next_state = IDLE;
		endcase
	end
	
	assign RLAST_S = (state == READ4) ? 1'b1 : 1'b0;
	assign RDATA_S = (state == READ1 || state == READ2 || state == READ3 || state == READ4) ? SRAM_Q : 16'd0;
	assign WREADY_S = (state == HANDSHAKE_WRITE) ? 1'b1 : 1'b0;
	assign RREADY_S = (state == HANDSHAKE_READ) ? 1'b1 : 1'b0;
	assign SRAM_D = WDATA_S;

	always @(posedge bus_clk or posedge bus_rst) begin
		if(bus_rst) begin
			SRAM_A <= 12'd0;
		end
		else begin
			case(state)
				HANDSHAKE_READ: SRAM_A <= ADDR_S;
				READ1: SRAM_A <= SRAM_A + 12'd1;
				READ2: SRAM_A <= SRAM_A + 12'd63;
				READ3: SRAM_A <= SRAM_A + 12'd1;
				HANDSHAKE_WRITE: SRAM_A <= ADDR_S;
				default: SRAM_A <= SRAM_A;
			endcase
		end
	end


	assign SRAM_ceb = (state == WRITE || state == READ1 || state == READ2 || state == READ3 || state == READ4 || state == HANDSHAKE_READ || state == HANDSHAKE_WRITE) ? 1'b1 : 1'b0; // Chip enable
	assign SRAM_web = (state == WRITE) ? 1'b0 : 1'b1;


endmodule