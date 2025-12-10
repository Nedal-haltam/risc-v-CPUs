////////////////////////////////////////////////////////////////////////////////////
module PE_conv1d_2dsys
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
module SystolicArray_conv1d_2dsys
(
    input clk, rst, trigger
    ,input `BIT_WIDTH Dim0Input0Lane0
    ,input `BIT_WIDTH Dim0Input1Lane0
    ,input `BIT_WIDTH Dim0Input2Lane0
    ,input `BIT_WIDTH Dim0Input3Lane0
    ,input `BIT_WIDTH Dim1Input0Lane0
    ,input `BIT_WIDTH Dim1Input1Lane0
    ,input `BIT_WIDTH Dim1Input2Lane0
    ,input `BIT_WIDTH Dim1Input3Lane0
	,output `BIT_WIDTH DimOutput0
	,output `BIT_WIDTH DimOutput1
	,output `BIT_WIDTH DimOutput2
	,output `BIT_WIDTH DimOutput3
	,output `BIT_WIDTH DimOutput4
	,output `BIT_WIDTH DimOutput5
	,output `BIT_WIDTH DimOutput6
);
    wire `BIT_WIDTH PassThroughWires0Lane0[3:0];
    wire `BIT_WIDTH PassThroughWires1Lane0[3:0];
    assign PassThroughWires0Lane0[0] = Dim0Input0Lane0;
    assign PassThroughWires0Lane0[1] = Dim0Input1Lane0;
    assign PassThroughWires0Lane0[2] = Dim0Input2Lane0;
    assign PassThroughWires0Lane0[3] = Dim0Input3Lane0;
    assign PassThroughWires1Lane0[0] = Dim1Input0Lane0;
    assign PassThroughWires1Lane0[1] = Dim1Input1Lane0;
    assign PassThroughWires1Lane0[2] = Dim1Input2Lane0;
    assign PassThroughWires1Lane0[3] = Dim1Input3Lane0;
    wire `BIT_WIDTH PEOutDim0Lane0 [3:0][3:0];
    wire `BIT_WIDTH PEOutDim1Lane0 [3:0][3:0];
    wire `BIT_WIDTH PEValues [15:0];
    genvar Dim0Index, Dim1Index, DummyIndex;
    generate
	    for (Dim0Index = 0; Dim0Index < 4; Dim0Index = Dim0Index + 1) begin : Dim0IndexForLoopBlock
		    for (Dim1Index = 0; Dim1Index < 4; Dim1Index = Dim1Index + 1) begin : Dim1IndexForLoopBlock
				localparam PECount = Dim1Index * 4 * 1 + Dim0Index * 1 + 0;
				wire `BIT_WIDTH InDim0Lane0;
				assign InDim0Lane0 = PassThroughWires0Lane0[Dim0Index];
				wire `BIT_WIDTH InDim1Lane0;
				assign InDim1Lane0 = PassThroughWires1Lane0[Dim1Index];
				PE_conv1d_2dsys #(.PECount(PECount)) pe
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
    reg `BIT_WIDTH OutputDim [6:0];
    reg `BIT_WIDTH index = 0;
    integer i;
    integer j;
    always@(posedge clk) begin
        if (rst) begin
            for (i = 0; i < 7; i = i + 1) begin
                OutputDim[i] <= 0;
            end
            index = 0;
        end
        else begin
            if (index < 2) begin
                for (i = 0; i < 4; i = i + 1) begin
                    for (j = 0; j < 4; j = j + 1) begin
                        OutputDim[i + j] = OutputDim[i + j] + PEValues[4 * j + i];
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

	integer k;
`ifdef VSCODE
    initial begin
        `ADVANCE_N_CYCLE(5);
        for (k = 0; k < 7; k = k + 1) begin
            $display("Output%-1d : Value = %-1d",k, $signed(OutputDim[k]));
        end
    end
`endif
endmodule
////////////////////////////////////////////////////////////////////////////////////
module PE_conv1d_1dsys_pl
#(
parameter PECount   = 0
,parameter DataWidth = 32
)
(
    input clk, rst, trigger
    ,input      [31:0] InDim0Lane0
    ,output reg [31:0] OutDim0Lane0
    ,output reg [31:0] PEValue
    ,input InternalRegisterEnable
    ,input [31:0] InternalRegisterInputValue0
);
    reg [31:0] InternalRegister0;
    always@(posedge clk) begin
        if (InternalRegisterEnable) begin
            InternalRegister0 <= InternalRegisterInputValue0;
        end
    end
    always@(posedge clk) begin
        if (rst) begin
            OutDim0Lane0 <= 0;
            PEValue <= 0;
        end
        else if (trigger) begin
            PEValue <= InternalRegister0 * InDim0Lane0;
            OutDim0Lane0 <= InDim0Lane0;
        end
    end
endmodule
module SystolicArray_conv1d_1dsys_pl
(
    input clk, rst, trigger
    ,input [31:0] Dim0InputLane0
    ,input [31:0] InternalRegisterEnableIndex
    ,input [31:0] InternalRegisterInputValue0

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
    wire [31:0] PassThroughWires0Lane0;
    assign PassThroughWires0Lane0 = Dim0InputLane0;
    wire [31:0] PEOutDim0Lane0 [9:0];
    wire [31:0] PEValues [9:0];
    genvar Dim0Index, DummyIndex;
    generate
	    for (Dim0Index = 0; Dim0Index < 10; Dim0Index = Dim0Index + 1) begin : Dim0IndexForLoopBlock
			localparam PECount = Dim0Index * 1 + 0;
			wire [31:0] InDim0Lane0;
			if (Dim0Index == 0) begin
			    assign InDim0Lane0 = PassThroughWires0Lane0;
			end
			else begin
			    assign InDim0Lane0 = PEOutDim0Lane0[Dim0Index-1];
			end
			PE_conv1d_1dsys_pl #(.PECount(PECount)) pe
			(
			    .clk(clk),
			    .rst(rst),
			    .trigger(trigger),
			    .InDim0Lane0(InDim0Lane0),
			    .OutDim0Lane0(PEOutDim0Lane0[Dim0Index]),
			    .PEValue(PEValues[PECount])
			    ,.InternalRegisterEnable(InternalRegisterEnableIndex == PECount+1)
			    ,.InternalRegisterInputValue0(InternalRegisterInputValue0)
			);
	    end
    endgenerate
    reg [31:0] OutputDim [18:0];
    reg [31:0] i = 0;
    integer ii;
    always@(posedge clk) begin
        if (rst) begin
            for (ii = 0; ii < 19; ii = ii + 1) begin
                OutputDim[ii] <= 0;
            end
            i = 0;
        end
        else begin
            if (i < 20) begin
                OutputDim[i-1] = PEValues[0] + PEValues[1] + PEValues[2] + PEValues[3] + PEValues[4] + PEValues[5] + PEValues[6] + PEValues[7] + PEValues[8] + PEValues[9] + 0;
            end
            i = i + 1;
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

	integer j;
`ifdef VSCODE
    initial begin
        `ADVANCE_N_CYCLE(36);
        for (j = 0; j < 19; j = j + 1) begin
            $display("Output%-1d : Value = %-1d",j, $signed(OutputDim[j]));
        end
    end
`endif
endmodule
////////////////////////////////////////////////////////////////////////////////////
module PE_conv1d_1dsys_bc
#(
parameter PECount   = 0
,parameter DataWidth = 32
)
(
    input clk, rst, trigger
    ,input      [31:0] InDim0Lane0
    ,output reg [31:0] OutDim0Lane0
    ,output reg [31:0] PEValue
    ,input InternalRegisterEnable
    ,input [31:0] InternalRegisterInputValue0
);
    reg [31:0] InternalRegister0;
    always@(posedge clk) begin
        if (InternalRegisterEnable) begin
            InternalRegister0 <= InternalRegisterInputValue0;
        end
    end
    always@(posedge clk) begin
        if (rst) begin
            OutDim0Lane0 <= 0;
            PEValue <= 0;
        end
        else if (trigger) begin
            PEValue <= InternalRegister0 * InDim0Lane0;
            OutDim0Lane0 <= InDim0Lane0;
        end
    end
