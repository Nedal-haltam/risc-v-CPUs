
// `timescale 1ns/1ps

`include "./hw/singlecycle/defs.h"

`include "./hw/singlecycle/CPU.v"
`include "./hw/singlecycle/DataMemory.v"

module SingleCycle_sim;

reg InputClk = 1, rst = 0;
wire `BIT_WIDTH AddressBus, DataBusIn, DataBusOut;
wire [10:0] ControlBus;
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
	.clock(~InputClk), 
	.storetype(ControlBus[10:7]),
    .MemReadEn(ControlBus[1]), 
    .MemWriteEn(ControlBus[2]),
	.AddressBus(AddressBus),
	.DataMemoryInput(DataBusOut),
	.DataMemoryOutput(DataBusIn)
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
