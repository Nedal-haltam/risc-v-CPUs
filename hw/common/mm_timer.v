//------------------------------------------------
// mm_timer
`define TIME(clks) (clks * 0.0001)

reg `BIT_WIDTH timer_timer;
reg `BIT_WIDTH timer_start;

wire timer_start_set;
wire timer_rden;
parameter [3:0] TIMER_STATE_OFF = 4'd1;
parameter [3:0] TIMER_STATE_ON  = 4'd2;
reg [3:0] timer_state;
//------------------------------------------------

// MMIO control circuit
// always@(negedge clk or posedge rst) begin
// 	if (rst) begin
// 	end
// 	else begin
// 		if (`MMIO_wren) begin
// 			//------------------------------------------------
// 			// mm_timer
// 			// if (`MMIO_TIMER_timer_wren)begin
// 			// 	timer_timer <= CPUDataBusOut;
// 			// end
// 		end
// 	end
// end


//----------------------------------------------------------------------------------------
// timer_start: reset after set
always@(posedge clk or posedge rst) begin
	if (rst) begin
		timer_start <= 0;
	end
	else if (timer_start_set) begin
		timer_start <= 64'd1;
	end
	else if (timer_start == 64'd1) begin
		timer_start <= 0;
	end
end

always@(posedge clk or posedge rst) begin
	if (rst) begin
		timer_state <= TIMER_STATE_OFF;
	end
	else begin
		case(timer_state)
			TIMER_STATE_OFF: begin
				if (timer_start == 64'd1) begin
					timer_state <= TIMER_STATE_ON;
				end
			end
			TIMER_STATE_ON: begin
				if (timer_rden == 64'd1) begin
					timer_state <= TIMER_STATE_OFF;
				end
			end
		endcase
	end
end

always@(posedge clk or posedge rst) begin
	if (rst) begin
		timer_timer <= 0;
	end
	else begin
		if (timer_state == TIMER_STATE_OFF) begin
			timer_timer <= 0;
		end
		else if (timer_state == TIMER_STATE_ON) begin
			timer_timer <= timer_timer + 1'b1;
		end
	end
end

assign timer_rden = `MMIO_TIMER_timer_rden;
assign timer_start_set = `MMIO_TIMER_start_wren && (CPUDataBusOut == 64'd1);
//----------------------------------------------------------------------------------------
