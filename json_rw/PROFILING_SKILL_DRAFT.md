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
- **AOT vs JIT**: Profiling AOT-compiled code yields different results than JIT code. Ensure you profile the mode that matches production if possible.
- **Wall Time vs CPU Time**: The VM profiler measures CPU samples, not wall time. Blocking I/O operations might not show up as hot spots in CPU profiles.

## Strategies for Discovery
- Look for shell scripts running `dart` with `--enable-vm-service` or `--profile`.
- Check for `package:vm_service` in `pubspec.yaml`.
- Look for custom benchmarking scripts that orchestrate runs and could benefit from programmatic profiling.
