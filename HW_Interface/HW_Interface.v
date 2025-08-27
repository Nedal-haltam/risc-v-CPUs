
`include "defs.h"

module HW_Interface(

	//////////// CLOCK //////////
	input 		          		ADC_CLK_10,
	input 		          		MAX10_CLK1_50,
	input 		          		MAX10_CLK2_50,

	//////////// SEG7 //////////
	output		     [7:0]		HEX0,
	output		     [7:0]		HEX1,
	output		     [7:0]		HEX2,
	output		     [7:0]		HEX3,
	output		     [7:0]		HEX4,
	output		     [7:0]		HEX5,

	//////////// KEY //////////
	input 		     [1:0]		KEY,

	//////////// LED //////////
	output		     [9:0]		LEDR,

	//////////// SW //////////
	input 		     [9:0]		SW,

	//////////// Arduino //////////
	inout 		    [15:0]		ARDUINO_IO,
	inout 		          		ARDUINO_RESET_N
);
`define CLK_BIT 15
reg [24:0] ClockDivider;
always@(posedge ADC_CLK_10) begin
	ClockDivider <= ClockDivider + 1'b1;
end
wire clk;
`define BUFFER_LEN 1025
reg [7:0] databuff [0 : `BUFFER_LEN - 1];

reg [31:0] index;
reg [7:0] DataOut;
reg done;

wire rst;
wire fillbuf;
wire datatrigger;
wire `BIT_WIDTH AddressBus, DataBusIn1, DataBusOut1, DataBusOut2, AddressBus2;
wire [10:0] ControlBus;

`define STR_LEN 10
reg [31:0] i;
always@(posedge clk, posedge fillbuf, posedge rst) begin
	if (rst) begin
		i = 0;
	end
	else if (fillbuf) begin
		databuff[i] = DataBusOut2[7:0];
		i = i + 32'd1;
	end
	else begin
		databuff[i] = 0;
	end
end

always@(posedge clk, posedge rst) begin
	if (rst) begin
		index = 0;
		DataOut = 0;
		done = 0;
	end
	else if (!done) begin
		done = (index >= `BUFFER_LEN) || (databuff[index] == 0);
		DataOut = databuff[index];
		index = index + 1'b1;
	end
end

assign datatrigger = (!done) ? rst | ~clk : 1'b0;
assign ARDUINO_IO[7:0] = DataOut;
assign ARDUINO_IO[8] = datatrigger;
assign ARDUINO_RESET_N = 1'b1;

assign clk = ClockDivider[`CLK_BIT];
assign rst = ~KEY[0];
assign fillbuf = ~KEY[1];

wire `BIT_WIDTH CyclesConsumed;
CPU cpu_dut
(
	.InputClk(clk),
	.rst(rst),
	.AddressBus(AddressBus1),
	.DataBusIn(DataBusIn1),
	.DataBusOut(DataBusOut1),
	.ControlBus(ControlBus),
	.CyclesConsumed(CyclesConsumed)
);

// TODO: use real altera dual-port ram 2 read / 2 write
DataMemory MemoryModule
(
	.clock1(~clk),
	.loadtype1(ControlBus[6:3]),
	.storetype1(ControlBus[10:7]),
    .MemReadEn1(ControlBus[1]),
    .MemWriteEn1(ControlBus[2]),
	.AddressBus1(AddressBus1),
	.DataMemoryInput1(DataBusOut1),
	.DataMemoryOutput1(DataBusIn1),

	.clock2(~clk),
	.loadtype2(`LOAD_BYTE), // TODO: drive the loadtype2, potentially always byte
    .MemReadEn2(fillbuf),
    .MemWriteEn2(1'b0),
	.AddressBus2(AddressBus2), // TODO: drive the AddressBus2, take the initial address from the CPU, potentially the addressbus of the cpu
	.DataMemoryInput2(DataBusOut2),
	.DataMemoryOutput2()
);

assign HEX0 = CyclesConsumed[7:0];

endmodule

