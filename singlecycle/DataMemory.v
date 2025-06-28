

module DataMemory
(
	input clock, MemReadEn, MemWriteEn,
	input `BIT_WIDTH AddressBus,
	input `BIT_WIDTH DataMemoryInput,
	output reg `BIT_WIDTH DataMemoryOutput
);

reg [31 : 0] DataMem [0 : (`MEMORY_SIZE-1)];
always @(negedge clock) begin
    if (MemReadEn) begin
        DataMemoryOutput <= DataMem[AddressBus[(`MEMORY_BITS-1):0]];
	end
    if (MemWriteEn) begin
        DataMem[AddressBus] <= DataMemoryInput;
	end
end
initial begin
for (i = 0; i <= (`MEMORY_SIZE-1); i = i + 1)
    DataMem[i] <= 0;

`include "DM_INIT.INIT"
end

`ifdef vscode
	integer i;
	initial begin
		#(`MAX_CLOCKS + `reset);
		$display("Data Memory Content : ");
		for (i = 0; i <= (`MEMORY_SIZE-1); i = i + 1) begin
			$display("Mem[%d] = %d",i[(`MEMORY_BITS-1):0],$signed(DataMem[i]));
		end
	end 
`endif
endmodule
