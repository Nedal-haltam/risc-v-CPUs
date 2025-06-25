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

module programCounter 
(
	input clk, rst, 
	input [31:0] PCin, 
	output reg [31:0] PCout
);
	parameter initialaddr = -1;
	always@(posedge clk, negedge rst) begin
		if(~rst) begin
			PCout <= initialaddr;
		end
		else begin
			PCout <= PCin;
		end
	end
	
endmodule

module IM
(
	input [31:0] addr,
	output [31:0] Data_Out
);
	reg [31:0] InstMem [0 : 2047];
	assign Data_Out = InstMem[addr[10:0]];

	integer i;
	initial begin
		for (i = 0; i <= 2047; i = i + 1)
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
		if(~rst) begin 
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
	input [31:0] operand1, operand2,
	output reg PCsrc
);

	always@(*) begin
		if (~rst)
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
	input [31:0] writeData,
	output wire [31:0] readData1, readData2
);

	reg [31:0] registers [0:31];
	assign readData1 = registers[readRegister1];
	assign readData2 = registers[readRegister2];
	always@(posedge clk,  negedge rst) begin : Write_on_register_file_block
		integer i;
		if(~rst) begin
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
  for (i = 0; i <= 31; i = i + 1)
    $display("index = %d , reg_out : signed = %d , unsigned = %d",i[31:0], $signed(registers[i]), $unsigned(registers[i]));
end 
`endif

endmodule

module ALU 
(
	input [31:0] operand1, operand2, 
	input [3:0] opSel, 
	output reg [31:0] result, 
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

module DM
(
	input clock, rden, wren,
	input [31:0] address,
	input [31:0] data,
	output reg [31:0] q
);

reg [31 : 0] DataMem [0 : (`MEMORY_SIZE-1)];
always @(posedge clock) begin
    if (rden)
        q <= DataMem[address[(`MEMORY_BITS-1):0]];
    if (wren)
        DataMem[address] <= data;
end
initial begin
for (i = 0; i <= (`MEMORY_SIZE-1); i = i + 1)
    DataMem[i] <= 0;

`include "DM_INIT.INIT"
end

`ifdef vscode
integer i;
initial begin
  #(`MAX_CLOCKS + `reset);
  // iterating through some of the addresses of the memory to check if the program loaded and stored the values properly
  $display("Data Memory Content : ");
  for (i = 0; i <= (`MEMORY_SIZE-1); i = i + 1)
    $display("Mem[%d] = %d",i[(`MEMORY_BITS-1):0],$signed(DataMem[i]));
end 
`endif
endmodule

module mux2x1 #(parameter size = 32) (in1, in2, s, out);

	// inputs	
	input s;
	//input [size:0] in1, in2;
	input [size - 1:0] in1, in2;
	
	// outputs
	//output [size:0] out; // was
	output [size - 1:0] out;

	// Unit logic
	assign out = (~s) ? in1 : in2;
	
endmodule

module SC_CPU(input_clk, rst, PC, cycles_consumed, clk);

	//inputs
	input input_clk, rst;
	output wire clk;
	//outputs
	output [31:0] PC;
	output reg [31:0] cycles_consumed;
	
	wire [31:0] instruction, wire_instruction, writeData, readData1, readData2, readData1_w, extImm, ALUin2;
	wire [31:0] ALUResult, memoryReadData, immediate, shamt, address, nextPC, PCPlus1, adderResult;
	wire [15:0] imm;
	wire [5:0] opcode, funct;
	wire [4:0] rs, rt, rd, WriteRegister;
	wire [3:0] ALUOp;
	wire RegDst, MemReadEn, MemtoReg, MemWriteEn, RegWriteEn, ALUSrc, zero, hlt;
	wire PCsrc;
	
	
	assign opcode  = (~rst) ? 0 : instruction[31:26];
	assign rd      = (~rst) ? 0 : ((opcode == `OPCODE_JAL) ? 5'd31 : instruction[15:11]);
	assign rs      = (~rst) ? 0 : instruction[25:21];
	assign rt      = (~rst) ? 0 : instruction[20:16];
	assign imm     = (~rst) ? 0 : instruction[15:0];
	assign shamt   = (~rst) ? 0 : {32'd0, instruction[10:6]};
	assign funct   = (~rst) ? 0 : instruction[5:0];
	assign address = (~rst) ? 0 : {32'd0, instruction[25:0]};


or hlt_logic(clk, input_clk, hlt);
 
	
always@(posedge clk , negedge rst) begin

	if (~rst)
		cycles_consumed <= 32'd0;
	else
		cycles_consumed <= cycles_consumed + 32'd1;

end

BranchController branchcontroller(.opcode(opcode), .funct(funct), .operand1(readData1), .operand2(ALUin2), .PCsrc(PCsrc), .rst(rst));


assign PCPlus1 = PC + 32'd1;
assign adderResult = (opcode == `OPCODE_JAL || opcode == `OPCODE_J) ? address : 
(
	(opcode == 0 && funct == `OPCODE_JR) ? readData1 : ( PC + {{32{imm[15]}}, imm})
);


assign nextPC = (PCsrc) ? adderResult : PCPlus1;
programCounter pc(.clk(clk), .rst(rst), .PCin(nextPC), .PCout(PC));	


IM InstMem(.addr(PC), .Data_Out(wire_instruction));

assign instruction = (~rst) ? 0 : wire_instruction;

controlUnit CU(.opcode(opcode), .funct(funct), .rst(rst),
				      .RegDst(RegDst), .MemReadEn(MemReadEn), .MemtoReg(MemtoReg),
				      .ALUOp(ALUOp), .MemWriteEn(MemWriteEn), .RegWriteEn(RegWriteEn), .ALUSrc(ALUSrc), .hlt(hlt));
	
mux2x1 #(5) RFMux(.in1(rt), .in2(rd), .s(RegDst), .out(WriteRegister));
	
registerFile RF(.clk(clk), .rst(rst), .we(RegWriteEn), 					
			    .readRegister1(rs), .readRegister2(rt), .writeRegister(WriteRegister),
			    .writeData(writeData), .readData1(readData1), .readData2(readData2));


assign extImm = (opcode == `OPCODE_ANDI || opcode == `OPCODE_ORI || opcode == `OPCODE_XORI) ? {16'd0, imm} : {{16{imm[15]}}, imm};
assign immediate = (opcode == 0 && (funct == `OPCODE_SLL || funct == `OPCODE_SRL)) ? shamt : (
	(opcode == `OPCODE_JAL) ? 32'd1 : extImm
);
mux2x1 #(32) ALUMux(.in1(readData2), .in2(immediate), .s(ALUSrc), .out(ALUin2));
	
assign readData1_w = (opcode == 0 && (funct == `OPCODE_SLL || funct == `OPCODE_SRL)) ? readData2 : (
	(opcode == `OPCODE_JAL) ? PC : readData1
);
ALU alu(.operand1(readData1_w), .operand2(ALUin2), .opSel(ALUOp), .result(ALUResult), .zero(zero));



DM dataMem(.address(ALUResult[31:0]), .clock(~clk), .data(readData2), .rden(MemReadEn), .wren(MemWriteEn), .q(memoryReadData));

mux2x1 #(32) WBMux(.in1(ALUResult), .in2(memoryReadData), .s(MemtoReg), .out(writeData));

	
endmodule
