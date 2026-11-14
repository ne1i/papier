# papier: intent

papier is a clipboard manager: it records each copy in a history and gives it back from a window that a shortcut shows.
This folder follows <https://srcmd.org>. It records why the code has its shape: the purpose, the decisions, the refused
alternatives, the subtle points. The user's documentation is in [docs/](../../docs/); the map of the code (the threads,
the files, the tests) is [docs/architecture.md](../../docs/architecture.md).

## Overview

- One process starts with the session and never closes its window: it hides it. A second `papier` sends its command
  over the instance socket and ends.
- The watcher thread holds the clipboard (`src/wlclip`, Wayland data-control) and is the only writer of the history (one
  SQLite database, `src/history`).
- The window's thread draws the window and the tray. It reads nothing itself: three workers answer it.
  - The reader (`src/reader.odin`) owns the window's connection to the history: the list, the search, the selected
    entry's text, the window's file jobs.
  - The decoder (`src/decoder.odin`) decodes the selected image, its QR code and the thumbnails.
  - The slow worker (`src/slow.odin`) does what takes seconds: OCR, the system's thumbnails of copied files.
- Each worker is a `tasks.Job` on a pool of one thread of its own (gt:tasks): an ask while a run waits adds nothing, an
  ask during a run makes one more run.

## State machines

- The window: hidden or shown, driven by an ordered queue of commands (show, hide, toggle, reload, quit).
- The history's version: the watcher bumps it after each transaction; the window asks for the list when it moves.
- A search: each query has a number; only the newest query's view is applied.
- The selected entry: loading, then loaded; an edit asked while loading starts when the text comes.
- The update: gt:update's `Updater`; once a new program is in place, papier ends at the next hide.

## Subtleties

- The window's thread touches no disk, network, process or blocking call, and does no work in proportion to the
  history in a frame. Two exceptions: the start reads the window's state and the preferences before the window exists
  (they give its size), and a drag out of the list runs the system's loop, which blocks by nature.
- The three workers are separate so that none waits behind another: an OCR of seconds never delays a preview.
- A new list and its view come together in one hold of the mailbox: the window never shows one list with the view of
  another.
- A copy from papier's own source is not recorded again; an empty selection gets the last entry back.
- At rest every thread sleeps: 0 % CPU, hidden or shown (the caret's blink aside).

## File Index

- [infrastructure/one-process.md](infrastructure/one-process.md): why one resident process that hides its window, the
  second start, the order of show and hide, the switch to an update
- [features/clipboard.md](features/clipboard.md): data-control instead of a focused window, papier's own copies, an
  empty selection, what a copy becomes (`plan_capture`, `classify`)
- [data/history.md](data/history.md): the SQLite model (entries, reps, blobs by hash, full-text texts), one writer, one
  transaction per change, keys, limits, the import of 0.4
- [features/window.md](features/window.md): how the window stays consistent with late answers: the list and its view,
  the numbered search, the selected entry, thumbnails, OCR
