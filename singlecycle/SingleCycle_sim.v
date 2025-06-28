


`define reset 4

`ifndef vscode
`timescale 1ns/1ps
`endif

`ifdef vscode
`include "SC_CPU.v"
`endif

module SingleCycle_sim;

reg InputClk = 1, rst = 1;
wire [31:0] CyclesConsumed;

SC_CPU dut
(
	.InputClk(InputClk), 
    .rst(rst),
	// output `BIT_WIDTH AddressBus,
	// output `BIT_WIDTH DataBus,
	// output [2:0] ControlBus,
	.CyclesConsumed(CyclesConsumed)
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

rst = 0; #(`reset) rst = 1;

#(`MAX_CLOCKS + 1);

$display("Number of cycles consumed : ", CyclesConsumed);
$finish;

end
	
	
endmodule
