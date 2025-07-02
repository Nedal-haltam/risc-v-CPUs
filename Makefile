MAKEFLAGS += --no-print-directory

.PHONY: serial run_all_serial parallel run_all_parallel run_benchmark run_sw run_hw

# Tools
ASSEMBLER=../risc-v-Assembler/bin/Debug/net8.0/risc-v-Assembler.exe
CAS=../risc-v-CAS/bin/Debug/net8.0/CAS.exe
IVERILOG=iverilog
VVP=vvp

# Paths
BENCHMARK_DIR=./BenchMarkFolder
SC_DIR=./singlecycle
PL_DIR=./PipeLine

SimulateSW=0
SimulateHW=0

# BENCHMARKS="1HelloWorld"
BENCHMARKS=\
	"JR_Dependency" \
	"InsertionSort" \
	"BubbleSort" \
	"Fibonacci" \
	"MaxAndMinArray" \
	"BinarySearch" \
	"ControlFlowInstructions" \
	"DataManipulation" \
	"SumOfNumbers" \
	"RemoveDuplicates" \
	"SelectionSort" \
	"SparseMatrixCount" \
	"Swapping" \
	"MultiplicationUsingAddition" \
	"ScalarMultiplicationUsingAddition"

# constants
IM_SIZE=1024
DM_SIZE=1024
DM_BITS=10

PARALLEL=0

all:
	@if [ "$(PARALLEL)" = "1" ]; then \
		$(MAKE) parallel -j; \
	else \
		$(MAKE) serial; \
	fi

serial: run_all_serial

parallel: run_all_parallel

run_all_parallel: $(BENCHMARKS)

$(BENCHMARKS):
	$(MAKE) run_benchmark BENCH=$@

run_all_serial:
	@i=1; total=`echo $(BENCHMARKS) | wc -w`; \
	for bench in $(BENCHMARKS); do \
		echo "[$$i/$$total]: Running benchmark $$bench"; \
		$(MAKE) run_benchmark BENCH=$$bench INDEX=$$i TOTAL=$$total; \
		i=`expr $$i + 1`; \
	done

run_benchmark:
	@rm -rf $(BENCHMARK_DIR)/$(BENCH)/Generated
	@mkdir -p $(BENCHMARK_DIR)/$(BENCH)/Generated
	@rm -rf $(BENCHMARK_DIR)/$(BENCH)/Generated/stats.txt
	@$(MAKE) run_sw BENCH="$(BENCH)" INDEX=$(INDEX) TOTAL=$(TOTAL)
	@$(MAKE) run_hw BENCH="$(BENCH)" INDEX=$(INDEX) TOTAL=$(TOTAL)

	@if [ "$(SimulateSW)" = "1" ] || [ "$(SimulateHW)" = "1" ]; then \
		echo "Comparing Software output with Hardware output" >> $(BENCHMARK_DIR)/$(BENCH)/Generated/stats.txt; \
		diff -a --color=never $(BENCHMARK_DIR)/$(BENCH)/Generated/VERILOG_SC_OUT.txt $(BENCHMARK_DIR)/$(BENCH)/Generated/CAS_SC_OUT.txt >> $(BENCHMARK_DIR)/$(BENCH)/Generated/stats.txt 2>&1 || echo "Difference detected" >> $(BENCHMARK_DIR)/$(BENCH)/Generated/stats.txt; \
		echo "-------------------------------------------------------------------------------------------------------------------------------------" >> $(BENCHMARK_DIR)/$(BENCH)/Generated/stats.txt; \
	else \
		echo "Skipping benchmark $(BENCH)"; \
		exit 0; \
	fi

