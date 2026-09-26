| program | M ops | baseline: cycles | CPI | performance: cycles | CPI | time, baseline 130 nm (7.5 MHz) | time, performance 130 nm (182 MHz) | time, performance 7 nm (1.37 GHz) |
|---|:-:|---:|---:|---:|---:|---:|---:|---:|
| `00_pipeline_fill` |  | 10 | 2.00 | 21 | **4.20** | 1.3 µs | 0.12 µs | 0.02 µs |
| `01_hello` |  | 139 | 1.43 | 147 | **1.52** | 18.5 µs | 0.81 µs | 0.11 µs |
| `02_forwarding` |  | 12 | 1.71 | 23 | **3.29** | 1.6 µs | 0.13 µs | 0.02 µs |
| `03_load_use` |  | 18 | 1.64 | 40 | **3.64** | 2.4 µs | 0.22 µs | 0.03 µs |
| `04_branch_penalty` |  | 50 | 1.52 | 53 | **1.61** | 6.7 µs | 0.29 µs | 0.04 µs |
| `05_fibonacci` |  | 366 | 1.20 | 328 | **1.08** | 48.8 µs | 1.80 µs | 0.24 µs |
| `06_bubble_sort` | yes | 1,124 | 1.56 | 1,003 | **1.39** | 149.9 µs | 5.51 µs | 0.73 µs |
| `07_factorial_recursive` | yes | 327 | 1.39 | 518 | **2.19** | 43.6 µs | 2.85 µs | 0.38 µs |
| `08_gcd_euclid` | yes | 33 | 1.74 | 76 | **4.00** | 4.4 µs | 0.42 µs | 0.06 µs |
| `09_primes_sieve` | yes | 19,773 | 1.33 | 17,044 | **1.15** | 2636.4 µs | 93.65 µs | 12.41 µs |
| `10_print_numbers` | yes | 737 | 1.37 | 1,024 | **1.90** | 98.3 µs | 5.63 µs | 0.75 µs |
| `11_gshare_patterns` |  | 1,519 | 1.38 | 1,139 | **1.03** | 202.5 µs | 6.26 µs | 0.83 µs |
| `12_measure_cpi` | yes | 122 | 1.28 | 151 | **1.59** | 16.3 µs | 0.83 µs | 0.11 µs |
| `13_function_call_cost` | yes | 174 | 1.54 | 277 | **2.45** | 23.2 µs | 1.52 µs | 0.20 µs |
| `14_false_load_stall` |  | 49 | 1.29 | 82 | **2.16** | 6.5 µs | 0.45 µs | 0.06 µs |
| `isa_selfcheck` | yes | 7,420 | 1.16 | 18,088 | **2.82** | 989.3 µs | 99.38 µs | 13.17 µs |

Geometric-mean speed-up of the performance edition over the baseline, both on 130 nm: **17.4x** (clock and cycles together). Cache misses are included: these programs are tiny, so their few cold misses weigh heavily.
