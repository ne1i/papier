# The window: list, search, preview

The window's thread reads nothing itself. Every read is an ask to a worker, and every answer may come late or out of
date. These rules keep what the window shows consistent.

## The list and its view

- The reader keeps the list and computes from it what goes over the whole history: the search, the count of pinned
  entries, an entry by its id. It computes them when the list changes, not in a frame.
- A new list comes with its view, in one hold of the mailbox: the window never shows the view of one list with another.
- An entry the user removes leaves the reader's list at once, and the view comes again without it. The window does not
  wait for the watcher's transaction to see it go.
- A request to the reader never waits: the window takes the mailbox's mutex for a copy, never for a search.

## The search

- It looks for each word of three letters or more in the whole text (the full-text index, trigrams), and for a shorter
  word in a lower-case copy of the preview. A trigram index cannot find a word of one or two letters.
- Each query has a number. The window applies the view of the newest one only, and keeps a newer list aside until that
  view comes. Without this, a fast typist sees the results of an old query over a new list.

## The selected entry

- Its text, its code's language and its QR text come from the reader; the newest selection wins. The preview says
  "Loading…" until they come.
- An edit asked meanwhile begins when they come: the edit view needs the whole text, not the preview.
- An image is decoded by the decoder; the newest selection wins, and the window makes one texture when the decoder wakes
  it. The decoder reads the picture for a QR code too, and gives its text with the picture.

## Thumbnails

At each build the window says which image rows in view still want a thumbnail, in place of what it said before. A row
that scrolled away is no longer asked for. The decoder shrinks each picture to 72 pixels on its shorter side; the window
keeps 300 textures, the least lately shown going first. The system's thumbnails of copied files go to the slow worker,
because a system's thumbnailer can run 30 seconds.

## The text of an image (OCR)

OCR takes a second or more, so it runs on the slow worker: one reading at a time, the newest ask first. At its start the
slow worker asks whether the system can read text (`ocr.available` loads a library); the window offers the action only
once it says so.
