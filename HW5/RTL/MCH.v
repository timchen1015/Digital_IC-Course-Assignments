module MCH (
    input               clk,
    input               reset,
    input               [ 7:0]  X,
    input               [ 7:0]  Y,
    output               Done,
    output reg          [16:0]  area
);

parameter READ = 4'd0, INIT0 = 4'd1, CROSS_JUDGE = 4'd2, CROSS = 4'd3, INIT1 = 4'd4, SCAN_JUDGE = 4'd5, SCAN = 4'd6, INIT2 = 4'd7, CALC_AREA = 4'd8, PREPARE_OUTPUT = 4'd9, DONE = 4'd10, CROSS_COLLINEAR = 4'd11;
reg [3:0] state, next_state;
reg [4:0] input_cnt, sort_boundary_cnt, sort_cnt, stack_cnt, area_cnt;
reg [7:0] X_buffer [0:19];
reg [7:0] Y_buffer [0:19];
reg [7:0] X_stack [0:19];
reg [7:0] Y_stack [0:19];
reg [7:0] x [0:2];
reg [7:0] y [0:2];
reg [8:0] dx1, dy1, dx2, dy2; //for collinear judge

reg signed  [ 8:0]  Vx, Vy, Wx, Wy;
reg signed  [17:0]  VxWy, WxVy;
reg signed  [18:0]  VxWy_WxVy;
reg signed  [21:0]  total_area;

always @(posedge clk or posedge reset) begin
    if (reset) begin
        state <= READ;
    end else begin
        state <= next_state;
    end
end

