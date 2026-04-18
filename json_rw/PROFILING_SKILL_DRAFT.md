---
name: dart-profiling
description: |-
  Profile Dart applications using the VM Service API to identify performance bottlenecks.
---

## When to use this skill
- When asked to profile a Dart or Flutter application.
- When investigating performance issues, high CPU usage, or slow execution.
- When validating performance improvements after a refactor.

## How to use this skill (The Workflow)
1.  **Enable VM Service**: Ensure the target Dart application is running with the VM Service enabled (e.g., `dart run --enable-vm-service`).
2.  **Connect to VM Service**: Establish a WebSocket or HTTP connection to the VM Service URI.
3.  **Configure Profiler**: Set the `profile_period` flag to a small value (e.g., `1000` microseconds for 1ms resolution) to capture dense samples.
4.  **Identify Target Isolate**: Find the main isolate ID by listing isolates via `getVM`.
5.  **Capture Samples**: Call `getCpuSamples` to retrieve profile samples.
6.  **Process Data**: Parse the call tree and sample counts to identify "hot" methods.

## Common Patterns

### Connecting and Configuring
```dart
// Example of setting the profile period via WebSocket
final response = await sendRpc(
  'setVMFlag',
  {'name': 'profile_period', 'value': '1000'},
);
```

### The "Zero Sample" Pitfall
When calling `getCpuSamples`, providing specific `timeOriginMicros` and `timeExtentMicros` can often result in empty sample lists due to clock skew or missing samples in that specific window.

**Prefer**: Fetching all samples without time filters and processing them manually on the client side.

```dart
// Safer approach: Fetch all samples
final response = await sendRpc(
  'getCpuSamples',
  {'isolateId': mainIsolateId},
);
```

### Avoid `List.sublist` in Tight Loops
When processing chunks of data (e.g., in a lexer), avoid using `List.sublist` to extract parts of the chunk for processing or accumulation. `sublist` allocates a new list every time, which creates significant memory pressure.

**Prefer**: Using `Uint8List.sublistView` to create a zero-copy view of the chunk if it is a `Uint8List`.

```dart
final chunk = _currentChunk;
if (chunk is Uint8List) {
  _bytesBuilder.add(Uint8List.sublistView(chunk, start, _index));
} else {
  _bytesBuilder.add(chunk.sublist(start, _index));
}
```

### Lexer Character Classification (Switch vs Lookup Table)
When building state-machine based lexers, classifying the current character is often the hottest path.

- **Direct `switch`**: Fast and readable. The JIT compiler is very good at optimizing sparse switches on character codes.
- **Lookup Table**: Pre-populating a mapping array (e.g., `Uint8List(128)`) and switching on the action code instead. This performs better in **AOT mode**, as it avoids sparse switch overhead.

**Pattern**:
```dart
// At initialization (or top-level)
final table = Uint8List(128);
table[34] = _actionString;
// ...

// In the hot loop
final action = c < 128 ? _actions[c] : 0;
switch (action) {
  case _actionString:
    // ...
}
```

### Timeline Events
While CPU sampling provides a statistical view of hot spots, `dart:developer`'s `Timeline` allows you to inject explicit, high-fidelity events into the timeline. These are visible in Dart DevTools.

**Prefer**: Using `Timeline.timeSync` for simple block timing, or `startSync`/`finishSync` for manual control.

```dart
import 'dart:developer';

Timeline.timeSync('MyExpensiveOperation', () {
  // Code to profile
});
```

**Pitfall**: Timeline events add overhead. Avoid using them in tight loops that execute thousands of times, as they can distort the profile.

### Case Study: Measuring Allocations
To understand the memory benefits of streaming JSON (avoiding intermediate maps and lists), you can use the allocation profile to count instances created during a benchmark.

**Results for `json_serializable` vs `json_rw` (UTF-8 encoding):**

- **`json_serializable`**: Created ~1000 `_Map` instances, ~7750 `_List` instances (826 KB), and ~1000 `_Closure`/`Context` instances.
- **`json_rw`**: Created zero (or < 1000) `_Map` instances, and only ~4621 `_List` instances (419 KB).

This confirms that the streaming approach successfully avoids intermediate map allocations and significantly reduces list allocations!

## Constraints
- **AOT vs JIT Optimization Differences**: The JIT compiler and AOT compiler can optimize hot paths differently. For example, in character classification loops:
    - The **JIT compiler** favored a sparse `switch` statement directly on character codes over an array lookup.
    - The **AOT compiler** favored an array lookup (`_actions[c]`) followed by a dense `switch` on mapped action codes, yielding a ~6% improvement.
  *Action*: Always benchmark in the target mode (usually AOT for production apps and CLI tools) to make final optimization decisions.
- **Wall Time vs CPU Time**: The VM profiler measures CPU samples, not wall time. Blocking I/O operations might not show up as hot spots in CPU profiles.

## Strategies for Discovery
- Look for shell scripts running `dart` with `--enable-vm-service` or `--profile`.
- Check for `package:vm_service` in `pubspec.yaml`.
- Look for custom benchmarking scripts that orchestrate runs and could benefit from programmatic profiling.
