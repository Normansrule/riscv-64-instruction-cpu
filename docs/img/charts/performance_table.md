| program | M ops | baseline: cycles | CPI | performance: cycles | CPI | time, baseline 130 nm (7.5 MHz) | time, performance 130 nm (265 MHz) | time, performance 7 nm (1.92 GHz) |
|---|:-:|---:|---:|---:|---:|---:|---:|---:|
| `00_pipeline_fill` |  | 10 | 2.00 | 21 | **4.20** | 1.3 µs | 0.08 µs | 0.01 µs |
| `01_hello` |  | 139 | 1.43 | 147 | **1.52** | 18.5 µs | 0.55 µs | 0.08 µs |
| `02_forwarding` |  | 12 | 1.71 | 23 | **3.29** | 1.6 µs | 0.09 µs | 0.01 µs |
| `03_load_use` |  | 18 | 1.64 | 40 | **3.64** | 2.4 µs | 0.15 µs | 0.02 µs |
| `04_branch_penalty` |  | 50 | 1.52 | 53 | **1.61** | 6.7 µs | 0.20 µs | 0.03 µs |
| `05_fibonacci` |  | 366 | 1.20 | 328 | **1.08** | 48.8 µs | 1.24 µs | 0.17 µs |
| `06_bubble_sort` | yes | 1,124 | 1.56 | 1,002 | **1.39** | 149.9 µs | 3.78 µs | 0.52 µs |
| `07_factorial_recursive` | yes | 327 | 1.39 | 482 | **2.04** | 43.6 µs | 1.82 µs | 0.25 µs |
| `08_gcd_euclid` | yes | 33 | 1.74 | 82 | **4.32** | 4.4 µs | 0.31 µs | 0.04 µs |
| `09_primes_sieve` | yes | 19,773 | 1.33 | 16,899 | **1.14** | 2636.4 µs | 63.77 µs | 8.82 µs |
| `10_print_numbers` | yes | 737 | 1.37 | 1,138 | **2.12** | 98.3 µs | 4.29 µs | 0.59 µs |
| `11_gshare_patterns` |  | 1,519 | 1.38 | 1,139 | **1.03** | 202.5 µs | 4.30 µs | 0.59 µs |
| `12_measure_cpi` | yes | 122 | 1.28 | 154 | **1.62** | 16.3 µs | 0.58 µs | 0.08 µs |
| `13_function_call_cost` | yes | 174 | 1.54 | 294 | **2.60** | 23.2 µs | 1.11 µs | 0.15 µs |
| `14_false_load_stall` |  | 49 | 1.29 | 82 | **2.16** | 6.5 µs | 0.31 µs | 0.04 µs |
| `15_system_calls` |  | 89 | 1.68 | 116 | **2.19** | 11.9 µs | 0.44 µs | 0.06 µs |
| `16_cache_conflicts` |  | 208 | 1.22 | 440 | **2.57** | 27.7 µs | 1.66 µs | 0.23 µs |
| `17_predictor_challenge` |  | 7,492 | 1.48 | 6,277 | **1.24** | 998.9 µs | 23.69 µs | 3.27 µs |
| `isa_selfcheck` | yes | 7,526 | 1.16 | 18,661 | **2.88** | 1003.5 µs | 70.42 µs | 9.73 µs |

Geometric-mean speed-up of the performance edition over the baseline, both on 130 nm: **25.2x** (clock and cycles together). Cache misses are included: these programs are tiny, so their few cold misses weigh heavily.
