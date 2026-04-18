# Benchmark Results

This document contains the summary and raw output of the full benchmark suite (AOT compiled, 5 runs).

## Performance Summary

- Benchmarks are run **5 times**.
- Benchmarks are **AOT compiled** before running.
- The numbers reported in the table are the **median** of the 5 runs.

| Mode | Size | Format | Old | New | Winner (% faster) |
| :--- | :--- | :--- | ---: | ---: | :--- |
| Write | Large | String | 2085.41 µs | **1838.44 µs** | 🏆 New (13.4% faster) |
| Write | Large | Utf8 | 2272.15 µs | **501.74 µs** | 🏆 New (**4.5x** faster) |
| Write | Small | String | **20.80 µs** | 24.18 µs | 🐢 Old (16.2% faster) |
| Write | Small | Utf8 | 22.34 µs | **7.89 µs** | 🏆 New (**2.8x** faster) |
| Read | Large | String | **954.03 µs** | 987.53 µs | 🐢 Old (3.5% faster) |
| Read | Large | Utf8 | **997.18 µs** | 1214.06 µs | 🐢 Old (21.7% faster) |
| Read | Large | Chunked | **1050.21 µs** | 1460.33 µs | 🐢 Old (39.1% faster) |
| Read | Large | File (ByteJsonReaderConverter) | **159.90 µs** | 465.62 µs | 🐢 Old (**2.9x** faster) |
| Read | Large | File (ChunkedJsonReader) | **159.90 µs** | 1810.97 µs | 🐢 Old (**11.3x** faster) |
| Read | Large | File (JsonReaderConverter) | **159.90 µs** | 202.52 µs | 🐢 Old (26.7% faster) |
| Read | Small | String | 13.71 µs | **12.70 µs** | 🏆 New (8.0% faster) |
| Read | Small | Utf8 | **14.50 µs** | 15.49 µs | 🐢 Old (6.9% faster) |

## Raw Benchmark Dump

### Run at: 2026-04-18 (AOT, Median of 5 runs)

```
json_rw | 1838.44 | 1851.23 | 1828.78 |
json_rw_chunked_read | 1460.33 | 1468.97 | 1455.25 |
json_rw_chunked_read_small | 17.45 | 17.38 | 17.10 |
json_rw_file_byte_json_reader_converter | 465.62 | 455.57 | 427.23 |
json_rw_file_chunked_json_reader | 1810.97 | 1817.17 | 1795.81 |
json_rw_file_json_reader_converter | 202.52 | 202.41 | 200.40 |
json_rw_read | 987.53 | 993.20 | 978.14 |
json_rw_read_small | 12.70 | 12.78 | 12.32 |
json_rw_small | 24.18 | 24.23 | 23.81 |
json_rw_utf8 | 501.74 | 501.57 | 494.12 |
json_rw_utf8_read | 1214.06 | 1223.07 | 1183.96 |
json_rw_utf8_read_small | 15.49 | 15.41 | 15.19 |
json_rw_utf8_small | 7.89 | 7.91 | 7.81 |
json_serializable | 2085.41 | 2125.82 | 2035.41 |
json_serializable_chunked_read | 1050.21 | 1047.01 | 1027.49 |
json_serializable_file | 159.90 | 160.94 | 159.12 |
json_serializable_read | 954.03 | 964.52 | 943.80 |
json_serializable_read_small | 13.71 | 13.65 | 13.48 |
json_serializable_small | 20.80 | 20.65 | 19.59 |
json_serializable_utf8 | 2272.15 | 2262.34 | 2196.99 |
json_serializable_utf8_read | 997.18 | 1005.47 | 979.40 |
json_serializable_utf8_read_small | 14.50 | 14.55 | 14.39 |
json_serializable_utf8_small | 22.34 | 22.25 | 21.92 |
```
