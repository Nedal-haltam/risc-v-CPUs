//------------------------------------------------
// mm_conv3d
`define KW (3)
`define KH (3)
`define KD (3)

(* preserve *) reg `INT_BIT_WIDTH conv3d_addr_input, conv3d_addr_kernel, conv3d_addr_out;
(* preserve *) reg `INT_BIT_WIDTH conv3d_input_width, conv3d_input_height, conv3d_input_depth;
(* preserve *) reg `INT_BIT_WIDTH conv3d_start, conv3d_done;
(* preserve *) reg `INT_BIT_WIDTH conv3d_counter_load_kernel, conv3d_counter_input_feed, conv3d_counter_output_unfeed;

(* preserve *) reg conv3d_dm_p2_en;
(* preserve *) reg [(`DM_BITS-1):0] conv3d_dm_p2_address;
(* preserve *) reg conv3d_dm_p2_wren;
(* preserve *) reg `INT_BIT_WIDTH conv3d_dm_p2_writedata;

(* keep *) wire conv3d_start_set;
(* preserve *) reg conv3d_done_set;
(* keep *) wire conv3d_done_rden;


parameter [4:0] CONV3D_STATE_OFF          = 5'd1;
parameter [4:0] CONV3D_STATE_START        = 5'd2;
parameter [4:0] CONV3D_STATE_READ_KERNEL  = 5'd3;
parameter [4:0] CONV3D_STATE_LOAD_KERNEL  = 5'd4;
parameter [4:0] CONV3D_STATE_INC_OFFSET   = 5'd5;
parameter [4:0] CONV3D_STATE_INPUT_FEED   = 5'd6;
parameter [4:0] CONV3D_STATE_READ_INPUT00 = 5'd7;
parameter [4:0] CONV3D_STATE_LOAD_INPUT00 = 5'd8;
parameter [4:0] CONV3D_STATE_READ_INPUT01 = 5'd9;
parameter [4:0] CONV3D_STATE_LOAD_INPUT01 = 5'd10;
parameter [4:0] CONV3D_STATE_READ_INPUT02 = 5'd11;
parameter [4:0] CONV3D_STATE_LOAD_INPUT02 = 5'd12;
parameter [4:0] CONV3D_STATE_READ_INPUT10 = 5'd13;
parameter [4:0] CONV3D_STATE_LOAD_INPUT10 = 5'd14;
parameter [4:0] CONV3D_STATE_READ_INPUT11 = 5'd15;
parameter [4:0] CONV3D_STATE_LOAD_INPUT11 = 5'd16;
parameter [4:0] CONV3D_STATE_READ_INPUT12 = 5'd17;
parameter [4:0] CONV3D_STATE_LOAD_INPUT12 = 5'd18;
parameter [4:0] CONV3D_STATE_READ_INPUT20 = 5'd19;
parameter [4:0] CONV3D_STATE_LOAD_INPUT20 = 5'd20;
parameter [4:0] CONV3D_STATE_READ_INPUT21 = 5'd21;
parameter [4:0] CONV3D_STATE_LOAD_INPUT21 = 5'd22;
parameter [4:0] CONV3D_STATE_READ_INPUT22 = 5'd23;
parameter [4:0] CONV3D_STATE_LOAD_INPUT22 = 5'd24;
parameter [4:0] CONV3D_STATE_TRIGGER      = 5'd25;
parameter [4:0] CONV3D_STATE_POINT        = 5'd26;
parameter [4:0] CONV3D_STATE_WRITE_BACK   = 5'd27;
parameter [4:0] CONV3D_STATE_FINISHED     = 5'd28;

(* preserve *) reg [4:0] conv3d_state;

(* preserve *) reg `INT_BIT_WIDTH Dim0Input00Lane0;
(* preserve *) reg `INT_BIT_WIDTH Dim0Input01Lane0;
(* preserve *) reg `INT_BIT_WIDTH Dim0Input02Lane0;
(* preserve *) reg `INT_BIT_WIDTH Dim0Input10Lane0;
(* preserve *) reg `INT_BIT_WIDTH Dim0Input11Lane0;
(* preserve *) reg `INT_BIT_WIDTH Dim0Input12Lane0;
(* preserve *) reg `INT_BIT_WIDTH Dim0Input20Lane0;
(* preserve *) reg `INT_BIT_WIDTH Dim0Input21Lane0;
(* preserve *) reg `INT_BIT_WIDTH Dim0Input22Lane0;

