type: Changed

**papier's folders are the toolkit's standard ones.** On Linux, with `history.persist` off and no session runtime folder (`$XDG_RUNTIME_DIR`), the history now goes in the temporary folder (`$TMPDIR/papier`, else `/tmp/papier`) instead of the data folder, where it outlived the session. The history's folder is readable by you alone. On Windows an entry opened as a file is written to `%TEMP%\papier\open` instead of `%TEMP%\papier-open`.
