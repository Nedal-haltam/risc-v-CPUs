//------------------------------------------------
// mm_conv2d
`define KW (3)
`define KH (3)

(* preserve *) reg `BIT_WIDTH conv2d_addr_input, conv2d_addr_kernel, conv2d_addr_out;
(* preserve *) reg `BIT_WIDTH conv2d_input_width, conv2d_input_height;
(* preserve *) reg `BIT_WIDTH conv2d_start, conv2d_done;

(* preserve *) reg conv2d_dm_p2_en;
(* preserve *) reg [(`DM_BITS-1):0] conv2d_dm_p2_address;
(* preserve *) reg conv2d_dm_p2_wren;
(* preserve *) reg `BIT_WIDTH conv2d_dm_p2_writedata;

(* keep *) wire conv2d_start_set;
(* preserve *) reg conv2d_done_set;
(* keep *) wire conv2d_done_rden;

parameter [4:0] CONV2D_STATE_OFF         = 5'd1;
parameter [4:0] CONV2D_STATE_START       = 5'd2;
parameter [4:0] CONV2D_STATE_READ_KERNEL = 5'd3;
parameter [4:0] CONV2D_STATE_LOAD_KERNEL = 5'd4;
parameter [4:0] CONV2D_STATE_INC_OFFSET  = 5'd5;
parameter [4:0] CONV2D_STATE_INPUT_FEED  = 5'd6;
parameter [4:0] CONV2D_STATE_READ_INPUT0 = 5'd7;
parameter [4:0] CONV2D_STATE_LOAD_INPUT0 = 5'd8;
parameter [4:0] CONV2D_STATE_READ_INPUT1 = 5'd9;
parameter [4:0] CONV2D_STATE_LOAD_INPUT1 = 5'd10;
parameter [4:0] CONV2D_STATE_READ_INPUT2 = 5'd11;
parameter [4:0] CONV2D_STATE_LOAD_INPUT2 = 5'd12;
parameter [4:0] CONV2D_STATE_TRIGGER     = 5'd13;
parameter [4:0] CONV2D_STATE_POINT       = 5'd14;
parameter [4:0] CONV2D_STATE_WRITE_BACK  = 5'd15;
parameter [4:0] CONV2D_STATE_FINISHED    = 5'd16;

(* preserve *) reg [4:0] conv2d_state;

(* preserve *) reg `BIT_WIDTH Dim0Input0Lane0;
(* preserve *) reg `BIT_WIDTH Dim0Input0Lane1;
(* preserve *) reg `BIT_WIDTH Dim0Input0Lane2;
(* preserve *) reg `BIT_WIDTH Dim0Input1Lane0;
(* preserve *) reg `BIT_WIDTH Dim0Input1Lane1;
(* preserve *) reg `BIT_WIDTH Dim0Input1Lane2;
(* preserve *) reg `BIT_WIDTH Dim0Input2Lane0;
(* preserve *) reg `BIT_WIDTH Dim0Input2Lane1;
(* preserve *) reg `BIT_WIDTH Dim0Input2Lane2;

(* preserve *) reg `BIT_WIDTH InternalRegisterEnableIndex;
(* preserve *) reg `BIT_WIDTH InternalRegisterInputValue0;
(* keep *) wire `BIT_WIDTH SystolicOutput0;
(* keep *) wire `BIT_WIDTH SystolicOutput1;
(* keep *) wire `BIT_WIDTH SystolicOutput2;
(* keep *) wire `BIT_WIDTH w;
(* keep *) wire `BIT_WIDTH pw;
(* keep *) wire `BIT_WIDTH h;
(* keep *) wire `BIT_WIDTH ph;

(* preserve *) reg `BIT_WIDTH conv2d_offset, conv2d_x, conv2d_wb_index;
(* preserve *) reg conv2d_trigger;
//------------------------------------------------

// MMIO control circuit
always@(negedge clk or posedge rst) begin
	if (rst) begin
	end
	else begin
		if (`MMIO_wren) begin
			//------------------------------------------------
			// mm_conv2d
            if (`MMIO_CONV2D_addr_input_wren) begin
                conv2d_addr_input <= CPUDataBusOut;
            end
            if (`MMIO_CONV2D_addr_kernel_wren) begin
                conv2d_addr_kernel <= CPUDataBusOut;
            end
            if (`MMIO_CONV2D_addr_out_wren) begin
                conv2d_addr_out <= CPUDataBusOut;
            end
            if (`MMIO_CONV2D_input_width_wren) begin
                conv2d_input_width <= CPUDataBusOut;
            end
            if (`MMIO_CONV2D_input_height_wren) begin
                conv2d_input_height <= CPUDataBusOut;
            end
		end
	end
end


