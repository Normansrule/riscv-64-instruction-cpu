# References

Numbers in **[brackets]** are used throughout the repo. Every design decision here follows a
published source; this page says which.

## Specification

**[1]** A. Waterman, K. Asanović (eds.), *The RISC-V Instruction Set Manual, Volume I:
Unprivileged Architecture*, RISC-V International. Source and releases:
https://github.com/riscv/riscv-isa-manual (ratified release `20240411`:
https://github.com/riscv/riscv-isa-manual/releases/tag/20240411).
Used for: every encoding in `sim/isa.js` and `binary/`, RV64 "W" semantics, M-extension
division-by-zero and overflow results, the placement of the immediate sign bit.

## Textbooks

**[2]** D. A. Patterson, J. L. Hennessy, *Computer Organization and Design RISC-V Edition:
The Hardware/Software Interface*, 2nd ed., Morgan Kaufmann, 2020. Ch. 1 (performance, the
CPU time equation), ch. 4 (the processor: pipelined datapath, forwarding, load-use stalls,
control hazards, dynamic branch prediction). The 5-stage pipeline this design extends to 6.

**[3]** J. L. Hennessy, D. A. Patterson, *Computer Architecture: A Quantitative Approach*,
6th ed., Morgan Kaufmann, 2017. Ch. 1 (quantitative principles, processor performance
equation), ch. 3 (branch prediction: 2-bit counters, correlating/gshare, tournament predictors,
branch target buffers), Appendix C (pipelining: basic and intermediate concepts).

**[4]** S. L. Harris, D. Harris, *Digital Design and Computer Architecture: RISC-V Edition*,
Morgan Kaufmann, 2021. Ch. 7 (single-cycle, multicycle and pipelined RISC-V microarchitectures
drawn at the Register Transfer Level, with HDL).

## Branch prediction papers

**[5]** J. E. Smith, "A Study of Branch Prediction Strategies," *Proc. 8th International
Symposium on Computer Architecture (ISCA)*, pp. 135-148, 1981. The 2-bit saturating counter.

**[6]** T.-Y. Yeh, Y. N. Patt, "Two-Level Adaptive Training Branch Prediction," *Proc. 24th
International Symposium on Microarchitecture (MICRO-24)*, 1991. Branch history registers indexing
pattern tables: the idea gshare builds on.

**[7]** S. McFarling, "Combining Branch Predictors," Digital Equipment Corporation Western
Research Laboratory, Technical Note TN-36, June 1993.
https://inst.eecs.berkeley.edu/~cs252/sp17/papers/McFarling-WRL-TN-36.pdf
(mirror: https://www.ece.ucdavis.edu/~akella/270W05/mcfarling93combining.pdf).
Introduces **gshare** (global history XOR address) and the combined (tournament) predictor.
This is the predictor in `rtl/branch_predictor.v`.

**[8]** A. Seznec, P. Michaud, "A case for (partially) TAgged GEometric history length branch
prediction," *Journal of Instruction-Level Parallelism*, vol. 8, 2006.
https://www.jilp.org/vol8/v8paper1.pdf. TAGE: the basis of most modern high-end predictors.

**[9]** D. A. Jiménez, C. Lin, "Dynamic Branch Prediction with Perceptrons," *Proc. 7th
International Symposium on High-Performance Computer Architecture (HPCA)*, 2001. A branch
predictor that is a small neural network: one perceptron per branch, trained online.

**[10]** K. Skadron, M. Martonosi, D. W. Clark, "Speculative Updates of Local and Global Branch
History: A Quantitative Analysis," *Journal of Instruction-Level Parallelism*, vol. 2, 2000.
Why real machines update history at prediction time and repair it (see docs/MATH.md §5f).

## Real RISC-V cores and chips to compare with

**[11]** F. Zaruba, L. Benini, "The Cost of Application-Class Processing: Energy and Performance
Analysis of a Linux-Ready 1.7-GHz 64-Bit RISC-V Core in 22-nm FDSOI Technology," *IEEE
Transactions on VLSI Systems*, vol. 27, no. 11, pp. 2629-2640, Nov. 2019,
doi:10.1109/TVLSI.2019.2926114. Preprint with die floorplan: https://arxiv.org/pdf/1904.05442.
Ariane (now CVA6): a **6-stage, single-issue, in-order RV64** core, the closest real relative of
this design, taped out in GlobalFoundries 22FDX on a 3 mm x 3 mm die.

**[12]** OpenHW Group, *CORE-V CVA6*, https://github.com/openhwgroup/cva6. Open-source
SystemVerilog of the core in [11], including its branch history table, branch target buffer and
return-address stack.

**[13]** C. Celio, P.-F. Chiu, K. Asanović, B. Nikolić, D. Patterson, "BROOM: An open-source
Out-of-Order processor with resilient low-voltage operation in 28nm CMOS," Hot Chips 30, 2018.
Slides: https://old.hotchips.org/hc30/1conf/1.03_Berkeley_BROOM_HC30.Berkeley.Celio.v02.pdf.
Journal version: IEEE Xplore document 8634812, https://ieeexplore.ieee.org/document/8634812/.

**[14]** The Berkeley Out-of-Order Machine (BOOM), https://boom-core.org/ and publications at
https://boom-core.org/boom-publications/. What an out-of-order RV64 core adds beyond this design.

**[15]** K. Asanović et al., "The Rocket Chip Generator," Technical Report UCB/EECS-2016-17,
UC Berkeley, 2016. Rocket: the classic 5-stage in-order RV64 core.

## Courses (MIT)

**[16]** C. Terman, *6.004 Computation Structures*, MIT OpenCourseWare, Spring 2017.
https://ocw.mit.edu/courses/6-004-computation-structures-spring-2017/ . Pipelining, hazards,
CPI = CPI_ideal + CPI_stall (lecture 21 and the "Pipelining the Beta" unit). Lecture archive:
https://computation-structures.github.io/course/ .

**[17]** MIT 6.004 (RISC-V version), Fall 2019, full lecture playlist:
https://www.youtube.com/playlist?list=PL0MxyGPHXXYIPmeYPTyPwqNAl6cgkl3d3 (English).

**[18]** Arvind et al., *6.175 Constructive Computer Architecture*, MIT. Builds pipelined RISC-V
processors with branch target buffers and branch history tables step by step:
http://csg.csail.mit.edu/6.175/ .

## Tools

**[19]** Icarus Verilog (https://steveicarus.github.io/iverilog/), Verilator
(https://www.veripool.org/verilator/), GTKWave (https://gtkwave.sourceforge.net/),
Yosys (https://yosyshq.net/yosys/).

**[20]** SkyWater SKY130 open process design kit, https://github.com/google/skywater-pdk ;
OpenLane RTL-to-GDSII flow, https://github.com/The-OpenROAD-Project/OpenLane ; Tiny Tapeout,
https://tinytapeout.com/ . How an RTL design like this one becomes real silicon; see
[SILICON.md](SILICON.md).
