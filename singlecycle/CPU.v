`include "defs.h"

module programCounter 
(
	input clk, rst, 
	input `BIT_WIDTH PCin, 
	output reg `BIT_WIDTH PCout
);
	parameter initialaddr = -4;
	always@(posedge clk, posedge rst) begin
		if(rst) begin
			PCout <= initialaddr;
		end
		else begin
			PCout <= PCin;
		end
	end
	
endmodule

module IM
(
	input clk,
	input `BIT_WIDTH addr,
	output [31:0] Data_Out
);
`ifdef simulate
	reg [7 : 0] InstMem [0 : (`IM_SIZE-1)];
	assign Data_Out[(8 * 1) - 1: 8 * 0] = InstMem[addr[(`IM_BITS-1):0] + 0];
	assign Data_Out[(8 * 2) - 1: 8 * 1] = InstMem[addr[(`IM_BITS-1):0] + 1];
	assign Data_Out[(8 * 3) - 1: 8 * 2] = InstMem[addr[(`IM_BITS-1):0] + 2];
	assign Data_Out[(8 * 4) - 1: 8 * 3] = InstMem[addr[(`IM_BITS-1):0] + 3];

	integer i;
	initial begin
		for (i = 0; i <= `IM_SIZE/2; i = i + 1)
			InstMem[i] <= 0;
		for (i = `IM_SIZE/2+1; i <= (`IM_SIZE-1); i = i + 1)
			InstMem[i] <= 0;
		`include `IM_INIT_FILE_PATH
	end
`else
singleprom singleprom_inst
(
	.address(addr[(`IM_BITS-1):0]), // it's word addressable
	.clock( clk ),
	.q(Data_Out)
);
`endif
endmodule

module controlUnit
(
	input `BIT_WIDTH PC,
	input [6:0] opcode,
	input [2:0] funct3,
	input [6:0] funct7,
	input [11:0] funct12,
	input rst,
	input [4:0] rs1, rs2, rd,
	input `BIT_WIDTH RegFileDataOut_1, RegFileDataOut_2, RegFileDataOut_3,
	input [11:0] imm12_itype, imm12_stype,
	input [19:0] imm20,

	output reg [4:0] WriteRegister,
	output reg IsPFC,
	output reg `BIT_WIDTH PFC_PC,
	output reg RegWriteEn,
	output reg MemReadEn,
	output reg MemWriteEn,
	output reg `BIT_WIDTH alu_in_1,
	output reg `BIT_WIDTH alu_in_2,
	output reg [5:0] aluop,
	output reg [3:0] loadtype,
	output reg [3:0] storetype,
	output reg ecall_enable
);
	always @(*) begin
		if(rst) begin
			WriteRegister <= 0;
			IsPFC <= 0;
			PFC_PC <= 0;
			RegWriteEn <= 0;
			MemReadEn <= 0;
			MemWriteEn <= 0;
			alu_in_1 <= 0;
			alu_in_2 <= 0;
			aluop <= 0;
			loadtype <= 0;
			storetype <= 0;
			ecall_enable <= 0;
		end
		else begin
			case(opcode)
				// start of R-TYPE instructions
				7'b0110011: begin
					IsPFC <= 0;
					PFC_PC <= 0;
					MemReadEn <= 0;
					MemWriteEn <= 0;
					loadtype <= 0;
					storetype <= 0;
					ecall_enable <= 0;

					WriteRegister <= rd;
					RegWriteEn <= 1'b1;
					alu_in_1 <= RegFileDataOut_1;
					alu_in_2 <= RegFileDataOut_2;
					case(funct3)
						3'b000: begin
							case(funct7)
								7'b0000000: begin // "add"
									aluop <= `ALU_OPCODE_ADD;
								end
								7'b0110000: begin // "sub"
									aluop <= `ALU_OPCODE_SUB;
								end
								7'b0000001: begin // "mul"
									aluop <= `ALU_OPCODE_MUL;
								end
								default: begin end
							endcase
						end
						3'b001: begin
							case(funct7)
								7'b0000000: begin // "sll"
									aluop <= `ALU_OPCODE_SLL;
								end
								default: begin end
							endcase
						end
						3'b010: begin
							case(funct7)
								7'b0000000: begin // "slt"
									aluop <= `ALU_OPCODE_SLT;
								end
								7'b0000001: begin // "seq"
									aluop <= `ALU_OPCODE_SEQ;
								end
								7'b0000010: begin // "sne"
									aluop <= `ALU_OPCODE_SNE;
								end
								default: begin end
							endcase
						end
						3'b011: begin
							case(funct7)
								7'b0000000: begin // "sltu"
									aluop <= `ALU_OPCODE_SLTU;
								end
								default: begin end
							endcase
						end
						3'b100: begin
							case(funct7)
								7'b0000000: begin // "xor"
									aluop <= `ALU_OPCODE_XOR;
								end
								7'b0000001: begin // "div"
									aluop <= `ALU_OPCODE_DIV;
								end
								default: begin end
							endcase
						end
						3'b101: begin
							case(funct7)
								7'b0000000: begin // "srl"
									aluop <= `ALU_OPCODE_SRL;
								end
								7'b0100000: begin // "sra"
									aluop <= `ALU_OPCODE_SRA;
								end
								7'b0000001: begin // "divu"
									aluop <= `ALU_OPCODE_DIVU;
								end
								default: begin end
							endcase
						end
						3'b110: begin
							case(funct7)
								7'b0000000: begin // "or"
									aluop <= `ALU_OPCODE_OR;
								end
								7'b0000001: begin // "rem"
									aluop <= `ALU_OPCODE_REM;
								end
								default: begin end
							endcase
						end
						3'b111: begin
							case(funct7)
								7'b0000000: begin // "and"
									aluop <= `ALU_OPCODE_AND;
								end
								7'b0000001: begin // "remu"
									aluop <= `ALU_OPCODE_REMU;
								end
								default: begin end
							endcase
						end
						default: begin end
					endcase
				end
				// end of R-TYPE instructions
				// start of I-TYPE instructions
				7'b0010011: begin
					MemReadEn <= 0;
					MemWriteEn <= 0;
					IsPFC <= 0;
					PFC_PC <= 0;
					loadtype <= 0;
					storetype <= 0;
					ecall_enable <= 0;

					RegWriteEn <= 1'b1;
					WriteRegister <= rd;
					alu_in_1 <= RegFileDataOut_1;
					alu_in_2 <= {{52{imm12_itype[11]}}, imm12_itype};
					case(funct3)
						3'b000: begin // "addi"
							aluop <= `ALU_OPCODE_ADD;
						end
						3'b010: begin // "slti"
							aluop <= `ALU_OPCODE_SLT;
						end
						3'b011: begin // "sltiu"
							aluop <= `ALU_OPCODE_SLTU;
						end
						3'b100: begin // "xori"
							aluop <= `ALU_OPCODE_XOR;
						end
						3'b110: begin // "ori"
							aluop <= `ALU_OPCODE_OR;
						end
						3'b111: begin // "andi"
							aluop <= `ALU_OPCODE_AND;
						end
						3'b001: begin // "slli"
							aluop <= `ALU_OPCODE_SLL;
						end
						3'b101: begin
							case(funct7)
								7'b0000000: begin // "srli"
									aluop <= `ALU_OPCODE_SRL;
								end
								7'b0100000: begin // "srai"
									aluop <= `ALU_OPCODE_SRA;
								end
								default: begin end
							endcase
						end
						default: begin end
					endcase
				end
				7'b1110011: begin
					WriteRegister <= 0;
					IsPFC <= 0;
					PFC_PC <= 0;
					RegWriteEn <= 0;
					MemReadEn <= 0;
					MemWriteEn <= 0;
					alu_in_1 <= 0;
					alu_in_2 <= 0;
					aluop <= 0;
					loadtype <= 0;
					storetype <= 0;

					case(funct3)
						3'b000: begin
							case(funct12)
								12'b000000000000: begin // "ecall_enable"
									ecall_enable <= 1'b1;
								end
								default: begin end
							endcase
						end
						default: begin end
					endcase
				end
				7'b0000011: begin 
					IsPFC <= 0;
					PFC_PC <= 0;
					MemWriteEn <= 0;
					storetype <= 0;
					ecall_enable <= 0;

					WriteRegister <= rd;
					RegWriteEn <= 1'b1;
					MemReadEn <= 1'b1;
					alu_in_1 <= RegFileDataOut_1;
					alu_in_2 <= {{52{imm12_itype[11]}}, imm12_itype};
					aluop <= `ALU_OPCODE_ADD;
					case(funct3)
						3'b000: begin // "lb"
							loadtype <= `LOAD_BYTE;
						end
						3'b001: begin // "lh"
							loadtype <= `LOAD_HALFWORD;
						end
						3'b010: begin // "lw"
							loadtype <= `LOAD_WORD;
						end
						3'b011: begin // "ld"
							loadtype <= `LOAD_DOUBLEWORD;
						end
						3'b100: begin // "lbu"
							loadtype <= `LOAD_BYTE_UNSIGNED;
						end
						3'b101: begin // "lhu"
							loadtype <= `LOAD_HALFWORD_UNSIGNED;
						end
						default: begin end
					endcase
				end
				7'b1110111: begin // "jalr"
					MemWriteEn <= 0;
					MemReadEn <= 0;
					loadtype <= 0;
					storetype <= 0;
					ecall_enable <= 0;

					WriteRegister <= rd;
					IsPFC <= 1'b1;
					PFC_PC <= (RegFileDataOut_1 + {{52{imm12_itype[11]}}, imm12_itype}) & ~1;
					RegWriteEn <= 1'b1;
					alu_in_1 <= PC;
					alu_in_2 <= 64'd4;
					aluop <= `ALU_OPCODE_ADD;
					case(funct3)
						3'b000: begin
						end
						default: begin end
					endcase
				end
				// end of I-TYPE instructions
				// start of S-TYPE instructions
				7'b0100011: begin
					IsPFC <= 0;
					PFC_PC <= 0;
					WriteRegister <= 0;
					RegWriteEn <= 0;
					MemReadEn <= 0;
					loadtype <= 0;
					ecall_enable <= 0;

					MemWriteEn <= 1'b1;
					alu_in_1 <= RegFileDataOut_1;
					alu_in_2 <= {{52{imm12_stype[11]}}, imm12_stype};
					aluop <= `ALU_OPCODE_ADD;
					case(funct3)
						3'b000: begin // "sb"
							storetype <= `STORE_BYTE;
						end
						3'b001: begin // "sh"
							storetype <= `STORE_HALFWORD;
						end
						3'b010: begin // "sw"
							storetype <= `STORE_WORD;
						end
						3'b011: begin // "sd"
							storetype <= `STORE_DOUBLEWORD;
						end
						default: begin end
					endcase
				end
				7'b1100011: begin
					WriteRegister <= 0;
					RegWriteEn <= 0;
					MemReadEn <= 0;
					MemWriteEn <= 0;
					alu_in_1 <= 0;
					alu_in_2 <= 0;
					aluop <= 0;
					loadtype <= 0;
					storetype <= 0;
					ecall_enable <= 0;

					PFC_PC <= PC + ({{51{imm12_stype[11]}}, imm12_stype, 1'b0});
					case(funct3)
						3'b000: begin // "beq"
							IsPFC <= RegFileDataOut_1 == RegFileDataOut_2;
						end
						3'b001: begin // "bne"
							IsPFC <= RegFileDataOut_1 != RegFileDataOut_2;
						end
						3'b100: begin // "blt"
							IsPFC <= $signed(RegFileDataOut_1) < $signed(RegFileDataOut_2);
						end
						3'b101: begin // "bge"
							IsPFC <= $signed(RegFileDataOut_1) >= $signed(RegFileDataOut_2);
						end
						3'b110: begin // "bltu"
							IsPFC <= $unsigned(RegFileDataOut_1) < $unsigned(RegFileDataOut_2);
						end
						3'b111: begin // "bgeu"
							IsPFC <= $unsigned(RegFileDataOut_1) >= $unsigned(RegFileDataOut_2);
						end
						default: begin end
					endcase
				end
				// end of S-TYPE instructions
				// start of U-TYPE instructions
				7'b0110111: begin // "lui"
					IsPFC <= 0;
					PFC_PC <= 0;
					MemReadEn <= 0;
					MemWriteEn <= 0;
					loadtype <= 0;
					storetype <= 0;
					ecall_enable <= 0;

					WriteRegister <= rd;
					RegWriteEn <= 1'b1;
					alu_in_1 <= 0;
					alu_in_2 <= {32'd0, {imm20, 12'd0}};
					aluop <= `ALU_OPCODE_ADD;
				end
				7'b0010111: begin // "auipc"
					IsPFC <= 0;
					PFC_PC <= 0;
					MemReadEn <= 0;
					MemWriteEn <= 0;
					loadtype <= 0;
					storetype <= 0;
					ecall_enable <= 0;

					WriteRegister <= rd;
					RegWriteEn <= 1'b1;
					alu_in_1 <= PC;
					alu_in_2 <= {32'd0, {imm20, 12'd0}};
					aluop <= `ALU_OPCODE_ADD;
				end
				7'b1111111: begin // "jal"
					MemReadEn <= 0;
					MemWriteEn <= 0;
					loadtype <= 0;
					storetype <= 0;
					ecall_enable <= 0;

					IsPFC <= 1'b1;
					PFC_PC <= PC + {{43{imm20[19]}}, imm20, 1'b0};
					WriteRegister <= rd;
					RegWriteEn <= 1'b1;
					alu_in_1 <= PC;
					alu_in_2 <= 64'd4;
					aluop <= `ALU_OPCODE_ADD;
				end
				7'b1111110: begin // "addi20u"
					IsPFC <= 0;
					PFC_PC <= 0;
					MemReadEn <= 0;
					MemWriteEn <= 0;
					loadtype <= 0;
					storetype <= 0;
					ecall_enable <= 0;

					WriteRegister <= rd;
					RegWriteEn <= 1'b1;
					alu_in_1 <= RegFileDataOut_3;
					alu_in_2 <= {44'd0, imm20};
					aluop <= `ALU_OPCODE_ADD;
				end
				// end of U-TYPE instructions
				default: begin end
			endcase
		end	
	end
endmodule

module registerFile 
(
	input clk, rst, we,
	input [4:0] readRegister1, readRegister2, readRegister3, WriteRegister,
	input `BIT_WIDTH writeData,
	output wire `BIT_WIDTH RegFileDataOut_1, RegFileDataOut_2, RegFileDataOut_3,
	output wire `BIT_WIDTH ecall_code,
	output wire `BIT_WIDTH write_ecall_fd, write_ecall_address, write_ecall_len
);

	reg `BIT_WIDTH registers [0:31];
	assign RegFileDataOut_1    = registers[readRegister1];
	assign RegFileDataOut_2    = registers[readRegister2];
	assign RegFileDataOut_3    = registers[readRegister3];
	assign ecall_code          = registers[17];
	assign write_ecall_fd      = registers[10];
	assign write_ecall_address = registers[11];
	assign write_ecall_len     = registers[12];
	always@(posedge clk,  posedge rst) begin : Write_on_register_file_block
		integer i;
		if (rst) begin
			for (i = 0; i < 32; i = i + 1) begin
				if (i == 2) begin
					registers[i] <= `SP_INITIAL_VALUE;
				end
				else begin
					registers[i] <= 0;
				end
			end
		end
		else if (we && WriteRegister != 0) begin
			registers[WriteRegister] <= writeData;
		end
	end
`ifdef simulate
	integer i;
	initial begin
		#(`MAX_CLOCKS + `reset+1);
		$display("Register file content : ");
		for (i = 0; i <= 31; i = i + 1) begin
			$display("index = %d , reg_out : signed = %d , unsigned = %d", i[31:0], $signed(registers[i]), $unsigned(registers[i]));
		end
	end 
`endif

endmodule

module ALU 
(
	input `BIT_WIDTH operand1, operand2, 
	input [5:0] opSel, 
	output reg `BIT_WIDTH result
);

always @ (*) begin
	case(opSel)
		`ALU_OPCODE_ADD:  result <= operand1 + operand2;
		`ALU_OPCODE_SUB:  result <= operand1 - operand2;
		`ALU_OPCODE_MUL:  result <= operand1 * operand2;
		`ALU_OPCODE_SLL:  result <= operand1 << operand2;
		`ALU_OPCODE_SLT:  result <= ($signed(operand1) < $signed(operand2)) ? 64'd1 : 64'd0;
		`ALU_OPCODE_SEQ:  result <= (operand1 == operand2) ? 64'd1 : 64'd0;
		`ALU_OPCODE_SNE:  result <= (operand1 != operand2) ? 64'd1 : 64'd0;
		`ALU_OPCODE_SLTU: result <= ($unsigned(operand1) < $unsigned(operand2)) ? 64'd1 : 64'd0;
		`ALU_OPCODE_XOR:  result <= operand1 ^ operand2;
		`ALU_OPCODE_DIV:  result <= ($signed(operand2) == 0) ? 64'd0 : $signed(operand1) / $signed(operand2);
		`ALU_OPCODE_SRL:  result <= operand1 >> operand2;
		`ALU_OPCODE_SRA:  result <= operand1 >>> operand2;
		`ALU_OPCODE_DIVU: result <= ($unsigned(operand2) == 0) ? 64'd0 : $unsigned(operand1) / $unsigned(operand2);
		`ALU_OPCODE_OR:   result <= operand1 | operand2;
		`ALU_OPCODE_REM:  result <= $signed(operand1) % $signed(operand2);
		`ALU_OPCODE_AND:  result <= operand1 & operand2;
		`ALU_OPCODE_REMU: result <= $unsigned(operand1) % $unsigned(operand2);
		default: result <= 12121212;
	endcase
end
endmodule

module CPU
(
	output `BIT_WIDTH pc,
	input InputClk, rst,
	output cpu_clk,
	output `BIT_WIDTH AddressBus,
	input `BIT_WIDTH DataBusIn,
	output `BIT_WIDTH DataBusOut,
	output [10:0] ControlBus,
	output reg `BIT_WIDTH CyclesConsumed

	,output exit_ecall
	,input write_ecall_finished
	,output reg write_ecall
	,output `BIT_WIDTH write_ecall_fd
	,output `BIT_WIDTH write_ecall_address
	,output `BIT_WIDTH write_ecall_len
	);

	wire [31:0] Instruction, InstructionMemoryOut;
	wire `BIT_WIDTH RegFileDataOut_1, RegFileDataOut_2, RegFileDataOut_3, ecall_code;
	wire `BIT_WIDTH DataBus, ALUResult, alu_in_1, alu_in_2;
	wire `BIT_WIDTH PC, nextPC, PFC_PC;
	wire [6:0] opcode;
	wire [2:0] funct3;
	wire [5:0] aluop;
	wire [6:0] funct7;
	wire [11:0] funct12;
	wire [4:0] rs1, rs2, rd, WriteRegister;
	wire [11:0] imm12_itype, imm12_stype;
	wire [19:0] imm20;
	wire [3:0] loadtype, storetype;
	wire clk, IsPFC, RegWriteEn, MemReadEn, MemWriteEn, ecall_enable;

	or exit_ecall_logic(clk, InputClk, exit_ecall | write_ecall);

	always@(posedge InputClk, posedge rst) begin
		if (rst) begin
			write_ecall <= 1'b0;
		end
		else if (write_ecall) begin
			write_ecall <= ~write_ecall_finished;
		end
		else begin
			write_ecall <= ecall_enable && ecall_code == `WRITE_ECALL;
		end
	end

	always@(posedge clk , posedge rst) begin
		if (rst)
			CyclesConsumed <= 64'd0;
		else
			CyclesConsumed <= CyclesConsumed + 64'd1;
	end

	programCounter programCounter_u0
	(
		.clk(clk), 
		.rst(rst), 
		.PCin(nextPC), 
		.PCout(PC)
	);

	IM InstMem
	(
		.clk(clk),
`ifdef simulate
		.addr(PC), 
`else
		.addr(nextPC >> 2), 
`endif
		.Data_Out(InstructionMemoryOut)
	);

	controlUnit CU
	(
		.PC(PC),
		.opcode(opcode), 
		.funct3(funct3), 
		.funct7(funct7), 
		.funct12(funct12),
		.rst(rst), 
		.rs1(rs1),
		.rs2(rs2),
		.rd(rd),
		.RegFileDataOut_1(RegFileDataOut_1),
		.RegFileDataOut_2(RegFileDataOut_2),
		.RegFileDataOut_3(RegFileDataOut_3),
		.imm12_itype(imm12_itype),
		.imm12_stype(imm12_stype),
		.imm20(imm20),

		.WriteRegister(WriteRegister),
		.IsPFC(IsPFC),
		.PFC_PC(PFC_PC),
		.RegWriteEn(RegWriteEn), 
		.MemReadEn(MemReadEn), 
		.MemWriteEn(MemWriteEn), 
		.alu_in_1(alu_in_1),
		.alu_in_2(alu_in_2),
		.aluop(aluop), 
		.loadtype(loadtype),
		.storetype(storetype),
		.ecall_enable(ecall_enable)
	);

	registerFile RF
	(
		.clk(clk), 
		.rst(rst), 
		.we(RegWriteEn), 
		.readRegister1(rs1), 
		.readRegister2(rs2), 
		.readRegister3(rd), 
		.WriteRegister(WriteRegister), 
		.writeData(DataBus), 
		.RegFileDataOut_1(RegFileDataOut_1), 
		.RegFileDataOut_2(RegFileDataOut_2),
		.RegFileDataOut_3(RegFileDataOut_3),

		.ecall_code(ecall_code),
		.write_ecall_fd(write_ecall_fd),
		.write_ecall_address(write_ecall_address),
		.write_ecall_len(write_ecall_len)
	);
		
	ALU alu
	(
		.operand1(alu_in_1), 
		.operand2(alu_in_2), 
		.opSel(aluop), 
		.result(ALUResult)
	);

	assign opcode       = Instruction[6:0];
	assign funct3       = Instruction[14:12];
	assign funct7       = Instruction[31:25];
	assign funct12      = Instruction[31:20];
	assign rs1          = Instruction[19:15];
	assign rs2          = Instruction[24:20];
	assign rd           = Instruction[11:7];
	assign imm12_itype  = Instruction[31:20];
	assign imm12_stype  = {Instruction[31:25], Instruction[11:7]};
	assign imm20        = Instruction[31:12];
	
	assign nextPC       = (IsPFC) ? (PFC_PC) : PC + 64'd4;
	assign Instruction  = (rst) ? 0 : InstructionMemoryOut;

	assign AddressBus   = ALUResult;
	assign DataBusOut   = (
		storetype == `STORE_BYTE ? {8{RegFileDataOut_2[7:0]}} : (
			storetype == `STORE_HALFWORD ? {4{RegFileDataOut_2[15:0]}} : (
				storetype == `STORE_WORD ? {2{RegFileDataOut_2[31:0]}} : (
					storetype == `STORE_DOUBLEWORD ? RegFileDataOut_2 : 64'd0
				)
			)
		)
	);
	assign DataBus      = (MemReadEn) ? (
		loadtype == `LOAD_BYTE ? {{56{DataBusIn[7]}}, DataBusIn[7:0]} : (
			loadtype == `LOAD_HALFWORD ? {{48{DataBusIn[15]}}, DataBusIn[15:0]} : (
				loadtype == `LOAD_WORD ? {{32{DataBusIn[31]}}, DataBusIn[31:0]} : (
					loadtype == `LOAD_DOUBLEWORD ? DataBusIn : (
						loadtype == `LOAD_BYTE_UNSIGNED ? {{56{1'b0}}, DataBusIn[7:0]} : (
							loadtype == `LOAD_HALFWORD_UNSIGNED ? {{48{1'b0}}, DataBusIn[15:0]} : 64'd0
						)
					)
				)
			)
		)
	) : ALUResult;
	assign ControlBus   = {storetype, loadtype, MemWriteEn, MemReadEn, RegWriteEn};

	assign exit_ecall   = ecall_enable && ecall_code == `EXIT_ECALL;
	assign cpu_clk      = clk;
	assign pc = PC;

endmodule