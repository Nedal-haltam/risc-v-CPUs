//------------------------------------------------
// mm_conv1d
`define CONV1D_PL_VSIZE_MAX 10

(* preserve *) reg `BIT_WIDTH conv1d_pl_addr_in1, conv1d_pl_addr_in2, conv1d_pl_addr_out;
(* preserve *) reg `BIT_WIDTH conv1d_pl_vsize;
(* preserve *) reg `BIT_WIDTH conv1d_pl_start, conv1d_pl_done;

(* preserve *) reg conv1d_pl_dm_p2_en;
(* preserve *) reg [(`DM_BITS-1):0] conv1d_pl_dm_p2_address;
(* preserve *) reg conv1d_pl_dm_p2_wren;
(* preserve *) reg `BIT_WIDTH conv1d_pl_dm_p2_writedata;
(* keep *) wire conv1d_pl_start_set;
(* preserve *) reg conv1d_pl_done_set;
(* keep *) wire conv1d_pl_done_rden;
parameter [3:0] CONV1D_PL_STATE_OFF         = 4'd1;
parameter [3:0] CONV1D_PL_STATE_START       = 4'd2;
parameter [3:0] CONV1D_PL_STATE_SET_ADDR_A  = 4'd3;
parameter [3:0] CONV1D_PL_STATE_READ_A      = 4'd4;
parameter [3:0] CONV1D_PL_STATE_SET_ADDR_B  = 4'd5;
parameter [3:0] CONV1D_PL_STATE_READ_B      = 4'd6;
parameter [3:0] CONV1D_PL_STATE_INC_OFFSET  = 4'd7;
parameter [3:0] CONV1D_PL_STATE_ACC_RESET   = 4'd8;
parameter [3:0] CONV1D_PL_STATE_ACC_EXECUTE = 4'd9;
parameter [3:0] CONV1D_PL_STATE_WRITE_C     = 4'd10;
parameter [3:0] CONV1D_PL_STATE_INC_OFFSET_WRITE_C = 4'd11;
(* preserve *) reg [3:0] conv1d_pl_state;
(* preserve *) reg `BIT_WIDTH conv1d_pl_regas [`CONV1D_PL_VSIZE_MAX - 1:0];
(* preserve *) reg `BIT_WIDTH conv1d_pl_regbs [`CONV1D_PL_VSIZE_MAX - 1:0];
(* keep *) wire `BIT_WIDTH conv1d_pl_regcs [2 * `CONV1D_PL_VSIZE_MAX - 1 - 1:0];
(* preserve *) reg `BIT_WIDTH Dim0InputLane0;
(* preserve *) reg `BIT_WIDTH InternalRegisterEnableIndex;
(* preserve *) reg `BIT_WIDTH InternalRegisterInputValue0;
(* preserve *) reg `BIT_WIDTH conv1d_pl_offset;
(* preserve *) reg conv1d_pl_trigger;
//------------------------------------------------

