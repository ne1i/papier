# Architecture

Papier is one program in [Odin](https://odin-lang.org) on [gui_toolkit](https://github.com/sachahjkl/gui_toolkit) (the
`ext/gui_toolkit` submodule, the collection `gt`). This page says how its parts fit. The reasons behind them (the
decisions, the refused alternatives, the subtle points) are in [src/md](../src/md/README.md).

## One process, its threads

```
papier --hidden ─┬─ the window's thread (app.odin, view.odin)
                 │     the window, hidden or shown; the tray icon; the list and the view the reader gave it
                 │
                 ├─ the watcher thread (watcher.odin)
                 │     the clipboard (wlclip), the history it writes (history), the instance socket
                 │
                 ├─ the reader (reader.odin)
                 │     the history as the window reads it, the search, the selected entry's text, the window's files
                 │
                 ├─ the decoder (decoder.odin)
                 │     the picture of the selected image (and the QR code in it), the images' thumbnails
                 │
                 ├─ the slow worker (slow.odin)
                 │     the text of an image (OCR), the system's thumbnails of copied files
                 │
                 └─ the toolkit's threads: the preferences' writer, the log's writer, the chores (the Save dialog)
```

The reader, the decoder and the slow worker are each a `tasks.Job` on a `tasks.Pool` of one thread of its own (gt:tasks):
an ask while a run waits adds nothing, an ask during a run makes one more run, and none of the three waits behind
another.

- **The watcher** sleeps in one `poll` on three descriptors: the Wayland connection of the data-control protocol, the
  instance socket (commands of other processes), an eventfd (commands of the window). It is the only writer of the
  history. Each change is one transaction of the database; then it bumps a version, and the window asks the reader for
  the list again when the version moves.
- **The reader** owns the window's connection to the history. It reads the list again, computes the view of a search
  (the newest query wins), reads the selected entry's text (the newest selection wins), and does the window's jobs in
  order: an entry saved or opened as a file, a program started, a drag's data, the preferences read again, the window's
  state written, what the install is (gt:setup). The preferences are written by gt:config's writer. It puts each answer in a mailbox and wakes the window. A new list comes with its view, in one hold of the
  mailbox: the window never shows the view of one list with another. An entry the user removes leaves the reader's list
  at once, and the view comes again without it.
- **The decoder** decodes pictures, through a connection of its own to the store. It reads the preview's picture for a
  QR code too, and gives its text with the picture.
- **The slow worker** does what takes seconds, so that it never waits behind the decoder or the reader: the text of an
  image (OCR, a second or more; one reading at a time, the newest ask first) and the thumbnails of copied files (a
  system's thumbnailer may run 30 seconds; the rows in view, as the decoder's). At its start it asks whether the system
  can read text (`ocr.available` loads a library), and the window offers the action once it says so.
- **The window** sleeps in the toolkit's wait: its own Wayland connection, its wake, the session bus (the tray). It asks
  the watcher by a queue (copy, pin, delete, clear) and the watcher asks it by another (show, hide, toggle, reload, quit),
  in order: a hide then a show that come between two steps of the loop end shown. It empties the reader's mailbox once
  per step of its loop.

**The rule**: the window's thread (its loop and each build) touches no disk, network, process or blocking system call,
and does no work in proportion to the history in a frame. What reads or writes goes to the reader; what goes over the
list (the search, the count of pinned entries, an entry by its id) is computed by the reader when the list changes, and
kept. A request to the reader never waits: it takes the mailbox's mutex for a copy, never for a search. Two exceptions
remain: the start, which reads the window's state and the preferences before the window exists (they give its size),
and a drag out of the list, a loop of the system that blocks by nature. The Save dialog runs on the toolkit's chores
(`ui.file_dialog`).

At rest every thread sleeps: 0 % CPU, hidden or shown (the caret's blink aside).

## Where each part lives

| Part | Code | Its reasons |
|---|---|---|
| The one process, the instance socket | `src/app.odin`, `src/commands.odin` | [one-process.md](../src/md/infrastructure/one-process.md) |
| The clipboard (Wayland data-control) | `src/wlclip`, `src/watcher.odin` | [clipboard.md](../src/md/features/clipboard.md) |
| What a copy becomes | `src/capture.odin` (pure, tested) | [clipboard.md](../src/md/features/clipboard.md) |
| The history (SQLite, `history.db`) | `src/history`, SQLite in `ext/sqlite` | [history.md](../src/md/data/history.md) |
| The window: list, search, preview, thumbnails | `src/view.odin`, `src/reader.odin`, `src/decoder.odin`, `src/thumbs.odin` | [window.md](../src/md/features/window.md) |

The interface is built again at each frame (immediate mode), and only when something changed. The list is the toolkit's
virtual list: it builds the rows in view, whatever the length of the history.

## Updates (src/updates.odin)

gui_toolkit's `update.Updater` runs on a thread of its own: the installed copy checks the manifest of the latest release
20 seconds after its start and then once a day, downloads the program it names, checks its size and SHA-256 against the
manifest, whose Ed25519 signature it checked first, and puts it in place of the running program. The thread wakes the
loop; the loop reads the state at each turn. Once the new program is in place, papier ends as soon as its window is
hidden, and the new one starts hidden (`--hidden`). Settings > Updates shows the state (`prefs_page`'s update line).

## The settings (src/settings.odin, src/settings_view.odin)

One registry (`gt:config`) holds the toolkit's standard settings (`prefs_page.standard_register`) and papier's own.
`prefs_page.standard_watch` applies each standard one to the toolkit when it changes (the zoom, the scrolling, the
delays, the text's rendering); papier shows the theme itself (`prefs_page.appearance_read`, `ui.theme_show`) and reads
its own settings again after each change. The user's themes file (`prefs_page.Themes_File`, `themes.txt` beside the
preferences) is looked at and read by tasks.

## The licence (src/licence.odin, src/licence)

A licence is a key signed with papier's Ed25519 key (`gt:licence`), checked on the computer with no network. Its store
keeps it in papier's configuration folder; every read and write of it is a task (`ui.task`), and the settings' General
page shows the last status read. `papiertool licence` makes the key pair and issues licences; the toolkit's licence Worker
sells them, and the site's shop pages come from the toolkit's templates at each `papiertool site build`.

## Tests

- Unit tests: `src` (capture, commands, window state, the reader, the decoder), `src/history`, `tools/papiertool` (versions, the changelog).
- `papiertool live`: the real program in a sway with no screen; copies of each kind through wl-clipboard, a secret, a
  copy again, an entry put back byte for byte, the clipboard emptied, the window read, searched, hidden and shown over
  the DevTools protocol.
- gui_toolkit's own desktop tests cover the hide and the show of a window with its renderer, and the loop's rest.
