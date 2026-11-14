# The clipboard and what a copy becomes

## Data-control, not a focused window

A Wayland client hears of the clipboard only while one of its windows has the focus. A manager uses data-control
instead: `ext-data-control-v1`, or `zwlr-data-control-unstable-v1` where only that one is offered (both have the same
requests).

- `src/wlclip` opens libwayland-client with `dlopen` and builds the protocol's tables by hand, then binds the manager
  and a device on the seat. It reports each new selection with its MIME types.
- It reads a type over a pipe while it keeps serving the connection: a slow source never stops the watcher.
- It can own the selection: it then answers each `send` with the bytes it holds.

## Loops and an empty selection

- A selection that comes from papier's own source is not recorded again.
- When the selection goes empty (its owner quit), the watcher puts the last entry back. On Wayland the bytes of a copy
  live in the program that copied; papier keeps the clipboard alive after that program ends.

## What a copy becomes (src/capture.odin)

`plan_capture` picks the types to read from those offered: one text type (stored as `text/plain;charset=utf-8`), the
HTML, one image type, one file list. A secret or an ignored type stops it: papier never reads the bytes of a password
manager's copy. `classify` makes the entry: its kind (files, then text or rich text, then image), its key (the hash of
its main type) and its preview.

Both procedures are pure and tested without a compositor. The watcher only does the reading and the writing around them.