// MMIO control circuit
always@(negedge clk or posedge rst) begin
	if (rst) begin
	end
	else begin
		if (`MMIO_wren) begin
			//------------------------------------------------
			// mm_conv1d
			if (`MMIO_CONV1D_PL_addr_in1_wren) begin
				conv1d_pl_addr_in1 <= CPUDataBusOut;
			end
			if (`MMIO_CONV1D_PL_addr_in2_wren) begin
				conv1d_pl_addr_in2 <= CPUDataBusOut;
			end
			if (`MMIO_CONV1D_PL_addr_out_wren) begin
				conv1d_pl_addr_out <= CPUDataBusOut;
			end
			if (`MMIO_CONV1D_PL_vsize_wren) begin
				conv1d_pl_vsize <= CPUDataBusOut;
			end
		end
	end
end


//----------------------------------------------------------------------------------------
// conv1d_pl_start: reset after set
always@(posedge clk or posedge rst) begin
	if (rst) begin
		conv1d_pl_start <= 0;
	end
	else if (conv1d_pl_start_set) begin
		conv1d_pl_start <= 64'd1;
	end
	else if (conv1d_pl_start == 64'd1) begin
		conv1d_pl_start <= 0;
	end
end

// conv1d_pl_done : reset after reading
always@(posedge clk or posedge rst) begin
	if (rst) begin
		conv1d_pl_done <= 0;
	end
	else if (conv1d_pl_done_set) begin
		conv1d_pl_done <= 64'd1;
	end
	else if (conv1d_pl_done_rden) begin
		conv1d_pl_done <= 0;
	end
end

integer i, j;
always@(posedge clk or posedge rst) begin
	if (rst) begin
		conv1d_pl_state <= CONV1D_PL_STATE_OFF;
		conv1d_pl_dm_p2_en <= 0;
		conv1d_pl_done_set <= 0;
		conv1d_pl_offset <= 0;
		conv1d_pl_dm_p2_wren <= 0;
		conv1d_pl_trigger <= 0;
		Dim0InputLane0 <= 0;
		InternalRegisterEnableIndex <= 0;
		InternalRegisterInputValue0 <= 0;
		for (i = 0; i < `CONV1D_PL_VSIZE_MAX; i = i + 1) begin
			conv1d_pl_regas[i] <= 0;
			conv1d_pl_regbs[i] <= 0;
		end
	end
	else begin
		case(conv1d_pl_state)
			CONV1D_PL_STATE_OFF: begin
				conv1d_pl_done_set <= 0;
				conv1d_pl_dm_p2_en <= 0;
				conv1d_pl_offset <= 0;
				conv1d_pl_dm_p2_wren <= 0;
				conv1d_pl_trigger <= 0;
				if (conv1d_pl_start == 64'd1) begin
					conv1d_pl_state <= CONV1D_PL_STATE_START;
				end
			end
			CONV1D_PL_STATE_START: begin
				if (conv1d_pl_offset < conv1d_pl_vsize) begin
					conv1d_pl_state <= CONV1D_PL_STATE_SET_ADDR_A;
					conv1d_pl_dm_p2_en <= 1'b1;
				end
				else begin
					conv1d_pl_offset <= 0;
					conv1d_pl_state <= CONV1D_PL_STATE_ACC_RESET;
				end
			end
/////////////////////////////////////
			CONV1D_PL_STATE_SET_ADDR_A: begin
				conv1d_pl_dm_p2_address <= conv1d_pl_addr_in1[`DM_BITS-1:0] + (14'd8 * conv1d_pl_offset[`DM_BITS-1:0]);
				conv1d_pl_state <= CONV1D_PL_STATE_READ_A;
			end
			CONV1D_PL_STATE_READ_A: begin
				InternalRegisterEnableIndex <= conv1d_pl_offset + 1'b1;
				InternalRegisterInputValue0 <= DMDataBusPort2;

				conv1d_pl_regas[conv1d_pl_offset] <= DMDataBusPort2;
				conv1d_pl_state <= CONV1D_PL_STATE_SET_ADDR_B;
			end
			CONV1D_PL_STATE_SET_ADDR_B: begin
				conv1d_pl_dm_p2_address <= conv1d_pl_addr_in2[`DM_BITS-1:0] + (14'd8 * conv1d_pl_offset[`DM_BITS-1:0]);
				conv1d_pl_state <= CONV1D_PL_STATE_READ_B;
			end
			CONV1D_PL_STATE_READ_B: begin
				conv1d_pl_regbs[conv1d_pl_offset] <= DMDataBusPort2;
				conv1d_pl_state <= CONV1D_PL_STATE_INC_OFFSET;
			end
			CONV1D_PL_STATE_INC_OFFSET: begin
				conv1d_pl_offset <= conv1d_pl_offset + 1'b1;
				conv1d_pl_state <= CONV1D_PL_STATE_START;
			end
