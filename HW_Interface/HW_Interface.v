
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
reg [7:0] DataOut;
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

wire `BIT_WIDTH AddressBus1, DMDataBus, DataBusOut1;
wire [10:0] ControlBus;
wire `BIT_WIDTH CyclesConsumed;

// FSM states
localparam IDLE    = 4'd0;
localparam SENDING = 4'd1;

reg [3:0] state;
always @(negedge clk or posedge rst) begin
    if (rst) begin
		done    <= 1'b1;
        offset  <= 0;
        DataOut <= 0;
        state   <= IDLE;
    end
	else begin
        case (state)

        IDLE: begin
			if (write_ecall) begin
				done    <= 1'b0;
				offset  <= 0;
				DataOut <= 0;
                state <= SENDING;
            end
			else begin
				done    <= 1'b1;
				offset  <= 0;
				DataOut <= 0;
				state <= IDLE;
			end
        end

        SENDING: begin
            if (offset < write_ecall_len) begin
				done <= 0;
                offset  <= offset + 1'b1;
                DataOut <= DMDataBus[7:0];
            end
			else begin
				done <= 1'b1;
                offset  <= 0;
                DataOut <= 0;
				state <= IDLE;
            end
        end
        endcase
    end
end

CPU cpu_dut
(
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

// TODO: use real altera dual-port ram 2 read / 2 write
// DataMemory MemoryModule
// (
// 	.rst(rst),
// 	.clock(~clk),
// 	.storetype       (write_ecall ? (`STORE_BYTE) : (ControlBus[10:7])),
//     .MemReadEn       (write_ecall ? (1'b1) : (ControlBus[1])),
//     .MemWriteEn      (write_ecall ? (1'b0) : (ControlBus[2])),
// 	.AddressBus      (write_ecall ? (write_ecall_address + offset) : (AddressBus1)),
// 	.DataMemoryInput (write_ecall ? (0) : (DataBusOut1)),
// 	.DataMemoryOutput(DMDataBus)
// );

dualpram dualpram_inst
(
	.clock_a(clk),
	.rden_a(write_ecall | ControlBus[1]),
	.wren_a(~write_ecall & ControlBus[2]),
	.address_a(write_ecall ? 
	(write_ecall_address[(`MEMORY_BITS-1):0] + offset[(`MEMORY_BITS-1):0]) : 
	(AddressBus1[(`MEMORY_BITS-1):0])),
	.data_a(write_ecall ? (0) : (DataBusOut1)),
	.q_a(DMDataBus),

	.clock_b(0),
	.rden_b(0),
	.wren_b(0),
	.address_b(0),
	.data_b(0),
	.q_b()
);

// bcd7seg HEX0_DISP
// (
// 	.num(offset[3:0]),
// 	.display(HEX0)
// );

// bcd7seg HEX1_DISP
// (
// 	.num(DMDataBus[3:0]),
// 	.display(HEX1)
// );

// bcd7seg HEX2_DISP
// (
// 	.num(DMDataBus[7:4]),
// 	.display(HEX2)
// );

assign datatrigger = (!done) ? (rst | clk) : (1'b0);
assign ARDUINO_IO[7:0] = DataOut;
assign ARDUINO_IO[8] = datatrigger;
assign ARDUINO_RESET_N = 1'b1;

assign write_ecall_finished = done;

assign clk = ClockDivider[16];
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

