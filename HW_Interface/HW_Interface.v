
`include "defs.h"

`define CPU_AddressBus AddressBus1[(`DM_BITS-1):0]

`define DataMem_rden (ControlBus[1] && ~((15360 <= `CPU_AddressBus) && (`CPU_AddressBus <= 16383)))
`define DataMem_wren (ControlBus[2] && ~((15360 <= `CPU_AddressBus) && (`CPU_AddressBus <= 16383)))

`define MMIO_rden (ControlBus[1] && ((15360 <= `CPU_AddressBus) && (`CPU_AddressBus <= 16383)))
`define MMIO_wren (ControlBus[2] && ((15360 <= `CPU_AddressBus) && (`CPU_AddressBus <= 16383)))

`define MMIO_LED_rden (ControlBus[1] && (`CPU_AddressBus == (16384 - (1 * 8))))
`define MMIO_LED_wren (ControlBus[2] && (`CPU_AddressBus == (16384 - (1 * 8))))

`define MMIO_ALU_in1_rden   (ControlBus[1] && (`CPU_AddressBus == (16384 - (2 * 8))))
`define MMIO_ALU_in1_wren   (ControlBus[2] && (`CPU_AddressBus == (16384 - (2 * 8))))
`define MMIO_ALU_in2_rden   (ControlBus[1] && (`CPU_AddressBus == (16384 - (3 * 8))))
`define MMIO_ALU_in2_wren   (ControlBus[2] && (`CPU_AddressBus == (16384 - (3 * 8))))
`define MMIO_ALU_out_rden   (ControlBus[1] && (`CPU_AddressBus == (16384 - (4 * 8))))
`define MMIO_ALU_out_wren   (ControlBus[2] && (`CPU_AddressBus == (16384 - (4 * 8))))
`define MMIO_ALU_start_rden (ControlBus[1] && (`CPU_AddressBus == (16384 - (5 * 8))))
`define MMIO_ALU_start_wren (ControlBus[2] && (`CPU_AddressBus == (16384 - (5 * 8))))
`define MMIO_ALU_done_rden  (ControlBus[1] && (`CPU_AddressBus == (16384 - (6 * 8))))
`define MMIO_ALU_done_wren  (ControlBus[2] && (`CPU_AddressBus == (16384 - (6 * 8))))

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

// MMIO
// LEDs
reg `BIT_WIDTH LED_MM_REG;
reg `BIT_WIDTH MMIODataBus;
// mm_alu
// 50 * 1000 cycle to get a delay of 5 sec
reg `BIT_WIDTH alu_in1, alu_in2, alu_out;
reg `BIT_WIDTH alu_start;
reg `BIT_WIDTH alu_done;
reg alu_done_set;
wire alu_start_set;
wire alu_done_rden;

parameter [3:0] ALU_STATE_OFF  = 4'd1;
parameter [3:0] ALU_STATE_ON   = 4'd2;
reg `BIT_WIDTH alu_counter;
reg [3:0] alu_state;
// mm_alu

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
wire [(`DM_BITS-1):0] write_ecall_mem_addr;

wire `BIT_WIDTH AddressBus1, DMDataBus, CPUDataBusIn, write_DMDataBus, CPUDataBusOut;
wire [10:0] ControlBus;
wire `BIT_WIDTH CyclesConsumed;

always@(negedge clk or posedge rst) begin
    if (rst) begin
		done <= 1'b1;
        offset <= 0;
    end
	else begin
		if (write_ecall) begin
			done <= (offset) >= (write_ecall_len);
		end
		else begin
			done <= 1'b1;
		end
		if (!done) begin
			offset <= offset + 64'd1;
		end
		else begin
			offset <= 0;
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
	.DataBusIn(CPUDataBusIn),
	.DataBusOut(CPUDataBusOut),
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
	.rden_a(`DataMem_rden),
	.wren_a(`DataMem_wren),
	.address_a(`CPU_AddressBus),
	.data_a(CPUDataBusOut),
	.q_a(DMDataBus),

	.clock_b(clk),
	.rden_b(!done),
	.wren_b(1'b0),
	.address_b(write_ecall_mem_addr),
	.data_b(0),
	.q_b(write_DMDataBus)
);

// MMIO control circuit
always@(negedge clk or posedge rst) begin
	if (rst) begin
		LED_MM_REG <= 0;
	end
	else if (`MMIO_rden) begin
		if (`MMIO_LED_rden) begin
			MMIODataBus <= LED_MM_REG;
		end
		else if (`MMIO_ALU_in1_rden) begin
			MMIODataBus <= alu_in1;
		end
		else if (`MMIO_ALU_in2_rden) begin
			MMIODataBus <= alu_in2;
		end
		else if (`MMIO_ALU_out_rden) begin
			MMIODataBus <= alu_out;
		end
		else if (`MMIO_ALU_start_rden) begin
			MMIODataBus <= alu_start;
		end
		else if (`MMIO_ALU_done_rden) begin
			MMIODataBus <= alu_done;
		end
		// add other MM regs to read from
	end
	else if (`MMIO_wren) begin
		if (`MMIO_LED_wren) begin
			LED_MM_REG <= CPUDataBusOut;
		end
		else if (`MMIO_ALU_in1_wren)begin
			alu_in1 <= CPUDataBusOut;
		end
		else if (`MMIO_ALU_in2_wren)begin
			alu_in2 <= CPUDataBusOut;
		end
		// else if (`MMIO_ALU_out_wren)begin
		// 	alu_out <= CPUDataBusOut;
		// end
		// else if (`MMIO_ALU_start_wren)begin
		// 	alu_start <= CPUDataBusOut;
		// end
		// else if (`MMIO_ALU_done_wren)begin
		// 	alu_done <= CPUDataBusOut;
		// end
		// add other MM regs to write to
	end
end


// alu_start: reset after set
always@(posedge clk or posedge rst) begin
	if (rst) begin
		alu_start <= 0;
	end
	else if (alu_start_set) begin
		alu_start <= 64'd1;
	end
	else if (alu_start == 64'd1) begin
		alu_start <= 0;
	end
end

// alu_done : reset after reading
always@(posedge clk or posedge rst) begin
	if (rst) begin
		alu_done <= 0;
	end
	else if (alu_done_set) begin
		alu_done <= 64'd1;
	end
	else if (alu_done_rden) begin
		alu_done <= 0;
	end
end

always@(posedge clk or posedge rst) begin
	if (rst) begin
		alu_state <= ALU_STATE_OFF;
		alu_counter <= 0;
		alu_done_set <= 0;
		alu_out <= 0;
	end
	else begin
		case(alu_state)
			ALU_STATE_OFF: begin
				alu_counter <= 0;
				alu_done_set <= 0;
				if (alu_start == 64'd1) begin
					alu_state <= ALU_STATE_ON;
				end
			end
			ALU_STATE_ON: begin
				alu_counter <= alu_counter + 1'b1;
				if (alu_counter == (50 * 1000)) begin
					alu_out <= alu_in1 + alu_in2;
					alu_done_set <= 1'b1;
					alu_state <= ALU_STATE_OFF;
				end
			end
		endcase
	end
end

assign alu_done_rden = `MMIO_ALU_done_rden;
assign alu_start_set = `MMIO_ALU_start_wren && (CPUDataBusOut == 64'd1);






// bcd7seg HEX0_DISP
// (
// 	.num(write_ecall_len[3:0]),
// 	.display(HEX0)
// );

assign datatrigger = (!done) ? (rst | ~clk) : (datatrigger);
assign ARDUINO_IO[7:0] = (!done && (offset) <= (write_ecall_len)) ? write_DMDataBus[7:0] : 8'd0;
assign ARDUINO_IO[8] = datatrigger;
assign ARDUINO_RESET_N = 1'b1;
assign write_ecall_mem_addr = write_ecall_address[(`DM_BITS-1):0] + offset[(`DM_BITS-1):0];
assign write_ecall_finished = done;
// TODO: show an idnication that the FPGA finished correctly through the 7seg, leds, exit code, ...
assign clk = ClockDivider[9];
assign rst = ~KEY[0];

assign CPUDataBusIn = (`DataMem_rden) ? DMDataBus : MMIODataBus;
assign LEDR = LED_MM_REG[9:0];

assign HEX0[0] = clk;
assign HEX0[1] = cpu_clk;
assign HEX0[2] = rst;
assign HEX0[3] = datatrigger;
assign HEX0[4] = done;
assign HEX0[5] = write_ecall_finished;
assign HEX0[6] = write_ecall;
assign HEX0[7] = exit_ecall;


endmodule

