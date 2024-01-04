

module code_cache
(
    input clk ,
    input rst , 
    input [22:0] user_addr ,

    input rw ,
    input in_valid ,

    input data_in_valid ,
    input [31:0] data_in ,

    output hit ,
    output reg out_valid ,
    output reg [31:0] data_out
);

// If address belong to 0x3800_0100~0x3800_03FF
// Then miss.

reg [31:0] cache [0:8] [0:7] ;
reg hit_array [0:8] [0:7] ;
reg hit_q , hit_d ;
reg miss ;
reg output_flag_d , output_flag_q ; 

reg save_state_d , save_state_q ;
reg output_state_d , output_state_q ;
reg [3:0] origin , origin_d ;
reg [2:0] offset , offset_d ;


reg [2:0] prefetch_count ;
always @(posedge clk) begin
    if (rst) begin
        prefetch_count <= 0 ; 
    end else begin
        prefetch_count <= prefetch_count + data_in_valid ;
    end
end
/*
origin (column)
 DC:Dont care                                  DC
 user_addr                                [ 09 | 08 | 07 | 06 | 05 ]
0x3800_0100 --> 100 --> 0001_0000_0000  -->  0    1    0    0    0  --> 0
0x3800_0120 --> 120 --> 0001_0010_0000  -->  0    1    0    0    1  --> 1
0x3800_0140 --> 140 --> 0001_0100_0000  -->  0    1    0    1    0  --> 2
0x3800_0160 --> 160 --> 0001_0110_0000  -->  0    1    0    1    1  --> 3
0x3800_0180 --> 180 --> 0001_1000_0000  -->  0    1    1    0    0  --> 4
0x3800_01A0 --> 1A0 --> 0001_1010_0000  -->  0    1    1    0    1  --> 5
0x3800_01C0 --> 1C0 --> 0001_1100_0000  -->  0    1    1    1    0  --> 6
0x3800_01E0 --> 1E0 --> 0001_1110_0000  -->  0    1    1    1    1  --> 7
0x3800_0200 --> 200 --> 0010_0000_0000  -->  1    0    0    0    0  --> 8

offset (row)
          [ 4 | 3 | 2 ]
 0x00   --> 0   0   0
 0x04   --> 0   0   1
 0x08   --> 0   1   0
 0x0C   --> 0   1   1
 0x10   --> 1   0   0
 0x14   --> 1   0   1   
 0x18   --> 1   1   0
 0x1C   --> 1   1   1
*/



// save data
localparam IDLE = 1'd0 ;
localparam SAVING = 1'd1 ;
always @(posedge clk) begin
    if (rst) begin
        save_state_q <= IDLE ;
    end else begin
        save_state_q <= save_state_d ;
    end
