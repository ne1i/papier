# The history

One SQLite database, `history.db`, in WAL mode. SQLite is linked into papier: its amalgamation is in `ext/sqlite`, and
`papiertool build` compiles it with FTS5.

## The model

- **entries**: an entry's id, the time of its last copy, its pin, its kind, its key and its preview.
- **reps**: its types, in order: the MIME type, the hash of the bytes, their size.
- **blobs**: the bytes, by their 64-bit XXH3 hash. The same bytes are stored once, whatever the number of entries and
  types that name them.
- **texts**: the whole text of each entry, in a full-text index (FTS5, trigrams). The search finds a word past the
  preview.

## Decisions

- **One writer.** The watcher is the only writer. The reader and the decoder read through connections of their own; WAL
  lets them read while it writes.
- **One transaction per change.** A copy, an edit, a removal, a trim: each is one transaction, so another connection sees
  the old list or the new one, never half of one. After each, the watcher bumps a version; the window asks the reader
  for the list again when the version moves.
- **Two opens of a new file.** The watcher and the reader open the history together at the start; on a new file both
  make its schema. The switch to WAL fails at once in the second connection (SQLite calls no busy handler there): it is
  tried again for `BUSY_WAIT_MS`. The schema is one `BEGIN IMMEDIATE` transaction, which waits for the write lock;
  statement by statement, each took a read lock then asked to write, an upgrade SQLite refuses at once. Either failure
  ended papier at its first start.
- **Keys.** A copy whose key is already there moves that entry to the top. Copying the same thing twice does not make
  two entries.
- **Limits.** `trim` drops the entries past the count or the age, pinned ones aside. `collect` deletes the bytes that no
  entry names; a blob is shared, so it cannot go with its entry.
- **Import.** At open, the history of papier 0.4 (a text index and a directory of blobs) goes into the database in one
  transaction, then its files are deleted (`src/history/import.odin`).