/////////////////////////////////////
			CONV1D_PL_STATE_ACC_RESET: begin
				conv1d_pl_trigger <= 1'b1;
				conv1d_pl_state <= CONV1D_PL_STATE_ACC_EXECUTE;
				// start from now to pipelined the input
				Dim0InputLane0 <= conv1d_pl_regbs[conv1d_pl_offset];
			end
			CONV1D_PL_STATE_ACC_EXECUTE: begin
				if (conv1d_pl_offset < (2 * conv1d_pl_vsize + 2)) begin
					if ((conv1d_pl_offset + 1'b1) < conv1d_pl_vsize) begin
						Dim0InputLane0 <= conv1d_pl_regbs[(conv1d_pl_offset + 1'b1)];
					end
					else begin
						Dim0InputLane0 <= 0;
					end
					conv1d_pl_offset <= conv1d_pl_offset + 1'b1;
					conv1d_pl_state <= CONV1D_PL_STATE_ACC_EXECUTE;
				end
				else begin
					conv1d_pl_offset <= 0;
					conv1d_pl_trigger <= 0;
					conv1d_pl_state <= CONV1D_PL_STATE_WRITE_C;
				end
			end
			CONV1D_PL_STATE_WRITE_C: begin
				if (conv1d_pl_offset < (2 * conv1d_pl_vsize - 1)) begin
					conv1d_pl_dm_p2_address <= conv1d_pl_addr_out[`DM_BITS-1:0] + (14'd8 * conv1d_pl_offset[`DM_BITS-1:0]);
					conv1d_pl_dm_p2_wren <= 1'b1;
					conv1d_pl_dm_p2_writedata <= conv1d_pl_regcs[conv1d_pl_offset];
					conv1d_pl_state <= CONV1D_PL_STATE_INC_OFFSET_WRITE_C;
				end
				else begin
					conv1d_pl_dm_p2_wren <= 1'b0;
					conv1d_pl_done_set <= 1'b1;
					conv1d_pl_dm_p2_en <= 1'b0;
					conv1d_pl_state <= CONV1D_PL_STATE_OFF;
				end
			end
			CONV1D_PL_STATE_INC_OFFSET_WRITE_C: begin
				conv1d_pl_offset <= conv1d_pl_offset + 1'b1;
				conv1d_pl_state <= CONV1D_PL_STATE_WRITE_C;
			end
		endcase
	end
end
assign conv1d_pl_done_rden = `MMIO_CONV1D_PL_done_rden;
assign conv1d_pl_start_set = `MMIO_CONV1D_PL_start_wren && (CPUDataBusOut == 64'd1);


(* noprune *) SystolicArray_conv1d_1dsys_pl SystolicArray_conv1d_1dsys_pl_dut
(
    .clk(clk),
	.rst(conv1d_pl_state == CONV1D_PL_STATE_ACC_RESET),
	.trigger(conv1d_pl_trigger)
    ,.Dim0InputLane0(Dim0InputLane0)
    ,.InternalRegisterEnableIndex(InternalRegisterEnableIndex)
    ,.InternalRegisterInputValue0(InternalRegisterInputValue0)

	,.DimOutput0(conv1d_pl_regcs[0])
	,.DimOutput1(conv1d_pl_regcs[1])
	,.DimOutput2(conv1d_pl_regcs[2])
	,.DimOutput3(conv1d_pl_regcs[3])
	,.DimOutput4(conv1d_pl_regcs[4])
	,.DimOutput5(conv1d_pl_regcs[5])
	,.DimOutput6(conv1d_pl_regcs[6])
	,.DimOutput7(conv1d_pl_regcs[7])
	,.DimOutput8(conv1d_pl_regcs[8])
	,.DimOutput9(conv1d_pl_regcs[9])
	,.DimOutput10(conv1d_pl_regcs[10])
	,.DimOutput11(conv1d_pl_regcs[11])
	,.DimOutput12(conv1d_pl_regcs[12])
	,.DimOutput13(conv1d_pl_regcs[13])
	,.DimOutput14(conv1d_pl_regcs[14])
	,.DimOutput15(conv1d_pl_regcs[15])
	,.DimOutput16(conv1d_pl_regcs[16])
	,.DimOutput17(conv1d_pl_regcs[17])
	,.DimOutput18(conv1d_pl_regcs[18])
);
//----------------------------------------------------------------------------------------
assign mmio_dm_p2_en = conv1d_pl_dm_p2_en;
assign mmio_clkPort2 = ~clk;
assign mmio_rdenPort2 = ~conv1d_pl_dm_p2_wren;
assign mmio_wrenPort2 = conv1d_pl_dm_p2_wren;
assign mmio_addressPort2 = conv1d_pl_dm_p2_address;
assign mmio_dataPort2 = conv1d_pl_dm_p2_writedata;
