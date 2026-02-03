module  Unit(
    input signed [31:0]  a,                 //[31] signed, [30:16] Integer, [15:0] Float
    input signed [31:0]  b,
    input signed [31:0]  c,
    input signed [31:0]  d,
    input [2:0]  w,
    output signed [31:0]    ffta_r,
    output signed [31:0]    ffta_i,
    output signed [31:0]    fftb_r,
    output signed [31:0]    fftb_i
);

reg signed [31:0] W_r, W_i;                //[31] signed, [30:16] Integer, [15:0] Float
wire signed [63:0] temp_br, temp_bi;        //[63] signed, [62:32] Integer, [31:0] Float
always @(*) begin
        case(w)
            3'd0: begin 
                W_r = 32'h00010000; 
                W_i = 32'h00000000; 
            end
            3'd1: begin 
                W_r = 32'h0000EC83; 
                W_i = 32'hFFFF9E09; 
            end
            3'd2: begin 
                W_r = 32'h0000B504; 
                W_i = 32'hFFFF4AFC; 
            end
            3'd3: begin 
                W_r = 32'h000061F7; 
                W_i = 32'hFFFF137D; 
            end
            3'd4: begin 
                W_r = 32'h00000000; 
                W_i = 32'hFFFF0000; 
            end
            3'd5: begin 
                W_r = 32'hFFFF9E09; 
                W_i = 32'hFFFF137D; 
            end
            3'd6: begin 
                W_r = 32'hFFFF4AFC; 
                W_i = 32'hFFFF4AFC; 
            end
            3'd7: begin 
                W_r = 32'hFFFF137D; 
                W_i = 32'hFFFF9E09; 
            end
        endcase
end

assign ffta_r = a + c;
assign ffta_i = b + d;
assign temp_br = (a - c) * W_r + (d - b) * W_i;
assign temp_bi = (b - d) * W_r + (a - c) * W_i;
assign fftb_r = {temp_br[63], temp_br[46:16]};
assign fftb_i = {temp_bi[63], temp_bi[46:16]};

endmodule