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

SimulateSW=1
SimulateHW=0

BENCHMARKS="1HelloWorld"

# BENCHMARKS=\
# 	"1HelloWorld" \
# 	"BinarySearch" \
# 	"BubbleSort" \
# 	"ControlFlowInstructions" \
# 	"DataManipulation" \
# 	"Fibonacci" \
# 	"InsertionSort" \
# 	"JR_Dependency" \
# 	"MaxAndMinArray" \
# 	"MultiplicationUsingAddition" \
# 	"RemoveDuplicates" \
# 	"ScalarMultiplicationUsingAddition" \
# 	"SelectionSort" \
# 	"SparseMatrixCount" \
# 	"SumOfNumbers" \
# 	"Swapping"


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

	@if [ "$(SimulateSW)" = "1" ] && [ "$(SimulateHW)" = "1" ]; then \
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
		-mc $(BENCHMARK_DIR)/$(BENCH)/Generated/MC.txt \
		-dm $(BENCHMARK_DIR)/$(BENCH)/Generated/DM.txt \
		--im-init $(BENCHMARK_DIR)/$(BENCH)/Generated/IM_INIT.INIT \
		--dm-init $(BENCHMARK_DIR)/$(BENCH)/Generated/DM_INIT.INIT \
		--im-mif $(BENCHMARK_DIR)/$(BENCH)/Generated/InstMem_MIF.mif \
		--dm-mif $(BENCHMARK_DIR)/$(BENCH)/Generated/DataMem_MIF.mif; \

	@if [ "$(SimulateSW)" = "1" ]; then \
		if [ "$(PARALLEL)" = "0" ]; then \
			echo "[$(INDEX)/$(TOTAL)]: Simulating $(BENCH) on Single Cycle"; \
		fi; \
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
		if [ "$(PARALLEL)" = "0" ]; then \
			echo "[$(INDEX)/$(TOTAL)]: Simulating $(BENCH) on Single Cycle Hardware"; \
		fi; \
		$(IVERILOG) -I$(BENCHMARK_DIR)/$(BENCH)/Generated -o $(BENCHMARK_DIR)/$(BENCH)/Generated/VERILOG_SC.vvp \
			-D MEMORY_SIZE=$(DM_SIZE) -D MEMORY_BITS=$(DM_BITS) -D vscode -D MAX_CLOCKS=1000000 \
			$(SC_DIR)/SingleCycle_sim.v; \
		$(VVP) $(BENCHMARK_DIR)/$(BENCH)/Generated/VERILOG_SC.vvp 2>&1 | grep -Ev 'VCD info:|\$$finish called' > $(BENCHMARK_DIR)/$(BENCH)/Generated/VERILOG_SC_OUT.txt; \
	else \
		echo "Skipping hardware simulation for $(BENCH)"; \
	fi
	
test: assemble-test run-test

assemble-test:
	@rm -rf $(BENCHMARK_DIR)/test/Generated
	@mkdir -p $(BENCHMARK_DIR)/test/Generated
	@$(ASSEMBLER) \
		$(BENCHMARK_DIR)/test/test.S \
		-mc $(BENCHMARK_DIR)/test/Generated/MC.txt \
		-dm $(BENCHMARK_DIR)/test/Generated/DM.txt \
		--im-init $(BENCHMARK_DIR)/test/Generated/IM_INIT.INIT \
		--dm-init $(BENCHMARK_DIR)/test/Generated/DM_INIT.INIT \
		--im-mif $(BENCHMARK_DIR)/test/Generated/InstMem_MIF.mif \
		-log \
		--dm-mif $(BENCHMARK_DIR)/test/Generated/DataMem_MIF.mif > $(BENCHMARK_DIR)/test/log.txt; \

run-test:
	@$(CAS) singlecycle \
		-mc $(BENCHMARK_DIR)/test/Generated/MC.txt \
		-dm $(BENCHMARK_DIR)/test/Generated/DM.txt \
		-o $(BENCHMARK_DIR)/test/Generated/CAS_SC_OUT.txt \
		--im-size $(IM_SIZE) \
		--dm-size $(DM_SIZE); \
