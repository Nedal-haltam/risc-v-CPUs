
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

wire clkPort2;
wire rdenPort2, wrenPort2;
wire [(`DM_BITS - 1):0] addressPort2;
wire `BIT_WIDTH dataPort2;

// MMIO
//------------------------------------------------
// mm_leds
reg `BIT_WIDTH LED_MM_REG;
reg `BIT_WIDTH MMIODataBus;
//------------------------------------------------
//------------------------------------------------
// mm_alu
// 50 * 1000 cycle to get a delay of 5 sec
reg `BIT_WIDTH alu_in1, alu_in2, alu_out;
reg `BIT_WIDTH alu_start;
reg `BIT_WIDTH alu_done;

wire alu_start_set;
reg alu_done_set;
wire alu_done_rden;
parameter [3:0] ALU_STATE_OFF  = 4'd1;
parameter [3:0] ALU_STATE_ON   = 4'd2;
reg [3:0] alu_state;
reg `BIT_WIDTH alu_counter;
//------------------------------------------------
//------------------------------------------------
// mm_vadd
reg `BIT_WIDTH vadd_addr_in1, vadd_addr_in2, vadd_addr_out;
reg `BIT_WIDTH vadd_vsize;
reg `BIT_WIDTH vadd_start, vadd_done;

reg vadd_dm_p2_en;
reg [(`DM_BITS-1):0] vadd_dm_p2_address;
reg vadd_dm_p2_wren;
reg `BIT_WIDTH vadd_dm_p2_writedata;
wire vadd_start_set;
reg vadd_done_set;
wire vadd_done_rden;
parameter [3:0] VADD_STATE_OFF        = 4'd1;
parameter [3:0] VADD_STATE_ON         = 4'd2;
parameter [3:0] VADD_STATE_SET_ADDR_A = 4'd3;
parameter [3:0] VADD_STATE_READ_A     = 4'd4;
parameter [3:0] VADD_STATE_SET_ADDR_B = 4'd5;
parameter [3:0] VADD_STATE_READ_B     = 4'd6;
parameter [3:0] VADD_STATE_OP         = 4'd7;
parameter [3:0] VADD_STATE_WRITE_C    = 4'd8;
parameter [3:0] VADD_STATE_INC_OFFSET = 4'd9;
reg [3:0] vadd_state;
reg `BIT_WIDTH vadd_rega, vadd_regb, vadd_regc;
reg `BIT_WIDTH vadd_offset;
//------------------------------------------------
//------------------------------------------------
// mm_conv1d
reg `BIT_WIDTH conv1d_addr_in1, conv1d_addr_in2, conv1d_addr_out;
reg `BIT_WIDTH conv1d_vsize;
reg `BIT_WIDTH conv1d_start, conv1d_done;

