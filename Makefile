MAKEFLAGS += --no-print-directory
# Tools
ASSEMBLER=../risc-v-Assembler/bin/Debug/net8.0/risc-v-Assembler.exe
CAS=../risc-v-CAS/bin/Debug/net8.0/CAS.exe
IVERILOG=iverilog
VVP=vvp

# Paths
BENCHMARK_DIR=./BenchMarkFolder
SC_DIR=./singlecycle

SimulateSW=1
SimulateHW=0

BENCHMARKS=\
	"BinarySearch" \
	"BubbleSort" \
	"ControlFlowInstructions" \
	"DataManipulation" \
	"Fibonacci" \
	"InsertionSort" \
	"JR_Dependency" \
	"MultiplicationUsingAddition" \
	"RemoveDuplicates" \
	"ScalarMultiplicationUsingAddition" \
	"SelectionSort" \
	"SparseMatrixCount" \
	"SumOfNumbers" \
	"Swapping"

.PHONY: all serial run_benchmark run_sw run_hw test assemble-test run-test

# constants
IM_SIZE=4096
DM_SIZE=8192
DM_BITS=13

all: serial

serial: 
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

	@if [ "$(SimulateSW)" = "1" ] && [ "$(SimulateHW)" = "1" ]; then \
		echo "Comparing Software output with Hardware output" >> $(BENCHMARK_DIR)/$(BENCH)/Generated/stats.txt; \
		diff -a --color=never $(BENCHMARK_DIR)/$(BENCH)/Generated/VERILOG_SC_OUT.txt $(BENCHMARK_DIR)/$(BENCH)/Generated/CAS_SC_OUT.txt >> $(BENCHMARK_DIR)/$(BENCH)/Generated/stats.txt 2>&1 || echo "Difference detected" >> $(BENCHMARK_DIR)/$(BENCH)/Generated/stats.txt; \
		echo "-------------------------------------------------------------------------------------------------------------------------------------" >> $(BENCHMARK_DIR)/$(BENCH)/Generated/stats.txt; \
	else \
		echo "Skipping benchmark $(BENCH)"; \
		exit 0; \
	fi

run_sw:
	@echo "[$(INDEX)/$(TOTAL)]: Assembling $(BENCH)..."; \
	$(ASSEMBLER) \
		$(BENCHMARK_DIR)/$(BENCH)/$(BENCH).S \
		-mc $(BENCHMARK_DIR)/$(BENCH)/Generated/MC.txt \
		-dm $(BENCHMARK_DIR)/$(BENCH)/Generated/DM.txt \
		--im-init $(BENCHMARK_DIR)/$(BENCH)/Generated/IM_INIT.INIT \
		--dm-init $(BENCHMARK_DIR)/$(BENCH)/Generated/DM_INIT.INIT \
		--im-mif $(BENCHMARK_DIR)/$(BENCH)/Generated/InstMem_MIF.mif \
		--dm-mif $(BENCHMARK_DIR)/$(BENCH)/Generated/DataMem_MIF.mif; \

	@if [ "$(SimulateSW)" = "1" ]; then \
		echo "[$(INDEX)/$(TOTAL)]: Simulating $(BENCH) on Single Cycle"; \
		$(CAS) singlecycle \
			-mc $(BENCHMARK_DIR)/$(BENCH)/Generated/MC.txt \
			-dm $(BENCHMARK_DIR)/$(BENCH)/Generated/DM.txt \
			-o $(BENCHMARK_DIR)/$(BENCH)/Generated/CAS_SC_OUT.txt \
			--im-size $(IM_SIZE) \
			--dm-size $(DM_SIZE); \
	else \
		echo "Skipping software simulation for $(BENCH)"; \
	fi

# -D VCD_OUT=\"$(BENCHMARK_DIR)/$(BENCH)/Generated/SingleCycle_WaveForm.vcd\"
run_hw:
	@if [ "$(SimulateHW)" = "1" ]; then \
		echo "[$(INDEX)/$(TOTAL)]: Simulating $(BENCH) on Single Cycle Hardware"; \
		$(IVERILOG) -I$(BENCHMARK_DIR)/$(BENCH)/Generated -o $(BENCHMARK_DIR)/$(BENCH)/Generated/VERILOG_SC.vvp \
			-D MEMORY_SIZE=$(DM_SIZE) -D MEMORY_BITS=$(DM_BITS) -D vscode -D MAX_CLOCKS=1000000 \
			$(SC_DIR)/Sim.v $(SC_DIR)/Design.v; \
		$(VVP) $(BENCHMARK_DIR)/$(BENCH)/Generated/VERILOG_SC.vvp 2>&1 | grep -Ev 'VCD info:|\$$finish called' > $(BENCHMARK_DIR)/$(BENCH)/Generated/VERILOG_SC_OUT.txt; \
	else \
		echo "Skipping hardware simulation for $(BENCH)"; \
	fi
