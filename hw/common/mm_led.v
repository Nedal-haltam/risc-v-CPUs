
//------------------------------------------------
// mm_leds
reg `BIT_WIDTH LED_MM_REG;
//-----------------------------------------------

// MMIO control circuit
always@(negedge clk or posedge rst) begin
	if (rst) begin
		LED_MM_REG <= 0;
	end
	else begin
		if (`MMIO_LED_wren) begin
			LED_MM_REG <= CPUDataBusOut;
		end
		else begin
		end
	end
end
assign mmio_dm_p2_en = 0;
assign mmio_clkPort2 = 0;
assign mmio_rdenPort2 = 0;
assign mmio_wrenPort2 = 0;
assign mmio_addressPort2 = 0;
assign mmio_dataPort2 = 0;