//----------------------------------------------------------------------------------------
// conv2d_start: reset after set
always@(posedge clk or posedge rst) begin
	if (rst) begin
		conv2d_start <= 0;
	end
	else if (conv2d_start_set) begin
		conv2d_start <= 64'd1;
	end
	else if (conv2d_start == 64'd1) begin
		conv2d_start <= 0;
	end
end

// conv2d_done : reset after reading
always@(posedge clk or posedge rst) begin
	if (rst) begin
		conv2d_done <= 0;
	end
	else if (conv2d_done_set) begin
		conv2d_done <= 64'd1;
	end
	else if (conv2d_done_rden) begin
		conv2d_done <= 0;
	end
end

always@(posedge clk or posedge rst) begin
	if (rst) begin
		conv2d_state <= CONV2D_STATE_OFF;
		conv2d_dm_p2_en <= 0;
		conv2d_done_set <= 0;
		conv2d_offset <= 0;
        conv2d_x <= 0;
        conv2d_wb_index <= 0;
		conv2d_dm_p2_wren <= 0;
		conv2d_trigger <= 0;

        Dim0Input0Lane0 <= 0;
        Dim0Input0Lane1 <= 0;
        Dim0Input0Lane2 <= 0;
        Dim0Input1Lane0 <= 0;
        Dim0Input1Lane1 <= 0;
        Dim0Input1Lane2 <= 0;
        Dim0Input2Lane0 <= 0;
        Dim0Input2Lane1 <= 0;
        Dim0Input2Lane2 <= 0;

        InternalRegisterEnableIndex <= 0;
		InternalRegisterInputValue0 <= 0;
	end
	else begin
        Dim0Input0Lane1 <= 0;
        Dim0Input0Lane2 <= 0;
        Dim0Input1Lane1 <= 0;
        Dim0Input1Lane2 <= 0;
        Dim0Input2Lane1 <= 0;
        Dim0Input2Lane2 <= 0;
		case(conv2d_state)
			CONV2D_STATE_OFF: begin
                conv2d_dm_p2_en <= 0;
				conv2d_done_set <= 0;
				conv2d_offset <= 0;
                conv2d_x <= 0;
                conv2d_wb_index <= 0;
				conv2d_dm_p2_wren <= 0;
				conv2d_trigger <= 0;
				if (conv2d_start == 64'd1) begin
					conv2d_state <= CONV2D_STATE_START;
				end
			end
			CONV2D_STATE_START: begin
                conv2d_dm_p2_en <= 1'b1;
                conv2d_state <= CONV2D_STATE_READ_KERNEL;
			end
//////////////////////////////////////////////
			CONV2D_STATE_READ_KERNEL: begin
                if (conv2d_offset < (`KW * `KH)) begin
                    conv2d_dm_p2_address <= conv2d_addr_kernel[`DM_BITS-1:0] + (14'd8 * conv2d_offset[`DM_BITS-1:0]);
                    conv2d_state <= CONV2D_STATE_LOAD_KERNEL;
                end
                else begin
                    conv2d_offset <= 0;
                    conv2d_state <= CONV2D_STATE_INPUT_FEED;
                end
			end
			CONV2D_STATE_LOAD_KERNEL: begin
				InternalRegisterEnableIndex <= conv2d_offset + 1'b1;
				InternalRegisterInputValue0 <= DMDataBusPort2;
				conv2d_state <= CONV2D_STATE_INC_OFFSET;
			end
			CONV2D_STATE_INC_OFFSET: begin
				conv2d_offset <= conv2d_offset + 1'b1;
				conv2d_state <= CONV2D_STATE_READ_KERNEL;
			end
//////////////////////////////////////////////
            CONV2D_STATE_INPUT_FEED: begin
                if (conv2d_offset < (pw * (ph - 2))) begin
                    if (conv2d_x == pw) begin
                        conv2d_x <= 0;
                    end
                    conv2d_state <= CONV2D_STATE_READ_INPUT0;
                end
                else begin
                    conv2d_state <= CONV2D_STATE_FINISHED;
                end
            end
//////////////////////////////////////////////
            CONV2D_STATE_READ_INPUT0: begin
                conv2d_dm_p2_address <= conv2d_addr_input[`DM_BITS-1:0] + (14'd8 * (conv2d_offset[`DM_BITS-1:0] + 14'd0 * pw[`DM_BITS-1:0]));
                conv2d_state <= CONV2D_STATE_LOAD_INPUT0;
            end
            CONV2D_STATE_LOAD_INPUT0: begin
                Dim0Input0Lane0 <= DMDataBusPort2;
                conv2d_state <= CONV2D_STATE_READ_INPUT1;
            end
            CONV2D_STATE_READ_INPUT1: begin
                conv2d_dm_p2_address <= conv2d_addr_input[`DM_BITS-1:0] + (14'd8 * (conv2d_offset[`DM_BITS-1:0] + 14'd1 * pw[`DM_BITS-1:0]));
                conv2d_state <= CONV2D_STATE_LOAD_INPUT1;
            end
            CONV2D_STATE_LOAD_INPUT1: begin
                Dim0Input1Lane0 <= DMDataBusPort2;
                conv2d_state <= CONV2D_STATE_READ_INPUT2;
            end
            CONV2D_STATE_READ_INPUT2: begin
                conv2d_dm_p2_address <= conv2d_addr_input[`DM_BITS-1:0] + (14'd8 * (conv2d_offset[`DM_BITS-1:0] + 14'd2 * pw[`DM_BITS-1:0]));
                conv2d_state <= CONV2D_STATE_LOAD_INPUT2;
            end
            CONV2D_STATE_LOAD_INPUT2: begin
                Dim0Input2Lane0 <= DMDataBusPort2;
                conv2d_state <= CONV2D_STATE_TRIGGER;
            end
//////////////////////////////////////////////
            CONV2D_STATE_TRIGGER: begin
                if (!conv2d_trigger) begin
                    conv2d_trigger <= 1'b1;
                    conv2d_state <= CONV2D_STATE_TRIGGER;
                end
                else begin
                    conv2d_trigger <= 0;
                    conv2d_offset <= conv2d_offset + 1'b1;
                    conv2d_x <= conv2d_x + 1'b1;
                    conv2d_state <= CONV2D_STATE_POINT;
                end
            end
            CONV2D_STATE_POINT: begin
                if (conv2d_x >= `KW) begin
                    conv2d_state <= CONV2D_STATE_WRITE_BACK;
                end
                else begin
                    conv2d_state <= CONV2D_STATE_INPUT_FEED;
                end
            end
            CONV2D_STATE_WRITE_BACK: begin
                if (!conv2d_dm_p2_wren) begin
					conv2d_dm_p2_address <= conv2d_addr_out[`DM_BITS-1:0] + (14'd8 * conv2d_wb_index);
					conv2d_dm_p2_wren <= 1'b1;
					conv2d_dm_p2_writedata <= SystolicOutput0;
					conv2d_state <= CONV2D_STATE_WRITE_BACK;
                end
                else begin
					conv2d_dm_p2_wren <= 0;
                    conv2d_wb_index <= conv2d_wb_index + 1'b1;
                    conv2d_state <= CONV2D_STATE_INPUT_FEED;
                end
            end
            CONV2D_STATE_FINISHED: begin
                conv2d_done_set <= 1'b1;
                conv2d_dm_p2_en <= 1'b0;
                conv2d_state <= CONV2D_STATE_OFF;
            end
//////////////////////////////////////////////
		endcase
	end
end
assign conv2d_done_rden = `MMIO_CONV2D_done_rden;
assign conv2d_start_set = `MMIO_CONV2D_start_wren && (CPUDataBusOut == 64'd1);


(* noprune *) SystolicArray_conv2d SystolicArray_conv2d_dut
(
    .clk(clk),
	.rst(rst),
	.trigger(conv2d_trigger)

    ,.Dim0Input0Lane0(Dim0Input0Lane0)
    // ,.Dim0Input0Lane1(Dim0Input0Lane1)
    // ,.Dim0Input0Lane2(Dim0Input0Lane2)
    ,.Dim0Input1Lane0(Dim0Input1Lane0)
    // ,.Dim0Input1Lane1(Dim0Input1Lane1)
    // ,.Dim0Input1Lane2(Dim0Input1Lane2)
    ,.Dim0Input2Lane0(Dim0Input2Lane0)
    // ,.Dim0Input2Lane1(Dim0Input2Lane1)
    // ,.Dim0Input2Lane2(Dim0Input2Lane2)
    ,.Dim1Input0Lane0(0)
    ,.Dim1Input0Lane1(0)
    ,.Dim1Input0Lane2(0)
    ,.Dim1Input1Lane0(0)
    ,.Dim1Input1Lane1(0)
    ,.Dim1Input1Lane2(0)
    ,.Dim1Input2Lane0(0)
    ,.Dim1Input2Lane1(0)
    ,.Dim1Input2Lane2(0)
    
    ,.InternalRegisterEnableIndex(InternalRegisterEnableIndex)
    ,.InternalRegisterInputValue0(InternalRegisterInputValue0)

    ,.Output0(SystolicOutput0)
    // ,.Output1(SystolicOutput1)
    // ,.Output2(SystolicOutput2)
);

assign w  = conv2d_input_width;
assign pw = conv2d_input_width + 2; // pw = w + 2 * (int)(kw / 2)
assign h  = conv2d_input_height;
assign ph = conv2d_input_height + 2; // ph = h + 2 * (int)(kh / 2)

//----------------------------------------------------------------------------------------
assign mmio_dm_p2_en = conv2d_dm_p2_en;
assign mmio_clkPort2 = ~clk;
assign mmio_rdenPort2 = ~conv2d_dm_p2_wren;
assign mmio_wrenPort2 = conv2d_dm_p2_wren;
assign mmio_addressPort2 = conv2d_dm_p2_address;
assign mmio_dataPort2 = conv2d_dm_p2_writedata;
