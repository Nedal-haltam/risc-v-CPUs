`define RType 6'h0
`define hlt_inst 6'b111111
`define add 6'h20
`define addu 6'h21
`define sub 6'h22
`define subu 6'h23
`define and_ 6'h24
`define or_ 6'h25
`define xor_ 6'h26
`define nor_ 6'h27
`define slt 6'h2a
`define sgt 6'h2b
`define sll 6'h00
`define srl 6'h02
`define jr 6'h08
`define addi  6'h08
`define andi  6'h0C
`define ori  6'h0D
`define xori  6'h0E
`define slti  6'h2A
`define lw  6'h23
`define sw  6'h2B
`define beq  6'h04
`define bne  6'h05
`define j  6'h02
`define jal  6'h03

module programCounter (clk, rst, PCin, PCout);
	
	//inputs
	input clk, rst;
	input [31:0] PCin;
	
	//outputs 
	output reg [31:0] PCout;
	
	parameter initialaddr = -1;
	//Counter logic
	always@(posedge clk, negedge rst) begin
		if(~rst) begin
			PCout <= initialaddr;
		end
		else begin
			PCout <= PCin;
		end
	end
	
endmodule

module IM(addr , Data_Out);

parameter bit_width = 32;
input [bit_width - 1:0] addr;
output [bit_width - 1:0] Data_Out;

reg [bit_width - 1:0] InstMem [0 : 2047];

assign Data_Out = InstMem[addr[10:0]];

integer i;
initial begin
// here we initialize the instruction memory

for (i = 0; i <= 2047; i = i + 1)
    InstMem[i] <= 0;

`include "IM_INIT.INIT"

end      
endmodule

module controlUnit
(
	opcode, funct, rst,
	RegDst, MemReadEn, MemtoReg,
	ALUOp, MemWriteEn, RegWriteEn, ALUSrc, hlt
);
	input wire [5:0] opcode, funct;
	input rst;
	output reg RegDst, MemReadEn, MemtoReg, MemWriteEn, RegWriteEn, ALUSrc, hlt;
	output reg [3:0] ALUOp;
	always @(*) begin
		if(~rst) begin 
			{RegDst, MemReadEn, MemtoReg, MemWriteEn, RegWriteEn, ALUSrc, ALUOp, hlt} <= 0;
		end
		else begin
			{RegDst, MemReadEn, MemtoReg, MemWriteEn, RegWriteEn, ALUSrc, ALUOp, hlt} = 0;

			case(opcode)


				`hlt_inst: begin
					hlt <= 1'b1;
				end
					
				`RType : begin
					
					RegDst <= 1'b1; 
					RegWriteEn <= 1'b1; 
						
					case (funct) 
						
						`jr : begin
						end


						`add, `addu : begin
							ALUOp <= 4'd0; 
						end
							
						`sub, `subu : begin
							ALUOp <= 4'd1; 
						end
							
						`and_ : begin
							ALUOp <= 4'd2; 
						end
							
						`or_ : begin 
							ALUOp <= 4'd3; 
						end

						`xor_ : begin 
							ALUOp <= 4'd4; 
						end

						`nor_ : begin 
							ALUOp <= 4'd5; 
						end

						`slt : begin 
							ALUOp <= 4'd6; 
						end

						`sgt : begin 
							ALUOp <= 4'd7; 
						end

						`sll : begin 
							ALUSrc <= 1'b1;
							ALUOp <= 4'd8; 
						end

						`srl : begin
							ALUSrc <= 1'b1;
							ALUOp <= 4'd9; 
						end

						`jr : begin
							ALUOp <= 4'd0;
						end
						
					endcase
					
				end

				`j : begin
				end

				`jal : begin
					RegWriteEn <= 1'b1;
					RegDst <= 1'b1;
					ALUSrc <= 1'b1;
				end

				`slti : begin
					RegWriteEn <= 1'b1;
					RegDst <= 1'b0;
					ALUSrc <= 1'b1;
					ALUOp <= 4'd6;
				end

					
				`addi : begin
					RegWriteEn <= 1'b1;
					ALUSrc <= 1'b1;
				end

				`andi : begin
					ALUOp <= 4'd2;
					RegWriteEn <= 1'b1;
					ALUSrc <= 1'b1;
				end

				`ori : begin
					ALUOp <= 4'd3;
					RegWriteEn <= 1'b1;
					ALUSrc <= 1'b1;
				end
					
				`xori : begin
					ALUOp <= 4'd4;
					RegWriteEn <= 1'b1;
					ALUSrc <= 1'b1;
				end

				`lw : begin
					MemReadEn <= 1'b1;
					RegWriteEn <= 1'b1;
					ALUSrc <= 1'b1;
					MemtoReg <= 1'b1;
				end
					
				`sw : begin
					MemWriteEn <= 1'b1;
					ALUSrc <= 1'b1;
				end
					
				`beq, `bne : begin
					ALUOp <= 4'd1;
				end
				
				default: ;
			endcase
		end	
	end
