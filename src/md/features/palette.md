# The command palette

The palette is gui_toolkit's, the same in every program: its sources, its prefixes, its keys and its usage memory are
the toolkit's ([gui_toolkit's palette intent](../../../ext/gui_toolkit/src/md/features/palette.md)). Papier gives it its
data only (`src/actions.odin`).

## What papier fills

- `>` and the plain search: the actions (`ACTIONS`), through `ui.palette_commands`; the views' moves come with them.
- `:` and the plain search: the settings, through `prefs_page.palette_settings_add` on the page's options. A switch
  flips there; another setting opens the settings on it alone. The toolkit runs both: papier only shows the settings
  (`open`).
- No `@`. The table's `@` names clipboard entries, but papier's window is already the search of its history, in its title
  bar, with the preview beside it. A second search of the same entries in the palette was refused: two lists of one
  history, each with its own ranking.

## Decisions

- **What can act is a version, not a table read at each frame.** `action_enabled` reads the selection, the rows shown,
  the cursor's answer and picture, OCR and the history's size. Papier keys `disabled` on their versions and ids
  (`Can_Act_Key`: the selection's `version`, which moves with its active row, and `ids_version`, which papier's own
  moves of the cursor go with). It reads `disabled` again and bumps the commands source's version only when the key
  moved. The toolkit compares the version.
- **The palette's keys are the toolkit's command**, read by `ui.palette_keys` at the top of `window_keys`. Papier's
  table has no line for it, and a test says no action takes Ctrl+K or Ctrl+Shift+P. The sheet of the keys lists the
  command itself.
- **One usage memory**: the toolkit's, in `palette_choices.txt` in the state folder, its keys `<source>:<id>`. Papier
  kept none before: nothing to carry over.
- **The settings source is added once** and asks for the page's options when it reads or acts, so the user's themes
  read again need nothing. A new registry of the preferences (a `papier set`, the file changed) bumps its version: a
  policy can fix other settings in it.
