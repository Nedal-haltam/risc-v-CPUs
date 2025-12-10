//------------------------------------------------
// mm_alu
// 50 * 1000 cycle to get a delay of 5 sec
reg `BIT_WIDTH alu_in1, alu_in2, alu_out;
reg `BIT_WIDTH alu_start;
reg `BIT_WIDTH alu_done;

wire alu_start_set;
reg alu_done_set;
wire alu_done_rden;
parameter [3:0] ALU_STATE_OFF  = 4'd1;
parameter [3:0] ALU_STATE_ON   = 4'd2;
reg [3:0] alu_state;
reg `BIT_WIDTH alu_counter;
//------------------------------------------------

// MMIO control circuit
always@(negedge clk or posedge rst) begin
	if (rst) begin
	end
	else begin
		if (`MMIO_wren) begin
			//------------------------------------------------
			// mm_alu
			if (`MMIO_ALU_in1_wren)begin
				alu_in1 <= CPUDataBusOut;
			end
			if (`MMIO_ALU_in2_wren)begin
				alu_in2 <= CPUDataBusOut;
			end
		end
	end
end


//----------------------------------------------------------------------------------------
// alu_start: reset after set
always@(posedge clk or posedge rst) begin
	if (rst) begin
		alu_start <= 0;
	end
	else if (alu_start_set) begin
		alu_start <= 64'd1;
	end
	else if (alu_start == 64'd1) begin
		alu_start <= 0;
	end
end

// alu_done : reset after reading
always@(posedge clk or posedge rst) begin
	if (rst) begin
		alu_done <= 0;
	end
	else if (alu_done_set) begin
		alu_done <= 64'd1;
	end
	else if (alu_done_rden) begin
		alu_done <= 0;
	end
end

always@(posedge clk or posedge rst) begin
	if (rst) begin
		alu_state <= ALU_STATE_OFF;
		alu_counter <= 0;
		alu_done_set <= 0;
		alu_out <= 0;
	end
	else begin
		case(alu_state)
			ALU_STATE_OFF: begin
				alu_counter <= 0;
				alu_done_set <= 0;
				if (alu_start == 64'd1) begin
					alu_state <= ALU_STATE_ON;
				end
			end
			ALU_STATE_ON: begin
				alu_counter <= alu_counter + 1'b1;
				if (alu_counter == (50 * 1000)) begin
					alu_out <= alu_in1 + alu_in2;
					alu_done_set <= 1'b1;
					alu_state <= ALU_STATE_OFF;
				end
			end
		endcase
	end
end
assign alu_done_rden = `MMIO_ALU_done_rden;
assign alu_start_set = `MMIO_ALU_start_wren && (CPUDataBusOut == 64'd1);
//----------------------------------------------------------------------------------------
assign mmio_dm_p2_en = 0;
assign mmio_clkPort2 = 0;
assign mmio_rdenPort2 = 0;
assign mmio_wrenPort2 = 0;
assign mmio_addressPort2 = 0;
assign mmio_dataPort2 = 0;
