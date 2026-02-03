module  FFT(
    input               clk      , 
    input               rst      , 
    input  [15:0]       fir_d    , 
    input               fir_valid,
    output              fft_valid, 
    output              done     ,
    output reg [15:0]   fft_d1   , 
    output reg [15:0]   fft_d2   ,
    output reg [15:0]   fft_d3   , 
    output reg [15:0]   fft_d4   , 
    output reg [15:0]   fft_d5   , 
    output reg [15:0]   fft_d6   , 
    output reg [15:0]   fft_d7   , 
    output reg [15:0]   fft_d8   ,
    output reg [15:0]   fft_d9   , 
    output reg [15:0]   fft_d10  , 
    output reg [15:0]   fft_d11  , 
    output reg [15:0]   fft_d12  , 
    output reg [15:0]   fft_d13  , 
    output reg [15:0]   fft_d14  , 
    output reg [15:0]   fft_d15  , 
    output reg [15:0]   fft_d0
);

/////////////////////////////////
// Please write your code here //
/////////////////////////////////

reg signed[15:0]x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15;
reg signed[31:0]a0, b0, c0, d0;
wire signed [31:0]ffta_r0, ffta_i0, fftb_r0, fftb_i0;
reg signed[31:0]a1, b1, c1, d1;
wire signed [31:0]ffta_r1, ffta_i1, fftb_r1, fftb_i1;
reg signed[31:0]a2, b2, c2, d2;
wire signed [31:0]ffta_r2, ffta_i2, fftb_r2, fftb_i2;
reg signed[31:0]a3, b3, c3, d3;
wire signed [31:0]ffta_r3, ffta_i3, fftb_r3, fftb_i3;
reg signed[31:0]a4, b4, c4, d4;
wire signed [31:0]ffta_r4, ffta_i4, fftb_r4, fftb_i4;
reg signed[31:0]a5, b5, c5, d5;
wire signed [31:0]ffta_r5, ffta_i5, fftb_r5, fftb_i5;
reg signed[31:0]a6, b6, c6, d6;
wire signed [31:0]ffta_r6, ffta_i6, fftb_r6, fftb_i6;
reg signed[31:0]a7, b7, c7, d7;
wire signed [31:0]ffta_r7, ffta_i7, fftb_r7, fftb_i7;
reg [2:0] w0, w1, w2, w3, w4, w5, w6, w7;


Unit unit0(.a(a0), .b(b0), .c(c0), .d(d0), .w(w0), .ffta_r(ffta_r0), .ffta_i(ffta_i0), .fftb_r(fftb_r0), .fftb_i(fftb_i0));
Unit unit1(.a(a1), .b(b1), .c(c1), .d(d1), .w(w1), .ffta_r(ffta_r1), .ffta_i(ffta_i1), .fftb_r(fftb_r1), .fftb_i(fftb_i1));
Unit unit2(.a(a2), .b(b2), .c(c2), .d(d2), .w(w2), .ffta_r(ffta_r2), .ffta_i(ffta_i2), .fftb_r(fftb_r2), .fftb_i(fftb_i2));
Unit unit3(.a(a3), .b(b3), .c(c3), .d(d3), .w(w3), .ffta_r(ffta_r3), .ffta_i(ffta_i3), .fftb_r(fftb_r3), .fftb_i(fftb_i3));
Unit unit4(.a(a4), .b(b4), .c(c4), .d(d4), .w(w4), .ffta_r(ffta_r4), .ffta_i(ffta_i4), .fftb_r(fftb_r4), .fftb_i(fftb_i4));
Unit unit5(.a(a5), .b(b5), .c(c5), .d(d5), .w(w5), .ffta_r(ffta_r5), .ffta_i(ffta_i5), .fftb_r(fftb_r5), .fftb_i(fftb_i5));
Unit unit6(.a(a6), .b(b6), .c(c6), .d(d6), .w(w6), .ffta_r(ffta_r6), .ffta_i(ffta_i6), .fftb_r(fftb_r6), .fftb_i(fftb_i6));
Unit unit7(.a(a7), .b(b7), .c(c7), .d(d7), .w(w7), .ffta_r(ffta_r7), .ffta_i(ffta_i7), .fftb_r(fftb_r7), .fftb_i(fftb_i7));


parameter [4:0]START = 5'd0, READ1 = 5'd1, READ2 = 5'd2, READ3 = 5'd3, READ4 = 5'd4, READ5 = 5'd5, READ6 = 5'd6, READ7 = 5'd7, READ8 = 5'd8, READ9 = 5'd9, READ10 = 5'd10, 
               READ11 = 5'd11, READ12 = 5'd12, READ13 = 5'd13, READ14 = 5'd14, READ15 = 5'd15, 
               STAGE1 = 5'd16, STAGE2 = 5'd17, STAGE3 = 5'd18, STAGE4 = 5'd19, OUTPUT_R = 5'd20, OUTPUT_I = 5'd21, DONE = 5'd22;
