| program | M ops | original: cycles | CPI | performance: cycles | CPI | run time, original (7.5 MHz) | run time, performance (207 MHz) | speed-up |
|---|:-:|---:|---:|---:|---:|---:|---:|---:|
| `00_pipeline_fill` |  | 10 | 2.00 | 10 | **2.00** | 1.3 µs | 0.05 µs | 27.6x |
| `01_hello` |  | 139 | 1.43 | 125 | **1.29** | 18.5 µs | 0.60 µs | 30.7x |
| `02_forwarding` |  | 12 | 1.71 | 12 | **1.71** | 1.6 µs | 0.06 µs | 27.6x |
| `03_load_use` |  | 18 | 1.64 | 18 | **1.64** | 2.4 µs | 0.09 µs | 27.6x |
| `04_branch_penalty` |  | 50 | 1.52 | 42 | **1.27** | 6.7 µs | 0.20 µs | 32.9x |
| `05_fibonacci` |  | 366 | 1.20 | 317 | **1.04** | 48.8 µs | 1.53 µs | 31.9x |
| `06_bubble_sort` | yes | 1,124 | 1.56 | 1,022 | **1.42** | 149.9 µs | 4.94 µs | 30.4x |
| `07_factorial_recursive` | yes | 327 | 1.39 | 385 | **1.63** | 43.6 µs | 1.86 µs | 23.4x |
| `08_gcd_euclid` | yes | 33 | 1.74 | 65 | **3.42** | 4.4 µs | 0.31 µs | 14.0x |
| `09_primes_sieve` | yes | 19,773 | 1.33 | 16,800 | **1.13** | 2636.4 µs | 81.16 µs | 32.5x |
| `10_print_numbers` | yes | 737 | 1.37 | 986 | **1.83** | 98.3 µs | 4.76 µs | 20.6x |
| `11_gshare_patterns` |  | 1,519 | 1.38 | 1,121 | **1.02** | 202.5 µs | 5.42 µs | 37.4x |
| `12_measure_cpi` | yes | 122 | 1.28 | 126 | **1.33** | 16.3 µs | 0.61 µs | 26.7x |
| `13_function_call_cost` | yes | 166 | 1.52 | 227 | **2.08** | 22.1 µs | 1.10 µs | 20.2x |
| `14_false_load_stall` |  | 25 | 1.32 | 24 | **1.26** | 3.3 µs | 0.12 µs | 28.8x |
| `isa_selfcheck` | yes | 7,420 | 1.16 | 12,644 | **1.97** | 989.3 µs | 61.08 µs | 16.2x |

Geometric-mean speed-up over all 16 programs: **26.0x** (clock and CPI together).