endmodule

module BranchController(
	input [5:0] opcode, funct,
	input [31:0] operand1, operand2,
	input rst,
	output reg PCsrc
);

always@(*) begin
if (~rst)
	PCsrc <= 0;
else begin
PCsrc <= (opcode == `beq && operand1 == operand2 || 
         opcode == `bne && operand1 != operand2 ||
		 opcode == `j || opcode == `jal || (opcode == 0 && funct == `jr));
end
end
endmodule

module registerFile (clk, rst, we, 
					 readRegister1, readRegister2, writeRegister,
					 writeData, readData1, readData2);
	// inputs
	input wire clk, rst, we;
	input wire [4:0] readRegister1, readRegister2, writeRegister;
	input wire [31:0] writeData;
	
	// outputs
	output wire [31:0] readData1, readData2;
	
	// register file (registers)
	reg [31:0] registers [0:31];
	
	// Read from the register file
	assign readData1 = registers[readRegister1];
  assign readData2 = registers[readRegister2];
						
  						
  always@(posedge clk,  negedge rst) begin : Write_on_register_file_block
	
		integer i;
		// Reset the register file
		if(~rst) begin
			for(i=0; i<32; i = i + 1) registers[i] <= 0; //it was = I changed it to <= for non-blocking assignment ID = 8
		end
		// Write to the register file
		else if(we) begin
			registers[writeRegister] <= writeData;
			registers[0] <= 32'b0; //added this line because writing on register 0 is illegal for MIPS-like architecture ID = 9
		end
		// Defualt to prevent latching
		else;
		
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

module ALU (operand1, operand2, opSel, result, zero);
	
parameter data_width = 32;  
parameter sel_width = 4;
	
input [data_width - 1 : 0] operand1, operand2;  
input [sel_width - 1 : 0] opSel;                  

output reg [data_width - 1 : 0] result;  
output zero;                          

parameter ADD = 4'd0, SUB = 4'd1, AND = 4'd2, OR = 4'd3, XOR = 4'd4, NOR = 4'd5, SLT = 4'd6, SGT = 4'd7, SLL = 4'd8, SRL = 4'd9;

always @ (*) begin
  case(opSel)
    ADD: result <= operand1 + operand2;
    SUB: result <= operand1 - operand2;
    AND: result <= operand1 & operand2;
    OR : result <= operand1 | operand2;
    XOR: result <= operand1 ^ operand2; 
    NOR: result <= ~(operand1 | operand2);
    SLT: result <= ($signed(operand1) < $signed(operand2)) ? 32'b1 : 32'b0; 
    SGT: result <= ($signed(operand1) > $signed(operand2)) ? 32'b1 : 32'b0; 
    SLL: result <= operand1 << operand2;
    SRL: result <= operand1 >> operand2;

    default: result <= -1;
  endcase
end
assign zero = (result == 32'b0);

endmodule


`define MEMORY_SIZE 4096
`define MEMORY_BITS 12 

module DM(address, clock,  data,  rden,  wren,  q);

input clock, rden, wren;
input [31 : 0] address;
input [31 : 0] data;


`ifdef vscode
output reg [31 : 0] q;
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

`else

output [31:0] q;
DataMemory_IP DataMemory
(
	address[(`MEMORY_BITS-1):0],
	clock,
	data,
	wren,
	q
);

`endif


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
	assign rd      = (~rst) ? 0 : ((opcode == `jal) ? 5'd31 : instruction[15:11]);
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
assign adderResult = (opcode == `jal || opcode == `j) ? address : 
(
	(opcode == 0 && funct == `jr) ? readData1 : ( PC + {{32{imm[15]}}, imm})
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


assign extImm = (opcode == `andi || opcode == `ori || opcode == `xori) ? {16'd0, imm} : {{16{imm[15]}}, imm};
assign immediate = (opcode == 0 && (funct == `sll || funct == `srl)) ? shamt : (
	(opcode == `jal) ? 32'd1 : extImm
);
mux2x1 #(32) ALUMux(.in1(readData2), .in2(immediate), .s(ALUSrc), .out(ALUin2));
	
assign readData1_w = (opcode == 0 && (funct == `sll || funct == `srl)) ? readData2 : (
	(opcode == `jal) ? PC : readData1
);
ALU alu(.operand1(readData1_w), .operand2(ALUin2), .opSel(ALUOp), .result(ALUResult), .zero(zero));



DM dataMem(.address(ALUResult[31:0]), .clock(~clk), .data(readData2), .rden(MemReadEn), .wren(MemWriteEn), .q(memoryReadData));

mux2x1 #(32) WBMux(.in1(ALUResult), .in2(memoryReadData), .s(MemtoReg), .out(writeData));

	
endmodule
