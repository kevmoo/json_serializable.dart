# Optimization Log - json_rw

This file catalogs the optimization work done on the `json_rw` package to improve performance, specifically targeting string and UTF-8 reading/writing.

## Baseline Metrics (AOT)

| Mode | Size | Format | `json_serializable` | `json_rw` | Winner (% faster) |
| :--- | :--- | :--- | :--- | :--- | :--- |
| Write | Large | String | 1940.58 µs | 3055.11 µs | `json_serializable` (57.4% faster) |
| Write | Large | UTF-8 | 2282.48 µs | 526.51 µs | `json_rw` (333.5% faster) |
| Read | Large | String | 1109.06 µs | 2028.89 µs | `json_serializable` (82.9% faster) |
| Read | Large | UTF-8 | 949.72 µs | 947.07 µs | `json_rw` (0.3% faster) |
| Write | Small | String | 18.63 µs | 47.90 µs | `json_serializable` (157.1% faster) |
| Write | Small | UTF-8 | 21.47 µs | 7.69 µs | `json_rw` (179.2% faster) |
| Read | Small | String | 13.82 µs | 25.07 µs | `json_serializable` (81.4% faster) |
| Read | Small | UTF-8 | 14.04 µs | 11.94 µs | `json_rw` (17.6% faster) |

## Work Log

### Initial State
- String read and write paths are significantly slower than `json_serializable`.
- UTF-8 write is much faster.
- UTF-8 read is comparable.

### Goal
- Improve String Read and Write performance to be competitive with `json_serializable`.
- Proceed to UTF-8 optimizations if time permits.

## Work Log

### Optimization 1: Use `codeUnitAt` in `StringJsonReader`
- **Date**: 2026-04-17
- **Details**: Replaced all character access using operator `[]` with `codeUnitAt()` in `lib/src/string_json_reader.dart`. This avoids string allocations for single characters and uses fast integer comparisons.
- **Results**:
    - **Read Large String**: Went from 2028.89 µs to **720.88 µs** (~64% reduction!). Now **33.7% faster** than `json_serializable`.
    - **Read Small String**: Went from 25.07 µs to **9.47 µs** (~62% reduction!). Now **36.9% faster** than `json_serializable`.

### Current State
- String **Read** is now winning!
- String **Write** is still slower than `json_serializable` by ~54% for large objects.
- UTF-8 paths are already winning or comparable.

### Next Steps
- Investigate `StringJsonWriter` to see if we can close the gap on string writing.

### Optimization 2: Optimize `escapeString` in `shared.dart`
- **Date**: 2026-04-17
- **Details**: Replaced regex-based `replaceAllMapped` with a manual loop using `codeUnitAt` in `lib/src/shared.dart`. It avoids allocations for clean strings and uses fast switch cases for escapes.
- **Results**:
    - **Write Large String**: Went from 3061.52 µs to **1366.26 µs** (~55% reduction!). Now **41.7% faster** than `json_serializable`.
    - **Write Small String**: Went from 47.38 µs to **17.75 µs** (~62% reduction!). Now **5.4% faster** than `json_serializable`.

### Optimization 3: Optimize `Utf8JsonReader`
- **Date**: 2026-04-17
- **Details**:
    - Replaced `utf8.decode(_source.sublist(...))` with `String.fromCharCodes(_source, start, end)` in `nextNumber` for ASCII numbers, avoiding allocations and full UTF-8 decoding.
    - Used `Uint8List.sublistView` in `_readString` if `_source` is a `Uint8List`, avoiding copies.
- **Results**:
    - **Read Large UTF-8**: Went from 947.07 µs to **849.33 µs** (~10% reduction). Now **12.9% faster** than `json_serializable`.
    - **Read Small UTF-8**: Went from 11.94 µs to **11.80 µs** (minor improvement). Now **19.3% faster** than `json_serializable`.

### Final State
- `json_rw` now wins in **ALL** categories (Read/Write, Small/Large, String/UTF-8)!
- Goal achieved and exceeded!
