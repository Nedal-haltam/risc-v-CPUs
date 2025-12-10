
`include "defs.h"

`define write_clkPort2     (clk)
`define write_rdenPort2    (!done)
`define write_wrenPort2    (1'b0)
`define write_addressPort2 (write_ecall_mem_addr)
`define write_dataPort2    (0)

`define CPU_AddressBus AddressBus1[(`DM_BITS-1):0]
`define DataMem_rden (ControlBus[1] && ~((15360 <= `CPU_AddressBus) && (`CPU_AddressBus <= 16383)))
`define DataMem_wren (ControlBus[2] && ~((15360 <= `CPU_AddressBus) && (`CPU_AddressBus <= 16383)))
`define MMIO_rden (ControlBus[1] && ((15360 <= `CPU_AddressBus) && (`CPU_AddressBus <= 16383)))
`define MMIO_wren (ControlBus[2] && ((15360 <= `CPU_AddressBus) && (`CPU_AddressBus <= 16383)))

`define ENABLE_MMIO
`define ENABLE_MMIO_LED
// `define ENABLE_MMIO_ALU
// `define ENABLE_MMIO_VADD
// `define ENABLE_MMIO_CONV1D
// `define ENABLE_MMIO_CONV1D_PL

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

`define MMIO_VADD_addr_in1_rden (ControlBus[1] && (`CPU_AddressBus == (16384 - (7 * 8))))
`define MMIO_VADD_addr_in1_wren (ControlBus[2] && (`CPU_AddressBus == (16384 - (7 * 8))))
`define MMIO_VADD_addr_in2_rden (ControlBus[1] && (`CPU_AddressBus == (16384 - (8 * 8))))
`define MMIO_VADD_addr_in2_wren (ControlBus[2] && (`CPU_AddressBus == (16384 - (8 * 8))))
`define MMIO_VADD_addr_out_rden (ControlBus[1] && (`CPU_AddressBus == (16384 - (9 * 8))))
`define MMIO_VADD_addr_out_wren (ControlBus[2] && (`CPU_AddressBus == (16384 - (9 * 8))))
`define MMIO_VADD_vsize_rden    (ControlBus[1] && (`CPU_AddressBus == (16384 - (10 * 8))))
`define MMIO_VADD_vsize_wren    (ControlBus[2] && (`CPU_AddressBus == (16384 - (10 * 8))))
`define MMIO_VADD_start_rden    (ControlBus[1] && (`CPU_AddressBus == (16384 - (11 * 8))))
`define MMIO_VADD_start_wren    (ControlBus[2] && (`CPU_AddressBus == (16384 - (11 * 8))))
`define MMIO_VADD_done_rden     (ControlBus[1] && (`CPU_AddressBus == (16384 - (12 * 8))))
`define MMIO_VADD_done_wren     (ControlBus[2] && (`CPU_AddressBus == (16384 - (12 * 8))))

`define MMIO_CONV1D_addr_in1_rden (ControlBus[1] && (`CPU_AddressBus == (16384 - (13 * 8))))
`define MMIO_CONV1D_addr_in1_wren (ControlBus[2] && (`CPU_AddressBus == (16384 - (13 * 8))))
`define MMIO_CONV1D_addr_in2_rden (ControlBus[1] && (`CPU_AddressBus == (16384 - (14 * 8))))
`define MMIO_CONV1D_addr_in2_wren (ControlBus[2] && (`CPU_AddressBus == (16384 - (14 * 8))))
`define MMIO_CONV1D_addr_out_rden (ControlBus[1] && (`CPU_AddressBus == (16384 - (15 * 8))))
`define MMIO_CONV1D_addr_out_wren (ControlBus[2] && (`CPU_AddressBus == (16384 - (15 * 8))))
`define MMIO_CONV1D_vsize_rden    (ControlBus[1] && (`CPU_AddressBus == (16384 - (16 * 8))))
`define MMIO_CONV1D_vsize_wren    (ControlBus[2] && (`CPU_AddressBus == (16384 - (16 * 8))))
`define MMIO_CONV1D_start_rden    (ControlBus[1] && (`CPU_AddressBus == (16384 - (17 * 8))))
`define MMIO_CONV1D_start_wren    (ControlBus[2] && (`CPU_AddressBus == (16384 - (17 * 8))))
`define MMIO_CONV1D_done_rden     (ControlBus[1] && (`CPU_AddressBus == (16384 - (18 * 8))))
`define MMIO_CONV1D_done_wren     (ControlBus[2] && (`CPU_AddressBus == (16384 - (18 * 8))))

