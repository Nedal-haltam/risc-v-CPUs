


`define reset 4

`ifndef vscode
`timescale 1ns/1ps
`endif

`ifdef vscode
`include "SC_CPU.v"
`endif

module SingleCycle_sim;

reg clk = 1, rst = 1;
wire [31 : 0] cycles_consumed;

SC_CPU cpu(clk, rst, cycles_consumed, clkout);


always #1 clk <= ~clk;
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

$display("Number of cycles consumed : %d", cycles_consumed);
$finish;

end
	
	
endmodule