endmodule
module SystolicArray_conv1d_1dsys_bc
(
    input clk, rst, trigger
    ,input [31:0] Dim0InputLane0
    ,input [31:0] InternalRegisterEnableIndex
    ,input [31:0] InternalRegisterInputValue0
);
    wire [31:0] PassThroughWires0Lane0;
    assign PassThroughWires0Lane0 = Dim0InputLane0;
    wire [31:0] PEOutDim0Lane0 [9:0];
    wire [31:0] PEValues [9:0];
    genvar Dim0Index, DummyIndex;
    generate
	    for (Dim0Index = 0; Dim0Index < 10; Dim0Index = Dim0Index + 1) begin : Dim0IndexForLoopBlock
			localparam PECount = Dim0Index * 1 + 0;
			wire [31:0] InDim0Lane0;
			assign InDim0Lane0 = PassThroughWires0Lane0;
			PE_conv1d_1dsys_bc #(.PECount(PECount)) pe
			(
			    .clk(clk),
			    .rst(rst),
			    .trigger(trigger),
			    .InDim0Lane0(InDim0Lane0),
			    .OutDim0Lane0(PEOutDim0Lane0[Dim0Index]),
			    .PEValue(PEValues[PECount])
			    ,.InternalRegisterEnable(InternalRegisterEnableIndex == PECount+1)
			    ,.InternalRegisterInputValue0(InternalRegisterInputValue0)
			);
	    end
    endgenerate
    reg [31:0] OutputDim [18:0];
    reg [31:0] i = 0;
    integer ii;
    always@(posedge clk) begin
        if (rst) begin
            for (ii = 0; ii < 19; ii = ii + 1) begin
                OutputDim[ii] <= 0;
            end
            i = 0;
        end
        else begin
            if (0 < i && i < 11) begin
                for (ii = 0; ii < 10; ii = ii + 1) begin
                    OutputDim[ii+i-1] = OutputDim[ii+i-1] + PEValues[ii];
                end
            end
            i = i + 1;
        end
    end
    integer j;
`ifdef VSCODE
    initial begin
        `ADVANCE_N_CYCLE(36);
        for (j = 0; j < 19; j = j + 1) begin
            $display("Output%-1d : Value = %-1d",j, $signed(OutputDim[j]));
        end
    end
`endif
endmodule
////////////////////////////////////////////////////////////////////////////////////