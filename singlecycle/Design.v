`define OPCODE_RTYPE 6'h0
`define OPCODE_HLT 6'b111111
`define OPCODE_ADD 6'h20
`define OPCODE_ADDU 6'h21
`define OPCODE_SUB 6'h22
`define OPCODE_SUBU 6'h23
`define OPCODE_AND 6'h24
`define OPCODE_OR 6'h25
`define OPCODE_XOR 6'h26
`define OPCODE_NOR 6'h27
`define OPCODE_SLT 6'h2a
`define OPCODE_SGT 6'h2b
`define OPCODE_SLL 6'h00
`define OPCODE_SRL 6'h02
`define OPCODE_JR 6'h08
`define OPCODE_ADDI  6'h08
`define OPCODE_ANDI  6'h0C
`define OPCODE_ORI  6'h0D
`define OPCODE_XORI  6'h0E
`define OPCODE_SLTI  6'h2A
`define OPCODE_LW  6'h23
`define OPCODE_SW  6'h2B
`define OPCODE_BEQ  6'h04
`define OPCODE_BNE  6'h05
`define OPCODE_J  6'h02
`define OPCODE_JAL  6'h03

`define ALU_OPCODE_ADD 4'd1 
`define ALU_OPCODE_SUB 4'd2 
`define ALU_OPCODE_AND 4'd3 
`define ALU_OPCODE_OR 4'd4 
`define ALU_OPCODE_XOR 4'd5 
`define ALU_OPCODE_NOR 4'd6 
`define ALU_OPCODE_SLT 4'd7 
`define ALU_OPCODE_SGT 4'd8 
`define ALU_OPCODE_SLL 4'd9
`define ALU_OPCODE_SRL 4'd10

`define RETURN_ADDRESS_REGISTER 5'd1

`define BIT_WIDTH [31:0]

