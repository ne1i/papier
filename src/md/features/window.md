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
- A text, Markdown or code scrolls in a `scroll_y` box. What it holds is sized by its children (`children_sum`): papier's
  base style gives a box a control's height, and content cut to it never overflows the box, which then does not scroll.
- What a text is (plain, code, Markdown, a diff) is `syntax.guess`'s answer, given by the reader with the text. A text
  that is only a table (a header row of `|` cells, then a row of `---` cells, `:` for the alignment) is Markdown: the
  toolkit's guess knows that shape. A text with `|` and no such separator row stays plain: a pipe alone is no table.
- A Markdown doc is read on the reader's thread, once per answer. Each closed ```` ```mermaid ```` block is laid out
  there too (`diagrams_make`), for the light and the dark theme: a layout takes milliseconds, and a theme change then
  lays out nothing. The window only draws the picture of the theme shown. At most 32 diagrams are laid out per entry;
  the blocks after them show as code.
- The diagrams go through `markdown.View_Options.code`, the toolkit's hook for a fenced block: papier draws no Markdown
  of its own. The view finds a block's diagram by its number among the fenced blocks (`markdown.Code.fence`), not by its
  text. A block that is no diagram shows its code, with mermaid's reason above it.
- The keyboard stays in the search, so Page Up / Page Down move in the list and Shift with them scrolls the preview. A
  focusable preview was refused: a click on it would take the keyboard from the search, where typing must go.

## Several entries

The list's selection is the toolkit's `Item_Selection` (gui_toolkit's `src/md/features/selection.md`): clicks with
Ctrl, Shift and Ctrl+Shift, and the keys the search leaves to the list (`move_keys` in `view.odin`). Each key gives the
row it goes to; `item_selection_move` gives its modifiers their meaning.

- **The preview is the cursor's entry**, and so are Edit, Open, Save as, the QR code and the text of an image: they show
  or change one entry. Ctrl and the arrows move the cursor alone, so the preview can show an entry of the selection, or
  one outside it, without changing it.
- **Copy, Pin and Remove act on the selection.** Copy of several joins their texts in the list's order, a line between
  two, as a new entry put on the clipboard (the reader's `Join`). A copy of the first entry alone, or a choice of one,
  was refused: Copy on several selected would then drop what the person chose. Pin pins them all when one is not pinned.
- **Shift+Page Up and Down stay the preview's pages**, so Shift extends with the arrows and with Ctrl+Shift+Home and
  End only (Ctrl+Home is the list's Home: the search keeps Home).
- **Escape takes several entries back to the cursor's**, then clears the search, then hides: the toolkit's rule
  (`item_selection_escape`), read by papier because the search has the keyboard.
- After Copy of several or Remove, the cursor's row is selected alone: the next Enter copies what the cursor shows.

## Thumbnails

At each build the window says which image rows in view still want a thumbnail, in place of what it said before. A row
that scrolled away is no longer asked for. The decoder shrinks each picture to 72 pixels on its shorter side; the window
keeps 300 textures, the least lately shown going first. The system's thumbnails of copied files go to the slow worker,
because a system's thumbnailer can run 30 seconds.

## The text of an image (OCR)

OCR takes a second or more, so it runs on the slow worker: one reading at a time, the newest ask first. At its start the
slow worker asks whether the system can read text (`ocr.available` loads a library); the window offers the action only
once it says so.
