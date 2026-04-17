# json_rw

Streaming encode/decode of JSON without intermediate objects.

## Performance Benchmarks

Here are the results comparing `json_rw` with `json_serializable` for a large object (1000 items).

| Operation | `json_serializable` | `json_rw` | Comparison |
| :--- | :--- | :--- | :--- |
| **Write String** | ~2.14 ms | ~3.39 ms | `json_serializable` is ~37% faster |
| **Write UTF-8** | ~2.31 ms | ~3.92 ms | `json_serializable` is ~41% faster |
| **Read String** | ~994 µs | **~754 µs** | **`json_rw` is ~24% faster** |
| **Read UTF-8** | ~1.05 ms | **~1.03 ms** | **`json_rw` is ~2% faster** |

*Note: `json_serializable` leverages the highly optimized native JSON encoder/decoder in the Dart VM, while `json_rw` is pure Dart.*