`ifdef vscode
`include "DataMemory.v"
`endif

module programCounter 
(
	input clk, rst, 
	input `BIT_WIDTH PCin, 
	output reg `BIT_WIDTH PCout
);
	parameter initialaddr = -1;
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
	input `BIT_WIDTH addr,
	output `BIT_WIDTH Data_Out
);
	reg `BIT_WIDTH InstMem [0 : 1023];
	assign Data_Out = InstMem[addr[9:0]];

	integer i;
	initial begin
		for (i = 0; i <= 1023; i = i + 1)
			InstMem[i] <= 0;
		`include "IM_INIT.INIT"
	end      
endmodule

module controlUnit
(
	input rst,
	input wire [5:0] opcode, funct,
	output reg [3:0] ALUOp,
	output reg RegDst, MemReadEn, MemtoReg, MemWriteEn, RegWriteEn, ALUSrc, hlt
);
	always @(*) begin
		if(rst) begin 
			{RegDst, MemReadEn, MemtoReg, MemWriteEn, RegWriteEn, ALUOp, ALUSrc, hlt} <= 0;
		end
		else begin
			{RegDst, MemReadEn, MemtoReg, MemWriteEn, RegWriteEn, ALUOp, ALUSrc, hlt} = 0;
			case(opcode)
				`OPCODE_HLT: begin
					hlt <= 1'b1;
				end
				`OPCODE_RTYPE : begin
					case (funct) 
						`OPCODE_JR : begin
							RegDst <= 1'b1; 
							RegWriteEn <= 1'b1; 
						end
						`OPCODE_ADD, `OPCODE_ADDU : begin
							ALUOp <= `ALU_OPCODE_ADD;
							RegDst <= 1'b1; 
							RegWriteEn <= 1'b1; 
						end
						`OPCODE_SUB, `OPCODE_SUBU : begin
							ALUOp <= `ALU_OPCODE_SUB;
							RegDst <= 1'b1; 
							RegWriteEn <= 1'b1; 
						end
						`OPCODE_AND : begin
							ALUOp <= `ALU_OPCODE_AND;
							RegDst <= 1'b1; 
							RegWriteEn <= 1'b1; 
						end
						`OPCODE_OR : begin 
							ALUOp <= `ALU_OPCODE_OR;
							RegDst <= 1'b1; 
							RegWriteEn <= 1'b1; 
						end
						`OPCODE_XOR : begin 
							ALUOp <= `ALU_OPCODE_XOR;
							RegDst <= 1'b1; 
							RegWriteEn <= 1'b1; 
						end
						`OPCODE_NOR : begin 
							ALUOp <= `ALU_OPCODE_NOR;
							RegDst <= 1'b1; 
							RegWriteEn <= 1'b1; 
						end
						`OPCODE_SLT : begin 
							ALUOp <= `ALU_OPCODE_SLT;
							RegDst <= 1'b1; 
							RegWriteEn <= 1'b1; 
						end
						`OPCODE_SGT : begin 
							ALUOp <= `ALU_OPCODE_SGT;
							RegDst <= 1'b1; 
							RegWriteEn <= 1'b1; 
						end
						`OPCODE_SLL : begin 
							ALUSrc <= 1'b1;
							ALUOp <= `ALU_OPCODE_SLL;
							RegDst <= 1'b1; 
							RegWriteEn <= 1'b1; 
						end
						`OPCODE_SRL : begin
							ALUSrc <= 1'b1;
							ALUOp <= `ALU_OPCODE_SRL;
							RegDst <= 1'b1; 
							RegWriteEn <= 1'b1; 
						end
						`OPCODE_JR : begin
							ALUOp <= `ALU_OPCODE_ADD;
							RegDst <= 1'b1; 
							RegWriteEn <= 1'b1; 
						end
						default : begin
							RegWriteEn <= 1'b0;
						end
					endcase
				end
				`OPCODE_J : begin
				end
				`OPCODE_JAL : begin
					RegWriteEn <= 1'b1;
					RegDst <= 1'b1;
					ALUSrc <= 1'b1;
					ALUOp <= `ALU_OPCODE_ADD;
				end
				`OPCODE_SLTI : begin
					RegWriteEn <= 1'b1;
					RegDst <= 1'b0;
					ALUSrc <= 1'b1;
					ALUOp <= `ALU_OPCODE_SLT;
				end
				`OPCODE_ADDI : begin
					RegWriteEn <= 1'b1;
					ALUSrc <= 1'b1;
					ALUOp <= `ALU_OPCODE_ADD;
				end
				`OPCODE_ANDI : begin
					ALUOp <= `ALU_OPCODE_AND;
					RegWriteEn <= 1'b1;
					ALUSrc <= 1'b1;
				end
				`OPCODE_ORI : begin
					ALUOp <= `ALU_OPCODE_OR;
					RegWriteEn <= 1'b1;
					ALUSrc <= 1'b1;
				end
				`OPCODE_XORI : begin
					ALUOp <= `ALU_OPCODE_XOR;
					RegWriteEn <= 1'b1;
					ALUSrc <= 1'b1;
				end
				`OPCODE_LW : begin
					MemReadEn <= 1'b1;
					RegWriteEn <= 1'b1;
					ALUSrc <= 1'b1;
					MemtoReg <= 1'b1;
					ALUOp <= `ALU_OPCODE_ADD;
				end
				`OPCODE_SW : begin
					MemWriteEn <= 1'b1;
					ALUSrc <= 1'b1;
					ALUOp <= `ALU_OPCODE_ADD;
				end
				`OPCODE_BEQ, `OPCODE_BNE : begin
					ALUOp <= `ALU_OPCODE_SUB;
				end
				default : begin
					MemWriteEn <= 1'b0; 
					RegWriteEn <= 1'b0;
				end
			endcase
		end	
	end
endmodule

