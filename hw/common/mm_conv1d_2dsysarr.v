//------------------------------------------------
// mm_conv1d
reg `BIT_WIDTH conv1d_addr_in1, conv1d_addr_in2, conv1d_addr_out;
reg `BIT_WIDTH conv1d_vsize;
reg `BIT_WIDTH conv1d_start, conv1d_done;

reg conv1d_dm_p2_en;
reg [(`DM_BITS-1):0] conv1d_dm_p2_address;
reg conv1d_dm_p2_wren;
reg `BIT_WIDTH conv1d_dm_p2_writedata;
wire conv1d_start_set;
reg conv1d_done_set;
wire conv1d_done_rden;
parameter [3:0] CONV1D_STATE_OFF        = 4'd1;
parameter [3:0] CONV1D_STATE_START      = 4'd2;
parameter [3:0] CONV1D_STATE_SET_ADDR_A = 4'd3;
parameter [3:0] CONV1D_STATE_READ_A     = 4'd4;
parameter [3:0] CONV1D_STATE_SET_ADDR_B = 4'd5;
parameter [3:0] CONV1D_STATE_READ_B     = 4'd6;
parameter [3:0] CONV1D_STATE_INC_OFFSET = 4'd7;
parameter [3:0] CONV1D_STATE_ACC_RESET  = 4'd8;
parameter [3:0] CONV1D_STATE_ACC_WAIT   = 4'd9;
parameter [3:0] CONV1D_STATE_WRITE_C    = 4'd10;
reg [3:0] conv1d_state;
reg `BIT_WIDTH conv1d_regas [9:0];
reg `BIT_WIDTH conv1d_regbs [9:0];
wire `BIT_WIDTH conv1d_regcs [18:0];
reg `BIT_WIDTH conv1d_offset;
reg conv1d_trigger;
//------------------------------------------------

// MMIO control circuit
always@(negedge clk or posedge rst) begin
	if (rst) begin
	end
	else begin
		if (`MMIO_wren) begin
			//------------------------------------------------
			// mm_conv1d
			if (`MMIO_CONV1D_addr_in1_wren) begin
				conv1d_addr_in1 <= CPUDataBusOut;
			end
			if (`MMIO_CONV1D_addr_in2_wren) begin
				conv1d_addr_in2 <= CPUDataBusOut;
			end
			if (`MMIO_CONV1D_addr_out_wren) begin
				conv1d_addr_out <= CPUDataBusOut;
			end
			if (`MMIO_CONV1D_vsize_wren) begin
				conv1d_vsize <= CPUDataBusOut;
			end
		end
	end
end


