Streaming encode/decode of JSON without intermediate objects.

## Documentation

All detailed documentation has been moved to the `docs/` directory:

- [Architecture Overview](docs/ARCHITECTURE.md) - Overview of the library's design (Imperative vs Converters).
- [Design Matrix](docs/DESIGN_MATRIX.md) - Matrix of supported operations and streaming models.
- [Profiling Skill Draft](docs/PROFILING_SKILL_DRAFT.md) - Lessons learned and patterns for high-performance Dart profiling.
- [Performance Benchmarks](docs/benchmark_results.md) - Historical performance data.

## Development

To run the benchmarks:

```bash
dart benchmark/serialization_benchmark.dart
```

To run the tests:

```bash
dart test
```