reg [4:0] state, next_state;






always @(posedge clk or posedge rst) begin
    if(rst) begin
        state <= START;
    end else begin
        state <= next_state;
    end
end

//state transition
always @(*) begin
    case(state)
        START: begin
            if(fir_valid) next_state = READ1;
            else next_state = START;
        end
        READ1: next_state = READ2;
        READ2: next_state = READ3;
        READ3: next_state = READ4;
        READ4: next_state = READ5;
        READ5: next_state = READ6;
        READ6: next_state = READ7;
        READ7: next_state = READ8;
        READ8: next_state = READ9;
        READ9: next_state = READ10;
        READ10: next_state = READ11;
        READ11: next_state = READ12;
        READ12: next_state = READ13;
        READ13: next_state = READ14;
        READ14: next_state = READ15;
        READ15: next_state = STAGE1;
        STAGE1: next_state = STAGE2;
        STAGE2: next_state = STAGE3;
        STAGE3: next_state = STAGE4;
        STAGE4: next_state = OUTPUT_R;
        OUTPUT_R: next_state = OUTPUT_I;
        OUTPUT_I: begin
            if(!fir_valid) next_state = DONE;
            else next_state = READ6;
        end
        DONE: next_state = DONE;
        default: next_state = START;
    endcase
end 

