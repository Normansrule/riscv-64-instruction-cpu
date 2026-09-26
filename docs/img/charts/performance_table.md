| program | M ops | baseline: cycles | CPI | performance: cycles | CPI | time, baseline 130 nm (7.5 MHz) | time, performance 130 nm (200 MHz) | time, performance 7 nm (1.34 GHz) |
|---|:-:|---:|---:|---:|---:|---:|---:|---:|
| `00_pipeline_fill` |  | 10 | 2.00 | 21 | **4.20** | 1.3 µs | 0.10 µs | 0.02 µs |
| `01_hello` |  | 139 | 1.43 | 147 | **1.52** | 18.5 µs | 0.73 µs | 0.11 µs |
| `02_forwarding` |  | 12 | 1.71 | 23 | **3.29** | 1.6 µs | 0.12 µs | 0.02 µs |
| `03_load_use` |  | 18 | 1.64 | 40 | **3.64** | 2.4 µs | 0.20 µs | 0.03 µs |
| `04_branch_penalty` |  | 50 | 1.52 | 53 | **1.61** | 6.7 µs | 0.27 µs | 0.04 µs |
| `05_fibonacci` |  | 366 | 1.20 | 328 | **1.08** | 48.8 µs | 1.64 µs | 0.25 µs |
| `06_bubble_sort` | yes | 1,124 | 1.56 | 1,003 | **1.39** | 149.9 µs | 5.01 µs | 0.75 µs |
| `07_factorial_recursive` | yes | 327 | 1.39 | 518 | **2.19** | 43.6 µs | 2.59 µs | 0.39 µs |
| `08_gcd_euclid` | yes | 33 | 1.74 | 76 | **4.00** | 4.4 µs | 0.38 µs | 0.06 µs |
| `09_primes_sieve` | yes | 19,773 | 1.33 | 17,044 | **1.15** | 2636.4 µs | 85.22 µs | 12.75 µs |
| `10_print_numbers` | yes | 737 | 1.37 | 1,024 | **1.90** | 98.3 µs | 5.12 µs | 0.77 µs |
| `11_gshare_patterns` |  | 1,519 | 1.38 | 1,139 | **1.03** | 202.5 µs | 5.70 µs | 0.85 µs |
| `12_measure_cpi` | yes | 122 | 1.28 | 151 | **1.59** | 16.3 µs | 0.76 µs | 0.11 µs |
| `13_function_call_cost` | yes | 174 | 1.54 | 277 | **2.45** | 23.2 µs | 1.39 µs | 0.21 µs |
| `14_false_load_stall` |  | 49 | 1.29 | 82 | **2.16** | 6.5 µs | 0.41 µs | 0.06 µs |
| `isa_selfcheck` | yes | 7,420 | 1.16 | 18,088 | **2.82** | 989.3 µs | 90.44 µs | 13.53 µs |

Geometric-mean speed-up of the performance edition over the baseline, both on 130 nm: **19.1x** (clock and cycles together). Cache misses are included: these programs are tiny, so their few cold misses weigh heavily.
