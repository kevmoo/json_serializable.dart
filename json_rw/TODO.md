# TODO

- [ ] **Fill the Gaps in the Matrix (Streaming Bytes)**
  - Support `Stream<List<int>>` reading (parsing) without decoding to full string.
  - Support `Stream<List<int>>` writing.
- [ ] **Update the Design Matrix**
  - Reflect that sync `List<int>` support is done (via `Utf8JsonReader` and `BytesJsonWriter`).
- [ ] **Code Generation Integration**
  - Plan how to generate `ResumableBuilder` classes and `.rw.dart` files automatically.
