
`include "./singlecycle/defs.h"

module DataMemory
(
	input clock, MemReadEn, MemWriteEn,
	input `BIT_WIDTH AddressBus,
	input `BIT_WIDTH DataMemoryInput,
	output reg `BIT_WIDTH DataMemoryOutput
);


reg [7 : 0] DataMem [0 : (`MEMORY_SIZE-1)];
always @(negedge clock) begin
    if (MemReadEn) begin
        DataMemoryOutput[(8 * 1) - 1:8 * 0] <= DataMem[AddressBus[(`MEMORY_BITS-1):0] + 0];
        DataMemoryOutput[(8 * 2) - 1:8 * 1] <= DataMem[AddressBus[(`MEMORY_BITS-1):0] + 1];
        DataMemoryOutput[(8 * 3) - 1:8 * 2] <= DataMem[AddressBus[(`MEMORY_BITS-1):0] + 2];
        DataMemoryOutput[(8 * 4) - 1:8 * 3] <= DataMem[AddressBus[(`MEMORY_BITS-1):0] + 3];
	end
    if (MemWriteEn) begin
        DataMem[AddressBus + 0] <= DataMemoryInput[(8 * 1) - 1:8 * 0];
        DataMem[AddressBus + 1] <= DataMemoryInput[(8 * 2) - 1:8 * 1];
        DataMem[AddressBus + 2] <= DataMemoryInput[(8 * 3) - 1:8 * 2];
        DataMem[AddressBus + 3] <= DataMemoryInput[(8 * 4) - 1:8 * 3];
	end
end
integer i;
initial begin
for (i = 0; i <= (`MEMORY_SIZE-1); i = i + 1)
    DataMem[i] <= 0;

`include "DM_INIT.INIT"
end

`ifdef simulate
	initial begin
		#(`MAX_CLOCKS + `reset+1);
		$display("Data Memory Content : ");
		for (i = 0; i <= (`MEMORY_SIZE-1); i = i + 1) begin
			$display("Mem[%d] = %d",i[(`MEMORY_BITS-1):0],$signed(DataMem[i]));
		end
	end 
`endif
endmodule