`define MMIO_CONV1D_PL_addr_in1_rden (ControlBus[1] && (`CPU_AddressBus == (16384 - (19 * 8))))
`define MMIO_CONV1D_PL_addr_in1_wren (ControlBus[2] && (`CPU_AddressBus == (16384 - (19 * 8))))
`define MMIO_CONV1D_PL_addr_in2_rden (ControlBus[1] && (`CPU_AddressBus == (16384 - (20 * 8))))
`define MMIO_CONV1D_PL_addr_in2_wren (ControlBus[2] && (`CPU_AddressBus == (16384 - (20 * 8))))
`define MMIO_CONV1D_PL_addr_out_rden (ControlBus[1] && (`CPU_AddressBus == (16384 - (21 * 8))))
`define MMIO_CONV1D_PL_addr_out_wren (ControlBus[2] && (`CPU_AddressBus == (16384 - (21 * 8))))
`define MMIO_CONV1D_PL_vsize_rden    (ControlBus[1] && (`CPU_AddressBus == (16384 - (22 * 8))))
`define MMIO_CONV1D_PL_vsize_wren    (ControlBus[2] && (`CPU_AddressBus == (16384 - (22 * 8))))
`define MMIO_CONV1D_PL_start_rden    (ControlBus[1] && (`CPU_AddressBus == (16384 - (23 * 8))))
`define MMIO_CONV1D_PL_start_wren    (ControlBus[2] && (`CPU_AddressBus == (16384 - (23 * 8))))
`define MMIO_CONV1D_PL_done_rden     (ControlBus[1] && (`CPU_AddressBus == (16384 - (24 * 8))))
`define MMIO_CONV1D_PL_done_wren     (ControlBus[2] && (`CPU_AddressBus == (16384 - (24 * 8))))

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