always @(posedge clk or posedge rst) begin
    if(rst) begin
        x0 <= 16'd0;
        x1 <= 16'd0;
        x2 <= 16'd0;
        x3 <= 16'd0;
        x4 <= 16'd0;
        x5 <= 16'd0;
        x6 <= 16'd0;
        x7 <= 16'd0;
        x8 <= 16'd0;
        x9 <= 16'd0;
        x10 <= 16'd0;
        x11 <= 16'd0;
        x12 <= 16'd0;
        x13 <= 16'd0;
        x14 <= 16'd0;
        x15 <= 16'd0;
    end else begin
        case(state)
            START: begin
                if(fir_valid) x0 <= fir_d;
                else x0 <= 16'd0;
            end
            READ1: x1 <= fir_d;
            READ2: x2 <= fir_d;
            READ3: x3 <= fir_d;
            READ4: x4 <= fir_d;
            READ5: x5 <= fir_d;
            READ6: x6 <= fir_d;
            READ7: x7 <= fir_d;
            READ8: x8 <= fir_d;
            READ9: x9 <= fir_d;
            READ10: x10 <= fir_d;
            READ11: x11 <= fir_d;
            READ12: x12 <= fir_d;
            READ13: x13 <= fir_d;
            READ14: x14 <= fir_d;
            READ15: x15 <= fir_d;
            STAGE1:begin
                if(fir_valid) x0 <= fir_d;
                //Unit 1
                a0 <= { {8{x0[15]}}, x0[15:0], 8'd0};                      //signed extension
                b0 <= 32'd0;
                c0 <= { {8{x8[15]}}, x8[15:0], 8'd0};                      //signed extension
                d0 <= 32'd0;
                w0 <= 3'd0;
                //Unit 2
                a1 <= { {8{x1[15]}}, x1[15:0], 8'd0};                      //signed extension
                b1 <= 32'd0;
                c1 <= { {8{x9[15]}}, x9[15:0], 8'd0};                      //signed extension
                d1 <= 32'd0;
                w1 <= 3'd1;
                //Unit 3
                a2 <= { {8{x2[15]}}, x2[15:0], 8'd0};                      //signed extension
                b2 <= 32'd0;
                c2 <= { {8{x10[15]}}, x10[15:0], 8'd0};                    //signed extension
                d2 <= 32'd0;
                w2 <= 3'd2;
                //Unit 4
                a3 <= { {8{x3[15]}}, x3[15:0], 8'd0};                      //signed extension
                b3 <= 32'd0;
                c3 <= { {8{x11[15]}}, x11[15:0], 8'd0};                    //signed extension
                d3 <= 32'd0;
                w3 <= 3'd3;
                //Unit 5
                a4 <= { {8{x4[15]}}, x4[15:0], 8'd0};                      //signed extension
                b4 <= 32'd0;
                c4 <= { {8{x12[15]}}, x12[15:0], 8'd0};                     //signed extension
                d4 <= 32'd0;
                w4 <= 3'd4;
                //Unit 6
                a5 <= { {8{x5[15]}}, x5[15:0], 8'd0};                      //signed extension
                b5 <= 32'd0;
                c5 <= { {8{x13[15]}}, x13[15:0], 8'd0};                     //signed extension
                d5 <= 32'd0;
                w5 <= 3'd5;
                //Unit 7
                a6 <= { {8{x6[15]}}, x6[15:0], 8'd0};                      //signed extension
                b6 <= 32'd0;
                c6 <= { {8{x14[15]}}, x14[15:0], 8'd0};                     //signed extension
                d6 <= 32'd0;
                w6 <= 3'd6;
                //Unit 8
                a7 <= { {8{x7[15]}}, x7[15:0], 8'd0};                      //signed extension
                b7 <= 32'd0;
                c7 <= { {8{x15[15]}}, x15[15:0], 8'd0};                     //signed extension
                d7 <= 32'd0;
                w7 <= 3'd7;
            end
            STAGE2:begin
                if(fir_valid) x1 <= fir_d;

                //Unit 1
                a0 <= ffta_r0;
                b0 <= ffta_i0;
                c0 <= ffta_r4;
                d0 <= ffta_i4;
                w0 <= 3'd0;
                //Unit 2
                a1 <= ffta_r1;
                b1 <= ffta_i1;
                c1 <= ffta_r5;
                d1 <= ffta_i5;
                w1 <= 3'd2;
                //Unit 3
                a2 <= ffta_r2;
                b2 <= ffta_i2;
                c2 <= ffta_r6;
                d2 <= ffta_i6;
                w2 <= 3'd4;
                //Unit 4
                a3 <= ffta_r3;
                b3 <= ffta_i3;
                c3 <= ffta_r7;
                d3 <= ffta_i7;
                w3 <= 3'd6;
                //Unit 5
                a4 <= fftb_r0;
                b4 <= fftb_i0;
                c4 <= fftb_r4;
                d4 <= fftb_i4;
                w4 <= 3'd0;
                //Unit 6
                a5 <= fftb_r1;
                b5 <= fftb_i1;
                c5 <= fftb_r5;
                d5 <= fftb_i5;
                w5 <= 3'd2;
                //Unit 7
                a6 <= fftb_r2;
                b6 <= fftb_i2;
                c6 <= fftb_r6;
                d6 <= fftb_i6;
                w6 <= 3'd4;
                //Unit 8
                a7 <= fftb_r3;
                b7 <= fftb_i3;
                c7 <= fftb_r7;
                d7 <= fftb_i7;
                w7 <= 3'd6;
            end
            STAGE3:begin
                if(fir_valid) x2 <= fir_d;
                //Unit 1
                a0 <= ffta_r0;
                b0 <= ffta_i0;
                c0 <= ffta_r2;
                d0 <= ffta_i2;
                w0 <= 3'd0;
                //Unit 2
                a1 <= ffta_r1;
                b1 <= ffta_i1;
                c1 <= ffta_r3;
                d1 <= ffta_i3;
                w1 <= 3'd4;
                //Unit 3
                a2 <= fftb_r0;
                b2 <= fftb_i0;
                c2 <= fftb_r2;
                d2 <= fftb_i2;
                w2 <= 3'd0;
                //Unit 4
                a3 <= fftb_r1;
                b3 <= fftb_i1;
                c3 <= fftb_r3;
                d3 <= fftb_i3;
                w3 <= 3'd4;
                //Unit 5
                a4 <= ffta_r4;
                b4 <= ffta_i4;
                c4 <= ffta_r6;
                d4 <= ffta_i6;
                w4 <= 3'd0;
                //Unit 6
                a5 <= ffta_r5;
                b5 <= ffta_i5;
                c5 <= ffta_r7;
                d5 <= ffta_i7;
                w5 <= 3'd4;
                //Unit 7
                a6 <= fftb_r4;
                b6 <= fftb_i4;
                c6 <= fftb_r6;
                d6 <= fftb_i6;
                w6 <= 3'd0;
                //Unit 8
                a7 <= fftb_r5;
                b7 <= fftb_i5;
                c7 <= fftb_r7;
                d7 <= fftb_i7;
                w7 <= 3'd4;
            end
            STAGE4: begin
                if(fir_valid) x3 <= fir_d;
                //Unit 1
                a0 <= ffta_r0;
                b0 <= ffta_i0;
                c0 <= ffta_r1;
                d0 <= ffta_i1;
                w0 <= 3'd0;
                //Unit 2
                a1 <= fftb_r0;
                b1 <= fftb_i0;
                c1 <= fftb_r1;
                d1 <= fftb_i1;
                w1 <= 3'd0;
                //Unit 3
                a2 <= ffta_r2;
                b2 <= ffta_i2;
                c2 <= ffta_r3;
                d2 <= ffta_i3;
                w2 <= 3'd0;
                //Unit 4
                a3 <= fftb_r2;
                b3 <= fftb_i2;
                c3 <= fftb_r3;
                d3 <= fftb_i3;
                w3 <= 3'd0;
                //Unit 5
                a4 <= ffta_r4;
                b4 <= ffta_i4;
                c4 <= ffta_r5;
                d4 <= ffta_i5;
                w4 <= 3'd0;
                //Unit 6
                a5 <= fftb_r4;
                b5 <= fftb_i4;
                c5 <= fftb_r5;
                d5 <= fftb_i5;
                w5 <= 3'd0;
                //Unit 7
                a6 <= ffta_r6;
                b6 <= ffta_i6;
                c6 <= ffta_r7;
                d6 <= ffta_i7;
                w6 <= 3'd0;
                //Unit 8
                a7 <= fftb_r6;
                b7 <= fftb_i6;
                c7 <= fftb_r7;
                d7 <= fftb_i7;
                w7 <= 3'd0;
            end
            OUTPUT_R: begin
                if(fir_valid) x4 <= fir_d;
            end
            OUTPUT_I: begin
                if(fir_valid) x5 <= fir_d;
            end
            default: begin
            end
        endcase
    end
end

assign done = (state == DONE) ? 1'b1 : 1'b0;
assign fft_valid = (state == OUTPUT_I || state == OUTPUT_R) ? 1'b1 : 1'b0;

//output logic
always @(*)begin
    if(state == OUTPUT_R) begin
            fft_d0 = {ffta_r0[31], ffta_r0[22:8]};
            fft_d1 = {ffta_r4[31], ffta_r4[22:8]};
            fft_d2 = {ffta_r2[31], ffta_r2[22:8]};
            fft_d3 = {ffta_r6[31], ffta_r6[22:8]};
            fft_d4 = {ffta_r1[31], ffta_r1[22:8]};
            fft_d5 = {ffta_r5[31], ffta_r5[22:8]};
            fft_d6 = {ffta_r3[31], ffta_r3[22:8]};
            fft_d7 = {ffta_r7[31], ffta_r7[22:8]};
            fft_d8 = {fftb_r0[31], fftb_r0[22:8]};
            fft_d9 = {fftb_r4[31], fftb_r4[22:8]};
            fft_d10 = {fftb_r2[31], fftb_r2[22:8]};
            fft_d11 = {fftb_r6[31], fftb_r6[22:8]};
            fft_d12 = {fftb_r1[31], fftb_r1[22:8]};
            fft_d13 = {fftb_r5[31], fftb_r5[22:8]};
            fft_d14 = {fftb_r3[31], fftb_r3[22:8]};
            fft_d15 = {fftb_r7[31], fftb_r7[22:8]};        
    end
    else if(state == OUTPUT_I) begin
            fft_d0 = {ffta_i0[31], ffta_i0[22:8]};
            fft_d1 = {ffta_i4[31], ffta_i4[22:8]};
            fft_d2 = {ffta_i2[31], ffta_i2[22:8]};
            fft_d3 = {ffta_i6[31], ffta_i6[22:8]};
            fft_d4 = {ffta_i1[31], ffta_i1[22:8]};
            fft_d5 = {ffta_i5[31], ffta_i5[22:8]};
            fft_d6 = {ffta_i3[31], ffta_i3[22:8]};
            fft_d7 = {ffta_i7[31], ffta_i7[22:8]};
            fft_d8 = {fftb_i0[31], fftb_i0[22:8]};
            fft_d9 = {fftb_i4[31], fftb_i4[22:8]};
            fft_d10 = {fftb_i2[31], fftb_i2[22:8]};
            fft_d11 = {fftb_i6[31], fftb_i6[22:8]};
            fft_d12 = {fftb_i1[31], fftb_i1[22:8]};
            fft_d13 = {fftb_i5[31], fftb_i5[22:8]};
            fft_d14 = {fftb_i3[31], fftb_i3[22:8]};
            fft_d15 = {fftb_i7[31], fftb_i7[22:8]};        
    end else begin
        // default values
        fft_d0 = 16'd0; 
        fft_d1 = 16'd0; 
        fft_d2 = 16'd0; 
        fft_d3 = 16'd0; 
        fft_d4 = 16'd0; 
        fft_d5 = 16'd0; 
        fft_d6 = 16'd0; 
        fft_d7 = 16'd0; 
        fft_d8 = 16'd0; 
        fft_d9 = 16'd0; 
        fft_d10 = 16'd0;
        fft_d11 = 16'd0;
        fft_d12 = 16'd0;
        fft_d13 = 16'd0;
        fft_d14 = 16'd0;
        fft_d15 = 16'd0;
    end
end


endmodule