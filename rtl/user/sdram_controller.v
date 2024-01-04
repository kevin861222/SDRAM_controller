// This controller has READ BURST MODE .
module sdram_controller (
        input   clk,
        input   rst,

        // these signals go directly to the IO pins
        // output  sdram_clk,
        output  sdram_cle,
        output  sdram_cs,
        output  sdram_cas,
        output  sdram_ras,
        output  sdram_we,
        output  sdram_dqm,
        output  [1:0]  sdram_ba,
        output  [12:0] sdram_a,
        // Jiin: split dq into dqi (input) dqo (output)
        // inout [7:0] sdram_dq,
        input   [31:0] sdram_dqi,
        output  [31:0] sdram_dqo,

        // User interface
        // Note: we want to remap addr (see below)
        // input [22:0] addr,       // address to read/write
        input   [22:0] user_addr,   // the address will be remap to addr later
        // [Row addr][Bank addr][Column addr]
        // Bank addr [9:8]
        // Row addr [22:10]
        // Column addr [7:0] 

        input   rw,                 // 1 = write, 0 = read
        input   [31:0] data_in,     // data from a read
        output  [31:0] data_out,    // data for a write
        output  busy,               // controller is busy when high
        input   in_valid,           // pulse high to initiate a read/write
        output  out_valid ,         // pulses high when data from read is valid
        output  out_valid_cache ,   // pulses high when prefrtch a data to cache
        input cache_hit             // 
    );

    // Jiin: SDRAM Timing  3-3-3, i.e. CASL=3, PRE=3, ACT=3
    localparam tCASL            = 13'd2;       // 3T actually
    localparam tPRE             = 13'd2;       // 3T
    localparam tACT             = 13'd2;       // 3T
    localparam tREF             = 13'd6;       // 7T
    localparam tRef_Counter     = 10'd750;     // 

    // MA Map
    // BA (Bank Address) - 9:8
    // RA (Row Address)  - 22:10
    // CA (Col Address)  - 2'b0, 1'b0, <7:0>, 2'b0
    `define BA      9:8
    `define RA      22:10
    `define CA      7:0

    // Address Remap
    //   - remap user address to addr to create more offpage/onpage cases
    // 
    wire [22:0] addr;
    wire [12:0] Mapped_RA;
    wire [1:0]  Mapped_BA;
    wire [7:0]  Mapped_CA;
    assign Mapped_RA = user_addr[22:10];
    assign Mapped_BA = user_addr[9:8];
    assign Mapped_CA = user_addr[7:0];
    assign addr = {Mapped_RA, Mapped_BA, Mapped_CA};
    // assign addr = user_addr ;

    // Commands for the SDRAM
    localparam CMD_UNSELECTED    = 4'b1000;
    localparam CMD_NOP           = 4'b0111;
    localparam CMD_ACTIVE        = 4'b0011;
    localparam CMD_READ          = 4'b0101;
    localparam CMD_WRITE         = 4'b0100;
    localparam CMD_TERMINATE     = 4'b0110;
    localparam CMD_PRECHARGE     = 4'b0010;
    localparam CMD_REFRESH       = 4'b0001;
    localparam CMD_LOAD_MODE_REG = 4'b0000;
    
    localparam STATE_SIZE = 4;
    localparam INIT = 4'd0,
               WAIT = 4'd1,
               PRECHARGE_INIT = 4'd2,
               REFRESH_INIT_1 = 4'd3,
               REFRESH_INIT_2 = 4'd4,
               LOAD_MODE_REG = 4'd5,
               IDLE = 4'd6,
               REFRESH = 4'd7,
               ACTIVATE = 4'd8,
               // only read data.
               READ = 4'd9,

               // only output the data.
               READ_RES = 4'd10,
               
               WRITE = 4'd11,
               PRECHARGE = 4'd12 , 

               // read and also output the data.
               READ_and_Output = 4'd13 ,
               READ_and_Output_to_cache = 4'd14 ;
    
    // registers for SDRAM signals
    reg cle_d, cle_q;
    reg dqm_q, dqm_d;
    reg [3:0] cmd_d, cmd_q;
    reg [1:0] ba_d, ba_q;
    reg [12:0] a_d, a_q;
    reg [31:0] dq_d, dq_q;
    reg [31:0] dqi_d, dqi_q;
    reg dq_en_d, dq_en_q;

    // Output assignments
    assign sdram_cle = cle_q;
    assign sdram_cs = cmd_q[3];
    assign sdram_ras = cmd_q[2];
    assign sdram_cas = cmd_q[1];
    assign sdram_we = cmd_q[0];
    assign sdram_dqm = dqm_q;
    assign sdram_ba = ba_q;
    assign sdram_a = a_q;
    // assign sdram_dqi = dq_en_q ? dq_q : 8'hZZ; // only drive when dq_en_q is 1
    assign sdram_dqo = dq_en_q ? dq_q : 32'hZZZZZZZZ;

    reg [STATE_SIZE-1:0] state_d, state_q;
    reg [STATE_SIZE-1:0] next_state_d, next_state_q;

    reg [22:0] addr_d, addr_q;
    reg [31:0] data_d, data_q;
    reg out_valid_d, out_valid_q;
    reg out_valid_cache_d, out_valid_cache_q ;
    assign out_valid_cache = out_valid_cache_q ;

    reg [15:0] delay_ctr_d, delay_ctr_q;

    reg [9:0] refresh_ctr_d, refresh_ctr_q;
    reg refresh_flag_d, refresh_flag_q;

    reg ready_d, ready_q;
    reg saved_rw_d, saved_rw_q;
    reg [22:0] saved_addr_d, saved_addr_q;
    reg [31:0] saved_data_d, saved_data_q;

    reg rw_op_d, rw_op_q;

    reg [3:0] row_open_d, row_open_q;
    reg [12:0] row_addr_d[3:0], row_addr_q[3:0];

    reg [2:0] burst_read_count_d , burst_read_count_q ;
    reg [7:0] origin_plus_id ;

    reg [2:0] precharge_bank_d, precharge_bank_q;
    integer i;

    reg burst_read_mode ;

    assign data_out = data_q;
    assign busy = !ready_q;
    assign out_valid = out_valid_q & ~cache_hit ;
    
    always @* begin
        // Default values
        dq_d = dq_q;
        dqi_d = sdram_dqi;
        dq_en_d = 1'b0; // normally keep the bus in high-Z
        cle_d = cle_q;
        cmd_d = CMD_NOP; // default to NOP
        dqm_d = 1'b0;
        ba_d = 2'd0;
        a_d = 13'd0;
        state_d = state_q;
        next_state_d = next_state_q;
        delay_ctr_d = delay_ctr_q;
        addr_d = addr_q;
        data_d = data_q;
        out_valid_d = 1'b0;
        out_valid_cache_d = 1'b0 ;
        precharge_bank_d = precharge_bank_q;
        rw_op_d = rw_op_q;

        row_open_d = row_open_q;

        // row_addr is a 2d array and must be coppied this way
        for (i = 0; i < 4; i = i + 1)
            row_addr_d[i] = row_addr_q[i];

        // The data in the SDRAM must be refreshed periodically.
        // This conter ensures that the data remains intact.
        refresh_flag_d = refresh_flag_q;
        refresh_ctr_d = refresh_ctr_q + 1'b1;
        // Jiin : refresh_counter tRef_Counter
        // if (refresh_ctr_q > 10'd750) begin
        if (refresh_ctr_q > tRef_Counter) begin
            refresh_ctr_d = 10'd0;
            refresh_flag_d = 1'b1;
        end


        // This is a queue of 1 for read/write operations.
        // When the queue is empty we aren't busy and can
        // accept another request.
        saved_rw_d = saved_rw_q;
        saved_data_d = saved_data_q;
        saved_addr_d = saved_addr_q;
        ready_d = ready_q;
        if (ready_q && in_valid) begin // ( !busy && in_valid )
            saved_rw_d = rw;
            saved_data_d = data_in;
            saved_addr_d = addr;
            ready_d = 1'b0;
        end 

        case (state_q)
            ///// INITALIZATION /////
            INIT: begin
                // ready_d = 1'b0;
                row_open_d = 4'b0;
                out_valid_d = 1'b0;
                // a_d = 13'b0;
                // Reserved, Burst Access, Standard Op, CAS = 2, Sequential, Burst = 4
                a_d = {3'b000, 1'b0, 2'b00, 3'b010, 1'b0, 3'b010}; //010
                ba_d = 2'b0;
                cle_d = 1'b1;
                state_d = WAIT;
                // Note: Jiin - We can skip the power-up sequence & LMR
                // directly jump to IDLE state
                // Power-up Sequence
                // 1. wait for power-up sequence, cmd - NOP or INHIBIT
                // 2. precharge all
                // 3. 2 x Auto-refresh

                // delay_ctr_d = 16'd10100; // wait for 101us
                // next_state_d = PRECHARGE_INIT;

                delay_ctr_d = 16'd0;
                // delay_ctr_d = 16'd1;
                next_state_d = IDLE;
                refresh_flag_d = 1'b0;
                refresh_ctr_d = 10'b1;
                ready_d = 1'b1;

                dq_en_d = 1'b0;
            end
            WAIT: begin
                delay_ctr_d = delay_ctr_q - 1'b1;
                if (delay_ctr_q == 13'd0) begin
                    state_d = next_state_q;
                    // if (next_state_q == WRITE) begin
                    //     dq_en_d = 1'b1; // enable the bus early
                    //     dq_d = data_q[7:0];
                    // end
                end
            end

            ///// IDLE STATE /////
            IDLE: begin
                if (refresh_flag_q) begin // we need to do a refresh
                    state_d = PRECHARGE;
                    next_state_d = REFRESH;
                    precharge_bank_d = 3'b100; // all banks
                    refresh_flag_d = 1'b0; // clear the refresh flag
                end else if (!ready_q) begin // operation waiting
                    ready_d = 1'b1; // clear the queue
                    rw_op_d = saved_rw_q; // save the values we'll need later
                    addr_d = saved_addr_q;

                    if (saved_rw_q) // Write
                        data_d = saved_data_q;

                    // if the row is open we don't have to activate it
                    if (row_open_q[saved_addr_q[9:8]]) begin
                        if (row_addr_q[saved_addr_q[9:8]] == saved_addr_q[22:10]) begin
                            // Row is already open
                            if (saved_rw_q) begin
                                state_d = WRITE;
                            end else begin
                                if (~cache_hit) begin
                                    state_d = READ;
                                    burst_read_mode = (user_addr[8]||user_addr[9]); // only burst for code addr
                                    // ready_d = 1'b0; if burst , should keep the busy signal.
                                    burst_read_count_d = 3'd0 ;
                                end else begin
                                    state_d = IDLE ;
                                end
                            end
                        end else begin
                            if (~cache_hit) begin // 淳不要罵我，我之後會來改這邊的code
                            // A different row in the bank is open
                                state_d = PRECHARGE; // precharge open row
                                precharge_bank_d = {1'b0, saved_addr_q[9:8]};
                                next_state_d = ACTIVATE; // open current row
                            end else begin
                                state_d = IDLE;
                            end
                        end
                    end else begin
                        // no rows open
                        state_d = ACTIVATE; // open the row
                    end
                end
            end

            ///// REFRESH /////
            REFRESH: begin
                cmd_d = CMD_REFRESH;
                state_d = WAIT;

                // Jiin
                // delay_ctr_d = 13'd6; // gotta wait 7 clocks (66ns)
                delay_ctr_d = tREF;

                next_state_d = IDLE;
            end

            ///// ACTIVATE /////
            ACTIVATE: begin
                cmd_d = CMD_ACTIVE;
                a_d = addr_q[22:10];
                ba_d = addr_q[9:8];

                // Jiin:
                //      delay_ctr_d = 13'd0;
                delay_ctr_d = tACT;

                state_d = WAIT;

                if (rw_op_q) begin
                    next_state_d = WRITE ; 
                end
                else begin
                    if (~cache_hit) begin
                        next_state_d = READ ;
                        burst_read_mode = (user_addr[8]||user_addr[9]);
                        burst_read_count_d = 3'd0 ;
                    end else begin
                        next_state_d = IDLE ;
                    end
                end

                row_open_d[addr_q[9:8]] = 1'b1; // row is now open
                row_addr_d[addr_q[9:8]] = addr_q[22:10];
            end

            ///// READ /////
            READ: begin
                cmd_d = CMD_READ;
                origin_plus_id = addr_q[7:0]+ 4*burst_read_count_q ;
                a_d = {2'b0, 1'b0, origin_plus_id , 2'b0};
                ba_d = addr_q[9:8];
                // state_d = WAIT;
                burst_read_count_d = burst_read_count_q + 1'd1 ;

                // Jiin
                // delay_ctr_d = 13'd2; // wait for the data to show up
                if (~burst_read_mode) begin
                    delay_ctr_d = tCASL; 
                    next_state_d = READ_RES;
                    state_d = WAIT;
                end else if (burst_read_count_d ==3'd4) begin 
                    // next_state_d = READ_RES;
                    state_d = READ_and_Output ;
                end else begin
                    // next_state_d = READ ;
                    state_d = READ ;
                end

            end
            READ_and_Output : begin
                // output the data.
                out_valid_d = 1'b1 ;
                out_valid_cache_d = 1'b1;
                data_d = dqi_q; // data_d by pass

                cmd_d = CMD_READ;
                origin_plus_id = addr_q[7:0]+ 4*burst_read_count_q ;
                a_d = {2'b0, 1'b0, origin_plus_id , 2'b0};
                ba_d = addr_q[9:8];
                state_d = READ_and_Output_to_cache;
                burst_read_count_d = burst_read_count_q + 1'd1 ;

                // Jiin
                // delay_ctr_d = 13'd2; // wait for the data to show up
                // delay_ctr_d = 3 ;// tCASL; 
                
                // if (burst_read_count_d ==3'd0) begin 
                //     next_state_d = IDLE ;
                //     state_d = READ_RES ;
                // end else begin
                //     // next_state_d = READ ;
                //     state_d = READ_and_Output ;
                // end
            end

            READ_and_Output_to_cache : begin
                // output the data.
                // out_valid_d = 1'b0 ;
                out_valid_cache_d = 1'b1 ;
                data_d = dqi_q; // data_d by pass

                cmd_d = CMD_READ;
                origin_plus_id = addr_q[7:0]+ 4*burst_read_count_q ;
                a_d = {2'b0, 1'b0, origin_plus_id , 2'b0};
                ba_d = addr_q[9:8];
                // state_d = WAIT;
                burst_read_count_d = burst_read_count_q + 1'd1 ;

                // Jiin
                // delay_ctr_d = 13'd2; // wait for the data to show up
                delay_ctr_d = 3 ;// tCASL; 
                
                if (burst_read_count_d ==3'd0) begin 
                    next_state_d = IDLE ;
                    state_d = READ_RES ;
                end else begin
                    // next_state_d = READ ;
                    state_d = READ_and_Output_to_cache ;
                end
            end

            READ_RES: begin
                if (burst_read_mode) begin
                    delay_ctr_d = delay_ctr_q - 1'b1 ;
                    if (delay_ctr_q == 13'd0) begin
                        state_d = next_state_q;
                        // if (next_state_q == WRITE) begin
                        //     dq_en_d = 1'b1; // enable the bus early
                        //     dq_d = data_q[7:0];
                        // end
                    end
                end else begin
                    state_d = IDLE ;
                end
                data_d = dqi_q; // data_d by pass
                out_valid_cache_d = burst_read_mode;
                out_valid_d = ~burst_read_mode;
                // state_d = READ_RES_second_cycle;
            end

            ///// WRITE /////
            WRITE: begin
                cmd_d = CMD_WRITE;

                dq_d = data_q;
                // data_d = data_q;
                dq_en_d = 1'b1; // enable out bus
                a_d = {2'b0, 1'b0, addr_q[7:0], 2'b00};
                ba_d = addr_q[9:8];

                state_d = IDLE;
            end

            ///// PRECHARGE /////
            PRECHARGE: begin
                cmd_d = CMD_PRECHARGE;
                a_d[10] = precharge_bank_q[2]; // all banks
                ba_d = precharge_bank_q[1:0];
                state_d = WAIT;

                // Jiin
                // delay_ctr_d = 13'd0;
                delay_ctr_d = tPRE;

                if (precharge_bank_q[2]) begin
                    row_open_d = 4'b0000; // closed all rows
                end else begin
                    row_open_d[precharge_bank_q[1:0]] = 1'b0; // closed one row
                end
            end

            default: state_d = INIT;
        endcase
    end

    always @(posedge clk) begin
        if(rst) begin
            cle_q <= 1'b0;
            dq_en_q <= 1'b0;
            state_q <= INIT;
            ready_q <= 1'b0;
        end else begin
            cle_q <= cle_d;
            dq_en_q <= dq_en_d;
            state_q <= state_d;
            ready_q <= ready_d;
        end

        saved_rw_q <= saved_rw_d;
        saved_data_q <= saved_data_d;
        saved_addr_q <= saved_addr_d;

        cmd_q <= cmd_d;
        dqm_q <= dqm_d;
        ba_q <= ba_d;
        a_q <= a_d;
        dq_q <= dq_d;
        dqi_q <= dqi_d;

        burst_read_count_q <= burst_read_count_d ;

        next_state_q <= next_state_d;
        refresh_flag_q <= refresh_flag_d;
        refresh_ctr_q <= refresh_ctr_d;
        data_q <= data_d;
        addr_q <= addr_d;
        out_valid_q <= out_valid_d ; 
        out_valid_cache_q <= out_valid_cache_d ;
        row_open_q <= row_open_d;
        for (i = 0; i < 4; i = i + 1)
            row_addr_q[i] <= row_addr_d[i];
        precharge_bank_q <= precharge_bank_d;
        rw_op_q <= rw_op_d;
        delay_ctr_q <= delay_ctr_d;
    end

endmodule