
`define reset 4

`timescale 1ns/1ps

module SingleCycle_sim;

reg InputClk = 1, rst = 0;
wire `BIT_WIDTH AddressBus, DataBusIn, DataBusOut;
wire [2:0] ControlBus;
wire [31:0] CyclesConsumed;

SC_CPU dut
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
	.clock(InputClk), 
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

// $dumpfile("SingleCycle_Waveform.vcd");
// $dumpvars;

`endif

rst = 1; #(`reset) rst = 0;

#(`MAX_CLOCKS + 1);

$display("Number of cycles consumed : ", CyclesConsumed);
$finish;

end
	
	
endmodule
