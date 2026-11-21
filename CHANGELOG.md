# Changelog

All notable changes to papier are listed here. The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and the versions follow [semantic versioning](https://semver.org/).

## [0.42.0] - 2026-11-21 10:01

### Added
- **How much of an update is downloaded**: the Updates settings page says the size received and the whole, with a bar.
- **The update button becomes its download bar**: after Install, the button turns into a bar that fills as the update downloads, then into Restart, in one smooth change.

## [0.41.0] - 2026-11-20 11:58

### Added
- **Lower latency on Linux**: during an animation or a drag, each frame starts as late as it can and still reaches the next refresh, so it shows the newest input.
- **A file's menu in the file dialogs**: copy its path or name, open it with its program, show it in its folder, rename it in place, or move it to the trash with an undo.

### Changed
- **Every menu filters what is typed**: a field at the top of a menu keeps the items that match, in every menu.

### Fixed
- **`nix run github:sachahjkl/papier` works.** A flake fetched from GitHub is a tarball without the gui_toolkit submodule, and the build stopped at once; the package now takes the toolkit from an input pinned to the submodule's commit.

## [0.40.2] - 2026-11-20 06:52

### Fixed
- **The full frame rate on a second screen**: on Wayland a window on a 144 Hz screen beside a 60 Hz one moves at 144 frames a second, not 60.

## [0.40.1] - 2026-11-19 22:11

### Fixed
- **Smooth animations on Wayland**: a menu, a dialog or a switch moves at each refresh of the screen, with no need to move the pointer.

## [0.40.0] - 2026-11-19 16:55

### Added
- **Several views in the file dialogs**: details, names, columns or cards with the pictures' thumbnails, from the view button or Ctrl+wheel; each dialog keeps its view.

## [0.39.0] - 2026-11-18 21:08

### Changed
- **Old Head theme**: sliders have a raised rectangular knob on a sunken track, and switches are drawn as check boxes.

### Fixed
- **No crash when a window closes while a font loads**: closing waits for the font family being read.

## [0.38.0] - 2026-11-18 16:01

### Changed
- **Old Head theme**: its title bar is a navy band with square bevelled buttons, and its scroll bars have bevelled arrows and thumb.

## [0.37.1] - 2026-11-18 14:01

### Fixed
- **Packages of 0.37.0**: its release stopped before its packages were built; this version publishes them, with the Old Head theme.

## [0.37.0] - 2026-11-18 13:34

### Added
- **Old Head theme**: square corners, two-tone bevels, a dotted focus and white on navy selections, in the theme list.

### Changed
- **The list folds to a rail in a narrow window**: when the window leaves the entry too little room, the list becomes a column of the entries' icons (the selected one lit, a pinned one in the accent colour, each with its first line as a tooltip); Up and Down still move in it, and a click, a double click and the menu act as in the list. It opens again when the window is wide enough. The panel button after papier's icon folds or opens the list, and a pull of the rail's edge opens it; that choice holds until the window next crosses that width. Papier remembers the fold with the list's width.

## [0.36.1] - 2026-11-18 08:31

### Fixed
- **Settings saved on Windows while another program reads them**: an antivirus or the indexer holding the settings file no longer makes a change get lost.

## [0.36.0] - 2026-11-18 00:14

### Added
- **The application menu and the start with the session in Settings > General**: the installed copy shows "In the
application menu" and "Start with the session", and each change adds or removes its launcher or its start with the
session at once. The install's dialog no longer has its own "Start with the session" box: the setting says it, on by
default.

## [0.35.0] - 2026-11-17 20:49

### Changed
- **The engraving on the back of the licence card blends into the foil**: it is struck in the card's own silver now, and still waits for the right angle.

## [0.34.0] - 2026-11-17 18:08

### Added
- **Something engraved on the back of the licence card**: turn the card over and look at it from the right angle.

## [0.33.0] - 2026-11-17 11:26

### Changed
- **Dialogs and menus of the new toolkit**: dialogs opened by a key appear at once, drop-down lists follow the rounding of the settings, and on Windows the window no longer freezes after it has loaded its fonts many times.

## [0.32.1] - 2026-11-16 22:08

### Fixed
- **The command palette appears at once, with its rows.** Ctrl+K showed it after a few empty frames, faded it in before its rows came, and jumped when a frame was late; now it comes in the frame its rows are ready, and fades in over 70 ms.

## [0.32.0] - 2026-11-16 17:51

### Added
- **Your licence as a card.** The Licence page of the settings shows a registered licence as a card: an engraved iridescent foil, your name raised in silver, a seal in relief; it tilts towards the pointer and turns over to show its back.

### Changed
- **Shift+Enter in the palette goes to an action's button**: on an action that has a button in the window (Settings, Hide, the filters, the preview's Copy, Edit, QR code, Pin, Remove and the image's text), Shift+Enter shows that button, focuses it and lights it once. An action chosen in the palette now shows its effect in the same frame.

## [0.31.0] - 2026-11-16 13:54

### Changed
- **Pictures of today.** The README and the site show papier as it is now, not as it was in version 0.15.
- **Even spacing.** The gaps of papier's windows follow the toolkit's one scale, so neighbouring parts line up.

## [0.30.0] - 2026-11-16 12:10

### Fixed
- **Closing your session no longer reads as a crash.** The next start no longer shows a crash report after a logout or a shutdown. Also from the toolkit: a setting found in the palette is changed right there (Shift+Enter opens its page), and the pricing page keeps the site's bar as it is.

## [0.29.0] - 2026-11-15 21:01

### Added
- **By Froment Software in the setup**: the install's dialog and the settings' Installation page say who makes Papier, with its mark; the name opens froment.software.
- **Your own keys and aliases for any command**: in the command palette (Ctrl+K), Ctrl+Enter on a command records a key for it, one key or two in a row (Ctrl+M, then T). Alt+Enter makes the letters typed an alias of the command: typed whole, the alias puts the command first. The menus, the tooltips and the sheet of the keys (F1) show your keys. Settings > Keys holds them, where a reset removes them.

### Changed
- **Papier's name capitalised, and its files in the vendor's folder**: the window, the tray, the menus and the settings say "Papier". The settings, the history, the logs and the licence are now in `FromentSoftware/Papier` (`~/.config/FromentSoftware/Papier`, `~/.local/share/FromentSoftware/Papier`...): the first start moves the old `papier` folders there once. The palette forgets once which commands you chose most often.

## [0.28.0] - 2026-11-15 17:35

### Added
- **papier --quit.** An installer (atelier, a script) asks the running papier to end before it replaces it: `papier --quit` closes it as its Quit does and waits for it; `papier --status` says `quit: yes`.

## [0.27.0] - 2026-11-15 16:47

### Added
- **A license to buy.** The pricing page sells a license of papier: a payment once through Paddle, the license by mail and on the thank-you page at once, its key or its file to give the program.

## [0.26.0] - 2026-11-15 14:18

### Added
- **What's new in the settings.** The settings have a What's new page: each version on a timeline with its day and time, its changes under pills of their kind. After an update, papier says what changed and opens it on request.

## [0.25.0] - 2026-11-15 12:52

### Added
- **Frame rate in Settings.** Settings › Rendering › Frame rate caps how many pictures a second papier draws when something moves: the screen's rate, 30 to 240, or no limit.
- **WebP on Windows.** The Windows version ships its own libwebp beside the program, so WebP pictures show there; the setup installs it with papier.

## [0.24.0] - 2026-11-15 08:32

### Changed
- **The window comes back maximized, and in its place on Windows.** papier remembers its window with the toolkit's placement: its size, its place where the system lets a program set it, and whether it was maximized. The size and place from an older papier are not read again: the window opens once at the default size.
- **papier's folders are the toolkit's standard ones.** On Linux, with `history.persist` off and no session runtime folder (`$XDG_RUNTIME_DIR`), the history now goes in the temporary folder (`$TMPDIR/papier`, else `/tmp/papier`) instead of the data folder, where it outlived the session. The history's folder is readable by you alone. On Windows an entry opened as a file is written to `%TEMP%\papier\open` instead of `%TEMP%\papier-open`.

## [0.23.2] - 2026-11-15 07:01

### Fixed
- **The palette puts the whole word first**: a search for a name ranks the item whose word ends there above a longer one that only starts with it.

## [0.23.1] - 2026-11-15 01:05

### Fixed
- **Two copies open at once no longer hide each other's crash**: when two copies of Papier ran at the same time, a crash or a forced end of one could go unreported, and its report could be hidden by the clean end of the other. Each copy now keeps its own trace, and the next start shows what it did not see.

## [0.23.0] - 2026-11-14 23:43

### Changed
- **The command palette is gui_toolkit's, the same as in the other programs.** `>` searches the actions, `:` the settings (a switch flips and the palette stays open), what you choose often comes first, and an action that cannot act is listed last.

## [0.22.0] - 2026-11-14 19:18

### Added
- **Select several items with Ctrl and Shift, from the keyboard too**: Shift+Up and Shift+Down select a range from the entry chosen last, Ctrl+Shift+Home and Ctrl+Shift+End to the first or the last, Ctrl+Shift with the arrows adds a range to what is selected; Ctrl+Up and Ctrl+Down move the cursor alone and Ctrl+Space adds or takes out its entry. A second Shift+click nearer the first entry makes the range smaller, and Ctrl+Shift+click adds a range. Copy, Pin and Remove act on every entry selected (Copy joins their texts as one, in the list's order); the preview, Edit, Open, Save as and the QR code follow the cursor. Escape on several entries keeps the cursor's alone, then clears the search, then hides.
- **Every dialog can be put elsewhere**: the sheet of the keys, a QR code and the setup can float inside the window (the icon beside the close cross, or a drag of the header), open in a window of the system of their own, or dock to the left, the right or the bottom of the window (a right click on the header). The command palette lists these moves for each dialog that is open. Papier remembers where each dialog was and its size, and opens it there next time.

### Fixed
- **Every text the preview shows can be selected and copied.** A drag selects across lines in a text, code, Markdown or diff entry, Ctrl+C copies it, and a drag near the edge scrolls. The entry's details (its kind, size, types and age), the editor's counts, the status line, the QR code's words and why a diagram could not be drawn select the same way.
- **The palette, the keys, quit and Ctrl+, work in every page.** In the settings and in the edit view, Ctrl+K, Ctrl+Shift+P, F1 and Ctrl+Q did nothing, and over the QR code or the sheet of the keys none of papier's keys worked. They now work there too, while a field has the keyboard as well. The shortcut recorder of the settings still records any combination.
- **On Windows, an entry opened as a file has a path with backslashes only**: the program that opened it received `C:\Users\you\AppData\Local\Temp/papier-open/…`; it now receives `C:\Users\you\AppData\Local\Temp\papier-open\…`.
- **A long entry scrolls in the preview.** The text of a long entry, rendered Markdown, plain text or code, was cut at the bottom of the pane: the wheel and the scroll bar did nothing. They scroll it now, and Shift+Page Up and Shift+Page Down move it by a page.
- **The shortcut brings back a window left behind another.** When papier was shown and the person clicked another window, the next press of the shortcut hid papier. It now comes to the front with the keyboard; the shortcut hides it only when it is the window in use. A click on the tray icon still shows or hides it.
- **`papier set` no longer stops papier.** Changing a setting from the command line while papier ran made it stop at the next frame: the settings read again from the file lacked the install's answer.
- **The update is shown once**: the status bar's button alone says that a new version is downloading or is ready to restart; the status line no longer repeats it beside the button, and its own text is no longer cut. A failed update is said there.
- **The font settings apply at once.** The interface, monospace and reading fonts took effect only at the next start; a family chosen in the settings now shows at once, in every window, and Default brings papier's own back. The reading font is now the text of a Markdown entry.

## [0.21.2] - 2026-11-14 01:53

### Fixed
- **papier starts on Windows**: 0.21.0 and 0.21.1 had no Windows download, because Windows refused to start the program (its manifest was broken). This version has it, and it starts.

## [0.21.1] - 2026-11-14 00:49

### Fixed
- **papier starts on Windows again**: 0.21.0 had no Windows download, because Windows refused to start it. Dialogs also open at their final size, without a jump.

## [0.21.0] - 2026-11-13 23:48

### Added
- **A Diagnostics page in the settings, with a Copy button.** It shows the versions, the system, the graphics adapter (and whether a software rasterizer draws), the window's size and scale, the last frames' times and how much partial redraw drew. If papier is slow, copy it and send it.

### Changed
- **Windows: papier works from a terminal without an install.** The archive has `papier.com` beside `papier.exe`: `papier list` in cmd or PowerShell prints its output and gives its exit code. papier's windows group under its shortcut in the taskbar. Paths longer than 260 characters and UTF-8 text work.
- **The licence has its own page in the settings, worded as in the other programs.** It says whether papier is registered. It offers Buy a licence, a field to paste a key, Choose a licence file… and Remove the licence.
- **A crash of the last session shows in a bar at the top of the window**, in place of a message with the report's path. The bar says what happened and offers Open the report, Copy and Report on GitHub (a new issue with the report in it). Its cross dismisses it.
- **The install is in the settings: an Installation page.** It says where the installed copy is, its version, and whether this copy is the installed one. It shows the menu entry, Settings > Apps, the start with the session and the PATH, with Install, Repair, Upgrade and Uninstall. The palette finds the page ("install").
The command line is `--install`, `--uninstall`, `--status` and `--setup`, as in the other programs. `--status` says what is installed and whether papier runs. `--install` installs the copy in its own folder. `papier install`, `uninstall`, `status` and the Setup… command are gone.
- **A change of language shows at once**: the window, the settings and the tray menu take the new language without a restart.
- **papier has the same settings as the other programs of Froment Software.** Only its theme, Papier, is its own. Its defaults stay the same: light or dark as the system is, the machined finish and 14 px text. The settings' reset button has the same arrow as in the other programs.

### Fixed
- **The filter and the status bar never cut their text.** The filter in the title bar is as wide as its longest word in every language. In a narrow window, the filter moves to its own row under the search, and the status bar drops its last hints.
- **French done right.** Keys have the names that a French keyboard prints ("Entrée", "Échap", "Ctrl+Maj+V") in the status bar, the tooltips and the message about a shortcut that cannot be used. Numbers and percents use the French decimal mark and spacing. Some texts are clearer ("Coller l'élément choisi", "1 format"), and the program writes its name "papier" everywhere.

## [0.20.2] - 2026-11-13 18:53

### Changed
- **One licence at one price, and a new pricing page**: the papier licence is now one edition at 15 €, paid once, taxes included; the Patron edition is gone. The pricing page shows papier's icon and name, one card with the price, what the licence gives as a list, one button, then "Before you buy". The licence is named "papier licence" on the site, at checkout and in the licence file.

## [0.20.1] - 2026-11-13 18:02

### Fixed
- **The Windows download is there again**: 0.20.0 had no Windows archive (its build stopped on a check that read the files with Windows line endings). This version has it.

## [0.20.0] - 2026-11-13 17:00

### Added
- **A menu in the edit view**: a right click in the text offers Undo, Redo, Cut, Copy, Paste, Delete and Select all, with their keys. Each menu is now as wide as its longest line.
- **A log and crash reports**: papier writes its errors to `papier.log` in the `logs` folder of its state folder (`~/.local/state/papier`, `%LOCALAPPDATA%\papier\state`). A crash writes a report in its `crashes` folder. At the next start, papier says that it stopped and where the report is. Nothing is sent anywhere.
- **Messages in the system's notifications**: what papier did (copied, saved, removed) is said by a notification of the system, or in the window where the system shows none. Settings > General > Messages chooses the system, the window, or nowhere. A failure is always said.
- **Diagrams and tables in Markdown entries**: the preview draws a ```mermaid block of a Markdown entry as its diagram, in the theme's colours. A block that is not a valid diagram shows its text, with the reason. A text that is only a table (a header row with its `|---|---|` separator under it) is shown as a table, not as raw text.
- **A licence to support papier**: Settings > General > Licence registers a licence key, pasted or read from its file, and says whom it is registered to. The key is checked on your computer, with no network. Papier stays free and does the same without a licence.
- **Export and import of the settings**: the settings' sidebar exports them to JSON, TOML, INI or papier's own format, and imports papier's own format back, to carry them to another computer.
- **Themes of your own**: Settings > Appearance links to a themes file. The first click makes it with a commented guide and opens it in your editor. Each theme that you write there shows with the others as soon as the file is saved.
- **Papier in French**: the window, the menus, the command palette, the messages, the settings, the setup dialog and the dates speak French. Settings > General > Language chooses System, English or Français; System follows the language of the system. The choice takes effect at the next start.

### Changed
- **Windows: the window's size is kept in the state folder** (`%LOCALAPPDATA%\papier\state\window`), beside the log, and no longer beside the preferences. Papier forgets the size of its window once.
- **The QR code dialog in the middle of the window**: Show as a QR code (Ctrl+Shift+Q) opens its dialog in the middle of the window, not near its top.
- **A faster command palette and keyboard shortcuts sheet**: the palette (Ctrl+K) sorts its actions and settings again only when you type or a setting changes, and the sheet of the keys (F1) builds only the lines in view.
- **Ages in one short unit**: the list, the preview and `papier list` say "now", "4m", "2h", "5d" or "1w".
- **A new settings page**: more settings, each on its page: zoom, density, rounding, animations, fonts and text rendering, scrolling, key and button repeats, tooltip and menu delays, rendering, where messages show, a place in the application menu and a start with the session. The technical ones are under a folded Advanced part of their page. The sidebar is resized with the mouse, and its foot opens the settings file. The settings have new names: the look is `appearance.theme`, `appearance.mode`, `appearance.finish`, `appearance.glow` (a level from 0 to 1) and `appearance.font_size`; the window's are `window.system_title`, `window.close_on_copy`, `window.width`, `window.height`, `window.shortcut` and `window.follow`. The `picker.*` names are gone: set again what you had changed.

### Fixed
- **Save as no longer freezes the window**: the system's file dialog no longer blocks the window. Papier saves the entry once you choose a name.

## [0.19.2] - 2026-11-13 00:55

### Fixed
- **Choosing an entry pastes it again** (Linux): papier pressed the paste keys as its window went, before the compositor gave the focus back to the other program (ShojiWM), so nothing was pasted. It now waits until another window has the focus, half a second at most. Also: the text read in an image and a QR code's content go on the clipboard with the window staying open (they were pasted, and the window closed); the preview says "Reading the text of the image…" with a moving bar while it reads; a right click on an image in the preview opens the entry's menu, the same as on its row, with "Copy the text of the image".

## [0.19.1] - 2026-11-12 19:44

### Changed
- **The machined finish in the light version too**: bevelled buttons, sunken fields and carved lines are drawn on the light themes as well, with light shadows and strong highlights, where they were drawn flat (gui_toolkit 0.229.0).

### Fixed
- **The settings say where the preferences file really is**: their foot showed `~/.config/papier/prefs` on Windows too, where the file is in `%APPDATA%\papier\prefs`.

## [0.19.0] - 2026-11-12 18:27

### Added
- **The preview shows what a text is**: Markdown is shown rendered (headings, lists, tables, code, links), with Ctrl+Shift+M or a button for its source; a diff shows its lines numbered and coloured; code is coloured in more languages (Java, C#, Kotlin, Swift, PHP, Ruby, Lua, Zig, Nix, YAML, TOML, HTML, XML, CSS and more), in the edit view too. The text is drawn in the system's monospace font (Cascadia Mono or Consolas on Windows), which reads better than the one papier carried, at 125 % above all.

## [0.18.1] - 2026-11-12 17:41

### Fixed
- **The window no longer freezes after a copy** (Linux, Wayland): with NVIDIA's driver, a compositor that held back its word that it showed the window's picture (ShojiWM, counting the window on the wrong screen) left the window without a new picture for good. Papier now presents in a way that never waits, waits for that word a quarter of a second at most, and draws at once after a key or a click (gui_toolkit 0.221.1).

## [0.18.0] - 2026-11-12 16:56

### Added
- **The text of a copied image, a QR code's content, and the thumbnails of copied files**: Ctrl+Shift+T (or the entry's menu, or the palette) copies the text read in an image, with the system's text recognition (on Linux, Tesseract). When a copied image holds a QR code, one click copies what it says. A copied file's row shows the system's thumbnail of it: a PDF's first page, a video's frame.

### Changed
- **The window never waits for the disk**: the search, the preview of the selected entry, saving or opening an entry, a drag and the settings are read and written on a thread of their own. Typing a search or moving through a long history stays smooth while the disk is slow or busy.

### Fixed
- **A dialog's Enter no longer opens the entry behind it**, and a paste into the search no longer waits for a slow program's clipboard. Also: each page of the settings restores its defaults with one button, and the command palette's last line is never cut in half (gui_toolkit 0.207.0).

## [0.17.7] - 2026-11-12 01:54

### Fixed
- **The window at rest uses no processor again** (Wayland): since 0.17.6 an open window drew a new picture at every refresh, and kept a core busy. Also: the scroll bars look like a thing to take, the dialogs' rounded corners are clean, and a menu's search edits as a field does (gui_toolkit 0.199.0).

## [0.17.6] - 2026-11-12 00:15

### Changed
- **Images are faster, and the palette's field follows its corners**: copied images and their thumbnails are read and written in half the time or less, and the command palette's darker field no longer shows a second, rounder corner inside the dialog's (gui_toolkit 0.196.2).

## [0.17.5] - 2026-11-11 22:55

### Changed
- **A clearer command palette**: a magnifier before the search and the number of results at the end of its line, a line under it, the selected command in a dark well with a bar of the accent, and what the search found readable, in the palette and in the list.

## [0.17.4] - 2026-11-11 22:05

### Changed
- **Square rows**: a selected row of a list, a table or a menu fills its whole width with square corners, and a table's tinted cell is square too. The Console theme is named Kernel (gui_toolkit 0.191.1).
- **The command palette's field stands out**: it keeps its place from edge to edge, on a darker background, so the place to type is clear.

## [0.17.3] - 2026-11-11 17:20

### Fixed
- **Escape closes the dialog, not the window**: with the Setup, the palette, the QR code or the sheet of the keys open,
  the keys are the dialog's (gui_toolkit: an open dialog holds the keys).

## [0.17.2] - 2026-11-11 16:30

### Fixed
- Linux: a desktop whose portal says "no preference" for light or dark follows its GTK theme again (dark here): the
  window showed its light version, and the machined finish flat (gui_toolkit's `platform.dark_mode_preferred`).

## [0.17.1] - 2026-11-11 15:41

### Fixed
- An image no longer shows too large for a moment when its entry is selected: it fits from its first frame
  (gui_toolkit's `ui.preview`).

## [0.17.0] - 2026-11-11 15:28

### Added
- The edged finish (`picker.finish edged`: the machined reliefs drawn crisp, square corners) and the Console theme
  (gui_toolkit 0.187.0).
- `picker.system_title`: the system's title bar in place of papier's own, switched at once (Windows, X11, KDE).

### Changed
- The Linux archive is built in Debian 12 (glibc 2.36): it starts on Debian 12, Ubuntu 22.04 and later. The checks run in
  the flake's shell, as on a developer's machine.
- Bold text in the window is the font's own bold, no longer a thickened regular (gui_toolkit 0.187.0).

## [0.16.0] - 2026-11-11 12:54

### Added
- The settings show papier's version at the bottom of their pages (gui_toolkit 0.185.0).
- An update shows in the status bar as a button: Install 0.x, Downloading…, then Restart to update, which restarts papier
  on the new version (gui_toolkit's `prefs_page.update_badge`).

### Fixed
- The machined finish at a small scale: the rings of a switch, a slider and a choice are clean in their curves, with no
  break nor change of grey (gui_toolkit 0.186.0).

## [0.15.0] - 2026-11-11 12:00

### Added
- The search lights its words in the list, the palette and the settings (gui_toolkit 0.184.0).
- Actions and settings have other words they are found by: "delete" finds Remove, "dark" the theme, "hotkey" the
  shortcut (gui_toolkit 0.183.0: tags).

## [0.14.0] - 2026-11-11 11:05

### Added
- The command palette finds the settings: one chosen opens the settings on it alone, its page underneath
  (gui_toolkit 0.182.0: `prefs_page.palette_commands`, `prefs_page.show`).
- Restart Papier and Quit Papier (Ctrl+Q), in the palette.

## [0.13.0] - 2026-11-11 09:08

### Added
- An image zooms and moves in the preview: the wheel zooms around the pointer, a drag moves it, a double click shows its
  pixels and fits it again; a bar in its corner shows the zoom and −, +, 1:1, Fit (gui_toolkit 0.180.3: `ui.preview`).

### Changed
- The window shown again shows the history, not the settings it was hidden on.
- The machined finish: a choice of the settings (Machined, Flat…) is a slot with a raised key; a switch's edges are
  clean; its labels are centred on their key (gui_toolkit 0.180.3).

## [0.12.0] - 2026-11-11 01:26

### Added
- Code in colours: a copied script, query or snippet (the shell, Python, SQL, Odin, Go, Rust, C, JavaScript, PowerShell,
  JSON) is shown in the theme's colours, its language found from the text and named in the entry's header; the edit
  view keeps the colours (gui_toolkit 0.176.0: `syntax.guess`, `ui.code_runs`).
- The command palette (Ctrl+K, Ctrl+Shift+P): every action, searched as you type; F1 shows every key. The palette, the
  menus, the tooltips and the keys come from one table of actions.
- Several entries at once: a Ctrl or Shift click marks entries, Ctrl+Shift+A marks all; Enter copies their texts as one
  new entry, Ctrl+P pins them, Shift+Delete removes them; the menu acts on them.
- An entry as a QR code (Ctrl+Shift+Q, the menu, the button beside the entry): text, an address, a path, for a phone.
- An entry dragged out of the list into another program: its text, its markup, its picture, its files.
- Middle-click autoscroll in the list, the preview and the settings (gui_toolkit 0.174.0).
- Linux (Wayland): `papier toggle` from a launcher hands its activation token to the running papier, whose window gets
  the keyboard even from a strict compositor.
- The search field and the editor have a menu on a right click: Undo, Redo, Cut, Copy, Paste, Delete, Select all
  (gui_toolkit 0.172.0).

## [0.11.0] - 2026-11-10 21:25

### Added
- An image's row shows a thumbnail of it, so a scroll through the list tells the images apart. Thumbnails are made beside
  the window for the rows in view only, the preview first (gui_toolkit 0.162.0: `paint.rgba_shrink`).

## [0.10.2] - 2026-11-10 17:23

### Changed
- Windows: the window shows on the screen under the mouse pointer, with no click needed there. `picker.follow focus`
  (Settings > Window) takes the screen of the window in front instead (gui_toolkit 0.157.0).

## [0.10.1] - 2026-11-10 15:46

### Fixed
- Windows: the window shows on the screen you work on (the one of the window in front, else the one under the pointer),
  at the same place of that screen, not on the screen it was last shown on.
- The site offers the download of your system (Windows or Linux), and the other one under it (gui_toolkit 0.151.0).
- The Setup's options are one per line: a long label wraps in its box instead of running past it (gui_toolkit 0.150.0).

## [0.10.0] - 2026-11-10 13:50

### Added
- Papier updates itself (Windows, and a Linux copy installed with `papier install`): the installed copy checks the latest
  release once a day, downloads the new program, checks it against its signed manifest and puts it in place, then gives
  way to it when its window is hidden. Settings > Updates says the state, checks now and installs; `update.auto` turns
  it off. A copy from Nix is left to Nix. (gui_toolkit 0.147.0: `update.Updater`, `gt:http`, `prefs_page`'s update line,
  `setup.updated`)
- A release publishes the programs alone and their update manifests, signed with papier's update key.

## [0.9.0] - 2026-11-10 12:19

### Changed
- Windows: the shortcut is **Ctrl+Shift+ù** by default, as on Linux. Win+Shift+V was Windows's own (it cycles through
  the notifications): the shortcut did nothing.
- Windows: the shortcut is recorded, not typed: in the settings, click the field and press the keys (gui_toolkit's
  `ui.hotkey_field`). A shortcut that cannot be used says why, under its line and in the status bar.

### Fixed
- Windows: papier.exe has its icon (the Start menu's shortcut, Settings > Apps, the window, the taskbar), its manifest
  and its version.
- Windows: after an install, the Setup no longer asks to repair it (an install in the default folder is recorded:
  gui_toolkit 0.143.0).

## [0.8.1] - 2026-11-10 06:33

### Fixed
- The window's panes join: the search's halo is no longer cut under the title bar, the rule under it has its lit line,
  and the list and the entry meet at the splitter's rule with no gap beside it (gui_toolkit 0.138.0).

## [0.8.0] - 2026-11-09 22:15

### Added
- **The entry chosen is pasted where you were** (`paste.on_select`, on): Enter, a double click or Alt+1…9 puts it on the
  clipboard, hides the window and presses Ctrl+V for the program that has the keyboard again (`paste.keys` for other
  keys: Ctrl+Shift+V in a terminal). On Wayland it needs a compositor that lets a program type for another
  (`zwp_virtual_keyboard_v1`: wlroots compositors, ShojiWM); on Windows it is SendInput. It is gui_toolkit 0.135.0's
  `send_hotkey`.
- Setup (Windows): the start with the session and papier on the PATH are boxes of the dialog.

## [0.7.2] - 2026-11-09 19:48

### Changed
- The icons are gui_toolkit's Lucide set (0.129.0): papier carries no copy of the font of its own.

## [0.7.1] - 2026-11-09 19:00

### Changed
- Windows: the Setup's dialog can be resized from its edges and its corner; what it says scrolls when it is small, its
  buttons stay under it. It is gui_toolkit 0.127.0.

## [0.7.0] - 2026-11-09 18:30

### Added
- **Windows: Setup.** A start of the downloaded `papier.exe` offers to install papier for you: the program in
  `%LOCALAPPDATA%\Programs\papier`, the Start menu, the start with the session, `papier` on the PATH with `papier.com`,
  and the Settings > Apps entry. The same dialog repairs, upgrades or removes the install (`papier --setup`; Settings >
  Apps > Papier > Uninstall opens it). It shows where everything is; a path is shown whole on hover and copied by its
  button. It is gui_toolkit's `setup`.
- **Windows**: `papier.com`, the console launcher, beside `papier.exe` (`papier install` writes it with the PATH entry).
  In cmd or PowerShell, `papier list`, `papier get`, `papier set`… give their output and their exit code; `papier`,
  `papier --hidden` and `papier toggle` give the prompt back. It is gui_toolkit's console launcher.

## [0.6.0] - 2026-11-09 16:45

### Added
- **Windows**: papier shows the system's clipboard history (the one Win+V shows), searched and filtered as on Linux, at
  a shortcut of its own (`picker.shortcut`, Win+Shift+V by default). Enter puts an entry back on the clipboard; an
  entry can be copied as plain text, edited (the edit is a new copy), removed, and the history cleared. The system keeps
  the history and its pins (Settings > System > Clipboard). The release has a `papier-<version>-windows-x64.zip`.
  Its CI builds it and runs its tests on Windows, where the system answers papier's reads; the runner's session has the
  clipboard history off, so reading the entries, putting one back and removing it have not run on a real desktop yet.

### Changed
- Each archive of a release has its SHA-256 in a file beside it (`<archive>.sha256`), in place of `SHA256SUMS.txt`.

## [0.5.2] - 2026-11-09 16:09

### Fixed
- Settings: a change (a theme chosen, a switch) is saved when `~/.config/papier` does not exist yet. It was lost, and
  the preferences read back from no file put the old value back. It is gui_toolkit 0.123.0.

## [0.5.1] - 2026-11-09 15:51

### Fixed
- Settings: a number with a unit (Max age, in days) no longer makes its line as tall as the page. It is gui_toolkit
  0.122.0.

## [0.5.0] - 2026-11-09 15:16

### Changed
- The history is a SQLite database, `history.db`, with SQLite linked into papier. Each change is written at once, in
  one transaction. The history of papier 0.4 (`index` and `blobs/`) is imported at the first start, with its ids,
  times and pins, then deleted.
- The search finds a word anywhere in the text of a copy, not only in its first kilobyte. A word of one or two letters
  is still looked for in the preview.

## [0.4.0] - 2026-11-09 14:58

### Added
- **Settings** (Ctrl+, or the gear of the title bar): every preference on four pages (Appearance, Window, History,
  Capture), the search, a switch, a choice, a slider or a field for each, the themes as cards in their own colours.
  A change is saved and applied at once. It is gui_toolkit's `prefs_page` (0.120.0).

### Changed
- `capture.max_bytes` is `capture.size_limit`.

## [0.3.0] - 2026-11-09 13:55

### Added
- **The machined finish**, the default (`picker.finish`): bevelled buttons, the search as a sunken well with a ring of
  light when focused, the filters on a carved track. `flat`, `gradient` and `glass` are the others.
- **Themes with a dark and a light version** (gui_toolkit 0.117.0): `picker.theme` names Papier or one of the toolkit's
  25 themes; `picker.mode` shows the system's version and follows it when it changes, or the dark one, or the light one.
  `picker.glow` turns the halos off.

### Changed
- `picker.theme` no longer takes "papier light": the light version is `picker.mode light`.

## [0.2.0] - 2026-11-09 13:18

### Added
- **The menu of an entry**: a right click on a row, the Menu key or Shift+F10. Copy, Copy as plain text (rich text),
  Edit…, Open (an address in the browser, a file with its program, the rest as a file of its type), Open with (the
  applications the system knows for the type: gui_toolkit's `desktop.handlers_for_file`), Show in folder (files),
  Save as…, Pin, Remove. Ctrl+O opens, Ctrl+S saves as.
- **The edit view**: Ctrl+E or the pencil puts the text of an entry in an editor. Ctrl+Enter copies it as a new entry;
  Ctrl+S saves it in place of the entry (its place and its pin kept); Escape leaves.

### Fixed
- **The preview follows an edit**: it was kept by the entry's id, which an edit does not change.

## [0.1.6] - 2026-11-09 11:26

### Fixed
- **papier is in no task bar while hidden** (gui_toolkit 0.114.2): started with `--hidden`, its window was a toplevel
  with no picture, and ShojiWM's task bar listed it. The toplevel is now made when the window shows.

## [0.1.5] - 2026-11-09 10:59

### Fixed
- **No spin at the end of a wait** (gui_toolkit 0.114.1): on Wayland, a wait with less than a millisecond left returned at
  once, and the loop woke about 150 times before its deadline.

## [0.1.4] - 2026-11-09 10:30

### Fixed
- **The search field is one box**: the field drew its own square focus ring inside the rounded search box. The box is now
  the toolkit's `field_frame`: one surface and one rounded focus ring around the icon and the field.

## [0.1.3] - 2026-11-09 10:21

### Fixed
- **The grip is grey**: its lines asked the theme for a colour name it lacks, and got the violet that marks a missing
  name. They take the weak text's colour, finer and shorter.

## [0.1.2] - 2026-11-09 10:08

### Added
- **A grip in the title bar**: three faint lines between the search and the filters mark a place reserved to move the
  window.

## [0.1.1] - 2026-11-09 10:01

### Fixed
- **The window takes the keyboard when it shows**: papier asks the compositor for the focus (`xdg-activation`). ShojiWM's
  Windows 7 configuration did not focus it, so the arrows and the search did nothing until a click.
- **The tray icon shows**: panels that read the icon in one call (Quickshell, Waybar) showed the "missing icon" pattern.
- **The selection moves at once over images**: a picture is decoded on a thread of its own, and the newest selection
  wins. A 4K screenshot took about 180 ms to decode, and the window waited for it at each step.

## [0.1.0] - 2026-11-09 07:53

### Added
- **The clipboard's history on Wayland**: every copy is recorded through the data-control protocol
  (`ext-data-control-v1`, or `zwlr-data-control-unstable-v1`), with no window and no focus: text, rich text (HTML), images
  (PNG, JPEG, WebP, GIF, BMP, SVG) and files copied in a file manager.
- **One process for the session**: papier lives in the notification area and its window comes up in a few milliseconds.
  A second `papier` hands it `show`; `papier toggle` is for a key binding.
- **The window**: an integrated title bar with the search and the filters (All, Text, Images, Files, Pinned), a dense list
  that builds only the rows in view, the selected entry in full beside it (text in a monospace face, images, files), a
  splitter, a status bar with the keys. Its size, its place (X11) and the list's width are remembered.
- **The keyboard**: typing filters, Up / Down / Page Up / Page Down move, Enter or a double click puts an entry back on the
  clipboard, Alt+1..9 the first nine, Ctrl+P pins, Shift+Delete removes, Tab switches the filter, Escape clears or hides.
- **Pinned entries** stay whatever the limits.
- **Secrets are left out**: what a password manager marks with `x-kde-passwordManagerHint` is not recorded.
- **The clipboard kept**: when the program that owned it quits and empties it, the last entry goes back.
- **The history on the disk**: content-addressed blobs (a copy of the same bytes is one file) and an index written
  atomically; the same copy twice is one entry, moved to the top.
- **Preferences** (`papier prefs`, `papier set`, `--pref`): history limits, what to record, the size limit, types to
  ignore, the primary selection, the theme (papier, papier light, or any of gui_toolkit's palettes), the window's size and
  text size.
- **The command line**: `list`, `get`, `copy`, `pin`, `unpin`, `delete`, `clear`, `show`, `hide`, `toggle`, `quit`.
- **The desktop**: `papier install` adds a launcher with its icons, `~/.local/bin/papier` and the start with the session;
  `uninstall` and `status`.
- **papiertool**: `build`, `test`, `check`, `live` (the real program in a headless sway), `shots`, `logo`, `package`,
  `notes`, `ship`, `site`.
[0.42.0]: https://github.com/sachahjkl/papier/releases/tag/v0.42.0
[0.41.0]: https://github.com/sachahjkl/papier/releases/tag/v0.41.0
[0.40.2]: https://github.com/sachahjkl/papier/releases/tag/v0.40.2
[0.40.1]: https://github.com/sachahjkl/papier/releases/tag/v0.40.1
[0.40.0]: https://github.com/sachahjkl/papier/releases/tag/v0.40.0
[0.39.0]: https://github.com/sachahjkl/papier/releases/tag/v0.39.0
[0.38.0]: https://github.com/sachahjkl/papier/releases/tag/v0.38.0
[0.37.1]: https://github.com/sachahjkl/papier/releases/tag/v0.37.1
[0.37.0]: https://github.com/sachahjkl/papier/releases/tag/v0.37.0
[0.36.1]: https://github.com/sachahjkl/papier/releases/tag/v0.36.1
[0.36.0]: https://github.com/sachahjkl/papier/releases/tag/v0.36.0
[0.35.0]: https://github.com/sachahjkl/papier/releases/tag/v0.35.0
[0.34.0]: https://github.com/sachahjkl/papier/releases/tag/v0.34.0
[0.33.0]: https://github.com/sachahjkl/papier/releases/tag/v0.33.0
[0.32.1]: https://github.com/sachahjkl/papier/releases/tag/v0.32.1
[0.32.0]: https://github.com/sachahjkl/papier/releases/tag/v0.32.0
[0.31.0]: https://github.com/sachahjkl/papier/releases/tag/v0.31.0
[0.30.0]: https://github.com/sachahjkl/papier/releases/tag/v0.30.0
[0.29.0]: https://github.com/sachahjkl/papier/releases/tag/v0.29.0
[0.28.0]: https://github.com/sachahjkl/papier/releases/tag/v0.28.0
[0.27.0]: https://github.com/sachahjkl/papier/releases/tag/v0.27.0
[0.26.0]: https://github.com/sachahjkl/papier/releases/tag/v0.26.0
[0.25.0]: https://github.com/sachahjkl/papier/releases/tag/v0.25.0
[0.24.0]: https://github.com/sachahjkl/papier/releases/tag/v0.24.0
[0.23.2]: https://github.com/sachahjkl/papier/releases/tag/v0.23.2
[0.23.1]: https://github.com/sachahjkl/papier/releases/tag/v0.23.1
[0.23.0]: https://github.com/sachahjkl/papier/releases/tag/v0.23.0
[0.22.0]: https://github.com/sachahjkl/papier/releases/tag/v0.22.0
[0.21.2]: https://github.com/sachahjkl/papier/releases/tag/v0.21.2
[0.21.1]: https://github.com/sachahjkl/papier/releases/tag/v0.21.1
[0.21.0]: https://github.com/sachahjkl/papier/releases/tag/v0.21.0
[0.20.2]: https://github.com/sachahjkl/papier/releases/tag/v0.20.2
[0.20.1]: https://github.com/sachahjkl/papier/releases/tag/v0.20.1
[0.20.0]: https://github.com/sachahjkl/papier/releases/tag/v0.20.0
[0.19.2]: https://github.com/sachahjkl/papier/releases/tag/v0.19.2
[0.19.1]: https://github.com/sachahjkl/papier/releases/tag/v0.19.1
[0.19.0]: https://github.com/sachahjkl/papier/releases/tag/v0.19.0
[0.18.1]: https://github.com/sachahjkl/papier/releases/tag/v0.18.1
[0.18.0]: https://github.com/sachahjkl/papier/releases/tag/v0.18.0
[0.17.7]: https://github.com/sachahjkl/papier/releases/tag/v0.17.7
[0.17.6]: https://github.com/sachahjkl/papier/releases/tag/v0.17.6
[0.17.5]: https://github.com/sachahjkl/papier/releases/tag/v0.17.5
[0.17.4]: https://github.com/sachahjkl/papier/releases/tag/v0.17.4
[0.1.0]: https://github.com/sachahjkl/papier/releases/tag/v0.1.0
[0.1.1]: https://github.com/sachahjkl/papier/releases/tag/v0.1.1
[0.1.2]: https://github.com/sachahjkl/papier/releases/tag/v0.1.2
[0.1.3]: https://github.com/sachahjkl/papier/releases/tag/v0.1.3
[0.1.4]: https://github.com/sachahjkl/papier/releases/tag/v0.1.4
[0.1.5]: https://github.com/sachahjkl/papier/releases/tag/v0.1.5
[0.1.6]: https://github.com/sachahjkl/papier/releases/tag/v0.1.6
[0.2.0]: https://github.com/sachahjkl/papier/releases/tag/v0.2.0
[0.3.0]: https://github.com/sachahjkl/papier/releases/tag/v0.3.0
[0.4.0]: https://github.com/sachahjkl/papier/releases/tag/v0.4.0
[0.5.0]: https://github.com/sachahjkl/papier/releases/tag/v0.5.0
[0.5.1]: https://github.com/sachahjkl/papier/releases/tag/v0.5.1
[0.5.2]: https://github.com/sachahjkl/papier/releases/tag/v0.5.2
[0.6.0]: https://github.com/sachahjkl/papier/releases/tag/v0.6.0
[0.7.0]: https://github.com/sachahjkl/papier/releases/tag/v0.7.0
[0.7.1]: https://github.com/sachahjkl/papier/releases/tag/v0.7.1
[0.7.2]: https://github.com/sachahjkl/papier/releases/tag/v0.7.2
[0.8.0]: https://github.com/sachahjkl/papier/releases/tag/v0.8.0
[0.8.1]: https://github.com/sachahjkl/papier/releases/tag/v0.8.1
[0.9.0]: https://github.com/sachahjkl/papier/releases/tag/v0.9.0
[0.10.0]: https://github.com/sachahjkl/papier/releases/tag/v0.10.0
[0.10.1]: https://github.com/sachahjkl/papier/releases/tag/v0.10.1
[0.10.2]: https://github.com/sachahjkl/papier/releases/tag/v0.10.2
[0.11.0]: https://github.com/sachahjkl/papier/releases/tag/v0.11.0
[0.12.0]: https://github.com/sachahjkl/papier/releases/tag/v0.12.0
[0.13.0]: https://github.com/sachahjkl/papier/releases/tag/v0.13.0
[0.14.0]: https://github.com/sachahjkl/papier/releases/tag/v0.14.0
[0.15.0]: https://github.com/sachahjkl/papier/releases/tag/v0.15.0
[0.16.0]: https://github.com/sachahjkl/papier/releases/tag/v0.16.0
[0.17.0]: https://github.com/sachahjkl/papier/releases/tag/v0.17.0
[0.17.1]: https://github.com/sachahjkl/papier/releases/tag/v0.17.1
[0.17.2]: https://github.com/sachahjkl/papier/releases/tag/v0.17.2
[0.17.3]: https://github.com/sachahjkl/papier/releases/tag/v0.17.3