run_sw:
	@if [ "$(PARALLEL)" = "0" ]; then \
		echo "[$(INDEX)/$(TOTAL)]: Assembling $(BENCH)..."; \
	fi
	@$(ASSEMBLER) \
		$(BENCHMARK_DIR)/$(BENCH)/$(BENCH).S \
		$(BENCHMARK_DIR)/$(BENCH)/Generated/MC.txt \
		$(BENCHMARK_DIR)/$(BENCH)/Generated/DM.txt \
		$(BENCHMARK_DIR)/$(BENCH)/Generated/IM_INIT.INIT \
		$(BENCHMARK_DIR)/$(BENCH)/Generated/DM_INIT.INIT \
		$(BENCHMARK_DIR)/$(BENCH)/Generated/InstMem_MIF.mif \
		$(BENCHMARK_DIR)/$(BENCH)/Generated/DataMem_MIF.mif; \

	@if [ "$(SimulateSW)" = "1" ]; then \
		if [ "$(PARALLEL)" = "0" ]; then \
			echo "[$(INDEX)/$(TOTAL)]: Simulating $(BENCH) on Single Cycle"; \
		fi; \
		$(CAS) sim singlecycle \
			$(BENCHMARK_DIR)/$(BENCH)/Generated/MC.txt \
			$(BENCHMARK_DIR)/$(BENCH)/Generated/DM.txt \
			$(BENCHMARK_DIR)/$(BENCH)/Generated/CAS_SC_OUT.txt \
			$(IM_SIZE) \
			$(DM_SIZE); \
		if [ "$(PARALLEL)" = "0" ]; then \
			echo "[$(INDEX)/$(TOTAL)]: Simulating $(BENCH) on Pipeline"; \
		fi; \
		$(CAS) sim pipeline \
			$(BENCHMARK_DIR)/$(BENCH)/Generated/MC.txt \
			$(BENCHMARK_DIR)/$(BENCH)/Generated/DM.txt \
			$(BENCHMARK_DIR)/$(BENCH)/Generated/CAS_PL_OUT.txt \
			$(IM_SIZE) \
			$(DM_SIZE); \
		diff -a --color=never $(BENCHMARK_DIR)/$(BENCH)/Generated/CAS_SC_OUT.txt $(BENCHMARK_DIR)/$(BENCH)/Generated/CAS_PL_OUT.txt >> $(BENCHMARK_DIR)/$(BENCH)/Generated/stats.txt 2>&1 || \
			echo "Software SC vs PL differs for $(BENCH)" >> $(BENCHMARK_DIR)/$(BENCH)/Generated/stats.txt; \
	else \
		echo "Skipping software simulation for $(BENCH)"; \
	fi

# -D VCD_OUT=\"$(BENCHMARK_DIR)/$(BENCH)/Generated/SingleCycle_WaveForm.vcd\"
# -D VCD_OUT=\"$(BENCHMARK_DIR)/$(BENCH)/Generated/PipeLine_WaveForm.vcd\"
run_hw:
	@if [ "$(SimulateHW)" = "1" ]; then \
		if [ "$(PARALLEL)" = "0" ]; then \
			echo "[$(INDEX)/$(TOTAL)]: Simulating $(BENCH) on Single Cycle Hardware"; \
		fi; \
		$(IVERILOG) -I$(BENCHMARK_DIR)/$(BENCH)/Generated -o $(BENCHMARK_DIR)/$(BENCH)/Generated/VERILOG_SC.vvp \
			-D MEMORY_SIZE=$(DM_SIZE) -D MEMORY_BITS=$(DM_BITS) -D vscode -D MAX_CLOCKS=1000000 \
			$(SC_DIR)/SingleCycle_sim.v; \
		$(VVP) $(BENCHMARK_DIR)/$(BENCH)/Generated/VERILOG_SC.vvp 2>&1 | grep -Ev 'VCD info:|\$$finish called' > $(BENCHMARK_DIR)/$(BENCH)/Generated/VERILOG_SC_OUT.txt; \
		if [ "$(PARALLEL)" = "0" ]; then \
			echo "[$(INDEX)/$(TOTAL)]: Simulating $(BENCH) on Pipeline Hardware"; \
		fi; \
		$(IVERILOG) -I$(BENCHMARK_DIR)/$(BENCH)/Generated -o $(BENCHMARK_DIR)/$(BENCH)/Generated/VERILOG_PL.vvp \
			-D MEMORY_SIZE=$(DM_SIZE) -D MEMORY_BITS=$(DM_BITS) -D vscode -D MAX_CLOCKS=1000000 \
			$(PL_DIR)/PipeLine_sim.v; \
		$(VVP) $(BENCHMARK_DIR)/$(BENCH)/Generated/VERILOG_PL.vvp 2>&1 | grep -Ev 'VCD info:|\$$finish called' > $(BENCHMARK_DIR)/$(BENCH)/Generated/VERILOG_PL_OUT.txt; \
		diff -a --color=never $(BENCHMARK_DIR)/$(BENCH)/Generated/VERILOG_SC_OUT.txt $(BENCHMARK_DIR)/$(BENCH)/Generated/VERILOG_PL_OUT.txt >> $(BENCHMARK_DIR)/$(BENCH)/Generated/stats.txt 2>&1 || \
			echo "Hardware SC vs PL differs for $(BENCH)" >> $(BENCHMARK_DIR)/$(BENCH)/Generated/stats.txt; \
	else \
		echo "Skipping hardware simulation for $(BENCH)"; \
	fi
	