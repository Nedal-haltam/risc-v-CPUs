
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

reg [24:0] ClockDivider;
always@(posedge ADC_CLK_10) begin
	ClockDivider <= ClockDivider + 1'b1;
end

reg `BIT_WIDTH offset;
reg done;

wire clk;
wire rst;
wire cpu_clk;

wire exit_ecall;
wire write_ecall_finished;
wire write_ecall;
wire `BIT_WIDTH write_ecall_fd;
wire `BIT_WIDTH write_ecall_address;
wire `BIT_WIDTH write_ecall_len;
wire datatrigger;
wire [(`MEMORY_BITS-1):0] write_ecall_mem_addr;

wire `BIT_WIDTH AddressBus1, DMDataBus, write_DMDataBus, DataBusOut1;
wire [10:0] ControlBus;
wire `BIT_WIDTH CyclesConsumed;

always @(negedge clk or posedge rst) begin
    if (rst) begin
		done    <= 1'b1;
        offset  <= 0;
    end
	else begin
		if (write_ecall) begin
			done    <= (offset) >= (write_ecall_len);
		end
		else begin
			done    <= 1'b1;
		end
		if (!done) begin
			offset  <= offset + 64'd1;
		end
		else begin
			offset  <= 0;
		end
    end
end
reg `BIT_WIDTH pc;
CPU cpu_dut
(
	.pc(pc),
	.InputClk(clk),
	.cpu_clk(cpu_clk),
	.rst(rst),
	.AddressBus(AddressBus1),
	.DataBusIn(DMDataBus),
	.DataBusOut(DataBusOut1),
	.ControlBus(ControlBus),
	.CyclesConsumed(CyclesConsumed),

	.exit_ecall(exit_ecall),
	.write_ecall_finished(write_ecall_finished),
	.write_ecall(write_ecall),
	.write_ecall_fd(write_ecall_fd), // TODO: we should handle it, for now it is ignored
	.write_ecall_address(write_ecall_address),
	.write_ecall_len(write_ecall_len)
);

dualpram dualpram_inst
(
	.clock_a(~clk),
	.rden_a(ControlBus[1]),
	.wren_a(ControlBus[2]),
	.address_a(AddressBus1[(`MEMORY_BITS-1):0]),
	.data_a(DataBusOut1),
	.q_a(DMDataBus),

	.clock_b(clk),
	.rden_b(!done),
	.wren_b(1'b0),
	.address_b(write_ecall_mem_addr),
	.data_b(0),
	.q_b(write_DMDataBus)
);

// bcd7seg HEX0_DISP
// (
// 	.num(write_ecall_len[3:0]),
// 	.display(HEX0)
// );

// bcd7seg HEX1_DISP
// (
// 	.num(write_ecall_len[7:4]),
// 	.display(HEX1)
// );

// bcd7seg HEX2_DISP
// (
// 	.num(pc[11:8]),
// 	.display(HEX2)
// );

assign datatrigger = (!done) ? (rst | ~clk) : (datatrigger);
assign ARDUINO_IO[7:0] = (!done && (offset) <= (write_ecall_len)) ? write_DMDataBus[7:0] : 8'd0;
assign ARDUINO_IO[8] = datatrigger;
assign ARDUINO_RESET_N = 1'b1;
assign write_ecall_mem_addr = write_ecall_address[(`MEMORY_BITS-1):0] + offset[(`MEMORY_BITS-1):0];
assign write_ecall_finished = done;

assign clk = ClockDivider[10];
assign rst = ~KEY[0];

assign LEDR[0] = clk;
assign LEDR[1] = cpu_clk;
assign LEDR[2] = rst;
assign LEDR[3] = datatrigger;
assign LEDR[4] = done;
assign LEDR[5] = write_ecall_finished;
assign LEDR[6] = write_ecall;
assign LEDR[7] = exit_ecall;


endmodule

