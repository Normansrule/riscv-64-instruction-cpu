# =============================================================================
# RV64IM 6-stage pipeline — every command in one place.   `make help`
# =============================================================================
PROG ?= 05_fibonacci
BP   ?= 1
SRC   = $(firstword $(wildcard programs/$(PROG).s tests/$(PROG).s $(PROG)))
RTL   = $(wildcard rtl/*.v)
NAME  = $(basename $(notdir $(SRC)))

.PHONY: help deps test test-model math run pipe bp cycle rtl vsim wave lint docs schematics synth serve clean

help:            ## list targets
	@grep -E '^[a-z-]+:.*##' Makefile | sed 's/:.*##/\t/' | expand -t 14
	@echo "\nvariables: PROG=<name in programs/ or tests/> (default $(PROG))  BP=1|0 (gshare on/off)"

deps:            ## install Ubuntu packages (needs sudo)
	sudo apt-get update
	sudo apt-get install -y nodejs npm iverilog verilator gtkwave yosys graphviz librsvg2-bin make git

test:            ## full regression: model vs expectations vs RTL, cycle-exact, predictor on and off
	node tools/test.mjs

test-model:      ## regression without Verilog (model only)
	node tools/test.mjs --no-rtl

math:            ## verify cycles = N + 5 + L + 3M on every program
	node tools/verify_math.mjs

run:             ## run PROG on the model:        make run PROG=09_primes_sieve BP=0
	node tools/rv.mjs run $(SRC) $(if $(filter 0,$(BP)),--no-bp)

pipe:            ## ASCII pipeline chart of PROG
	node tools/rv.mjs pipe $(SRC) --cycles 48 $(if $(filter 0,$(BP)),--no-bp)

bp:              ## compare no predictor / bimodal / gshare on PROG
	node tools/rv.mjs bp $(SRC)

cycle:           ## explain one cycle:            make cycle PROG=02_forwarding C=6
	node tools/rv.mjs cycle $(SRC) $(C) $(if $(filter 0,$(BP)),--no-bp)

build/sim.vvp: $(RTL) tb/tb_soc.v
	@mkdir -p build
	iverilog -g2012 -Wall -I rtl -o $@ tb/tb_soc.v $(RTL)

rtl: build/sim.vvp  ## run PROG on the Verilog RTL (Icarus), print trace file
	@mkdir -p build
	node tools/rv.mjs asm $(SRC) -o build/$(NAME)
	vvp -n build/sim.vvp +HEX=build/$(NAME).hex +TRACE=build/$(NAME).rtl.trace +BP=$(BP)
	@echo "per-cycle pipeline trace: build/$(NAME).rtl.trace"

build/vsim/vsim: $(RTL) tb/tb_soc.v
	verilator --binary --timing -Wno-fatal -Wno-lint -Wno-style -Irtl tb/tb_soc.v $(RTL) --top-module tb_soc -Mdir build/vsim -o vsim

vsim: build/vsim/vsim  ## run PROG on the Verilator-compiled RTL (much faster)
	node tools/rv.mjs asm $(SRC) -o build/$(NAME)
	./build/vsim/vsim +HEX=build/$(NAME).hex +BP=$(BP)

wave: build/sim.vvp  ## dump waveforms of PROG and open GTKWave with the pipeline view
	node tools/rv.mjs asm $(SRC) -o build/$(NAME)
	vvp -n build/sim.vvp +HEX=build/$(NAME).hex +VCD=build/$(NAME).vcd +BP=$(BP)
	gtkwave build/$(NAME).vcd docs/gtkwave/pipeline.gtkw &

lint:            ## Verilator lint, all warnings on
	verilator --lint-only -Wall -Irtl $(RTL) --top-module soc_top

docs:            ## regenerate binary/, docs/img/, web/programs.js
	node tools/gendocs.mjs

schematics:      ## Yosys gate-level schematics of the small control modules
	@mkdir -p docs/img/schematics
	for m in forward_unit hazard_unit branch_unit imm_gen; do \
	  yosys -q -p "read_verilog -Irtl rtl/$$m.v; hierarchy -top $$m; proc; opt -full; clean; show -format svg -width -stretch -prefix docs/img/schematics/$$m $$m"; \
	done; rm -f docs/img/schematics/*.dot

synth:           ## Yosys synthesis of the core -> docs/synth_stat.txt + area chart (takes minutes)
	@mkdir -p build
	yosys -q -s tools/synth.ys && cp build/synth_stat.txt docs/synth_stat.txt && node tools/areachart.mjs

serve:           ## interactive simulator at http://localhost:8000/web/
	@echo "open http://localhost:8000/web/"
	python3 -m http.server 8000

clean:
	rm -rf build
