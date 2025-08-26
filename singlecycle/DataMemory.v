
`include "defs.h"

module DataMemory
(
	input clock1,
	input MemReadEn1, MemWriteEn1,
	input `BIT_WIDTH AddressBus1,
	input `BIT_WIDTH DataMemoryInput1,
	output reg `BIT_WIDTH DataMemoryOutput1,
	input clock2,
	input MemReadEn2, MemWriteEn2,
	input `BIT_WIDTH AddressBus2,
	input `BIT_WIDTH DataMemoryInput2,
	output reg `BIT_WIDTH DataMemoryOutput2
);


reg [7 : 0] DataMem [0 : (`MEMORY_SIZE-1)];
always @(posedge clock1) begin
    if (MemReadEn1) begin
        DataMemoryOutput1[(8 * 1) - 1:8 * 0] <= DataMem[AddressBus1[(`MEMORY_BITS-1):0] + 0];
        DataMemoryOutput1[(8 * 2) - 1:8 * 1] <= DataMem[AddressBus1[(`MEMORY_BITS-1):0] + 1];
        DataMemoryOutput1[(8 * 3) - 1:8 * 2] <= DataMem[AddressBus1[(`MEMORY_BITS-1):0] + 2];
        DataMemoryOutput1[(8 * 4) - 1:8 * 3] <= DataMem[AddressBus1[(`MEMORY_BITS-1):0] + 3];
		DataMemoryOutput1[63:32] <= {32{DataMem[AddressBus1[(`MEMORY_BITS-1):0] + 3][7]}};
	end
	else begin
		DataMemoryOutput1 <= 0;
	end
    if (MemWriteEn1) begin
        DataMem[AddressBus1[(`MEMORY_BITS-1):0] + 0] <= DataMemoryInput1[(8 * 1) - 1:8 * 0];
        DataMem[AddressBus1[(`MEMORY_BITS-1):0] + 1] <= DataMemoryInput1[(8 * 2) - 1:8 * 1];
        DataMem[AddressBus1[(`MEMORY_BITS-1):0] + 2] <= DataMemoryInput1[(8 * 3) - 1:8 * 2];
        DataMem[AddressBus1[(`MEMORY_BITS-1):0] + 3] <= DataMemoryInput1[(8 * 4) - 1:8 * 3];
	end
end

always @(posedge clock2) begin
    if (MemReadEn2) begin
        DataMemoryOutput2[(8 * 1) - 1:8 * 0] <= DataMem[AddressBus2[(`MEMORY_BITS-1):0] + 0];
        DataMemoryOutput2[(8 * 2) - 1:8 * 1] <= DataMem[AddressBus2[(`MEMORY_BITS-1):0] + 1];
        DataMemoryOutput2[(8 * 3) - 1:8 * 2] <= DataMem[AddressBus2[(`MEMORY_BITS-1):0] + 2];
        DataMemoryOutput2[(8 * 4) - 1:8 * 3] <= DataMem[AddressBus2[(`MEMORY_BITS-1):0] + 3];
		DataMemoryOutput2[63:32] <= {32{DataMem[AddressBus2[(`MEMORY_BITS-1):0] + 3][7]}};
	end
	else begin
		DataMemoryOutput2 <= 0;
	end
end




integer i;
initial begin
for (i = 0; i <= `MEMORY_SIZE/2; i = i + 1)
    DataMem[i] <= 0;
for (i = `MEMORY_SIZE/2+1; i <= (`MEMORY_SIZE-1); i = i + 1)
    DataMem[i] <= 0;

`include `DM_INIT_FILE_PATH
end

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
