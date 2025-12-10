//------------------------------------------------
// mm_vadd
reg `BIT_WIDTH vadd_addr_in1, vadd_addr_in2, vadd_addr_out;
reg `BIT_WIDTH vadd_vsize;
reg `BIT_WIDTH vadd_start, vadd_done;

reg vadd_dm_p2_en;
reg [(`DM_BITS-1):0] vadd_dm_p2_address;
reg vadd_dm_p2_wren;
reg `BIT_WIDTH vadd_dm_p2_writedata;
wire vadd_start_set;
reg vadd_done_set;
wire vadd_done_rden;
parameter [3:0] VADD_STATE_OFF        = 4'd1;
parameter [3:0] VADD_STATE_ON         = 4'd2;
parameter [3:0] VADD_STATE_SET_ADDR_A = 4'd3;
parameter [3:0] VADD_STATE_READ_A     = 4'd4;
parameter [3:0] VADD_STATE_SET_ADDR_B = 4'd5;
parameter [3:0] VADD_STATE_READ_B     = 4'd6;
parameter [3:0] VADD_STATE_OP         = 4'd7;
parameter [3:0] VADD_STATE_WRITE_C    = 4'd8;
parameter [3:0] VADD_STATE_INC_OFFSET = 4'd9;
reg [3:0] vadd_state;
reg `BIT_WIDTH vadd_rega, vadd_regb, vadd_regc;
reg `BIT_WIDTH vadd_offset;
//------------------------------------------------

// MMIO control circuit
always@(negedge clk or posedge rst) begin
	if (rst) begin
	end
	else begin
		if (`MMIO_wren) begin
			//------------------------------------------------
			// mm_vadd
			if (`MMIO_VADD_addr_in1_wren) begin
				vadd_addr_in1 <= CPUDataBusOut;
			end
			if (`MMIO_VADD_addr_in2_wren) begin
				vadd_addr_in2 <= CPUDataBusOut;
			end
			if (`MMIO_VADD_addr_out_wren) begin
				vadd_addr_out <= CPUDataBusOut;
			end
			if (`MMIO_VADD_vsize_wren) begin
				vadd_vsize <= CPUDataBusOut;
			end
		end
	end
end


//----------------------------------------------------------------------------------------
// vadd_start: reset after set
always@(posedge clk or posedge rst) begin
	if (rst) begin
		vadd_start <= 0;
	end
	else if (vadd_start_set) begin
		vadd_start <= 64'd1;
	end
	else if (vadd_start == 64'd1) begin
		vadd_start <= 0;
	end
end

// vadd_done : reset after reading
always@(posedge clk or posedge rst) begin
	if (rst) begin
		vadd_done <= 0;
	end
	else if (vadd_done_set) begin
		vadd_done <= 64'd1;
	end
	else if (vadd_done_rden) begin
		vadd_done <= 0;
	end
end

always@(posedge clk or posedge rst) begin
	if (rst) begin
		vadd_state <= VADD_STATE_OFF;
		vadd_dm_p2_en <= 0;
		vadd_done_set <= 0;
		vadd_offset <= 0;
		vadd_dm_p2_wren <= 0;
	end
	else begin
		case(vadd_state)
			VADD_STATE_OFF: begin
				vadd_done_set <= 0;
				vadd_dm_p2_en <= 0;
				vadd_offset <= 0;
				vadd_dm_p2_wren <= 0;
				if (vadd_start == 64'd1) begin
					vadd_state <= VADD_STATE_ON;
				end
			end
			VADD_STATE_ON: begin
				if (vadd_offset < vadd_vsize) begin
					vadd_state <= VADD_STATE_SET_ADDR_A;
					vadd_dm_p2_en <= 1'b1;
				end
				else begin
					vadd_done_set <= 1'b1;
					vadd_dm_p2_en <= 1'b0;
					vadd_state <= VADD_STATE_OFF;
				end
			end
			VADD_STATE_SET_ADDR_A: begin
				vadd_dm_p2_address <= vadd_addr_in1 + (64'd8 * vadd_offset);
				vadd_state <= VADD_STATE_READ_A;
			end
			VADD_STATE_READ_A: begin
				vadd_rega <= DMDataBusPort2;
				vadd_state <= VADD_STATE_SET_ADDR_B;
			end
			VADD_STATE_SET_ADDR_B: begin
				vadd_dm_p2_address <= vadd_addr_in2 + (64'd8 * vadd_offset);
				vadd_state <= VADD_STATE_READ_B;
			end
			VADD_STATE_READ_B: begin
				vadd_regb <= DMDataBusPort2;
				vadd_state <= VADD_STATE_OP;
			end
			VADD_STATE_OP: begin
				vadd_regc <= vadd_rega + vadd_regb;
				vadd_state <= VADD_STATE_WRITE_C;
			end
			VADD_STATE_WRITE_C: begin
				vadd_dm_p2_address <= vadd_addr_out + (64'd8 * vadd_offset);
				vadd_dm_p2_wren <= 1'b1;
				vadd_dm_p2_writedata <= vadd_regc;
				vadd_state <= VADD_STATE_INC_OFFSET;
			end
			VADD_STATE_INC_OFFSET: begin
				vadd_dm_p2_wren <= 1'b0;
				vadd_offset <= vadd_offset + 1'b1;
				vadd_state <= VADD_STATE_ON;
			end
		endcase
	end
end
assign vadd_done_rden = `MMIO_VADD_done_rden;
assign vadd_start_set = `MMIO_VADD_start_wren && (CPUDataBusOut == 64'd1);
//----------------------------------------------------------------------------------------
assign mmio_dm_p2_en = vadd_dm_p2_en;
assign mmio_clkPort2 = ~clk;
assign mmio_rdenPort2 = ~vadd_dm_p2_wren;
assign mmio_wrenPort2 = vadd_dm_p2_wren;
assign mmio_addressPort2 = vadd_dm_p2_address;
assign mmio_dataPort2 = vadd_dm_p2_writedata;
