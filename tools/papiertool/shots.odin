#+build linux
package papiertool

// shots: the pictures of the README, the documentation and the site, the program's own frames (over the DevTools protocol,
// session.odin): a history of made-up entries (never the person's clipboard), then the window as each picture shows it.
//
//   papiertool shots [--out folder]      (default: docs/screenshots, copied to site/img)

import "core:fmt"
import "core:os"
import "core:strings"
import cdp "gt:cdp"
import cli "gt:cli"

SHOTS_DIR     :: "build/shots"
SHOTS_OUT     :: "docs/screenshots"
SHOTS_SITE    :: "site/img"

// What is copied, oldest first (the last one is on top of the list).
@(private = "file")
Sample :: struct { text, mime, file, seen: string }

@(private = "file")
SAMPLES :: [?]Sample{
	// (the oldest: a Markdown text with a diagram and a table, the "markdown" picture)
	{text = "# Release plan\n\nWhat goes out with **0.2**.\n\n```mermaid\nflowchart LR\n    A[Fragments] --> B[Changelog]\n    B --> C[Release]\n    C --> D[Site]\n    C --> E[Updates]\n```\n\n| Step | Who | When |\n|---|---|---|\n| Changelog | the tool | at the release |\n| Pictures | shots | before it |\n| Site | site build | after it |\n", seen = "# Release plan"},
	{text = "SELECT name, email FROM users\nWHERE created_at > now() - interval '7 days'\nORDER BY created_at DESC;", seen = "SELECT name, email"},
	{text = "Meeting moved to Thursday 10:00, room B. Bring the printed agenda and the budget figures.", seen = "Meeting moved"},
	{text = "<h2>Release notes</h2><p>Papier <b>0.1.0</b> keeps the clipboard's history: text, rich text, images and files.</p>", mime = "text/html", seen = "Release notes"},
	{text = "file:///home/ada/Documents/report-2026.pdf\r\nfile:///home/ada/Pictures/harbour.jpg\r\n", mime = "text/uri-list", seen = "report-2026.pdf"},
	{text = "https://github.com/sachahjkl/papier", seen = "github.com/sachahjkl/papier"},
	{mime = "image/png", file = "assets/logo_256.png", seen = "image/png 256 × 256"},
	{text = "#!/usr/bin/env bash\nset -euo pipefail\nfor f in *.png; do\n  magick \"$f\" -resize 50% \"small-$f\"\ndone", seen = "#!/usr/bin/env bash"},
	{text = "proc fibonacci(n: u64) -> u64 {\n\tif n < 2 { return n }\n\treturn fibonacci(n - 1) + fibonacci(n - 2)\n}", seen = "proc fibonacci"},
}

