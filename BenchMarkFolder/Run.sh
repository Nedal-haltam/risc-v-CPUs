#!/bin/bash

# for a given bench mark their will be a folder with the name of the benchmark
# and inside that folder their will be a file named with the same name for simplicity and because simplicity favours regularity
# and this file will contain the program or the source code of the benchmark

SWFILE=""
HWFILE=""
INDEX=1
TOTAL=15
comapre_two_files()
{
    if diff $1 $2 > /dev/null; then
        printf "[INFO $INDEX/$TOTAL ]: Files are identical.\n"
    else
        printf "[INFO $INDEX/$TOTAL ]: Files are different. Detailed differences:\n"
        diff -a --color=always $1 $2
    fi
}

Run_BenchMark_SW()
{
    ProgName=$1
    ProgFolder="./$ProgName/"
    ProgCode="./$ProgName/$ProgName.S"

    # define the I/O
    ASSEMBLER_IN=$ProgCode
    ASSEMBLER_OUT_TO_CAS_IM=$ProgFolder"MC.txt"
    ASSEMBLER_OUT_TO_CAS_DM=$ProgFolder"DM.txt"
    ASSEMBLER_OUT_IM_INIT=$ProgFolder"IM_INIT.INIT"
    ASSEMBLER_OUT_DM_INIT=$ProgFolder"DM_INIT.INIT"
    ASSEMBLER_OUT_IM_MIF=$ProgFolder"InstMem_MIF.mif"
    ASSEMBLER_OUT_DM_MIF=$ProgFolder"DataMem_MIF.mif"
    # define the program and its arguments
    
    ASSEMBLER="../../risc-v-AssemblerApp/bin/Debug/net8.0-windows/AssemblerApp.exe"
    ASSEMBLER_ARGS="gen $ASSEMBLER_IN $ASSEMBLER_OUT_TO_CAS_IM $ASSEMBLER_OUT_TO_CAS_DM $ASSEMBLER_OUT_IM_INIT $ASSEMBLER_OUT_DM_INIT $ASSEMBLER_OUT_IM_MIF $ASSEMBLER_OUT_DM_MIF"

    # run the the assembler
    printf "[INFO $INDEX/$TOTAL ]: Assembling "$ProgName"...\n"
    $ASSEMBLER $ASSEMBLER_ARGS

    if [ $? -ne 0 ]; then
        printf "\033[31mAssembler failed to assemble the program:\033[0m\nUsage: [path to assembler] gen [input (program)] [IM to CAS] [DM to CAS]\n[IM INIT] [DM INIT] [IM MIF] [DM MIF]\n"
        read -p "Press Enter to exit"
        exit 1
    fi

    printf "[INFO $INDEX/$TOTAL ]: "$ProgName" Assembled Successfully\n"

    # define the I/O
    CAS_IN_IM=$ASSEMBLER_OUT_TO_CAS_IM
    CAS_IN_DM=$ASSEMBLER_OUT_TO_CAS_DM
    CAS_SC_OUT=$ProgFolder"CAS_SC_OUT.txt"
    CAS_PL_OUT=$ProgFolder"CAS_PL_OUT.txt"
    # define the program and its arguments
    CAS="../../risc-v-CAS/bin/Debug/net8.0/CAS.exe"
    
##############################################################################################################
    CAS_ARGS="sim singlecycle $CAS_IN_IM $CAS_IN_DM $CAS_SC_OUT"
    # run the CAS on the single cycle
    printf "[INFO $INDEX/$TOTAL ]: Simulating "$ProgName" on the Single Cycle\n"
    $CAS $CAS_ARGS
    if [ $? -ne 0 ]; then
        printf "\033[31mCycle Accurate Simulator failed to run the program:\033[0m\nUsage: [path to CAS] sim [singlecycle/pipline/OOO] [IM input (machine code)] [DM input] [CAS output]\n"
        read -p "Press Enter to exit"
        exit 1
    fi
    printf "[INFO $INDEX/$TOTAL ]: "$ProgName" simulated successfully on the Single Cycle\n"

##############################################################################################################
    CAS_PL_DATASET=$ProgFolder"BranchPredictorDataset.csv"
    CAS_ARGS="sim pipeline $CAS_PL_DATASET $CAS_IN_IM $CAS_IN_DM $CAS_PL_OUT"
    # run the CAS on the PipeLine
    printf "[INFO $INDEX/$TOTAL ]: Simulating "$ProgName" on the PipeLine\n"
    $CAS $CAS_ARGS

    if [ $? -ne 0 ]; then
        printf "\033[31mCycle Accurate Simulator failed to run the program:\033[0m\nUsage: [path to CAS] sim [singlecycle/pipline/OOO] [IM input (machine code)] [DM input] [CAS output]\n"
        read -p "Press Enter to exit"
        exit 1
    fi
    printf "[INFO $INDEX/$TOTAL ]: "$ProgName" simulated successfully on the PipeLine\n"

    
    STATS=$ProgFolder"stats.txt"
    printf "Software Stats: \n" > $STATS

    printf "\tSingleCycle: \n" >> $STATS
    printf "\t\t" >> $STATS
    sed -n '$p'  "$CAS_SC_OUT" >> $STATS
    printf "\tPipLined: \n" >> $STATS
    printf "\t\t" >> $STATS
    sed -n '$p'  "$CAS_PL_OUT" >> $STATS

    sed -i '$d' "$CAS_SC_OUT"
    sed -i '$d' "$CAS_PL_OUT"

    printf "[INFO $INDEX/$TOTAL ]: Comparing Software Outputs\n"
    comapre_two_files "$CAS_SC_OUT" "$CAS_PL_OUT"

    SWFILE="$CAS_SC_OUT"
}