//----------------------------------------------------------------------------------------
// conv1d_start: reset after set
always@(posedge clk or posedge rst) begin
	if (rst) begin
		conv1d_start <= 0;
	end
	else if (conv1d_start_set) begin
		conv1d_start <= 64'd1;
	end
	else if (conv1d_start == 64'd1) begin
		conv1d_start <= 0;
	end
end

// conv1d_done : reset after reading
always@(posedge clk or posedge rst) begin
	if (rst) begin
		conv1d_done <= 0;
	end
	else if (conv1d_done_set) begin
		conv1d_done <= 64'd1;
	end
	else if (conv1d_done_rden) begin
		conv1d_done <= 0;
	end
end

always@(posedge clk or posedge rst) begin
	if (rst) begin
		conv1d_state <= CONV1D_STATE_OFF;
		conv1d_dm_p2_en <= 0;
		conv1d_done_set <= 0;
		conv1d_offset <= 0;
		conv1d_dm_p2_wren <= 0;
		conv1d_trigger <= 0;
	end
	else begin
		case(conv1d_state)
			CONV1D_STATE_OFF: begin
				conv1d_done_set <= 0;
				conv1d_dm_p2_en <= 0;
				conv1d_offset <= 0;
				conv1d_dm_p2_wren <= 0;
				conv1d_trigger <= 0;
				if (conv1d_start == 64'd1) begin
					conv1d_state <= CONV1D_STATE_START;
				end
			end
			CONV1D_STATE_START: begin
				if (conv1d_offset < conv1d_vsize) begin
					conv1d_state <= CONV1D_STATE_SET_ADDR_A;
					conv1d_dm_p2_en <= 1'b1;
				end
				else begin
					conv1d_offset <= 0;
					conv1d_state <= CONV1D_STATE_ACC_RESET;
				end
			end
			CONV1D_STATE_SET_ADDR_A: begin
				conv1d_dm_p2_address <= conv1d_addr_in1 + (64'd8 * conv1d_offset);
				conv1d_state <= CONV1D_STATE_READ_A;
			end
			CONV1D_STATE_READ_A: begin
				conv1d_regas[conv1d_offset] <= DMDataBusPort2;
				conv1d_state <= CONV1D_STATE_SET_ADDR_B;
			end
			CONV1D_STATE_SET_ADDR_B: begin
				conv1d_dm_p2_address <= conv1d_addr_in2 + (64'd8 * conv1d_offset);
				conv1d_state <= CONV1D_STATE_READ_B;
			end
			CONV1D_STATE_READ_B: begin
				conv1d_regbs[conv1d_offset] <= DMDataBusPort2;
				conv1d_state <= CONV1D_STATE_INC_OFFSET;
			end
			CONV1D_STATE_INC_OFFSET: begin
				conv1d_offset <= conv1d_offset + 1'b1;
				conv1d_state <= CONV1D_STATE_START;
			end
			CONV1D_STATE_ACC_RESET: begin
				// reset conv1d_dut (see the `rst` input signal)
				conv1d_trigger <= 1'b1;
				conv1d_state <= CONV1D_STATE_ACC_WAIT;
			end
			CONV1D_STATE_ACC_WAIT: begin
				if (conv1d_offset >= 6) begin
					conv1d_offset <= 0;
					conv1d_trigger <= 0;
					conv1d_state <= CONV1D_STATE_WRITE_C;
				end
				else begin
					conv1d_offset <= conv1d_offset + 1'b1;
					conv1d_state <= CONV1D_STATE_ACC_WAIT;
				end
			end
			CONV1D_STATE_WRITE_C: begin
				if (conv1d_offset >= (2 * conv1d_vsize - 1)) begin
					conv1d_dm_p2_wren <= 1'b0;
					conv1d_done_set <= 1'b1;
					conv1d_dm_p2_en <= 1'b0;
					conv1d_state <= CONV1D_STATE_OFF;
				end
				else begin
					conv1d_dm_p2_address <= conv1d_addr_out + (64'd8 * conv1d_offset);
					conv1d_dm_p2_wren <= 1'b1;
					conv1d_dm_p2_writedata <= conv1d_regcs[conv1d_offset];
					conv1d_offset <= conv1d_offset + 1'b1;
					conv1d_state <= CONV1D_STATE_WRITE_C;
				end
			end
		endcase
	end
end
assign conv1d_done_rden = `MMIO_CONV1D_done_rden;
assign conv1d_start_set = `MMIO_CONV1D_start_wren && (CPUDataBusOut == 64'd1);

SystolicArray_conv1d_2dsys SystolicArray_conv1d_2dsys_dut
(
    .clk(clk)
	,.rst(conv1d_state == CONV1D_STATE_ACC_RESET)
	,.trigger(conv1d_trigger)
    ,.Dim0Input0Lane0(conv1d_regas[0])
    ,.Dim0Input1Lane0(conv1d_regas[1])
    ,.Dim0Input2Lane0(conv1d_regas[2])
    ,.Dim0Input3Lane0(conv1d_regas[3])
    ,.Dim1Input0Lane0(conv1d_regbs[0])
    ,.Dim1Input1Lane0(conv1d_regbs[1])
    ,.Dim1Input2Lane0(conv1d_regbs[2])
    ,.Dim1Input3Lane0(conv1d_regbs[3])

	,.DimOutput0(conv1d_regcs[0])
	,.DimOutput1(conv1d_regcs[1])
	,.DimOutput2(conv1d_regcs[2])
	,.DimOutput3(conv1d_regcs[3])
	,.DimOutput4(conv1d_regcs[4])
	,.DimOutput5(conv1d_regcs[5])
	,.DimOutput6(conv1d_regcs[6])
);
//----------------------------------------------------------------------------------------
assign mmio_dm_p2_en = conv1d_dm_p2_en;
assign mmio_clkPort2 = ~clk;
assign mmio_rdenPort2 = ~conv1d_dm_p2_wren;
assign mmio_wrenPort2 = conv1d_dm_p2_wren;
assign mmio_addressPort2 = conv1d_dm_p2_address;
assign mmio_dataPort2 = conv1d_dm_p2_writedata;
