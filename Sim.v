
// `timescale 1ns/1ps

`include "./singlecycle/defs.h"

`include "./singlecycle/CPU.v"
`include "./singlecycle/DataMemory.v"

module SingleCycle_sim;

reg InputClk = 1, rst = 0;
wire `BIT_WIDTH AddressBus, DataBusIn, DataBusOut;
wire [2:0] ControlBus;
wire `BIT_WIDTH CyclesConsumed;

CPU dut
(
	.InputClk(InputClk), 
    .rst(rst),
	.AddressBus(AddressBus),
	.DataBusIn(DataBusIn),
	.DataBusOut(DataBusOut),
	.ControlBus(ControlBus),
	.CyclesConsumed(CyclesConsumed)
);

DataMemory MemoryModule
(
	.clock1(~InputClk), 
    .MemReadEn1(ControlBus[1]), 
    .MemWriteEn1(ControlBus[2]),
	.AddressBus1(AddressBus),
	.DataMemoryInput1(DataBusOut),
	.DataMemoryOutput1(DataBusIn)
);

always #1 InputClk <= ~InputClk;
initial begin

`ifdef VCD_OUT

$dumpfile(`VCD_OUT);
$dumpvars;

`else

$dumpfile("SingleCycle_Waveform.vcd");
$dumpvars;

`endif

rst = 1; #(`reset) rst = 0;

#(`MAX_CLOCKS);

$display("Number of cycles consumed : %d", CyclesConsumed[31:0]);
#1;
$finish;


end
	
	
endmodule