RunBenchMark_HW()
{

    ProgName=$1
    ProgFolder="./$ProgName/"
    
    printf "[INFO $INDEX/$TOTAL ]: simulating on single cycle hardware\n"
    BASE_PATH="../singlecycle/"
    VERILOG_EXT_SC="VERILOG_SC.vvp"
    VERILOG_EXT_SC_OUT="VERILOG_SC_OUT.txt"
    VERILOG_SC=$ProgFolder""$VERILOG_EXT_SC
    VERILOG_SC_OUT=$ProgFolder""$VERILOG_EXT_SC_OUT
    iverilog -I$ProgFolder -I$BASE_PATH -o $VERILOG_SC -D vscode -D VCD_OUT=\"$ProgFolder"SingleCycle_WaveForm.vcd"\" -D MEMORY_SIZE=4096 -D MEMORY_BITS=12 -D MAX_CLOCKS=1000000 $BASE_PATH"SingleCycle_sim.v"
    printf "finished compiling the single cycle hardware\n"
    
    vvp $VERILOG_SC > $VERILOG_SC_OUT
    printf "[INFO $INDEX/$TOTAL ]: simulating on pipeline hardware\n"
    BASE_PATH="../PipeLine/"
    VERILOG_EXT_PL="VERILOG_PL.vvp"
    VERILOG_EXT_PL_OUT="VERILOG_PL_OUT.txt"
    VERILOG_PL=$ProgFolder""$VERILOG_EXT_PL
    VERILOG_PL_OUT=$ProgFolder""$VERILOG_EXT_PL_OUT
    iverilog -I$ProgFolder -I$BASE_PATH -o $VERILOG_PL -D vscode -D VCD_OUT=\"$ProgFolder"PipeLine_WaveForm.vcd"\" -D MEMORY_SIZE=4096 -D MEMORY_BITS=12 -D MAX_CLOCKS=1000000 $BASE_PATH"PipeLine_sim.v"
    vvp $VERILOG_PL > $VERILOG_PL_OUT

    sed -i '1d' "$VERILOG_SC_OUT"
    sed -i '$d' "$VERILOG_SC_OUT"
    sed -i '1d' "$VERILOG_PL_OUT"
    sed -i '$d' "$VERILOG_PL_OUT"


    STATS=$ProgFolder"stats.txt"
    printf "\n\nHardWare Stats: \n" >> $STATS

    printf "\tSingleCycle: \n" >> $STATS
    printf "\t\t" >> $STATS
    tail -n 1 "$VERILOG_SC_OUT" >> $STATS

    printf "\tPipLined: \n" >> $STATS
    tail -n 8  "$VERILOG_PL_OUT" >> $STATS

    sed -i '$d' "$VERILOG_SC_OUT"
    head -n -8 "$VERILOG_PL_OUT" > "./temp" && mv "./temp" "$VERILOG_PL_OUT"

    printf "[INFO $INDEX/$TOTAL ]: Comparing HardWare Outputs\n"

    comapre_two_files "$VERILOG_SC_OUT" "$VERILOG_PL_OUT"

    HWFILE="$VERILOG_SC_OUT"
}

Run_BenchMark()
{
    Run_BenchMark_SW $1
    RunBenchMark_HW $1
    printf "[INFO $INDEX/$TOTAL ]: comparing Software output with hardware output\n"
    comapre_two_files $SWFILE $HWFILE
    INDEX=$(($INDEX + 1))
    echo ""
}

Run_All()
{
    Run_BenchMark "JR_Dependency(Silicore_BenchMark)"
    Run_BenchMark "InsertionSort(SiliCore_version)"
    Run_BenchMark "BubbleSort(Silicore_BenchMark)"
    Run_BenchMark "Fibonacci(Silicore_BenchMark)"

    Run_BenchMark "Max&MinArray"
    Run_BenchMark "BinarySearch"
    Run_BenchMark "ControlFlowInstructions"
    Run_BenchMark "DataManipulation"
    Run_BenchMark "SumOfNumbers"
    Run_BenchMark "RemoveDuplicates"
    Run_BenchMark "SelectionSort"
    Run_BenchMark "SparseMatrixCount"
    Run_BenchMark "Swapping"
    Run_BenchMark "MultiplicationUsingAddition"
    Run_BenchMark "ScalarMultiplicationUsingAddition"
}


Run_All


read -p "Press any key to exit"