module BranchController(
	input rst,
	input [5:0] opcode, funct,
	input `BIT_WIDTH operand1, operand2,
	output reg PCsrc
);

	always@(*) begin
		if (rst)
			PCsrc <= 0;
		else begin
			PCsrc <= (
						opcode == `OPCODE_BEQ && operand1 == operand2 || 
						opcode == `OPCODE_BNE && operand1 != operand2 ||
						opcode == `OPCODE_J || opcode == `OPCODE_JAL || (opcode == 0 && funct == `OPCODE_JR)
					);
		end
	end
endmodule

module registerFile 
(
	input clk, rst, we,
	input [4:0] readRegister1, readRegister2, writeRegister,
	input `BIT_WIDTH writeData,
	output wire `BIT_WIDTH RegFileDataOut_1, RegFileDataOut_2
);

	reg `BIT_WIDTH registers [0:31];
	assign RegFileDataOut_1 = registers[readRegister1];
	assign RegFileDataOut_2 = registers[readRegister2];
	always@(posedge clk,  posedge rst) begin : Write_on_register_file_block
		integer i;
		if(rst) begin
			for(i=0; i<32; i = i + 1) registers[i] <= 0;
		end
		else if(we && writeRegister != 0) begin
			registers[writeRegister] <= writeData;
		end
	end
`ifdef vscode
	integer i;
	initial begin
		#(`MAX_CLOCKS + `reset);
		$display("Register file content : ");
		for (i = 0; i <= 31; i = i + 1) begin
			$display("index = %d , reg_out : signed = %d , unsigned = %d",i`BIT_WIDTH, $signed(registers[i]), $unsigned(registers[i]));
		end
	end 
`endif

endmodule

module ALU 
(
	input `BIT_WIDTH operand1, operand2, 
	input [3:0] opSel, 
	output reg `BIT_WIDTH result, 
	output zero
);

always @ (*) begin
  case(opSel)
    `ALU_OPCODE_ADD: result <= operand1 + operand2;
    `ALU_OPCODE_SUB: result <= operand1 - operand2;
    `ALU_OPCODE_AND: result <= operand1 & operand2;
    `ALU_OPCODE_OR : result <= operand1 | operand2;
    `ALU_OPCODE_XOR: result <= operand1 ^ operand2; 
    `ALU_OPCODE_NOR: result <= ~(operand1 | operand2);
    `ALU_OPCODE_SLT: result <= ($signed(operand1) < $signed(operand2)) ? 32'b1 : 32'b0; 
    `ALU_OPCODE_SGT: result <= ($signed(operand1) > $signed(operand2)) ? 32'b1 : 32'b0; 
    `ALU_OPCODE_SLL: result <= operand1 << operand2;
    `ALU_OPCODE_SRL: result <= operand1 >> operand2;

    default: result <= -1;
  endcase
end
assign zero = (result == 32'b0);

endmodule

module mux2x1 #(parameter size = 32) 
(
	input [size-1:0] in1, in2, 
	input s, 
	output [size-1:0]out
);
	assign out = (~s) ? in1 : in2;
endmodule


module SC_CPU
(
	input InputClk, rst,
	output `BIT_WIDTH AddressBus,
	input `BIT_WIDTH DataBusIn,
	output `BIT_WIDTH DataBusOut,
	output [2:0] ControlBus,
	output reg `BIT_WIDTH CyclesConsumed
);
	wire `BIT_WIDTH PC;
	
	wire `BIT_WIDTH Instruction, InstructionMemoryOut, RegFileDataOut_1, RegFileDataOut_2, 
	RegFileDataOut_1_w, extImm, ALUin2, DataBus, ALUResult, immediate, shamt, address, nextPC, PCPlus1, adderResult;

	wire [15:0] imm;
	wire [5:0] opcode, funct;
	wire [4:0] rs, rt, rd, WriteRegister;
	wire [3:0] ALUOp;
	wire RegDst, MemReadEn, MemtoReg, MemWriteEn, RegWriteEn, ALUSrc, zero, hlt;
	wire PCsrc;
	
	
	assign opcode  = Instruction[31:26];
	assign rd      = ((opcode == `OPCODE_JAL) ? `RETURN_ADDRESS_REGISTER : Instruction[15:11]);
	assign rs      = Instruction[25:21];
	assign rt      = Instruction[20:16];
	assign imm     = Instruction[15:0];
	assign shamt   = {32'd0, Instruction[10:6]};
	assign funct   = Instruction[5:0];
	assign address = {32'd0, Instruction[25:0]};


	or hlt_logic(clk, InputClk, hlt);
		
	always@(posedge clk , posedge rst) begin
		if (rst)
			CyclesConsumed <= 32'd0;
		else
			CyclesConsumed <= CyclesConsumed + 32'd1;
	end

	programCounter pc
	(
		.clk(clk), 
		.rst(rst), 
		.PCin(nextPC), 
		.PCout(PC)
	);

	IM InstMem
	(
		.addr(PC), 
		.Data_Out(InstructionMemoryOut)
	);

	BranchController branchcontroller
	(
		.opcode(opcode), 
		.funct(funct), 
		.operand1(RegFileDataOut_1), 
		.operand2(ALUin2), 
		.PCsrc(PCsrc), 
		.rst(rst)
	);

	controlUnit CU
	(
		.opcode(opcode), 
		.funct(funct), 
		.rst(rst), 
		.RegDst(RegDst), 
		.MemReadEn(MemReadEn), 
		.MemtoReg(MemtoReg), 
		.ALUOp(ALUOp), 
		.MemWriteEn(MemWriteEn), 
		.RegWriteEn(RegWriteEn), 
		.ALUSrc(ALUSrc), 
		.hlt(hlt)
	);

	registerFile RF
	(
		.clk(clk), 
		.rst(rst), 
		.we(RegWriteEn), 
		.readRegister1(rs), 
		.readRegister2(rt), 
		.writeRegister(WriteRegister), 
		.writeData(DataBus), 
		.RegFileDataOut_1(RegFileDataOut_1), 
		.RegFileDataOut_2(RegFileDataOut_2)
	);
		
	ALU alu
	(
		.operand1(RegFileDataOut_1_w), 
		.operand2(ALUin2), 
		.opSel(ALUOp), 
		.result(ALUResult), 
		.zero(zero)
	);

	mux2x1 #(5) RFMux
	(
		.in1(rt), 
		.in2(rd), 
		.s(RegDst), 
		.out(WriteRegister)
	);

	mux2x1 #(32) ALUMux
	(
		.in1(RegFileDataOut_2), 
		.in2(immediate), 
		.s(ALUSrc), 
		.out(ALUin2)
	);

	assign PCPlus1 = PC + 32'd1;
	assign adderResult = (opcode == `OPCODE_JAL || opcode == `OPCODE_J) ? address : 
	(
		(opcode == 0 && funct == `OPCODE_JR) ? RegFileDataOut_1 : ( PC + {{32{imm[15]}}, imm})
	);
	assign nextPC = (PCsrc) ? adderResult : PCPlus1;
	assign extImm = (opcode == `OPCODE_ANDI || opcode == `OPCODE_ORI || opcode == `OPCODE_XORI) ? {16'd0, imm} : {{16{imm[15]}}, imm};
	assign immediate = (opcode == 0 && (funct == `OPCODE_SLL || funct == `OPCODE_SRL)) ? shamt : (
		(opcode == `OPCODE_JAL) ? 32'd1 : extImm
	);
	assign RegFileDataOut_1_w = (opcode == 0 && (funct == `OPCODE_SLL || funct == `OPCODE_SRL)) ? RegFileDataOut_2 : ((opcode == `OPCODE_JAL) ? PC : RegFileDataOut_1);
	assign Instruction = (rst) ? 0 : InstructionMemoryOut;
	
	assign AddressBus = ALUResult;
	assign DataBusOut = RegFileDataOut_2;
	assign DataBus = (MemReadEn) ? DataBusIn : ALUResult;
	assign ControlBus = {MemWriteEn, MemReadEn, RegWriteEn};

endmodule