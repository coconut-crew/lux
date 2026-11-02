# Lux

Lux is a work-in-progress runtime agnostic ser/des, networking, and
code generation tool for Luau.

## Features

- Full Type Safety & Validation;

- Easy Table Syntax; `lux.tbl_message({ [u8] = { foo = str, bar = { f64 } } })`

- Peer-to-peer; first-class support for custom peer-to-peer connections

- Stream-based batching; send events to streams like "red team", and
  flush those events to a set of players at the end of the frame.

- Flexible Typing; You can create custom datatypes, choose between
  pre-allocated and dynamically allocated streams, and work directly
  with luau's type system.

- Full Control; You can decide all of the details about batching,
  event dispatch, remote events, and even security. Or you can let lux
  handle those things with the default roblox-based implementation.


## Roadmap

- A Compiler; Everything in lux is built runtime-agnostic by default
  and exports as much information as possible. The vision for Lux, in
  the long term, is to support ease of use and dynamic patterns
  without sacrificing performance or types.

- Documentation; contributions are open, this will come with a full release

- Delta Compression & Streaming Structs

- Type Validation
