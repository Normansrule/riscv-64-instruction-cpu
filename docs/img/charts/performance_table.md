| program | M ops | baseline: cycles | CPI | performance: cycles | CPI | time, baseline 130 nm (7.5 MHz) | time, performance 130 nm (180 MHz) | time, performance 7 nm (1.37 GHz) |
|---|:-:|---:|---:|---:|---:|---:|---:|---:|
| `00_pipeline_fill` |  | 10 | 2.00 | 21 | **4.20** | 1.3 µs | 0.12 µs | 0.02 µs |
| `01_hello` |  | 139 | 1.43 | 147 | **1.52** | 18.5 µs | 0.82 µs | 0.11 µs |
| `02_forwarding` |  | 12 | 1.71 | 23 | **3.29** | 1.6 µs | 0.13 µs | 0.02 µs |
| `03_load_use` |  | 18 | 1.64 | 40 | **3.64** | 2.4 µs | 0.22 µs | 0.03 µs |
| `04_branch_penalty` |  | 50 | 1.52 | 53 | **1.61** | 6.7 µs | 0.29 µs | 0.04 µs |
| `05_fibonacci` |  | 366 | 1.20 | 328 | **1.08** | 48.8 µs | 1.82 µs | 0.24 µs |
| `06_bubble_sort` | yes | 1,124 | 1.56 | 992 | **1.38** | 149.9 µs | 5.51 µs | 0.72 µs |
| `07_factorial_recursive` | yes | 327 | 1.39 | 463 | **1.96** | 43.6 µs | 2.57 µs | 0.34 µs |
| `08_gcd_euclid` | yes | 33 | 1.74 | 76 | **4.00** | 4.4 µs | 0.42 µs | 0.06 µs |
| `09_primes_sieve` | yes | 19,773 | 1.33 | 16,868 | **1.14** | 2636.4 µs | 93.71 µs | 12.29 µs |
| `10_print_numbers` | yes | 737 | 1.37 | 1,024 | **1.90** | 98.3 µs | 5.69 µs | 0.75 µs |
| `11_gshare_patterns` |  | 1,519 | 1.38 | 1,139 | **1.03** | 202.5 µs | 6.33 µs | 0.83 µs |
| `12_measure_cpi` | yes | 122 | 1.28 | 151 | **1.59** | 16.3 µs | 0.84 µs | 0.11 µs |
| `13_function_call_cost` | yes | 174 | 1.54 | 277 | **2.45** | 23.2 µs | 1.54 µs | 0.20 µs |
| `14_false_load_stall` |  | 49 | 1.29 | 82 | **2.16** | 6.5 µs | 0.46 µs | 0.06 µs |
| `15_system_calls` |  | 89 | 1.68 | 116 | **2.19** | 11.9 µs | 0.64 µs | 0.08 µs |
| `16_cache_conflicts` |  | 208 | 1.22 | 440 | **2.57** | 27.7 µs | 2.44 µs | 0.32 µs |
| `17_predictor_challenge` |  | 7,492 | 1.48 | 6,277 | **1.24** | 998.9 µs | 34.87 µs | 4.58 µs |
| `isa_selfcheck` | yes | 7,526 | 1.16 | 18,229 | **2.81** | 1003.5 µs | 101.27 µs | 13.29 µs |

Geometric-mean speed-up of the performance edition over the baseline, both on 130 nm: **17.5x** (clock and cycles together). Cache misses are included: these programs are tiny, so their few cold misses weigh heavily.