run_shots :: proc(args: []string) -> cli.Exit {
	out := SHOTS_OUT
	if len(args) == 2 && args[0] == "--out" { out = args[1] }
	if run_build({"release"}) != .Done { return .Failed }
	s: Session
	defer session_stop(&s)
	if why := session_start(&s, SHOTS_DIR, {"appearance.mode\tdark"}); why != "" { fmt.eprintfln("papiertool shots: %s", why); return .Failed }
	samples := SAMPLES
	for x in samples {
		if !copy_and_wait(&s, x.text, x.mime, x.file, x.seen) { fmt.eprintfln("papiertool shots: %q did not reach the history", x.seen); return .Failed }
	}
	// the address pinned
	list, _ := run_in(&s, PROGRAM, "list", "100")
	rest := list
	for line in strings.split_lines_iterator(&rest) {
		if strings.contains(line, "github.com/sachahjkl/papier") { _, _ = run_in(&s, PROGRAM, "pin", strings.split(line, "\t", context.temp_allocator)[0]) }
	}

	_ = os.make_directory_all(out)
	_, _ = run_in(&s, PROGRAM, "show")
	c, ok := window_connect(&s)
	if !ok { fmt.eprintln("papiertool shots: the window does not answer"); return .Failed }
	defer cdp.close(&c)
	failed := false
	shot :: proc(c: ^cdp.Client, out, name: string, failed: ^bool) {
		cdp.wait_idle(c, SESSION_WAIT)
		path := fmt.tprintf("%s/%s.png", out, name)
		if cdp.shot(c, path) { fmt.printfln("wrote %s", path) } else { failed^ = true }
	}
	cdp.wait_for(&c, "proc fibonacci", SESSION_WAIT)
	shot(&c, out, "main", &failed)
	cdp.key(&c, "Tab")
	cdp.key(&c, "Tab")   // Images
	cdp.wait_for(&c, "image/png 256 × 256", SESSION_WAIT)
	shot(&c, out, "images", &failed)
	cdp.key(&c, "shift+Tab")
	cdp.key(&c, "shift+Tab")   // All
	cdp.type_text(&c, "release")
	cdp.wait_for(&c, "proc fibonacci", SESSION_WAIT, gone = true)
	shot(&c, out, "search", &failed)
	// the entry's menu, then the edit view, on the first entry
	cdp.key(&c, "Escape")   // (the search, cleared)
	cdp.wait_for(&c, "proc fibonacci", SESSION_WAIT)
	cdp.key(&c, "ContextMenu")
	cdp.wait_for(&c, "Open with", SESSION_WAIT)
	shot(&c, out, "menu", &failed)
	cdp.key(&c, "Escape")
	cdp.wait_for(&c, "Open with", SESSION_WAIT, gone = true)
	cdp.key(&c, "ctrl+e")
	cdp.wait_for(&c, "Editing", SESSION_WAIT)
	shot(&c, out, "edit", &failed)
	cdp.key(&c, "Escape")
	cdp.wait_for(&c, "Editing", SESSION_WAIT, gone = true)
	// the command palette, searched
	cdp.key(&c, "ctrl+k")
	cdp.wait_for(&c, "Copy as plain text", SESSION_WAIT)   // (papier's commands come first in the list)
	cdp.type_text(&c, "theme")
	cdp.wait_for(&c, "Show every entry", SESSION_WAIT, gone = true)
	shot(&c, out, "palette", &failed)
	// a setting chosen with Shift+Enter, go to: the settings, on it (Enter would change it in the palette itself)
	cdp.key(&c, "shift+Enter")
	if !cdp.wait_name(&c, "palette_top", SESSION_WAIT, gone = true) { fmt.eprintln("papiertool shots: the palette did not close on its setting"); failed = true }
	if !cdp.wait_for(&c, "The colours of Papier's windows", SESSION_WAIT) { fmt.eprintln("papiertool shots: the palette's setting did not open the settings"); failed = true }
	cdp.key(&c, "ctrl+,")
	cdp.wait_for(&c, "The colours of Papier's windows", SESSION_WAIT, gone = true)
	if !cdp.wait_for(&c, "proc fibonacci", SESSION_WAIT) { fmt.eprintln("papiertool shots: the list is not back after the settings"); failed = true }
	// the address as a QR code
	cdp.type_text(&c, "github")
	cdp.wait_for(&c, "proc fibonacci", SESSION_WAIT, gone = true)
	cdp.key(&c, "ctrl+shift+q")
	if !cdp.wait_name(&c, "qr_code", SESSION_WAIT) { fmt.eprintln("papiertool shots: the QR code did not show"); failed = true }
	shot(&c, out, "qr", &failed)
	cdp.key(&c, "Escape")
	cdp.key(&c, "Escape")   // (the search, cleared)
	cdp.wait_for(&c, "proc fibonacci", SESSION_WAIT)
	// a Markdown text: its diagram drawn, its table
	cdp.type_text(&c, "release plan")
	cdp.wait_for(&c, "proc fibonacci", SESSION_WAIT, gone = true)
	shot(&c, out, "markdown", &failed)
	cdp.key(&c, "Escape")   // (the search, cleared)
	cdp.wait_for(&c, "proc fibonacci", SESSION_WAIT)
	// the settings
	cdp.key(&c, "ctrl+,")
	cdp.wait_for(&c, "The language of the interface", SESSION_WAIT)   // (the first page, General: the palette's jump is gone)
	cdp.wait_for(&c, "Appearance", SESSION_WAIT)
	cdp.click_text(&c, "Appearance")
	cdp.wait_for(&c, "Light or dark", SESSION_WAIT)
	shot(&c, out, "settings", &failed)
	cdp.key(&c, "ctrl+,")
	cdp.close(&c)

	_, _ = run_in(&s, PROGRAM, "set", "appearance.mode", "light")
	_, _ = run_in(&s, PROGRAM, "hide")
	_, _ = run_in(&s, PROGRAM, "show")
	if lc, lok := window_connect(&s); lok {
		cdp.wait_for(&lc, "proc fibonacci", SESSION_WAIT)
		shot(&lc, out, "light", &failed)
		cdp.close(&lc)
	} else {
		failed = true
	}
	if failed { return .Failed }

	// the site shows the same pictures (not pictures written elsewhere: --out leaves the site as it is)
	if out != SHOTS_OUT { return .Done }
	_ = os.make_directory_all(SHOTS_SITE)
	for name in ([]string{"main", "images", "search", "menu", "edit", "palette", "qr", "markdown", "settings", "light"}) {
		data, err := os.read_entire_file(fmt.tprintf("%s/%s.png", out, name), context.temp_allocator)
		if err == nil { _ = os.write_entire_file(fmt.tprintf("%s/%s.png", SHOTS_SITE, name), data) }
	}
	return .Done
}
