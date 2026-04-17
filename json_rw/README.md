# json_rw

Streaming encode/decode of JSON without intermediate objects.

## Performance Benchmarks

Here are the results comparing `json_rw` with `json_serializable` for a large object (1000 items).

| Operation | `json_serializable` (Median) | `json_rw` (Median) | Winner (% faster) |
| :--- | :--- | :--- | :--- |
| **Write String** | **2108.36 µs** | 3283.95 µs | `json_serializable` (~55.8% faster) |
| **Write UTF-8** | 2367.04 µs | **538.90 µs** | `json_rw` (~339.2% faster) |
| **Read String** | **1030.80 µs** | 2188.54 µs | `json_serializable` (~112.3% faster) |
| **Read UTF-8** | 1064.85 µs | **1011.95 µs** | `json_rw` (~5.2% faster) |

*Note: `json_serializable` leverages the highly optimized native JSON encoder/decoder in the Dart VM, while `json_rw` is pure Dart.*