(* preserve *) reg `INT_BIT_WIDTH InternalRegisterEnableIndex;
(* preserve *) reg `INT_BIT_WIDTH InternalRegisterInputValue0;
(* keep *) wire `INT_BIT_WIDTH SystolicOutput0;
(* keep *) wire `INT_BIT_WIDTH SystolicOutput1;
(* keep *) wire `INT_BIT_WIDTH SystolicOutput2;
(* keep *) wire `INT_BIT_WIDTH w;
(* keep *) wire `INT_BIT_WIDTH pw;
(* keep *) wire `INT_BIT_WIDTH h;
(* keep *) wire `INT_BIT_WIDTH ph;
(* keep *) wire `INT_BIT_WIDTH d;
(* keep *) wire `INT_BIT_WIDTH pd;

(* preserve *) reg `INT_BIT_WIDTH conv3d_offset, conv3d_x, depth_offset, index, conv3d_wb_index;
(* preserve *) reg conv3d_trigger;
//------------------------------------------------

// MMIO control circuit
always@(negedge clk or posedge rst) begin
	if (rst) begin
	end
	else begin
		if (`MMIO_wren) begin
			//------------------------------------------------
			// mm_conv3d
            if (`MMIO_CONV3D_addr_input_wren) begin
                conv3d_addr_input <= CPUDataBusOut[`INT_BITS-1:0];
            end
            if (`MMIO_CONV3D_addr_kernel_wren) begin
                conv3d_addr_kernel <= CPUDataBusOut[`INT_BITS-1:0];
            end
            if (`MMIO_CONV3D_addr_out_wren) begin
                conv3d_addr_out <= CPUDataBusOut[`INT_BITS-1:0];
            end
            if (`MMIO_CONV3D_input_width_wren) begin
                conv3d_input_width <= CPUDataBusOut[`INT_BITS-1:0];
            end
            if (`MMIO_CONV3D_input_height_wren) begin
                conv3d_input_height <= CPUDataBusOut[`INT_BITS-1:0];
            end
            if (`MMIO_CONV3D_input_depth_wren) begin
                conv3d_input_depth <= CPUDataBusOut[`INT_BITS-1:0];
            end
		end
	end
end


//----------------------------------------------------------------------------------------
// conv3d_start: reset after set
always@(posedge clk or posedge rst) begin
	if (rst) begin
		conv3d_start <= 0;
	end
	else if (conv3d_start_set) begin
		conv3d_start <= 1;
	end
	else if (conv3d_start == 1) begin
		conv3d_start <= 0;
	end
end

// conv3d_done : reset after reading
always@(posedge clk or posedge rst) begin
	if (rst) begin
		conv3d_done <= 0;
	end
	else if (conv3d_done_set) begin
		conv3d_done <= 1;
	end
	else if (conv3d_done_rden) begin
		conv3d_done <= 0;
	end
end

always@(posedge clk or posedge rst) begin
	if (rst) begin
		conv3d_state <= CONV3D_STATE_OFF;
		conv3d_dm_p2_en <= 0;
		conv3d_done_set <= 0;
		conv3d_offset <= 0;
        conv3d_x <= 0;
        depth_offset <= 0;
        index <= 0;
        conv3d_wb_index <= 0;
		conv3d_dm_p2_wren <= 0;
		conv3d_trigger <= 0;
        conv3d_counter_load_kernel <= 0;
        conv3d_counter_input_feed <= 0;
        conv3d_counter_output_unfeed <= 0;

        Dim0Input00Lane0 <= 0;
        Dim0Input01Lane0 <= 0;
        Dim0Input02Lane0 <= 0;
        Dim0Input10Lane0 <= 0;
        Dim0Input11Lane0 <= 0;
        Dim0Input12Lane0 <= 0;
        Dim0Input20Lane0 <= 0;
        Dim0Input21Lane0 <= 0;
        Dim0Input22Lane0 <= 0;

        InternalRegisterEnableIndex <= 0;
		InternalRegisterInputValue0 <= 0;
	end
	else begin
		case(conv3d_state)
			CONV3D_STATE_OFF: begin
                conv3d_dm_p2_en <= 0;
				conv3d_done_set <= 0;
				conv3d_offset <= 0;
                conv3d_x <= 0;
                depth_offset <= 0;
                index <= 0;
                conv3d_wb_index <= 0;
				conv3d_dm_p2_wren <= 0;
				conv3d_trigger <= 0;
				if (conv3d_start == 64'd1) begin
					conv3d_state <= CONV3D_STATE_START;
                    conv3d_counter_load_kernel <= 0;
                    conv3d_counter_input_feed <= 0;
                    conv3d_counter_output_unfeed <= 0;
				end
			end
			CONV3D_STATE_START: begin
                conv3d_dm_p2_en <= 1'b1;
                conv3d_state <= CONV3D_STATE_READ_KERNEL;
			end
//////////////////////////////////////////////
			CONV3D_STATE_READ_KERNEL: begin
                if (conv3d_offset < (`KW * `KH * `KD)) begin
                    conv3d_dm_p2_address <= conv3d_addr_kernel[`DM_BITS-1:0] + (14'd8 * conv3d_offset[`DM_BITS-1:0]);
                    conv3d_counter_load_kernel <= conv3d_counter_load_kernel + 1'b1;
                    conv3d_state <= CONV3D_STATE_LOAD_KERNEL;
                end
                else begin
                    conv3d_offset <= 0;
                    conv3d_state <= CONV3D_STATE_INPUT_FEED;
                end
			end
			CONV3D_STATE_LOAD_KERNEL: begin
				InternalRegisterEnableIndex <= conv3d_offset + 1'b1;
				InternalRegisterInputValue0 <= DMDataBusPort2[`INT_BITS-1:0];
                conv3d_counter_load_kernel <= conv3d_counter_load_kernel + 1'b1;
				conv3d_state <= CONV3D_STATE_INC_OFFSET;
			end
			CONV3D_STATE_INC_OFFSET: begin
				conv3d_offset <= conv3d_offset + 1'b1;
                conv3d_counter_load_kernel <= conv3d_counter_load_kernel + 1'b1;
				conv3d_state <= CONV3D_STATE_READ_KERNEL;
			end
//////////////////////////////////////////////
            CONV3D_STATE_INPUT_FEED: begin
                if (conv3d_offset < ((pd - `KD + 1) * (ph - `KH + 1) * (pw))) begin
                    if (((index) == ((ph - `KH + 1) * (pw)))) begin
                        depth_offset <= depth_offset + 1'b1;
                        index <= 0;
                    end
                    if (conv3d_x == pw) begin
                        conv3d_x <= 0;
                    end
                    conv3d_state <= CONV3D_STATE_READ_INPUT00;
                    conv3d_counter_input_feed <= conv3d_counter_input_feed + 1'b1;
                end
                else begin
                    conv3d_state <= CONV3D_STATE_FINISHED;
                end
            end