wire clk;
wire rst;
wire cpu_clk;
wire `BIT_WIDTH pc;

wire exit_ecall;
wire write_ecall_finished;
wire write_ecall;
wire `BIT_WIDTH write_ecall_fd;
wire `BIT_WIDTH write_ecall_address;
wire `BIT_WIDTH write_ecall_len;
wire datatrigger;
wire [(`DM_BITS-1):0] write_ecall_mem_addr;

wire `BIT_WIDTH AddressBus1, DMDataBusPort1, CPUDataBusIn, DMDataBusPort2, CPUDataBusOut;
wire [10:0] ControlBus;
wire `BIT_WIDTH CyclesConsumed;

reg `BIT_WIDTH offset;
reg done;

wire clkPort2, rdenPort2, wrenPort2;
wire [(`DM_BITS - 1):0] addressPort2;
wire `BIT_WIDTH dataPort2;

//------------------------------------------------
// MMIO
reg `BIT_WIDTH MMIODataBus = 0;
wire mmio_dm_p2_en;
wire mmio_clkPort2, mmio_rdenPort2, mmio_wrenPort2;
wire [(`DM_BITS - 1):0] mmio_addressPort2;
wire `BIT_WIDTH mmio_dataPort2;
//------------------------------------------------

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
			offset <= offset + 1'b1;
		end
		else begin
			offset <= 0;
		end
    end
end

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
	.q_a(DMDataBusPort1),


	.clock_b(clkPort2),
	.rden_b(rdenPort2),
	.wren_b(wrenPort2),
	.address_b(addressPort2),
	.data_b(dataPort2),
	.q_b(DMDataBusPort2)
);

// MMIO control circuit
always@(negedge clk or posedge rst) begin
	if (rst) begin
		MMIODataBus <= 0;
	end
	else begin
`ifdef ENABLE_MMIO_LED
		if (`MMIO_LED_rden) begin
			MMIODataBus <= LED_MM_REG;
		end
`endif
`ifdef ENABLE_MMIO_ALU
		if (`MMIO_ALU_in1_rden) begin
			MMIODataBus <= alu_in1;
		end
		if (`MMIO_ALU_in2_rden) begin
			MMIODataBus <= alu_in2;
		end
		if (`MMIO_ALU_out_rden) begin
			MMIODataBus <= alu_out;
		end
		if (`MMIO_ALU_start_rden) begin
			MMIODataBus <= alu_start;
		end
		if (`MMIO_ALU_done_rden) begin
			MMIODataBus <= alu_done;
		end
`endif
`ifdef ENABLE_MMIO_VADD
		if (`MMIO_VADD_addr_in1_rden) begin
			MMIODataBus <= vadd_addr_in1;
		end
		if (`MMIO_VADD_addr_in2_rden) begin
			MMIODataBus <= vadd_addr_in2;
		end
		if (`MMIO_VADD_addr_out_rden) begin
			MMIODataBus <= vadd_addr_out;
		end
		if (`MMIO_VADD_vsize_rden) begin
			MMIODataBus <= vadd_vsize;
		end
		if (`MMIO_VADD_start_rden) begin
			MMIODataBus <= vadd_start;
		end
		if (`MMIO_VADD_done_rden) begin
			MMIODataBus <= vadd_done;
		end
`endif
`ifdef ENABLE_MMIO_CONV1D
		if (`MMIO_CONV1D_addr_in1_rden) begin
			MMIODataBus <= conv1d_addr_in1;
		end
		if (`MMIO_CONV1D_addr_in2_rden) begin
			MMIODataBus <= conv1d_addr_in2;
		end
		if (`MMIO_CONV1D_addr_out_rden) begin
			MMIODataBus <= conv1d_addr_out;
		end
		if (`MMIO_CONV1D_vsize_rden) begin
			MMIODataBus <= conv1d_vsize;
		end
		if (`MMIO_CONV1D_start_rden) begin
			MMIODataBus <= conv1d_start;
		end
		if (`MMIO_CONV1D_done_rden) begin
			MMIODataBus <= conv1d_done;
		end
`endif
`ifdef ENABLE_MMIO_CONV1D_PL
		if (`MMIO_CONV1D_PL_addr_in1_rden) begin
			MMIODataBus <= conv1d_pl_addr_in1;
		end
		if (`MMIO_CONV1D_PL_addr_in2_rden) begin
			MMIODataBus <= conv1d_pl_addr_in2;
		end
		if (`MMIO_CONV1D_PL_addr_out_rden) begin
			MMIODataBus <= conv1d_pl_addr_out;
		end
		if (`MMIO_CONV1D_PL_vsize_rden) begin
			MMIODataBus <= conv1d_pl_vsize;
		end
		if (`MMIO_CONV1D_PL_start_rden) begin
			MMIODataBus <= conv1d_pl_start;
		end
		if (`MMIO_CONV1D_PL_done_rden) begin
			MMIODataBus <= conv1d_pl_done;
		end
`endif
`ifndef ENABLE_MMIO
		MMIODataBus <= 0;
`endif
	end
end

`ifdef ENABLE_MMIO_LED
	`include "mm_led.v"
`endif
`ifdef ENABLE_MMIO_ALU
	`include "mm_alu.v"
`endif
`ifdef ENABLE_MMIO_VADD
	`include "mm_vadd.v"
`endif
`ifdef ENABLE_MMIO_CONV1D
	`include "mm_conv1d_2dsysarr.v"
`endif
`ifdef ENABLE_MMIO_CONV1D_PL
	`include "mm_conv1d_pl.v"
`endif

assign clkPort2     = mmio_dm_p2_en ? mmio_clkPort2     : `write_clkPort2;
assign rdenPort2    = mmio_dm_p2_en ? mmio_rdenPort2    : `write_rdenPort2;
assign wrenPort2    = mmio_dm_p2_en ? mmio_wrenPort2    : `write_wrenPort2;
assign addressPort2 = mmio_dm_p2_en ? mmio_addressPort2 : `write_addressPort2;
assign dataPort2    = mmio_dm_p2_en ? mmio_dataPort2    : `write_dataPort2;

`ifndef ENABLE_MMIO
	assign mmio_dm_p2_en = 0;
	assign mmio_clkPort2 = 0;
	assign mmio_rdenPort2 = 0;
	assign mmio_wrenPort2 = 0;
	assign mmio_addressPort2 = 0;
	assign mmio_dataPort2 = 0;
`endif

//-------------------
assign datatrigger = (!done) ? (rst | ~clk) : (datatrigger);
assign ARDUINO_IO[7:0] = (!done && (offset) <= (write_ecall_len)) ? DMDataBusPort2[7:0] : 8'd0;
assign ARDUINO_IO[8] = datatrigger;
assign ARDUINO_RESET_N = 1'b1;
assign write_ecall_mem_addr = write_ecall_address[(`DM_BITS-1):0] + offset[(`DM_BITS-1):0];
assign write_ecall_finished = done;
//-------------------
assign CPUDataBusIn = (`DataMem_rden) ? DMDataBusPort1 : MMIODataBus;

`ifdef ENABLE_MMIO_LED
	assign LEDR = LED_MM_REG[9:0];
`else
	assign LEDR[0] = mmio_dm_p2_en;
	assign LEDR[9:1] = 0;
`endif

assign HEX0[0] = clk;
assign HEX0[1] = cpu_clk;
assign HEX0[2] = rst;
assign HEX0[3] = datatrigger;
assign HEX0[4] = done;
assign HEX0[5] = write_ecall_finished;
assign HEX0[6] = write_ecall;
assign HEX0[7] = exit_ecall;
assign HEX1 = 0;
assign HEX2 = 0;
assign HEX3 = 0;
assign HEX4 = 0;
assign HEX5 = 0;

assign clk = ClockDivider[9];
assign rst = ~KEY[0];

endmodule

// bcd7seg HEX0_DISP
// (
// 	.num([3:0]),
// 	.display(HEX0)
// );
