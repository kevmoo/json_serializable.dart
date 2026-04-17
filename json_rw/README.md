# json_rw

Streaming encode/decode of JSON without intermediate objects.

## Performance Benchmarks

| Mode | Size | Format | `json_serializable` | `json_rw` | Winner (% faster) |
| :--- | :--- | :--- | :--- | :--- | :--- |
| Write | Large | String | 1901.78 µs | 3076.35 µs | `json_serializable` (61.8% faster) |
| Write | Large | UTF-8 | 2118.38 µs | 504.59 µs | `json_rw` (319.8% faster) |
| Read | Large | String | 905.64 µs | 2022.05 µs | `json_serializable` (123.3% faster) |
| Read | Large | UTF-8 | 953.83 µs | 914.51 µs | `json_rw` (4.3% faster) |
| Write | Small | String | 18.55 µs | 47.94 µs | `json_serializable` (158.5% faster) |
| Write | Small | UTF-8 | 21.78 µs | 7.75 µs | `json_rw` (181.1% faster) |
| Read | Small | String | 13.17 µs | 24.66 µs | `json_serializable` (87.2% faster) |
| Read | Small | UTF-8 | 14.05 µs | 11.93 µs | `json_rw` (17.8% faster) |