reg conv1d_dm_p2_en;
reg [(`DM_BITS-1):0] conv1d_dm_p2_address;
reg conv1d_dm_p2_wren;
reg `BIT_WIDTH conv1d_dm_p2_writedata;
wire conv1d_start_set;
reg conv1d_done_set;
wire conv1d_done_rden;
parameter [3:0] CONV1D_STATE_OFF        = 4'd1;
parameter [3:0] CONV1D_STATE_START      = 4'd2;
parameter [3:0] CONV1D_STATE_SET_ADDR_A = 4'd3;
parameter [3:0] CONV1D_STATE_READ_A     = 4'd4;
parameter [3:0] CONV1D_STATE_SET_ADDR_B = 4'd5;
parameter [3:0] CONV1D_STATE_READ_B     = 4'd6;
parameter [3:0] CONV1D_STATE_INC_OFFSET = 4'd7;
parameter [3:0] CONV1D_STATE_ACC_RESET  = 4'd8;
parameter [3:0] CONV1D_STATE_ACC_WAIT   = 4'd9;
parameter [3:0] CONV1D_STATE_WRITE_C    = 4'd10;
reg [3:0] conv1d_state;
reg `BIT_WIDTH conv1d_regas [9:0];
reg `BIT_WIDTH conv1d_regbs [9:0];
wire `BIT_WIDTH conv1d_regcs [18:0];
reg `BIT_WIDTH conv1d_offset;
reg conv1d_trigger;
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
		LED_MM_REG <= 0;
	end
	else if (`MMIO_rden) begin
		//------------------------------------------------
		// mm_leds
		if (`MMIO_LED_rden) begin
			MMIODataBus <= LED_MM_REG;
		end
		//------------------------------------------------
		// mm_alu
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
		//------------------------------------------------
		// mm_vadd
		else if (`MMIO_VADD_addr_in1_rden) begin
			MMIODataBus <= vadd_addr_in1;
		end
		else if (`MMIO_VADD_addr_in2_rden) begin
			MMIODataBus <= vadd_addr_in2;
		end
		else if (`MMIO_VADD_addr_out_rden) begin
			MMIODataBus <= vadd_addr_out;
		end
		else if (`MMIO_VADD_vsize_rden) begin
			MMIODataBus <= vadd_vsize;
		end
		else if (`MMIO_VADD_start_rden) begin
			MMIODataBus <= vadd_start;
		end
		else if (`MMIO_VADD_done_rden) begin
			MMIODataBus <= vadd_done;
		end
		//------------------------------------------------
		// mm_conv1d
		else if (`MMIO_CONV1D_addr_in1_rden) begin
			MMIODataBus <= conv1d_addr_in1;
		end
		else if (`MMIO_CONV1D_addr_in2_rden) begin
			MMIODataBus <= conv1d_addr_in2;
		end
		else if (`MMIO_CONV1D_addr_out_rden) begin
			MMIODataBus <= conv1d_addr_out;
		end
		else if (`MMIO_CONV1D_vsize_rden) begin
			MMIODataBus <= conv1d_vsize;
		end
		else if (`MMIO_CONV1D_start_rden) begin
			MMIODataBus <= conv1d_start;
		end
		else if (`MMIO_CONV1D_done_rden) begin
			MMIODataBus <= conv1d_done;
		end
		//------------------------------------------------
		// add other MM regs to read from
	end
	else if (`MMIO_wren) begin
		//------------------------------------------------
		// mm_leds
		if (`MMIO_LED_wren) begin
			LED_MM_REG <= CPUDataBusOut;
		end
		//------------------------------------------------
		// mm_alu
		else if (`MMIO_ALU_in1_wren)begin
			alu_in1 <= CPUDataBusOut;
		end
		else if (`MMIO_ALU_in2_wren)begin
			alu_in2 <= CPUDataBusOut;
		end
		//------------------------------------------------
		// mm_vadd
		else if (`MMIO_VADD_addr_in1_wren) begin
			vadd_addr_in1 <= CPUDataBusOut;
		end
		else if (`MMIO_VADD_addr_in2_wren) begin
			vadd_addr_in2 <= CPUDataBusOut;
		end
		else if (`MMIO_VADD_addr_out_wren) begin
			vadd_addr_out <= CPUDataBusOut;
		end
		else if (`MMIO_VADD_vsize_wren) begin
			vadd_vsize <= CPUDataBusOut;
		end
		//------------------------------------------------
		// mm_conv1d
		else if (`MMIO_CONV1D_addr_in1_wren) begin
			conv1d_addr_in1 <= CPUDataBusOut;
		end
		else if (`MMIO_CONV1D_addr_in2_wren) begin
			conv1d_addr_in2 <= CPUDataBusOut;
		end
		else if (`MMIO_CONV1D_addr_out_wren) begin
			conv1d_addr_out <= CPUDataBusOut;
		end
		else if (`MMIO_CONV1D_vsize_wren) begin
			conv1d_vsize <= CPUDataBusOut;
		end
		//------------------------------------------------
		// add other MM regs to write to
	end
end


//----------------------------------------------------------------------------------------
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
//----------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------
// vadd_start: reset after set
always@(posedge clk or posedge rst) begin
	if (rst) begin
		vadd_start <= 0;
	end
	else if (vadd_start_set) begin
		vadd_start <= 64'd1;
	end
	else if (vadd_start == 64'd1) begin
		vadd_start <= 0;
	end
end

// vadd_done : reset after reading
always@(posedge clk or posedge rst) begin
	if (rst) begin
		vadd_done <= 0;
	end
	else if (vadd_done_set) begin
		vadd_done <= 64'd1;
	end
	else if (vadd_done_rden) begin
		vadd_done <= 0;
	end
end

always@(posedge clk or posedge rst) begin
	if (rst) begin
		vadd_state <= VADD_STATE_OFF;
		vadd_dm_p2_en <= 0;
		vadd_done_set <= 0;
		vadd_offset <= 0;
		vadd_dm_p2_wren <= 0;
	end
	else begin
		case(vadd_state)
			VADD_STATE_OFF: begin
				vadd_done_set <= 0;
				vadd_dm_p2_en <= 0;
				vadd_offset <= 0;
				vadd_dm_p2_wren <= 0;
				if (vadd_start == 64'd1) begin
					vadd_state <= VADD_STATE_ON;
				end
			end
			VADD_STATE_ON: begin
				if (vadd_offset < vadd_vsize) begin
					vadd_state <= VADD_STATE_SET_ADDR_A;
					vadd_dm_p2_en <= 1'b1;
				end
				else begin
					vadd_done_set <= 1'b1;
					vadd_dm_p2_en <= 1'b0;
					vadd_state <= VADD_STATE_OFF;
				end
			end
			VADD_STATE_SET_ADDR_A: begin
				vadd_dm_p2_address <= vadd_addr_in1 + (64'd8 * vadd_offset);
				vadd_state <= VADD_STATE_READ_A;
			end
			VADD_STATE_READ_A: begin
				vadd_rega <= DMDataBusPort2;
				vadd_state <= VADD_STATE_SET_ADDR_B;
			end
			VADD_STATE_SET_ADDR_B: begin
				vadd_dm_p2_address <= vadd_addr_in2 + (64'd8 * vadd_offset);
				vadd_state <= VADD_STATE_READ_B;
			end
			VADD_STATE_READ_B: begin
				vadd_regb <= DMDataBusPort2;
				vadd_state <= VADD_STATE_OP;
			end
			VADD_STATE_OP: begin
				vadd_regc <= vadd_rega + vadd_regb;
				vadd_state <= VADD_STATE_WRITE_C;
			end
			VADD_STATE_WRITE_C: begin
				vadd_dm_p2_address <= vadd_addr_out + (64'd8 * vadd_offset);
				vadd_dm_p2_wren <= 1'b1;
				vadd_dm_p2_writedata <= vadd_regc;
				vadd_state <= VADD_STATE_INC_OFFSET;
			end
			VADD_STATE_INC_OFFSET: begin
				vadd_dm_p2_wren <= 1'b0;
				vadd_offset <= vadd_offset + 1'b1;
				vadd_state <= VADD_STATE_ON;
			end
		endcase
	end
end
assign vadd_done_rden = `MMIO_VADD_done_rden;
assign vadd_start_set = `MMIO_VADD_start_wren && (CPUDataBusOut == 64'd1);
//----------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------
// conv1d_start: reset after set
always@(posedge clk or posedge rst) begin
	if (rst) begin
		conv1d_start <= 0;
	end
	else if (conv1d_start_set) begin
		conv1d_start <= 64'd1;
	end
	else if (conv1d_start == 64'd1) begin
		conv1d_start <= 0;
	end
end

// conv1d_done : reset after reading
always@(posedge clk or posedge rst) begin
	if (rst) begin
		conv1d_done <= 0;
	end
	else if (conv1d_done_set) begin
		conv1d_done <= 64'd1;
	end
	else if (conv1d_done_rden) begin
		conv1d_done <= 0;
	end
end

always@(posedge clk or posedge rst) begin
	if (rst) begin
		conv1d_state <= CONV1D_STATE_OFF;
		conv1d_dm_p2_en <= 0;
		conv1d_done_set <= 0;
		conv1d_offset <= 0;
		conv1d_dm_p2_wren <= 0;
		conv1d_trigger <= 0;
	end
	else begin
		case(conv1d_state)
			CONV1D_STATE_OFF: begin
				conv1d_done_set <= 0;
				conv1d_dm_p2_en <= 0;
				conv1d_offset <= 0;
				conv1d_dm_p2_wren <= 0;
				conv1d_trigger <= 0;
				if (conv1d_start == 64'd1) begin
					conv1d_state <= CONV1D_STATE_START;
				end
			end
			CONV1D_STATE_START: begin
				if (conv1d_offset < conv1d_vsize) begin
					conv1d_state <= CONV1D_STATE_SET_ADDR_A;
					conv1d_dm_p2_en <= 1'b1;
				end
				else begin
					conv1d_offset <= 0;
					conv1d_state <= CONV1D_STATE_ACC_RESET;
				end
			end
			CONV1D_STATE_SET_ADDR_A: begin
				conv1d_dm_p2_address <= conv1d_addr_in1 + (64'd8 * conv1d_offset);
				conv1d_state <= CONV1D_STATE_READ_A;
			end
			CONV1D_STATE_READ_A: begin
				conv1d_regas[conv1d_offset] <= DMDataBusPort2;
				conv1d_state <= CONV1D_STATE_SET_ADDR_B;
			end
			CONV1D_STATE_SET_ADDR_B: begin
				conv1d_dm_p2_address <= conv1d_addr_in2 + (64'd8 * conv1d_offset);
				conv1d_state <= CONV1D_STATE_READ_B;
			end
			CONV1D_STATE_READ_B: begin
				conv1d_regbs[conv1d_offset] <= DMDataBusPort2;
				conv1d_state <= CONV1D_STATE_INC_OFFSET;
			end
			CONV1D_STATE_INC_OFFSET: begin
				conv1d_offset <= conv1d_offset + 1'b1;
				conv1d_state <= CONV1D_STATE_START;
			end
			CONV1D_STATE_ACC_RESET: begin
				// reset conv1d_dut (see the `rst` input signal)
				conv1d_trigger <= 1'b1;
				conv1d_state <= CONV1D_STATE_ACC_WAIT;
			end
			CONV1D_STATE_ACC_WAIT: begin
				if (conv1d_offset >= 6) begin
					conv1d_offset <= 0;
					conv1d_trigger <= 0;
					conv1d_state <= CONV1D_STATE_WRITE_C;
				end
				else begin
					conv1d_offset <= conv1d_offset + 1'b1;
					conv1d_state <= CONV1D_STATE_ACC_WAIT;
				end
			end
			CONV1D_STATE_WRITE_C: begin
				if (conv1d_offset >= 19) begin
					conv1d_dm_p2_wren <= 1'b0;
					conv1d_done_set <= 1'b1;
					conv1d_dm_p2_en <= 1'b0;
					conv1d_state <= CONV1D_STATE_OFF;
				end
				else begin
					conv1d_dm_p2_address <= conv1d_addr_out + (64'd8 * conv1d_offset);
					conv1d_dm_p2_wren <= 1'b1;
					conv1d_dm_p2_writedata <= conv1d_regcs[conv1d_offset];
					conv1d_offset <= conv1d_offset + 1'b1;
					conv1d_state <= CONV1D_STATE_WRITE_C;
				end
			end
		endcase
	end
end
assign conv1d_done_rden = `MMIO_CONV1D_done_rden;
assign conv1d_start_set = `MMIO_CONV1D_start_wren && (CPUDataBusOut == 64'd1);

SystolicArray conv1d_dut
(
    .clk(clk)
	,.rst(conv1d_state == CONV1D_STATE_ACC_RESET)
	,.trigger(conv1d_trigger)
    ,.Dim0Input00Lane0(conv1d_regas[0])
    ,.Dim0Input01Lane0(conv1d_regas[1])
    ,.Dim0Input02Lane0(conv1d_regas[2])
    ,.Dim0Input03Lane0(conv1d_regas[3])
    ,.Dim0Input04Lane0(conv1d_regas[4])
    ,.Dim0Input05Lane0(conv1d_regas[5])
    ,.Dim0Input06Lane0(conv1d_regas[6])
    ,.Dim0Input07Lane0(conv1d_regas[7])
    ,.Dim0Input08Lane0(conv1d_regas[8])
    ,.Dim0Input09Lane0(conv1d_regas[9])
    ,.Dim1Input00Lane0(conv1d_regbs[0])
    ,.Dim1Input01Lane0(conv1d_regbs[1])
    ,.Dim1Input02Lane0(conv1d_regbs[2])
    ,.Dim1Input03Lane0(conv1d_regbs[3])
    ,.Dim1Input04Lane0(conv1d_regbs[4])
    ,.Dim1Input05Lane0(conv1d_regbs[5])
    ,.Dim1Input06Lane0(conv1d_regbs[6])
    ,.Dim1Input07Lane0(conv1d_regbs[7])
    ,.Dim1Input08Lane0(conv1d_regbs[8])
    ,.Dim1Input09Lane0(conv1d_regbs[9])

	,.DimOutput0(conv1d_regcs[0])
	,.DimOutput1(conv1d_regcs[1])
	,.DimOutput2(conv1d_regcs[2])
	,.DimOutput3(conv1d_regcs[3])
	,.DimOutput4(conv1d_regcs[4])
	,.DimOutput5(conv1d_regcs[5])
	,.DimOutput6(conv1d_regcs[6])
	,.DimOutput7(conv1d_regcs[7])
	,.DimOutput8(conv1d_regcs[8])
	,.DimOutput9(conv1d_regcs[9])
	,.DimOutput10(conv1d_regcs[10])
	,.DimOutput11(conv1d_regcs[11])
	,.DimOutput12(conv1d_regcs[12])
	,.DimOutput13(conv1d_regcs[13])
	,.DimOutput14(conv1d_regcs[14])
	,.DimOutput15(conv1d_regcs[15])
	,.DimOutput16(conv1d_regcs[16])
	,.DimOutput17(conv1d_regcs[17])
	,.DimOutput18(conv1d_regcs[18])
);
//----------------------------------------------------------------------------------------

assign clkPort2     = (conv1d_dm_p2_en) ? (~clk) : ((vadd_dm_p2_en) ? (~clk)   : clk);
assign rdenPort2    = (conv1d_dm_p2_en) ? (~conv1d_dm_p2_wren) : ((vadd_dm_p2_en) ? (~vadd_dm_p2_wren) : !done);
assign wrenPort2    = (conv1d_dm_p2_en) ? (conv1d_dm_p2_wren) : ((vadd_dm_p2_en) ? (vadd_dm_p2_wren) : 1'b0);
assign addressPort2 = (conv1d_dm_p2_en) ? (conv1d_dm_p2_address) : ((vadd_dm_p2_en) ? (vadd_dm_p2_address) : write_ecall_mem_addr);
assign dataPort2    = (conv1d_dm_p2_en) ? (conv1d_dm_p2_writedata) : ((vadd_dm_p2_en) ? (vadd_dm_p2_writedata)    : 0);

assign clk = ClockDivider[9];
assign rst = ~KEY[0];

//-------------------
assign datatrigger = (!done) ? (rst | ~clk) : (datatrigger);
assign ARDUINO_IO[7:0] = (!done && (offset) <= (write_ecall_len)) ? DMDataBusPort2[7:0] : 8'd0;
assign ARDUINO_IO[8] = datatrigger;
assign ARDUINO_RESET_N = 1'b1;
assign write_ecall_mem_addr = write_ecall_address[(`DM_BITS-1):0] + offset[(`DM_BITS-1):0];
assign write_ecall_finished = done;
//-------------------
assign CPUDataBusIn = (`DataMem_rden) ? DMDataBusPort1 : MMIODataBus;


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

// bcd7seg HEX0_DISP
// (
// 	.num(write_ecall_len[3:0]),
// 	.display(HEX0)
// );


module PE
#(
parameter PECount   = 0
,parameter DataWidth = 32
)
(
    input clk, rst, trigger
    ,input      `BIT_WIDTH InDim0Lane0
    ,output reg `BIT_WIDTH OutDim0Lane0
    ,input      `BIT_WIDTH InDim1Lane0
    ,output reg `BIT_WIDTH OutDim1Lane0
    ,output reg `BIT_WIDTH PEValue
);
    always@(posedge clk) begin
        if (rst) begin
            OutDim0Lane0 <= 0;
            OutDim1Lane0 <= 0;
            PEValue <= 0;
        end
        else if (trigger) begin
            PEValue <= InDim1Lane0 * InDim0Lane0;
            OutDim0Lane0 <= InDim0Lane0;
            OutDim1Lane0 <= InDim1Lane0;
        end
    end
endmodule
module SystolicArray
(
    input clk, rst, trigger
    ,input `BIT_WIDTH Dim0Input00Lane0
    ,input `BIT_WIDTH Dim0Input01Lane0
    ,input `BIT_WIDTH Dim0Input02Lane0
    ,input `BIT_WIDTH Dim0Input03Lane0
    ,input `BIT_WIDTH Dim0Input04Lane0
    ,input `BIT_WIDTH Dim0Input05Lane0
    ,input `BIT_WIDTH Dim0Input06Lane0
    ,input `BIT_WIDTH Dim0Input07Lane0
    ,input `BIT_WIDTH Dim0Input08Lane0
    ,input `BIT_WIDTH Dim0Input09Lane0
    ,input `BIT_WIDTH Dim1Input00Lane0
    ,input `BIT_WIDTH Dim1Input01Lane0
    ,input `BIT_WIDTH Dim1Input02Lane0
    ,input `BIT_WIDTH Dim1Input03Lane0
    ,input `BIT_WIDTH Dim1Input04Lane0
    ,input `BIT_WIDTH Dim1Input05Lane0
    ,input `BIT_WIDTH Dim1Input06Lane0
    ,input `BIT_WIDTH Dim1Input07Lane0
    ,input `BIT_WIDTH Dim1Input08Lane0
    ,input `BIT_WIDTH Dim1Input09Lane0
	,output `BIT_WIDTH DimOutput0
	,output `BIT_WIDTH DimOutput1
	,output `BIT_WIDTH DimOutput2
	,output `BIT_WIDTH DimOutput3
	,output `BIT_WIDTH DimOutput4
	,output `BIT_WIDTH DimOutput5
	,output `BIT_WIDTH DimOutput6
	,output `BIT_WIDTH DimOutput7
	,output `BIT_WIDTH DimOutput8
	,output `BIT_WIDTH DimOutput9
	,output `BIT_WIDTH DimOutput10
	,output `BIT_WIDTH DimOutput11
	,output `BIT_WIDTH DimOutput12
	,output `BIT_WIDTH DimOutput13
	,output `BIT_WIDTH DimOutput14
	,output `BIT_WIDTH DimOutput15
	,output `BIT_WIDTH DimOutput16
	,output `BIT_WIDTH DimOutput17
	,output `BIT_WIDTH DimOutput18
);
    wire `BIT_WIDTH PassThroughWires0Lane0[9:0];
    wire `BIT_WIDTH PassThroughWires1Lane0[9:0];
    assign PassThroughWires0Lane0[0] = Dim0Input00Lane0;
    assign PassThroughWires0Lane0[1] = Dim0Input01Lane0;
    assign PassThroughWires0Lane0[2] = Dim0Input02Lane0;
    assign PassThroughWires0Lane0[3] = Dim0Input03Lane0;
    assign PassThroughWires0Lane0[4] = Dim0Input04Lane0;
    assign PassThroughWires0Lane0[5] = Dim0Input05Lane0;
    assign PassThroughWires0Lane0[6] = Dim0Input06Lane0;
    assign PassThroughWires0Lane0[7] = Dim0Input07Lane0;
    assign PassThroughWires0Lane0[8] = Dim0Input08Lane0;
    assign PassThroughWires0Lane0[9] = Dim0Input09Lane0;
    assign PassThroughWires1Lane0[0] = Dim1Input00Lane0;
    assign PassThroughWires1Lane0[1] = Dim1Input01Lane0;
    assign PassThroughWires1Lane0[2] = Dim1Input02Lane0;
    assign PassThroughWires1Lane0[3] = Dim1Input03Lane0;
    assign PassThroughWires1Lane0[4] = Dim1Input04Lane0;
    assign PassThroughWires1Lane0[5] = Dim1Input05Lane0;
    assign PassThroughWires1Lane0[6] = Dim1Input06Lane0;
    assign PassThroughWires1Lane0[7] = Dim1Input07Lane0;
    assign PassThroughWires1Lane0[8] = Dim1Input08Lane0;
    assign PassThroughWires1Lane0[9] = Dim1Input09Lane0;
    wire `BIT_WIDTH PEOutDim0Lane0 [9:0][9:0];
    wire `BIT_WIDTH PEOutDim1Lane0 [9:0][9:0];
    wire `BIT_WIDTH PEValues [99:0];
    genvar Dim0Index, Dim1Index, DummyIndex;
    generate
	    for (Dim0Index = 0; Dim0Index < 10; Dim0Index = Dim0Index + 1) begin : Dim0IndexForLoopBlock
		    for (Dim1Index = 0; Dim1Index < 10; Dim1Index = Dim1Index + 1) begin : Dim1IndexForLoopBlock
				localparam PECount = Dim1Index * 10 * 1 + Dim0Index * 1 + 0;
				wire `BIT_WIDTH InDim0Lane0;
				assign InDim0Lane0 = PassThroughWires0Lane0[Dim0Index];
				wire `BIT_WIDTH InDim1Lane0;
				assign InDim1Lane0 = PassThroughWires1Lane0[Dim1Index];
				PE #(.PECount(PECount)) pe
				(
				    .clk(clk),
				    .rst(rst),
				    .trigger(trigger),
				    .InDim0Lane0(InDim0Lane0),
				    .OutDim0Lane0(PEOutDim0Lane0[Dim0Index][Dim1Index]),
				    .InDim1Lane0(InDim1Lane0),
				    .OutDim1Lane0(PEOutDim1Lane0[Dim0Index][Dim1Index]),
				    .PEValue(PEValues[PECount])
				);
		    end
	    end
    endgenerate
    reg `BIT_WIDTH OutputDim [18:0];
    reg `BIT_WIDTH index = 0;
    integer i;
    integer j;
    always@(posedge clk) begin
        if (rst) begin
            for (i = 0; i < 19; i = i + 1) begin
                OutputDim[i] <= 0;
            end
            index = 0;
        end
        else begin
            if (index < 2) begin
                for (i = 0; i < 10; i = i + 1) begin
                    for (j = 0; j < 10; j = j + 1) begin
                        OutputDim[i + j] = OutputDim[i + j] + PEValues[10 * j + i];
                    end
                end
            end
            index = index + 1;
        end
    end

	assign DimOutput0 = OutputDim[0];
	assign DimOutput1 = OutputDim[1];
	assign DimOutput2 = OutputDim[2];
	assign DimOutput3 = OutputDim[3];
	assign DimOutput4 = OutputDim[4];
	assign DimOutput5 = OutputDim[5];
	assign DimOutput6 = OutputDim[6];
	assign DimOutput7 = OutputDim[7];
	assign DimOutput8 = OutputDim[8];
	assign DimOutput9 = OutputDim[9];
	assign DimOutput10 = OutputDim[10];
	assign DimOutput11 = OutputDim[11];
	assign DimOutput12 = OutputDim[12];
	assign DimOutput13 = OutputDim[13];
	assign DimOutput14 = OutputDim[14];
	assign DimOutput15 = OutputDim[15];
	assign DimOutput16 = OutputDim[16];
	assign DimOutput17 = OutputDim[17];
	assign DimOutput18 = OutputDim[18];

    integer k;
`ifdef VSCODE
    initial begin
        `ADVANCE_N_CYCLE(5);
        for (k = 0; k < 19; k = k + 1) begin
            $display("Output%-1d : Value = %-1d",k, $signed(OutputDim[k]));
        end
    end
`endif
endmodule