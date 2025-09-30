
`include "defs.h"

module DataMemory
(
	input rst,
	input clock1,
	input [3:0] loadtype1,
	input [3:0] storetype1,
	input MemReadEn1, MemWriteEn1,
	input `BIT_WIDTH AddressBus1,
	input `BIT_WIDTH DataMemoryInput1,
	output reg `BIT_WIDTH DataMemoryOutput1,
	input clock2,
	input [3:0] loadtype2,
	input MemReadEn2, MemWriteEn2,
	input `BIT_WIDTH AddressBus2,
	input `BIT_WIDTH DataMemoryInput2,
	output reg `BIT_WIDTH DataMemoryOutput2
);

reg [7 : 0] DataMem [0 : (`MEMORY_SIZE-1)];

initial begin
`include `DM_INIT_FILE_PATH
end

always @(posedge clock1, posedge rst) begin
	if (MemReadEn1) begin
		if (loadtype1 == `LOAD_BYTE) begin
			DataMemoryOutput1[(8 * 1) - 1:8 * 0] <= DataMem[AddressBus1[(`MEMORY_BITS-1):0] + 0];
			DataMemoryOutput1[63:8] <= {56{DataMem[AddressBus1[(`MEMORY_BITS-1):0] + 0][7]}};
		end
		else if (loadtype1 == `LOAD_HALFWORD) begin
			DataMemoryOutput1[(8 * 1) - 1:8 * 0] <= DataMem[AddressBus1[(`MEMORY_BITS-1):0] + 0];
			DataMemoryOutput1[(8 * 2) - 1:8 * 1] <= DataMem[AddressBus1[(`MEMORY_BITS-1):0] + 1];
			DataMemoryOutput1[63:16] <= {48{DataMem[AddressBus1[(`MEMORY_BITS-1):0] + 1][7]}};
		end
		else if (loadtype1 == `LOAD_WORD) begin
			DataMemoryOutput1[(8 * 1) - 1:8 * 0] <= DataMem[AddressBus1[(`MEMORY_BITS-1):0] + 0];
			DataMemoryOutput1[(8 * 2) - 1:8 * 1] <= DataMem[AddressBus1[(`MEMORY_BITS-1):0] + 1];
			DataMemoryOutput1[(8 * 3) - 1:8 * 2] <= DataMem[AddressBus1[(`MEMORY_BITS-1):0] + 2];
			DataMemoryOutput1[(8 * 4) - 1:8 * 3] <= DataMem[AddressBus1[(`MEMORY_BITS-1):0] + 3];
			DataMemoryOutput1[63:32] <= {32{DataMem[AddressBus1[(`MEMORY_BITS-1):0] + 3][7]}};
		end
		else if (loadtype1 == `LOAD_DOUBLEWORD) begin
			DataMemoryOutput1[(8 * 1) - 1:8 * 0] <= DataMem[AddressBus1[(`MEMORY_BITS-1):0] + 0];
			DataMemoryOutput1[(8 * 2) - 1:8 * 1] <= DataMem[AddressBus1[(`MEMORY_BITS-1):0] + 1];
			DataMemoryOutput1[(8 * 3) - 1:8 * 2] <= DataMem[AddressBus1[(`MEMORY_BITS-1):0] + 2];
			DataMemoryOutput1[(8 * 4) - 1:8 * 3] <= DataMem[AddressBus1[(`MEMORY_BITS-1):0] + 3];
			DataMemoryOutput1[(8 * 5) - 1:8 * 4] <= DataMem[AddressBus1[(`MEMORY_BITS-1):0] + 4];
			DataMemoryOutput1[(8 * 6) - 1:8 * 5] <= DataMem[AddressBus1[(`MEMORY_BITS-1):0] + 5];
			DataMemoryOutput1[(8 * 7) - 1:8 * 6] <= DataMem[AddressBus1[(`MEMORY_BITS-1):0] + 6];
			DataMemoryOutput1[(8 * 8) - 1:8 * 7] <= DataMem[AddressBus1[(`MEMORY_BITS-1):0] + 7];
		end
		else if (loadtype1 == `LOAD_BYTE_UNSIGNED) begin
			DataMemoryOutput1[(8 * 1) - 1:8 * 0] <= DataMem[AddressBus1[(`MEMORY_BITS-1):0] + 0];
			DataMemoryOutput1[63:8] <= 56'd0;
		end
		else if (loadtype1 == `LOAD_HALFWORD_UNSIGNED) begin
			DataMemoryOutput1[(8 * 1) - 1:8 * 0] <= DataMem[AddressBus1[(`MEMORY_BITS-1):0] + 0];
			DataMemoryOutput1[(8 * 2) - 1:8 * 1] <= DataMem[AddressBus1[(`MEMORY_BITS-1):0] + 1];
			DataMemoryOutput1[63:16] <= 48'd0;
		end
	end
	else begin
		DataMemoryOutput1 <= 0;
	end
	if (MemWriteEn1) begin
		if (storetype1 == `STORE_BYTE) begin
			DataMem[AddressBus1[(`MEMORY_BITS-1):0] + 0] <= DataMemoryInput1[(8 * 1) - 1:8 * 0];
		end
		else if (storetype1 == `STORE_HALFWORD) begin
			DataMem[AddressBus1[(`MEMORY_BITS-1):0] + 0] <= DataMemoryInput1[(8 * 1) - 1:8 * 0];
			DataMem[AddressBus1[(`MEMORY_BITS-1):0] + 1] <= DataMemoryInput1[(8 * 2) - 1:8 * 1];
		end
		else if (storetype1 == `STORE_WORD) begin
			DataMem[AddressBus1[(`MEMORY_BITS-1):0] + 0] <= DataMemoryInput1[(8 * 1) - 1:8 * 0];
			DataMem[AddressBus1[(`MEMORY_BITS-1):0] + 1] <= DataMemoryInput1[(8 * 2) - 1:8 * 1];
			DataMem[AddressBus1[(`MEMORY_BITS-1):0] + 2] <= DataMemoryInput1[(8 * 3) - 1:8 * 2];
			DataMem[AddressBus1[(`MEMORY_BITS-1):0] + 3] <= DataMemoryInput1[(8 * 4) - 1:8 * 3];
		end
		else if (storetype1 == `STORE_DOUBLEWORD) begin
			DataMem[AddressBus1[(`MEMORY_BITS-1):0] + 0] <= DataMemoryInput1[(8 * 1) - 1:8 * 0];
			DataMem[AddressBus1[(`MEMORY_BITS-1):0] + 1] <= DataMemoryInput1[(8 * 2) - 1:8 * 1];
			DataMem[AddressBus1[(`MEMORY_BITS-1):0] + 2] <= DataMemoryInput1[(8 * 3) - 1:8 * 2];
			DataMem[AddressBus1[(`MEMORY_BITS-1):0] + 3] <= DataMemoryInput1[(8 * 4) - 1:8 * 3];
			DataMem[AddressBus1[(`MEMORY_BITS-1):0] + 4] <= DataMemoryInput1[(8 * 5) - 1:8 * 4];
			DataMem[AddressBus1[(`MEMORY_BITS-1):0] + 5] <= DataMemoryInput1[(8 * 6) - 1:8 * 5];
			DataMem[AddressBus1[(`MEMORY_BITS-1):0] + 6] <= DataMemoryInput1[(8 * 7) - 1:8 * 6];
			DataMem[AddressBus1[(`MEMORY_BITS-1):0] + 7] <= DataMemoryInput1[(8 * 8) - 1:8 * 7];
		end
		else begin
		end
	end
end

always @(posedge clock2) begin
    if (MemReadEn2) begin
		if (loadtype2 == `LOAD_BYTE) begin
    	    DataMemoryOutput2[(8 * 1) - 1:8 * 0] <= DataMem[AddressBus2[(`MEMORY_BITS-1):0] + 0];
			DataMemoryOutput2[63:8] <= {56{DataMem[AddressBus2[(`MEMORY_BITS-1):0] + 0][7]}};
		end
		else if (loadtype2 == `LOAD_HALFWORD) begin
			DataMemoryOutput2[(8 * 1) - 1:8 * 0] <= DataMem[AddressBus2[(`MEMORY_BITS-1):0] + 0];
			DataMemoryOutput2[(8 * 2) - 1:8 * 1] <= DataMem[AddressBus2[(`MEMORY_BITS-1):0] + 1];
			DataMemoryOutput2[63:16] <= {48{DataMem[AddressBus2[(`MEMORY_BITS-1):0] + 1][7]}};
		end
		else if (loadtype2 == `LOAD_WORD) begin
			DataMemoryOutput2[(8 * 1) - 1:8 * 0] <= DataMem[AddressBus2[(`MEMORY_BITS-1):0] + 0];
			DataMemoryOutput2[(8 * 2) - 1:8 * 1] <= DataMem[AddressBus2[(`MEMORY_BITS-1):0] + 1];
			DataMemoryOutput2[(8 * 3) - 1:8 * 2] <= DataMem[AddressBus2[(`MEMORY_BITS-1):0] + 2];
			DataMemoryOutput2[(8 * 4) - 1:8 * 3] <= DataMem[AddressBus2[(`MEMORY_BITS-1):0] + 3];
			DataMemoryOutput2[63:32] <= {32{DataMem[AddressBus2[(`MEMORY_BITS-1):0] + 3][7]}};
		end
		else if (loadtype2 == `LOAD_DOUBLEWORD) begin
			DataMemoryOutput2[(8 * 1) - 1:8 * 0] <= DataMem[AddressBus2[(`MEMORY_BITS-1):0] + 0];
			DataMemoryOutput2[(8 * 2) - 1:8 * 1] <= DataMem[AddressBus2[(`MEMORY_BITS-1):0] + 1];
			DataMemoryOutput2[(8 * 3) - 1:8 * 2] <= DataMem[AddressBus2[(`MEMORY_BITS-1):0] + 2];
			DataMemoryOutput2[(8 * 4) - 1:8 * 3] <= DataMem[AddressBus2[(`MEMORY_BITS-1):0] + 3];
			DataMemoryOutput2[(8 * 5) - 1:8 * 4] <= DataMem[AddressBus2[(`MEMORY_BITS-1):0] + 4];
			DataMemoryOutput2[(8 * 6) - 1:8 * 5] <= DataMem[AddressBus2[(`MEMORY_BITS-1):0] + 5];
			DataMemoryOutput2[(8 * 7) - 1:8 * 6] <= DataMem[AddressBus2[(`MEMORY_BITS-1):0] + 6];
			DataMemoryOutput2[(8 * 8) - 1:8 * 7] <= DataMem[AddressBus2[(`MEMORY_BITS-1):0] + 7];
		end
		else if (loadtype2 == `LOAD_BYTE_UNSIGNED) begin
	        DataMemoryOutput2[(8 * 1) - 1:8 * 0] <= DataMem[AddressBus2[(`MEMORY_BITS-1):0] + 0];
			DataMemoryOutput2[63:8] <= 56'd0;
		end
		else if (loadtype2 == `LOAD_HALFWORD_UNSIGNED) begin
			DataMemoryOutput2[(8 * 1) - 1:8 * 0] <= DataMem[AddressBus2[(`MEMORY_BITS-1):0] + 0];
			DataMemoryOutput2[(8 * 2) - 1:8 * 1] <= DataMem[AddressBus2[(`MEMORY_BITS-1):0] + 1];
			DataMemoryOutput2[63:16] <= 48'd0;
		end
	end
	else begin
		DataMemoryOutput2 <= 0;
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