end
always @(*) begin
    case (save_state_q)
        IDLE: begin
            save_state_d = (miss) ? SAVING : IDLE ;
        end
        SAVING : begin
            save_state_d = (prefetch_count==3'd7) ? IDLE : SAVING ;
        end
        default: save_state_d = (miss) ? SAVING : IDLE ;
    endcase
end
integer i , j ;
always @(posedge clk) begin
    if (rst) begin
        for ( i = 0; i<9 ; i=i+1 ) begin
            for ( j = 0 ; j<8 ; j=j+1 ) begin
                hit_array [i][j] <= 1'b0 ;
            end
        end
    end 
    /* if cache miss */
    else begin
        case (save_state_q)
            IDLE: begin
                // origin <= {user_addr[9] ,user_addr[7:5]} ;
            end
            SAVING : begin
                if (data_in_valid) begin
                    cache [origin][prefetch_count] <= data_in ;
                    hit_array [origin][prefetch_count] <= 1'd1 ;
                end
            end
            default: begin
                // origin <= {user_addr[9] ,user_addr[7:5]} ;
            end
        endcase
    end
end

// Output data to WB
// localparam IDLE = 1'b0 ; 
localparam OUTPUT_STATE = 1'b1 ;
always @(posedge clk) begin
    if (rst) begin
        output_state_q <= IDLE ;
    end else begin
        output_state_q <= output_state_d ;
    end
end
always @(*) begin
    case (output_state_q)
        IDLE: begin
            if (output_flag_d) begin
                output_state_d = IDLE ;
            end else begin
                output_state_d = (hit_d) ? (OUTPUT_STATE) : (IDLE) ;
            end
        end
        OUTPUT_STATE : begin
            output_state_d = IDLE ;
        end
        default: begin
            if (output_flag_d) begin
                output_state_d = IDLE ;
            end else begin
                output_state_d = (hit_d) ? (OUTPUT_STATE) : (IDLE) ;
            end
        end
    endcase
end
always @(*) begin
    out_valid = output_state_q ;
    data_out = (out_valid)? (cache [origin] [offset]) : 0 ; 
end

always @(*) begin 
    if (rst) begin
        hit_d = 0 ;
        origin = 0 ;
        offset = 0 ;
    end else begin
        if ( (~rw) & in_valid) begin
            origin = {user_addr[9] , user_addr[7:5]} ;
            offset = user_addr[4:2] ;
        end else begin
            origin = origin_d ;
            offset = offset_d ;
        end
        case (save_state_q)
            IDLE: begin
                if ((~rw) & in_valid) begin
                    hit_d = (user_addr[9]|user_addr[8])&(hit_array [origin][offset]) ;
                end else begin
                    hit_d = hit_d ;//(hit_array [origin][offset]) ;//0 ;
                end
            end 
            SAVING : begin
                hit_d = (user_addr[9]|user_addr[8])&(hit_array [origin][offset]) ;
            end
            default: begin
                if ((~rw) & in_valid) begin
                    hit_d = (user_addr[9]|user_addr[8])&(hit_array [origin][offset]) ;
                end else begin
                    hit_d = hit_d; //(hit_array [origin][offset]) ;//0 ;
                end
            end
        endcase
    end
end
always @(posedge clk) begin
    if (rst) begin
        hit_q <= 1'd0 ;
    end else begin
        hit_q <= hit_d ;
    end
end
assign hit = hit_d ;

always @(*) begin
    miss <= (~rw) & in_valid & (~hit_array [origin][offset]) & ~rst & (user_addr[9]|user_addr[8]);
end

always @(posedge clk) begin
    if (rst) begin
        offset_d <= 0 ;
        origin_d <= 0 ;
    end else begin
        if ( (~rw) & in_valid ) begin
            origin_d = {user_addr[9] , user_addr[7:5]} ;
            offset_d = user_addr[4:2] ;
        end
    end
end

/* output flag */
always @(*) begin
    if (rst) begin
        output_flag_d = 0 ; 
    end else begin
        case (output_flag_q)
            /* When cache output a data , flags . */
            0 : output_flag_d = out_valid ;
            /* When a new read request is asserted , remove the output flag . */
            1 : output_flag_d = !((~rw) & in_valid) ;
            default: output_flag_d = out_valid ;
        endcase
    end
end
always @(posedge clk) begin
    if (rst) begin
        output_flag_q <= 0 ;
    end else begin
        output_flag_q <= output_flag_d ;
    end
end

/* for testing only */
wire hit_array_0_0 , hit_array_0_1 , hit_array_0_2 ;
wire [31:0] cache_0_0 , cache_0_1 , cache_0_2 , cache_0_3 , cache_0_4 , cache_0_5 , cache_0_6 , cache_0_7 ;
assign hit_array_0_0 = hit_array [0][0] ;
assign hit_array_0_1 = hit_array [0][1] ;
assign hit_array_0_2 = hit_array [0][2] ;
assign cache_0_0 = cache [0][0] ;
assign cache_0_1 = cache [0][1] ;
assign cache_0_2 = cache [0][2] ;
assign cache_0_3 = cache [0][3] ;
assign cache_0_4 = cache [0][4] ;
assign cache_0_5 = cache [0][5] ;
assign cache_0_6 = cache [0][6] ;
assign cache_0_7 = cache [0][7] ;

endmodule

// Remind to change the end time of TB .