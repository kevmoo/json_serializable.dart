# Benchmark Results

This document contains the summary and raw output of the full benchmark suite (AOT compiled, 5 runs).

## Performance Summary

- Benchmarks are run **5 times**.
- Benchmarks are **AOT compiled** before running.
- The numbers reported in the table are the **fastest** of the 5 runs (to avoid system noise).

| Mode | Size | Format | Old | New | Winner (% faster) |
| :--- | :--- | :--- | ---: | ---: | :--- |
| Write | Large | String | 2031.10 µs | **1806.90 µs** | 🏆 New (12.4% faster) |
| Write | Large | Utf8 | 2167.47 µs | **516.70 µs** | 🏆 New (**4.2x** faster) |
| Write | Large | File | 7012.42 µs | **766.23 µs** | 🏆 New (**9.2x** faster) |
| Write | Small | String | **19.91 µs** | 23.57 µs | 🐢 Old (18.4% faster) |
| Write | Small | Utf8 | 21.99 µs | **8.33 µs** | 🏆 New (**2.6x** faster) |
| Read | Large | String | **966.98 µs** | 996.00 µs | 🐢 Old (3.0% faster) |
| Read | Large | Utf8 | **992.08 µs** | 1192.96 µs | 🐢 Old (20.2% faster) |
| Read | Large | Chunked | **1038.53 µs** | 1466.78 µs | 🐢 Old (41.2% faster) |
| Read | Large | File (ByteJsonReaderConverter) | **160.96 µs** | 439.90 µs | 🐢 Old (**2.7x** faster) |
| Read | Large | File (ChunkedJsonReader) | **160.96 µs** | 1801.91 µs | 🐢 Old (**11.2x** faster) |
| Read | Large | File (JsonReaderConverter) | **160.96 µs** | 202.36 µs | 🐢 Old (25.7% faster) |
| Read | Small | String | 13.44 µs | **12.48 µs** | 🏆 New (7.7% faster) |
| Read | Small | Utf8 | **14.19 µs** | 15.28 µs | 🐢 Old (7.7% faster) |

## Raw Benchmark Dump

### Run at: 2026-04-18 (AOT, Fastest of 5 runs)

```
json_rw | 1831.46 | 1839.70 | 1806.90 |
json_rw_chunked_read | 1484.91 | 1526.79 | 1466.78 |
json_rw_chunked_read_small | 17.89 | 17.84 | 17.53 |
json_rw_file_byte_json_reader_converter | 451.85 | 463.20 | 439.90 |
json_rw_file_chunked_json_reader | 1837.24 | 1899.50 | 1801.91 |
json_rw_file_json_reader_converter | 206.00 | 207.24 | 202.36 |
json_rw_file_write | 774.00 | 781.86 | 766.23 |
json_rw_read | 1009.08 | 1009.23 | 996.00 |
json_rw_read_small | 12.54 | 12.54 | 12.48 |
json_rw_small | 24.33 | 24.55 | 23.57 |
json_rw_utf8 | 527.32 | 528.08 | 516.70 |
json_rw_utf8_read | 1206.15 | 1207.76 | 1192.96 |
json_rw_utf8_read_small | 15.54 | 15.52 | 15.28 |
json_rw_utf8_small | 8.55 | 8.51 | 8.33 |
json_serializable | 2084.76 | 2078.53 | 2031.10 |
json_serializable_chunked_read | 1066.40 | 1063.85 | 1038.53 |
json_serializable_file | 165.38 | 169.02 | 160.96 |
json_serializable_file_write | 7137.37 | 7207.90 | 7012.42 |
json_serializable_read | 990.81 | 991.84 | 966.98 |
json_serializable_read_small | 13.64 | 14.08 | 13.44 |
json_serializable_small | 20.05 | 20.10 | 19.91 |
json_serializable_utf8 | 2199.38 | 2218.46 | 2167.47 |
json_serializable_utf8_read | 1014.66 | 1010.43 | 992.08 |
json_serializable_utf8_read_small | 14.43 | 14.44 | 14.19 |
json_serializable_utf8_small | 22.18 | 22.17 | 21.99 |
```
