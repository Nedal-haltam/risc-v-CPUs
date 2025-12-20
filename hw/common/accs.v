////////////////////////////////////////////////////////////////////////////////////
module PE_conv1d_2dsys
#(
parameter PECount   = 0
,parameter DataWidth = 32
)
(
    input clk, rst, trigger
    ,input      `INT_BIT_WIDTH InDim0Lane0
    ,output reg `INT_BIT_WIDTH OutDim0Lane0
    ,input      `INT_BIT_WIDTH InDim1Lane0
    ,output reg `INT_BIT_WIDTH OutDim1Lane0
    ,output reg `INT_BIT_WIDTH PEValue
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
    ,input `INT_BIT_WIDTH Dim0Input0Lane0
    ,input `INT_BIT_WIDTH Dim0Input1Lane0
    ,input `INT_BIT_WIDTH Dim0Input2Lane0
    ,input `INT_BIT_WIDTH Dim0Input3Lane0
    ,input `INT_BIT_WIDTH Dim1Input0Lane0
    ,input `INT_BIT_WIDTH Dim1Input1Lane0
    ,input `INT_BIT_WIDTH Dim1Input2Lane0
    ,input `INT_BIT_WIDTH Dim1Input3Lane0
	,output `INT_BIT_WIDTH DimOutput0
	,output `INT_BIT_WIDTH DimOutput1
	,output `INT_BIT_WIDTH DimOutput2
	,output `INT_BIT_WIDTH DimOutput3
	,output `INT_BIT_WIDTH DimOutput4
	,output `INT_BIT_WIDTH DimOutput5
	,output `INT_BIT_WIDTH DimOutput6
);
    wire `INT_BIT_WIDTH PassThroughWires0Lane0[3:0];
    wire `INT_BIT_WIDTH PassThroughWires1Lane0[3:0];
    assign PassThroughWires0Lane0[0] = Dim0Input0Lane0;
    assign PassThroughWires0Lane0[1] = Dim0Input1Lane0;
    assign PassThroughWires0Lane0[2] = Dim0Input2Lane0;
    assign PassThroughWires0Lane0[3] = Dim0Input3Lane0;
    assign PassThroughWires1Lane0[0] = Dim1Input0Lane0;
    assign PassThroughWires1Lane0[1] = Dim1Input1Lane0;
    assign PassThroughWires1Lane0[2] = Dim1Input2Lane0;
    assign PassThroughWires1Lane0[3] = Dim1Input3Lane0;
    wire `INT_BIT_WIDTH PEOutDim0Lane0 [3:0][3:0];
    wire `INT_BIT_WIDTH PEOutDim1Lane0 [3:0][3:0];
    wire `INT_BIT_WIDTH PEValues [15:0];
    genvar Dim0Index, Dim1Index, DummyIndex;
    generate
	    for (Dim0Index = 0; Dim0Index < 4; Dim0Index = Dim0Index + 1) begin : Dim0IndexForLoopBlock
		    for (Dim1Index = 0; Dim1Index < 4; Dim1Index = Dim1Index + 1) begin : Dim1IndexForLoopBlock
				localparam PECount = Dim1Index * 4 * 1 + Dim0Index * 1 + 0;
				wire `INT_BIT_WIDTH InDim0Lane0;
				assign InDim0Lane0 = PassThroughWires0Lane0[Dim0Index];
				wire `INT_BIT_WIDTH InDim1Lane0;
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
    reg `INT_BIT_WIDTH OutputDim [6:0];
    reg `INT_BIT_WIDTH index = 0;
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
    ,input      `INT_BIT_WIDTH InDim0Lane0
    ,output reg `INT_BIT_WIDTH OutDim0Lane0
    ,output reg `INT_BIT_WIDTH PEValue
    ,input InternalRegisterEnable
    ,input `INT_BIT_WIDTH InternalRegisterInputValue0
);
    reg `INT_BIT_WIDTH InternalRegister0;
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
    ,input `INT_BIT_WIDTH Dim0InputLane0
    ,input `INT_BIT_WIDTH InternalRegisterEnableIndex
    ,input `INT_BIT_WIDTH InternalRegisterInputValue0

	,output `INT_BIT_WIDTH DimOutput0
	,output `INT_BIT_WIDTH DimOutput1
	,output `INT_BIT_WIDTH DimOutput2
	,output `INT_BIT_WIDTH DimOutput3
	,output `INT_BIT_WIDTH DimOutput4
	,output `INT_BIT_WIDTH DimOutput5
	,output `INT_BIT_WIDTH DimOutput6
	,output `INT_BIT_WIDTH DimOutput7
	,output `INT_BIT_WIDTH DimOutput8
	,output `INT_BIT_WIDTH DimOutput9
	,output `INT_BIT_WIDTH DimOutput10
	,output `INT_BIT_WIDTH DimOutput11
	,output `INT_BIT_WIDTH DimOutput12
	,output `INT_BIT_WIDTH DimOutput13
	,output `INT_BIT_WIDTH DimOutput14
	,output `INT_BIT_WIDTH DimOutput15
	,output `INT_BIT_WIDTH DimOutput16
	,output `INT_BIT_WIDTH DimOutput17
	,output `INT_BIT_WIDTH DimOutput18
);
    wire `INT_BIT_WIDTH PassThroughWires0Lane0;
    assign PassThroughWires0Lane0 = Dim0InputLane0;
    wire `INT_BIT_WIDTH PEOutDim0Lane0 [9:0];
    wire `INT_BIT_WIDTH PEValues [9:0];
    genvar Dim0Index, DummyIndex;
    generate
	    for (Dim0Index = 0; Dim0Index < 10; Dim0Index = Dim0Index + 1) begin : Dim0IndexForLoopBlock
			localparam PECount = Dim0Index * 1 + 0;
			wire `INT_BIT_WIDTH InDim0Lane0;
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
    reg `INT_BIT_WIDTH OutputDim [18:0];
    reg `INT_BIT_WIDTH i = 0;
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
    ,input      `INT_BIT_WIDTH InDim0Lane0
    ,output reg `INT_BIT_WIDTH OutDim0Lane0
    ,output reg `INT_BIT_WIDTH PEValue
    ,input InternalRegisterEnable
    ,input `INT_BIT_WIDTH InternalRegisterInputValue0
);
    reg `INT_BIT_WIDTH InternalRegister0;
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
    ,input `INT_BIT_WIDTH Dim0InputLane0
    ,input `INT_BIT_WIDTH InternalRegisterEnableIndex
    ,input `INT_BIT_WIDTH InternalRegisterInputValue0
);
    wire `INT_BIT_WIDTH PassThroughWires0Lane0;
    assign PassThroughWires0Lane0 = Dim0InputLane0;
    wire `INT_BIT_WIDTH PEOutDim0Lane0 [9:0];
    wire `INT_BIT_WIDTH PEValues [9:0];
    genvar Dim0Index, DummyIndex;
    generate
	    for (Dim0Index = 0; Dim0Index < 10; Dim0Index = Dim0Index + 1) begin : Dim0IndexForLoopBlock
			localparam PECount = Dim0Index * 1 + 0;
			wire `INT_BIT_WIDTH InDim0Lane0;
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
    reg `INT_BIT_WIDTH OutputDim [18:0];
    reg `INT_BIT_WIDTH i = 0;
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
////////////////////////////////////////////////////////////////////////////////////
module PE_conv2d
#(
parameter PECount   = 0
,parameter DataWidth = 8
)
(
    input clk, rst, trigger, input `INT_BIT_WIDTH file
    ,input      `INT_BIT_WIDTH InDim0Lane0
    ,output reg `INT_BIT_WIDTH OutDim0Lane0
    ,input      `INT_BIT_WIDTH InDim0Lane1
    ,output reg `INT_BIT_WIDTH OutDim0Lane1
    ,input      `INT_BIT_WIDTH InDim0Lane2
    ,output reg `INT_BIT_WIDTH OutDim0Lane2
    ,input      `INT_BIT_WIDTH InDim1Lane0
    ,output reg `INT_BIT_WIDTH OutDim1Lane0
    ,input      `INT_BIT_WIDTH InDim1Lane1
    ,output reg `INT_BIT_WIDTH OutDim1Lane1
    ,input      `INT_BIT_WIDTH InDim1Lane2
    ,output reg `INT_BIT_WIDTH OutDim1Lane2
    ,output reg `INT_BIT_WIDTH PEValue
    ,input InternalRegisterEnable
    ,input `INT_BIT_WIDTH InternalRegisterInputValue0
);
    reg `INT_BIT_WIDTH InternalRegister0;
    always@(posedge clk) begin
        if (InternalRegisterEnable) begin
            InternalRegister0 <= InternalRegisterInputValue0;
        end
    end
    always@(posedge clk) begin
        if (rst) begin
            OutDim0Lane0 <= 0;
            // OutDim0Lane1 <= 0;
            // OutDim0Lane2 <= 0;
            OutDim1Lane0 <= 0;
            // OutDim1Lane1 <= 0;
            // OutDim1Lane2 <= 0;
            PEValue <= 0;
        end
        else if (trigger) begin
            OutDim0Lane0 <= InDim0Lane0;
            // OutDim0Lane1 <= InDim0Lane1;
            // OutDim0Lane2 <= InDim0Lane2;
            OutDim1Lane0 <= InDim0Lane0 * InternalRegister0;
            // OutDim1Lane1 <= InDim0Lane1 * InternalRegister0;
            // OutDim1Lane2 <= InDim0Lane2 * InternalRegister0;
        end
    end
endmodule
module SystolicArray_conv2d
(
    input clk, rst, trigger

    ,input `INT_BIT_WIDTH Dim0Input0Lane0
    ,input `INT_BIT_WIDTH Dim0Input0Lane1
    ,input `INT_BIT_WIDTH Dim0Input0Lane2
    ,input `INT_BIT_WIDTH Dim0Input1Lane0
    ,input `INT_BIT_WIDTH Dim0Input1Lane1
    ,input `INT_BIT_WIDTH Dim0Input1Lane2
    ,input `INT_BIT_WIDTH Dim0Input2Lane0
    ,input `INT_BIT_WIDTH Dim0Input2Lane1
    ,input `INT_BIT_WIDTH Dim0Input2Lane2
    ,input `INT_BIT_WIDTH Dim1Input0Lane0
    ,input `INT_BIT_WIDTH Dim1Input0Lane1
    ,input `INT_BIT_WIDTH Dim1Input0Lane2
    ,input `INT_BIT_WIDTH Dim1Input1Lane0
    ,input `INT_BIT_WIDTH Dim1Input1Lane1
    ,input `INT_BIT_WIDTH Dim1Input1Lane2
    ,input `INT_BIT_WIDTH Dim1Input2Lane0
    ,input `INT_BIT_WIDTH Dim1Input2Lane1
    ,input `INT_BIT_WIDTH Dim1Input2Lane2
    ,input `INT_BIT_WIDTH InternalRegisterEnableIndex
    ,input `INT_BIT_WIDTH InternalRegisterInputValue0

    ,output `INT_BIT_WIDTH Output0
    ,output `INT_BIT_WIDTH Output1
    ,output `INT_BIT_WIDTH Output2
);
    integer file;
    wire `INT_BIT_WIDTH PassThroughWires0Lane0[2:0];
    wire `INT_BIT_WIDTH PassThroughWires0Lane1[2:0];
    wire `INT_BIT_WIDTH PassThroughWires0Lane2[2:0];
    wire `INT_BIT_WIDTH PassThroughWires1Lane0[2:0];
    wire `INT_BIT_WIDTH PassThroughWires1Lane1[2:0];
    wire `INT_BIT_WIDTH PassThroughWires1Lane2[2:0];
    assign PassThroughWires0Lane0[0] = Dim0Input0Lane0;
    assign PassThroughWires0Lane1[0] = Dim0Input0Lane1;
    assign PassThroughWires0Lane2[0] = Dim0Input0Lane2;
    assign PassThroughWires0Lane0[1] = Dim0Input1Lane0;
    assign PassThroughWires0Lane1[1] = Dim0Input1Lane1;
    assign PassThroughWires0Lane2[1] = Dim0Input1Lane2;
    assign PassThroughWires0Lane0[2] = Dim0Input2Lane0;
    assign PassThroughWires0Lane1[2] = Dim0Input2Lane1;
    assign PassThroughWires0Lane2[2] = Dim0Input2Lane2;
    assign PassThroughWires1Lane0[0] = Dim1Input0Lane0;
    assign PassThroughWires1Lane1[0] = Dim1Input0Lane1;
    assign PassThroughWires1Lane2[0] = Dim1Input0Lane2;
    assign PassThroughWires1Lane0[1] = Dim1Input1Lane0;
    assign PassThroughWires1Lane1[1] = Dim1Input1Lane1;
    assign PassThroughWires1Lane2[1] = Dim1Input1Lane2;
    assign PassThroughWires1Lane0[2] = Dim1Input2Lane0;
    assign PassThroughWires1Lane1[2] = Dim1Input2Lane1;
    assign PassThroughWires1Lane2[2] = Dim1Input2Lane2;
    wire `INT_BIT_WIDTH PEOutDim0Lane0 [2:0][2:0];
    wire `INT_BIT_WIDTH PEOutDim0Lane1 [2:0][2:0];
    wire `INT_BIT_WIDTH PEOutDim0Lane2 [2:0][2:0];
    wire `INT_BIT_WIDTH PEOutDim1Lane0 [2:0][2:0];
    wire `INT_BIT_WIDTH PEOutDim1Lane1 [2:0][2:0];
    wire `INT_BIT_WIDTH PEOutDim1Lane2 [2:0][2:0];
    wire `INT_BIT_WIDTH PEValues [8:0];
    genvar Dim0Index, Dim1Index, DummyIndex;
    generate
	    for (Dim0Index = 0; Dim0Index < 3; Dim0Index = Dim0Index + 1) begin : Dim0IndexForLoopBlock
		    for (Dim1Index = 0; Dim1Index < 3; Dim1Index = Dim1Index + 1) begin : Dim1IndexForLoopBlock
				localparam PECount = Dim0Index * 3 * 1 + Dim1Index * 1 + 0;
				wire `INT_BIT_WIDTH InDim0Lane0;
				wire `INT_BIT_WIDTH InDim0Lane1;
				wire `INT_BIT_WIDTH InDim0Lane2;
				if (Dim0Index == 0) begin
				    assign InDim0Lane0 = PassThroughWires0Lane0[Dim1Index];
				    assign InDim0Lane1 = PassThroughWires0Lane1[Dim1Index];
				    assign InDim0Lane2 = PassThroughWires0Lane2[Dim1Index];
				end
				else begin
				    assign InDim0Lane0 = PEOutDim0Lane0[Dim0Index-1][Dim1Index];
				    assign InDim0Lane1 = PEOutDim0Lane1[Dim0Index-1][Dim1Index];
				    assign InDim0Lane2 = PEOutDim0Lane2[Dim0Index-1][Dim1Index];
				end
				wire `INT_BIT_WIDTH InDim1Lane0;
				wire `INT_BIT_WIDTH InDim1Lane1;
				wire `INT_BIT_WIDTH InDim1Lane2;
				assign InDim1Lane0 = PassThroughWires1Lane0[Dim0Index];
				assign InDim1Lane1 = PassThroughWires1Lane1[Dim0Index];
				assign InDim1Lane2 = PassThroughWires1Lane2[Dim0Index];
				PE_conv2d #(.PECount(PECount)) pe
				(
				    .clk(clk),
				    .rst(rst),
				    .trigger(trigger),
				    .file(1),
				    .InDim0Lane0(InDim0Lane0),
				    .OutDim0Lane0(PEOutDim0Lane0[Dim0Index][Dim1Index]),
				    .InDim0Lane1(InDim0Lane1),
				    .OutDim0Lane1(PEOutDim0Lane1[Dim0Index][Dim1Index]),
				    .InDim0Lane2(InDim0Lane2),
				    .OutDim0Lane2(PEOutDim0Lane2[Dim0Index][Dim1Index]),
				    .InDim1Lane0(InDim1Lane0),
				    .OutDim1Lane0(PEOutDim1Lane0[Dim0Index][Dim1Index]),
				    .InDim1Lane1(InDim1Lane1),
				    .OutDim1Lane1(PEOutDim1Lane1[Dim0Index][Dim1Index]),
				    .InDim1Lane2(InDim1Lane2),
				    .OutDim1Lane2(PEOutDim1Lane2[Dim0Index][Dim1Index]),
				    .PEValue(PEValues[PECount])
				    ,.InternalRegisterEnable(InternalRegisterEnableIndex == PECount+1)
				    ,.InternalRegisterInputValue0(InternalRegisterInputValue0)
				);
		    end
	    end
    endgenerate
    wire signed `INT_BIT_WIDTH SUM0 =
        $signed(PEOutDim1Lane0[0][0]) + $signed(PEOutDim1Lane0[0][1]) + $signed(PEOutDim1Lane0[0][2]) +
        $signed(PEOutDim1Lane0[1][0]) + $signed(PEOutDim1Lane0[1][1]) + $signed(PEOutDim1Lane0[1][2]) +
        $signed(PEOutDim1Lane0[2][0]) + $signed(PEOutDim1Lane0[2][1]) + $signed(PEOutDim1Lane0[2][2]);

    // wire signed `INT_BIT_WIDTH SUM1 =
    //     $signed(PEOutDim1Lane1[0][0]) + $signed(PEOutDim1Lane1[0][1]) + $signed(PEOutDim1Lane1[0][2]) +
    //     $signed(PEOutDim1Lane1[1][0]) + $signed(PEOutDim1Lane1[1][1]) + $signed(PEOutDim1Lane1[1][2]) +
    //     $signed(PEOutDim1Lane1[2][0]) + $signed(PEOutDim1Lane1[2][1]) + $signed(PEOutDim1Lane1[2][2]);

    // wire signed `INT_BIT_WIDTH SUM2 =
    //     $signed(PEOutDim1Lane2[0][0]) + $signed(PEOutDim1Lane2[0][1]) + $signed(PEOutDim1Lane2[0][2]) +
    //     $signed(PEOutDim1Lane2[1][0]) + $signed(PEOutDim1Lane2[1][1]) + $signed(PEOutDim1Lane2[1][2]) +
    //     $signed(PEOutDim1Lane2[2][0]) + $signed(PEOutDim1Lane2[2][1]) + $signed(PEOutDim1Lane2[2][2]);

    function [7:0] clamp8(input signed `INT_BIT_WIDTH v);
        reg signed `INT_BIT_WIDTH abs_v;
        begin
            abs_v = (v < 0) ? -v : v;
            if (abs_v < 0) // keep this in case we removed the abs
                clamp8 = 8'd0;
            else if (abs_v > 8'd255)
                clamp8 = 8'd255;
            else
                clamp8 = abs_v[7:0];
        end
    endfunction

    // wire [7:0] c0 = clamp8(SUM0);
    // wire [7:0] c1 = clamp8(SUM1);
    // wire [7:0] c2 = clamp8(SUM2);
    assign Output0 = SUM0;
    // assign Output1 = SUM1;
    // assign Output2 = SUM2;

endmodule
////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////
module PE_conv3d
#(
parameter PECount   = 0
,parameter DataWidth = 32
)
(
    input clk, rst, trigger, input `INT_BIT_WIDTH file
    ,input      `INT_BIT_WIDTH InDim0Lane0
    ,output reg `INT_BIT_WIDTH OutDim0Lane0
    ,input      `INT_BIT_WIDTH InDim1Lane0
    ,output reg `INT_BIT_WIDTH OutDim1Lane0
    ,input      `INT_BIT_WIDTH InDim2Lane0
    ,output reg `INT_BIT_WIDTH OutDim2Lane0
    ,output reg `INT_BIT_WIDTH PEValue
    ,input InternalRegisterEnable
    ,input `INT_BIT_WIDTH InternalRegisterInputValue0
);
    reg `INT_BIT_WIDTH InternalRegister0;
    always@(posedge clk) begin
        if (InternalRegisterEnable) begin
            InternalRegister0 <= InternalRegisterInputValue0;
        end
    end
    always@(posedge clk) begin
        if (rst) begin
            OutDim0Lane0 <= 0;
            OutDim1Lane0 <= 0;
            OutDim2Lane0 <= 0;
            PEValue <= 0;
        end
        else if (trigger) begin
            OutDim0Lane0 <= InDim0Lane0;
            OutDim1Lane0 <= InDim0Lane0 * InternalRegister0;
        end
    end
endmodule
module SystolicArray_conv3d
(
    input clk, rst, trigger
    ,input `INT_BIT_WIDTH Dim0Input00Lane0
    ,input `INT_BIT_WIDTH Dim0Input01Lane0
    ,input `INT_BIT_WIDTH Dim0Input02Lane0
    ,input `INT_BIT_WIDTH Dim0Input10Lane0
    ,input `INT_BIT_WIDTH Dim0Input11Lane0
    ,input `INT_BIT_WIDTH Dim0Input12Lane0
    ,input `INT_BIT_WIDTH Dim0Input20Lane0
    ,input `INT_BIT_WIDTH Dim0Input21Lane0
    ,input `INT_BIT_WIDTH Dim0Input22Lane0
    ,input `INT_BIT_WIDTH Dim1Input00Lane0
    ,input `INT_BIT_WIDTH Dim1Input01Lane0
    ,input `INT_BIT_WIDTH Dim1Input02Lane0
    ,input `INT_BIT_WIDTH Dim1Input10Lane0
    ,input `INT_BIT_WIDTH Dim1Input11Lane0
    ,input `INT_BIT_WIDTH Dim1Input12Lane0
    ,input `INT_BIT_WIDTH Dim1Input20Lane0
    ,input `INT_BIT_WIDTH Dim1Input21Lane0
    ,input `INT_BIT_WIDTH Dim1Input22Lane0
    ,input `INT_BIT_WIDTH Dim2Input00Lane0
    ,input `INT_BIT_WIDTH Dim2Input01Lane0
    ,input `INT_BIT_WIDTH Dim2Input02Lane0
    ,input `INT_BIT_WIDTH Dim2Input10Lane0
    ,input `INT_BIT_WIDTH Dim2Input11Lane0
    ,input `INT_BIT_WIDTH Dim2Input12Lane0
    ,input `INT_BIT_WIDTH Dim2Input20Lane0
    ,input `INT_BIT_WIDTH Dim2Input21Lane0
    ,input `INT_BIT_WIDTH Dim2Input22Lane0

    ,input `INT_BIT_WIDTH InternalRegisterEnableIndex
    ,input `INT_BIT_WIDTH InternalRegisterInputValue0

    ,output `INT_BIT_WIDTH Output0

);
    integer file;
    wire `INT_BIT_WIDTH PassThroughWires0Lane0[2:0][2:0];
    wire `INT_BIT_WIDTH PassThroughWires1Lane0[2:0][2:0];
    wire `INT_BIT_WIDTH PassThroughWires2Lane0[2:0][2:0];
    assign PassThroughWires0Lane0[0][0] = Dim0Input00Lane0;
    assign PassThroughWires0Lane0[0][1] = Dim0Input01Lane0;
    assign PassThroughWires0Lane0[0][2] = Dim0Input02Lane0;
    assign PassThroughWires0Lane0[1][0] = Dim0Input10Lane0;
    assign PassThroughWires0Lane0[1][1] = Dim0Input11Lane0;
    assign PassThroughWires0Lane0[1][2] = Dim0Input12Lane0;
    assign PassThroughWires0Lane0[2][0] = Dim0Input20Lane0;
    assign PassThroughWires0Lane0[2][1] = Dim0Input21Lane0;
    assign PassThroughWires0Lane0[2][2] = Dim0Input22Lane0;
    assign PassThroughWires1Lane0[0][0] = Dim1Input00Lane0;
    assign PassThroughWires1Lane0[0][1] = Dim1Input01Lane0;
    assign PassThroughWires1Lane0[0][2] = Dim1Input02Lane0;
    assign PassThroughWires1Lane0[1][0] = Dim1Input10Lane0;
    assign PassThroughWires1Lane0[1][1] = Dim1Input11Lane0;
    assign PassThroughWires1Lane0[1][2] = Dim1Input12Lane0;
    assign PassThroughWires1Lane0[2][0] = Dim1Input20Lane0;
    assign PassThroughWires1Lane0[2][1] = Dim1Input21Lane0;
    assign PassThroughWires1Lane0[2][2] = Dim1Input22Lane0;
    assign PassThroughWires2Lane0[0][0] = Dim2Input00Lane0;
    assign PassThroughWires2Lane0[0][1] = Dim2Input01Lane0;
    assign PassThroughWires2Lane0[0][2] = Dim2Input02Lane0;
    assign PassThroughWires2Lane0[1][0] = Dim2Input10Lane0;
    assign PassThroughWires2Lane0[1][1] = Dim2Input11Lane0;
    assign PassThroughWires2Lane0[1][2] = Dim2Input12Lane0;
    assign PassThroughWires2Lane0[2][0] = Dim2Input20Lane0;
    assign PassThroughWires2Lane0[2][1] = Dim2Input21Lane0;
    assign PassThroughWires2Lane0[2][2] = Dim2Input22Lane0;
    wire `INT_BIT_WIDTH PEOutDim0Lane0 [2:0][2:0][2:0];
    wire `INT_BIT_WIDTH PEOutDim1Lane0 [2:0][2:0][2:0];
    wire `INT_BIT_WIDTH PEOutDim2Lane0 [2:0][2:0][2:0];
    wire `INT_BIT_WIDTH PEValues [26:0];
    genvar Dim0Index, Dim1Index, Dim2Index, DummyIndex;
    generate
	    for (Dim0Index = 0; Dim0Index < 3; Dim0Index = Dim0Index + 1) begin : Dim0IndexForLoopBlock
		    for (Dim1Index = 0; Dim1Index < 3; Dim1Index = Dim1Index + 1) begin : Dim1IndexForLoopBlock
			    for (Dim2Index = 0; Dim2Index < 3; Dim2Index = Dim2Index + 1) begin : Dim2IndexForLoopBlock
					localparam PECount = Dim0Index * 3 * 3 * 1 + Dim1Index * 3 * 1 + Dim2Index * 1 + 0;
					wire `INT_BIT_WIDTH InDim0Lane0;
					if (Dim0Index == 0) begin
					    assign InDim0Lane0 = PassThroughWires0Lane0[Dim1Index][Dim2Index];
					end
					else begin
					    assign InDim0Lane0 = PEOutDim0Lane0[Dim0Index-1][Dim1Index][Dim2Index];
					end
					wire `INT_BIT_WIDTH InDim1Lane0;
					assign InDim1Lane0 = PassThroughWires1Lane0[Dim0Index][Dim2Index];
					wire `INT_BIT_WIDTH InDim2Lane0;
					assign InDim2Lane0 = PassThroughWires2Lane0[Dim0Index][Dim1Index];
					PE_conv3d #(.PECount(PECount)) pe
					(
					    .clk(clk),
					    .rst(rst),
					    .trigger(trigger),
					    .file(1),
					    .InDim0Lane0(InDim0Lane0),
					    .OutDim0Lane0(PEOutDim0Lane0[Dim0Index][Dim1Index][Dim2Index]),
					    .InDim1Lane0(InDim1Lane0),
					    .OutDim1Lane0(PEOutDim1Lane0[Dim0Index][Dim1Index][Dim2Index]),
					    .InDim2Lane0(InDim2Lane0),
					    .OutDim2Lane0(PEOutDim2Lane0[Dim0Index][Dim1Index][Dim2Index]),
					    .PEValue(PEValues[PECount])
					    ,.InternalRegisterEnable(InternalRegisterEnableIndex == PECount+1)
					    ,.InternalRegisterInputValue0(InternalRegisterInputValue0)
					);
			    end
		    end
	    end
    endgenerate
    wire signed `INT_BIT_WIDTH SUM0 =
        $signed(PEOutDim1Lane0[0][0][0]) + $signed(PEOutDim1Lane0[0][0][1]) + $signed(PEOutDim1Lane0[0][0][2]) + $signed(PEOutDim1Lane0[0][1][0]) + $signed(PEOutDim1Lane0[0][1][1]) + $signed(PEOutDim1Lane0[0][1][2]) + $signed(PEOutDim1Lane0[0][2][0]) + $signed(PEOutDim1Lane0[0][2][1]) + $signed(PEOutDim1Lane0[0][2][2]) + $signed(PEOutDim1Lane0[1][0][0]) + $signed(PEOutDim1Lane0[1][0][1]) + $signed(PEOutDim1Lane0[1][0][2]) + $signed(PEOutDim1Lane0[1][1][0]) + $signed(PEOutDim1Lane0[1][1][1]) + $signed(PEOutDim1Lane0[1][1][2]) + $signed(PEOutDim1Lane0[1][2][0]) + $signed(PEOutDim1Lane0[1][2][1]) + $signed(PEOutDim1Lane0[1][2][2]) + $signed(PEOutDim1Lane0[2][0][0]) + $signed(PEOutDim1Lane0[2][0][1]) + $signed(PEOutDim1Lane0[2][0][2]) + $signed(PEOutDim1Lane0[2][1][0]) + $signed(PEOutDim1Lane0[2][1][1]) + $signed(PEOutDim1Lane0[2][1][2]) + $signed(PEOutDim1Lane0[2][2][0]) + $signed(PEOutDim1Lane0[2][2][1]) + $signed(PEOutDim1Lane0[2][2][2]) +  0;
    function [7:0] clamp8(input signed `INT_BIT_WIDTH v);
        reg signed `INT_BIT_WIDTH abs_v;
        begin
            abs_v = (v < 0) ? -v : v;
            if (abs_v < 0) // keep this in case we removed the abs
                clamp8 = 8'd0;
            else if (abs_v > 8'd255)
                clamp8 = 8'd255;
            else
                clamp8 = abs_v[7:0];
        end
    endfunction

    // wire `INT_BIT_WIDTH c0 = SUM0;
    assign Output0 = SUM0;


endmodule
////////////////////////////////////////////////////////////////////////////////////