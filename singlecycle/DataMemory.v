
`include "defs.h"

module DataMemory
(
	input rst,
	input clock,
	input [3:0] storetype,
	input MemReadEn, MemWriteEn,
	input `BIT_WIDTH AddressBus,
	input `BIT_WIDTH DataMemoryInput,
	output reg `BIT_WIDTH DataMemoryOutput
);

reg [7 : 0] DataMem [0 : (`MEMORY_SIZE-1)];

initial begin
	for (i = 0; i <= `MEMORY_SIZE/2; i = i + 1)
		DataMem[i] <= 0;
	for (i = `MEMORY_SIZE/2+1; i <= (`MEMORY_SIZE-1); i = i + 1)
		DataMem[i] <= 0;

	`include `DM_INIT_FILE_PATH
end

always @(posedge clock) begin
	if (MemReadEn) begin
		DataMemoryOutput[(8 * 1) - 1:8 * 0] <= DataMem[AddressBus[(`MEMORY_BITS-1):0] + 0];
		DataMemoryOutput[(8 * 2) - 1:8 * 1] <= DataMem[AddressBus[(`MEMORY_BITS-1):0] + 1];
		DataMemoryOutput[(8 * 3) - 1:8 * 2] <= DataMem[AddressBus[(`MEMORY_BITS-1):0] + 2];
		DataMemoryOutput[(8 * 4) - 1:8 * 3] <= DataMem[AddressBus[(`MEMORY_BITS-1):0] + 3];
		DataMemoryOutput[(8 * 5) - 1:8 * 4] <= DataMem[AddressBus[(`MEMORY_BITS-1):0] + 4];
		DataMemoryOutput[(8 * 6) - 1:8 * 5] <= DataMem[AddressBus[(`MEMORY_BITS-1):0] + 5];
		DataMemoryOutput[(8 * 7) - 1:8 * 6] <= DataMem[AddressBus[(`MEMORY_BITS-1):0] + 6];
		DataMemoryOutput[(8 * 8) - 1:8 * 7] <= DataMem[AddressBus[(`MEMORY_BITS-1):0] + 7];
	end
	else begin
		DataMemoryOutput <= 0;
	end
	if (MemWriteEn) begin
		if (storetype == `STORE_BYTE) begin
			DataMem[AddressBus[(`MEMORY_BITS-1):0] + 0] <= DataMemoryInput[(8 * 1) - 1:8 * 0];
		end
		else if (storetype == `STORE_HALFWORD) begin
			DataMem[AddressBus[(`MEMORY_BITS-1):0] + 0] <= DataMemoryInput[(8 * 1) - 1:8 * 0];
			DataMem[AddressBus[(`MEMORY_BITS-1):0] + 1] <= DataMemoryInput[(8 * 2) - 1:8 * 1];
		end
		else if (storetype == `STORE_WORD) begin
			DataMem[AddressBus[(`MEMORY_BITS-1):0] + 0] <= DataMemoryInput[(8 * 1) - 1:8 * 0];
			DataMem[AddressBus[(`MEMORY_BITS-1):0] + 1] <= DataMemoryInput[(8 * 2) - 1:8 * 1];
			DataMem[AddressBus[(`MEMORY_BITS-1):0] + 2] <= DataMemoryInput[(8 * 3) - 1:8 * 2];
			DataMem[AddressBus[(`MEMORY_BITS-1):0] + 3] <= DataMemoryInput[(8 * 4) - 1:8 * 3];
		end
		else if (storetype == `STORE_DOUBLEWORD) begin
			DataMem[AddressBus[(`MEMORY_BITS-1):0] + 0] <= DataMemoryInput[(8 * 1) - 1:8 * 0];
			DataMem[AddressBus[(`MEMORY_BITS-1):0] + 1] <= DataMemoryInput[(8 * 2) - 1:8 * 1];
			DataMem[AddressBus[(`MEMORY_BITS-1):0] + 2] <= DataMemoryInput[(8 * 3) - 1:8 * 2];
			DataMem[AddressBus[(`MEMORY_BITS-1):0] + 3] <= DataMemoryInput[(8 * 4) - 1:8 * 3];
			DataMem[AddressBus[(`MEMORY_BITS-1):0] + 4] <= DataMemoryInput[(8 * 5) - 1:8 * 4];
			DataMem[AddressBus[(`MEMORY_BITS-1):0] + 5] <= DataMemoryInput[(8 * 6) - 1:8 * 5];
			DataMem[AddressBus[(`MEMORY_BITS-1):0] + 6] <= DataMemoryInput[(8 * 7) - 1:8 * 6];
			DataMem[AddressBus[(`MEMORY_BITS-1):0] + 7] <= DataMemoryInput[(8 * 8) - 1:8 * 7];
		end
		else begin
		end
	end
end

integer i;
`ifdef simulate
	initial begin
		#(`MAX_CLOCKS + `reset+1);
		$display("Data Memory Content : ");
		for (i = 0; i <= (`MEMORY_SIZE-1); i = i + 1) begin
			$display("Mem[%d] = signed =  %d , unsigned = %d", i[(`MEMORY_BITS-1):0], $signed(DataMem[i]), $unsigned(DataMem[i]));
		end
	end 
`endif
endmodule