always @(*) begin
    case (state)
        READ: next_state = (input_cnt == 5'd19) ? INIT0 : READ;
        INIT0: next_state = CROSS_JUDGE;
        CROSS_JUDGE: begin
            if(VxWy_WxVy == 0) next_state = CROSS_COLLINEAR; 
            else next_state = (sort_boundary_cnt == 5'd20) ? INIT1 : CROSS;
        end
        CROSS: next_state = CROSS_JUDGE;
        CROSS_COLLINEAR: next_state = (sort_boundary_cnt == 5'd20) ? INIT1 : CROSS;
        INIT1: next_state = SCAN_JUDGE;
        SCAN_JUDGE: next_state = (sort_boundary_cnt == 5'd20) ? INIT2 : SCAN;
        SCAN: next_state = SCAN_JUDGE;
        INIT2: next_state = CALC_AREA;
        CALC_AREA: next_state = (area_cnt == stack_cnt + 5'd1) ? PREPARE_OUTPUT : CALC_AREA;
        PREPARE_OUTPUT: next_state = DONE;
        DONE: next_state = READ;
        default: next_state = READ;
    endcase
end

integer i;
always @(posedge clk or posedge reset) begin
    if (reset) begin
        input_cnt <= 5'd0;
        sort_boundary_cnt <= 5'd2;
        sort_cnt <= 5'd2; 
        stack_cnt <= 5'd0;
        area_cnt <= 5'd1;
        total_area <= 22'd0;
        for (i = 0; i < 20; i = i + 1) begin
            X_buffer[i] <= 8'd0;
            Y_buffer[i] <= 8'd0;
            X_stack[i] <= 8'd0;
            Y_stack[i] <= 8'd0;
        end
    end else begin
        case (state)
            READ: begin                         //read inputs and find anchor point
                input_cnt <= input_cnt + 5'd1;
                if(input_cnt == 5'd0) begin
                    X_buffer[0] <= X;
                    Y_buffer[0] <= Y;
                end 
                else if(Y < Y_buffer[0] || (Y == Y_buffer[0] && X < X_buffer[0])) begin
                    X_buffer[0] <= X;
                    Y_buffer[0] <= Y;
                    X_buffer[input_cnt] <= X_buffer[0];
                    Y_buffer[input_cnt] <= Y_buffer[0];
                end
                else begin
                    X_buffer[input_cnt] <= X;
                    Y_buffer[input_cnt] <= Y;
                end
            end
            INIT0: begin
                x[0] <= X_buffer[0];
                y[0] <= Y_buffer[0];
                x[1] <= X_buffer[1];
                y[1] <= Y_buffer[1];
                x[2] <= X_buffer[2];
                y[2] <= Y_buffer[2];
            end
            CROSS_JUDGE: begin
                if(sort_boundary_cnt != 5'd20) begin
                    if(VxWy_WxVy < 0) begin             //swap
                        X_buffer[sort_cnt] <= X_buffer[sort_cnt - 1];
                        Y_buffer[sort_cnt] <= Y_buffer[sort_cnt - 1];
                        X_buffer[sort_cnt - 1] <= X_buffer[sort_cnt];
                        Y_buffer[sort_cnt - 1] <= Y_buffer[sort_cnt];
                        if(sort_cnt == 5'd2) begin
                            sort_boundary_cnt <= sort_boundary_cnt + 5'd1;
                            sort_cnt <= sort_boundary_cnt + 5'd1;
                        end
                        else begin
                            sort_cnt <= sort_cnt - 5'd1;
                        end
                    end
                    else if(VxWy_WxVy == 0) begin     //compare distance
                        dx1 = (X_buffer[sort_cnt-1] > X_buffer[0]) ?  (X_buffer[sort_cnt-1] - X_buffer[0]) : (X_buffer[0] - X_buffer[sort_cnt-1]);
                        dy1 = (Y_buffer[sort_cnt-1] > Y_buffer[0]) ?  (Y_buffer[sort_cnt-1] - Y_buffer[0]) : (Y_buffer[0] - Y_buffer[sort_cnt-1]);
                        dx2 = (X_buffer[sort_cnt] > X_buffer[0]) ?  (X_buffer[sort_cnt] - X_buffer[0]) : (X_buffer[0] - X_buffer[sort_cnt]);
                        dy2 = (Y_buffer[sort_cnt] > Y_buffer[0]) ?  (Y_buffer[sort_cnt] - Y_buffer[0]) : (Y_buffer[0] - Y_buffer[sort_cnt]);
                    end
                    else begin                        
                        sort_boundary_cnt <= sort_boundary_cnt + 5'd1;
                        sort_cnt <= sort_boundary_cnt + 5'd1;
                    end
                end
            end
            CROSS: begin
                x[1] <= X_buffer[sort_cnt - 1];
                y[1] <= Y_buffer[sort_cnt - 1];
                x[2] <= X_buffer[sort_cnt];
                y[2] <= Y_buffer[sort_cnt];
            end
            CROSS_COLLINEAR: begin
                if(dx1 + dy1 > dx2 + dy2) begin             //swap
                    X_buffer[sort_cnt] <= X_buffer[sort_cnt - 1];
                    Y_buffer[sort_cnt] <= Y_buffer[sort_cnt - 1];
                    X_buffer[sort_cnt - 1] <= X_buffer[sort_cnt];
                    Y_buffer[sort_cnt - 1] <= Y_buffer[sort_cnt];
                    if(sort_cnt == 5'd2) begin
                        sort_boundary_cnt <= sort_boundary_cnt + 5'd1;
                        sort_cnt <= sort_boundary_cnt + 5'd1;
                    end
                    else begin
                        sort_cnt <= sort_cnt - 5'd1;
                    end
                end
                else begin
                    sort_boundary_cnt <= sort_boundary_cnt + 5'd1;
                    sort_cnt <= sort_boundary_cnt + 5'd1; 
                end
            end
            INIT1: begin
                x[0] <=  X_buffer[0];
                y[0] <=  Y_buffer[0];
                x[1] <=  X_buffer[1];
                y[1] <=  Y_buffer[1];
                x[2] <=  X_buffer[2];
                y[2] <=  Y_buffer[2];

                X_stack[0] <= X_buffer[0];
                Y_stack[0] <= Y_buffer[0];
                X_stack[1] <= X_buffer[1];
                Y_stack[1] <= Y_buffer[1];
                stack_cnt <= 5'd1;
                sort_boundary_cnt <= 5'd2;
            end
            SCAN_JUDGE: begin
                if(sort_boundary_cnt < 5'd20) begin
                    if(VxWy_WxVy <= 19'sd0) begin            //right or collinear -> pop stack
                        if(stack_cnt == 5'd1) begin         //last point in stack
                            X_stack[1] <= X_buffer[sort_boundary_cnt];
                            Y_stack[1] <= Y_buffer[sort_boundary_cnt];
                            sort_boundary_cnt <= sort_boundary_cnt + 5'd1;
                        end
                        else begin
                            stack_cnt <= stack_cnt - 5'd1;
                        end    
                    end
                    else begin
                        X_stack[stack_cnt + 1] <= X_buffer[sort_boundary_cnt];
                        Y_stack[stack_cnt + 1] <= Y_buffer[sort_boundary_cnt];
                        stack_cnt <= stack_cnt + 5'd1;
                        sort_boundary_cnt <= sort_boundary_cnt + 5'd1;
                    end
                end
            end
            SCAN: begin
                x[0] <= X_stack[stack_cnt - 1];
                y[0] <= Y_stack[stack_cnt - 1];
                x[1] <= X_stack[stack_cnt];
                y[1] <= Y_stack[stack_cnt];
                x[2] <= X_buffer[sort_boundary_cnt];
                y[2] <= Y_buffer[sort_boundary_cnt];
            end
            INIT2: begin
                x[0] <= 8'd0;
                y[0] <= 8'd0;
                x[1] <= X_stack[0];
                y[1] <= Y_stack[0];
                x[2] <= X_stack[1];
                y[2] <= Y_stack[1];
                total_area <= 22'd0;       
            end
            CALC_AREA: begin
                total_area <= total_area + VxWy_WxVy;
                area_cnt <= area_cnt + 5'd1;
                x[1] <= X_stack[area_cnt];
                y[1] <= Y_stack[area_cnt];
                if(area_cnt == stack_cnt) begin
                    x[2] <= X_stack[0];
                    y[2] <= Y_stack[0];
                end
                else begin
                    x[2] <= X_stack[area_cnt + 1];
                    y[2] <= Y_stack[area_cnt + 1];
                end

            end
            DONE: begin
                input_cnt <= 5'd0;
                sort_boundary_cnt <= 5'd2;
                sort_cnt <= 5'd2; 
                stack_cnt <= 5'd0;
                area_cnt <= 5'd1;
                for (i = 0; i < 20; i = i + 1) begin
                    X_buffer[i] <= 8'd0;
                    Y_buffer[i] <= 8'd0;
                    X_stack[i] <= 8'd0;
                    Y_stack[i] <= 8'd0;
                end
            end
        endcase
    end
end

always @(*) begin
    Vx = {1'b0, x[1]} - {1'b0, x[0]};
    Vy = {1'b0, y[1]} - {1'b0, y[0]};
    Wx = {1'b0, x[2]} - {1'b0, x[0]};
    Wy = {1'b0, y[2]} - {1'b0, y[0]};
    VxWy = Vx * Wy;
    WxVy = Wx * Vy;
    VxWy_WxVy = VxWy - WxVy;
end


always @(*) begin
    if(state == DONE || state == PREPARE_OUTPUT) area = total_area[16:0];
    else area = 17'd0;
end
assign Done = (state == DONE) ? 1'b1 : 1'b0;

endmodule