//////////////////////////////////////////////
            CONV3D_STATE_READ_INPUT00: begin
                conv3d_dm_p2_address <= conv3d_addr_input[`DM_BITS-1:0] + (14'd8 * (index[`DM_BITS-1:0] +  (14'd0 + depth_offset[`DM_BITS-1:0]) * pw[`DM_BITS-1:0] * ph[`DM_BITS-1:0] + 14'd0 * pw[`DM_BITS-1:0]));
                conv3d_counter_input_feed <= conv3d_counter_input_feed + 1'b1;
                conv3d_state <= CONV3D_STATE_LOAD_INPUT00;
            end
            CONV3D_STATE_LOAD_INPUT00: begin
                Dim0Input00Lane0 <= DMDataBusPort2[`INT_BITS-1:0];
                conv3d_counter_input_feed <= conv3d_counter_input_feed + 1'b1;
                conv3d_state <= CONV3D_STATE_READ_INPUT01;
            end
            CONV3D_STATE_READ_INPUT01: begin
                conv3d_dm_p2_address <= conv3d_addr_input[`DM_BITS-1:0] + (14'd8 * (index[`DM_BITS-1:0] +  (14'd1 + depth_offset[`DM_BITS-1:0]) * pw[`DM_BITS-1:0] * ph[`DM_BITS-1:0] + 14'd0 * pw[`DM_BITS-1:0]));
                conv3d_counter_input_feed <= conv3d_counter_input_feed + 1'b1;
                conv3d_state <= CONV3D_STATE_LOAD_INPUT01;
            end
            CONV3D_STATE_LOAD_INPUT01: begin
                Dim0Input01Lane0 <= DMDataBusPort2[`INT_BITS-1:0];
                conv3d_counter_input_feed <= conv3d_counter_input_feed + 1'b1;
                conv3d_state <= CONV3D_STATE_READ_INPUT02;
            end
            CONV3D_STATE_READ_INPUT02: begin
                conv3d_dm_p2_address <= conv3d_addr_input[`DM_BITS-1:0] + (14'd8 * (index[`DM_BITS-1:0] +  (14'd2 + depth_offset[`DM_BITS-1:0]) * pw[`DM_BITS-1:0] * ph[`DM_BITS-1:0] + 14'd0 * pw[`DM_BITS-1:0]));
                conv3d_counter_input_feed <= conv3d_counter_input_feed + 1'b1;
                conv3d_state <= CONV3D_STATE_LOAD_INPUT02;
            end
            CONV3D_STATE_LOAD_INPUT02: begin
                Dim0Input02Lane0 <= DMDataBusPort2[`INT_BITS-1:0];
                conv3d_counter_input_feed <= conv3d_counter_input_feed + 1'b1;
                conv3d_state <= CONV3D_STATE_READ_INPUT10;
            end
            CONV3D_STATE_READ_INPUT10: begin
                conv3d_dm_p2_address <= conv3d_addr_input[`DM_BITS-1:0] + (14'd8 * (index[`DM_BITS-1:0] +  (14'd0 + depth_offset[`DM_BITS-1:0]) * pw[`DM_BITS-1:0] * ph[`DM_BITS-1:0] + 14'd1 * pw[`DM_BITS-1:0]));
                conv3d_counter_input_feed <= conv3d_counter_input_feed + 1'b1;
                conv3d_state <= CONV3D_STATE_LOAD_INPUT10;
            end
            CONV3D_STATE_LOAD_INPUT10: begin
                Dim0Input10Lane0 <= DMDataBusPort2[`INT_BITS-1:0];
                conv3d_counter_input_feed <= conv3d_counter_input_feed + 1'b1;
                conv3d_state <= CONV3D_STATE_READ_INPUT11;
            end
            CONV3D_STATE_READ_INPUT11: begin
                conv3d_dm_p2_address <= conv3d_addr_input[`DM_BITS-1:0] + (14'd8 * (index[`DM_BITS-1:0] +  (14'd1 + depth_offset[`DM_BITS-1:0]) * pw[`DM_BITS-1:0] * ph[`DM_BITS-1:0] + 14'd1 * pw[`DM_BITS-1:0]));
                conv3d_counter_input_feed <= conv3d_counter_input_feed + 1'b1;
                conv3d_state <= CONV3D_STATE_LOAD_INPUT11;
            end
            CONV3D_STATE_LOAD_INPUT11: begin
                Dim0Input11Lane0 <= DMDataBusPort2[`INT_BITS-1:0];
                conv3d_counter_input_feed <= conv3d_counter_input_feed + 1'b1;
                conv3d_state <= CONV3D_STATE_READ_INPUT12;
            end
            CONV3D_STATE_READ_INPUT12: begin
                conv3d_dm_p2_address <= conv3d_addr_input[`DM_BITS-1:0] + (14'd8 * (index[`DM_BITS-1:0] +  (14'd2 + depth_offset[`DM_BITS-1:0]) * pw[`DM_BITS-1:0] * ph[`DM_BITS-1:0] + 14'd1 * pw[`DM_BITS-1:0]));
                conv3d_counter_input_feed <= conv3d_counter_input_feed + 1'b1;
                conv3d_state <= CONV3D_STATE_LOAD_INPUT12;
            end
            CONV3D_STATE_LOAD_INPUT12: begin
                Dim0Input12Lane0 <= DMDataBusPort2[`INT_BITS-1:0];
                conv3d_counter_input_feed <= conv3d_counter_input_feed + 1'b1;
                conv3d_state <= CONV3D_STATE_READ_INPUT20;
            end
            CONV3D_STATE_READ_INPUT20: begin
                conv3d_dm_p2_address <= conv3d_addr_input[`DM_BITS-1:0] + (14'd8 * (index[`DM_BITS-1:0] +  (14'd0 + depth_offset[`DM_BITS-1:0]) * pw[`DM_BITS-1:0] * ph[`DM_BITS-1:0] + 14'd2 * pw[`DM_BITS-1:0]));
                conv3d_counter_input_feed <= conv3d_counter_input_feed + 1'b1;
                conv3d_state <= CONV3D_STATE_LOAD_INPUT20;
            end
            CONV3D_STATE_LOAD_INPUT20: begin
                Dim0Input20Lane0 <= DMDataBusPort2[`INT_BITS-1:0];
                conv3d_counter_input_feed <= conv3d_counter_input_feed + 1'b1;
                conv3d_state <= CONV3D_STATE_READ_INPUT21;
            end
            CONV3D_STATE_READ_INPUT21: begin
                conv3d_dm_p2_address <= conv3d_addr_input[`DM_BITS-1:0] + (14'd8 * (index[`DM_BITS-1:0] +  (14'd1 + depth_offset[`DM_BITS-1:0]) * pw[`DM_BITS-1:0] * ph[`DM_BITS-1:0] + 14'd2 * pw[`DM_BITS-1:0]));
                conv3d_counter_input_feed <= conv3d_counter_input_feed + 1'b1;
                conv3d_state <= CONV3D_STATE_LOAD_INPUT21;
            end
            CONV3D_STATE_LOAD_INPUT21: begin
                Dim0Input21Lane0 <= DMDataBusPort2[`INT_BITS-1:0];
                conv3d_counter_input_feed <= conv3d_counter_input_feed + 1'b1;
                conv3d_state <= CONV3D_STATE_READ_INPUT22;
            end
            CONV3D_STATE_READ_INPUT22: begin
                conv3d_dm_p2_address <= conv3d_addr_input[`DM_BITS-1:0] + (14'd8 * (index[`DM_BITS-1:0] +  (14'd2 + depth_offset[`DM_BITS-1:0]) * pw[`DM_BITS-1:0] * ph[`DM_BITS-1:0] + 14'd2 * pw[`DM_BITS-1:0]));
                conv3d_counter_input_feed <= conv3d_counter_input_feed + 1'b1;
                conv3d_state <= CONV3D_STATE_LOAD_INPUT22;
            end
            CONV3D_STATE_LOAD_INPUT22: begin
                Dim0Input22Lane0 <= DMDataBusPort2[`INT_BITS-1:0];
                conv3d_counter_input_feed <= conv3d_counter_input_feed + 1'b1;
                conv3d_state <= CONV3D_STATE_TRIGGER;
            end
//////////////////////////////////////////////
            CONV3D_STATE_TRIGGER: begin
                if (!conv3d_trigger) begin
                    conv3d_trigger <= 1'b1;
                    conv3d_state <= CONV3D_STATE_TRIGGER;
                end
                else begin
                    conv3d_trigger <= 0;
                    conv3d_offset <= conv3d_offset + 1'b1;
                    conv3d_x <= conv3d_x + 1'b1;
                    index <= index + 1'b1;
                    conv3d_state <= CONV3D_STATE_POINT;
                end
            end
            CONV3D_STATE_POINT: begin
                if (conv3d_x >= `KW) begin
                    conv3d_state <= CONV3D_STATE_WRITE_BACK;
                end
                else begin
                    conv3d_state <= CONV3D_STATE_INPUT_FEED;
                end
            end
            CONV3D_STATE_WRITE_BACK: begin
                if (!conv3d_dm_p2_wren) begin
					conv3d_dm_p2_address <= conv3d_addr_out[`DM_BITS-1:0] + (14'd8 * conv3d_wb_index[`DM_BITS-1:0]);
					conv3d_dm_p2_wren <= 1'b1;
					conv3d_dm_p2_writedata <= SystolicOutput0;
                    conv3d_counter_output_unfeed <= conv3d_counter_output_unfeed + 1'b1;
					conv3d_state <= CONV3D_STATE_WRITE_BACK;
                end
                else begin
					conv3d_dm_p2_wren <= 0;
                    conv3d_wb_index <= conv3d_wb_index + 1'b1;
                    conv3d_state <= CONV3D_STATE_INPUT_FEED;
                end
            end
            CONV3D_STATE_FINISHED: begin
                conv3d_done_set <= 1'b1;
                conv3d_dm_p2_en <= 1'b0;
                conv3d_state <= CONV3D_STATE_OFF;
            end
//////////////////////////////////////////////
		endcase
	end
end
assign conv3d_done_rden = `MMIO_CONV3D_done_rden;
assign conv3d_start_set = `MMIO_CONV3D_start_wren && (CPUDataBusOut == 64'd1);


(* noprune *) SystolicArray_conv3d SystolicArray_conv3d_dut
(
    .clk(clk),
	.rst(rst),
	.trigger(conv3d_trigger)

    ,.Dim0Input00Lane0(Dim0Input00Lane0)
    ,.Dim0Input01Lane0(Dim0Input01Lane0)
    ,.Dim0Input02Lane0(Dim0Input02Lane0)
    ,.Dim0Input10Lane0(Dim0Input10Lane0)
    ,.Dim0Input11Lane0(Dim0Input11Lane0)
    ,.Dim0Input12Lane0(Dim0Input12Lane0)
    ,.Dim0Input20Lane0(Dim0Input20Lane0)
    ,.Dim0Input21Lane0(Dim0Input21Lane0)
    ,.Dim0Input22Lane0(Dim0Input22Lane0)
    ,.Dim1Input00Lane0(0)
    ,.Dim1Input01Lane0(0)
    ,.Dim1Input02Lane0(0)
    ,.Dim1Input10Lane0(0)
    ,.Dim1Input11Lane0(0)
    ,.Dim1Input12Lane0(0)
    ,.Dim1Input20Lane0(0)
    ,.Dim1Input21Lane0(0)
    ,.Dim1Input22Lane0(0)
    ,.Dim2Input00Lane0(0)
    ,.Dim2Input01Lane0(0)
    ,.Dim2Input02Lane0(0)
    ,.Dim2Input10Lane0(0)
    ,.Dim2Input11Lane0(0)
    ,.Dim2Input12Lane0(0)
    ,.Dim2Input20Lane0(0)
    ,.Dim2Input21Lane0(0)
    ,.Dim2Input22Lane0(0)
    
    ,.InternalRegisterEnableIndex(InternalRegisterEnableIndex)
    ,.InternalRegisterInputValue0(InternalRegisterInputValue0)

    ,.Output0(SystolicOutput0)
);

assign w  = conv3d_input_width;
assign pw = conv3d_input_width + 2; // pw = w + 2 * (int)(kw / 2)
assign h  = conv3d_input_height;
assign ph = conv3d_input_height + 2; // ph = h + 2 * (int)(kh / 2)
assign d  = conv3d_input_depth;
assign pd = conv3d_input_depth + 2; // pd = d + 2 * (int)(kd / 2)

//----------------------------------------------------------------------------------------
assign mmio_dm_p2_en = conv3d_dm_p2_en;
assign mmio_clkPort2 = ~clk;
assign mmio_rdenPort2 = ~conv3d_dm_p2_wren;
assign mmio_wrenPort2 = conv3d_dm_p2_wren;
assign mmio_addressPort2 = conv3d_dm_p2_address;
assign mmio_dataPort2 = conv3d_dm_p2_writedata;
