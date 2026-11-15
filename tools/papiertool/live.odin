#+build linux
package papiertool

// live: the real program against a real compositor that nobody sees (session.odin), and what a person does through
// wl-clipboard and over the DevTools protocol: copies of each kind, a secret, a copy of an entry already there, an entry
// put back, the clipboard emptied, the window shown, searched, hidden and shown again. Each wait is for a condition, with
// a bound.
//
//   papiertool live [--keep]     (--keep: build/live stays, with the logs and the window's pictures)
//
// Needs sway and wl-clipboard on the PATH (nix develop has them).

import "core:encoding/json"
import "core:fmt"
import "core:os"
import "core:strings"
import "core:time"
import cdp "gt:cdp"
import ocr "gt:ocr"

LIVE_DIR  :: "build/live"
LIVE_PORT :: 9361

@(private = "file")
Live :: struct {
	using session: Session,
	failures:      int,
	checks:        int,
}

@(private = "file")
check :: proc(l: ^Live, ok: bool, what: string, args: ..any) {
	l.checks += 1
	msg := fmt.tprintf(what, ..args)
	if ok { fmt.printfln("  ok    %s", msg); return }
	l.failures += 1
	fmt.printfln("  FAIL  %s", msg)
}

// The fields of the line of `list` whose preview holds `text`: id, kind, age, preview.
@(private = "file")
entry_of :: proc(list, text: string) -> (fields: []string, ok: bool) {
	rest := list
	for line in strings.split_lines_iterator(&rest) {
		if strings.contains(line, text) { return strings.split(line, "\t", context.temp_allocator), true }
	}
	return
}

@(private = "file")
line_count :: proc(list: string) -> int {
	t := strings.trim_space(list)
	return t == "" ? 0 : strings.count(t, "\n") + 1
}

run_live :: proc(args: []string) -> int {
	keep := len(args) > 0 && args[0] == "--keep"
	if run_build(nil) != 0 { return 1 }
	l: Live
	if why := session_start(&l.session, LIVE_DIR, LIVE_PORT); why != "" {
		fmt.eprintfln("papiertool live: %s", why)
		session_stop(&l.session)
		return 1
	}
	dir := strings.clone(l.dir, context.temp_allocator)
	fmt.printfln("live: papier runs in a headless sway (%s)", dir)
	check(&l, true, "papier --hidden runs and answers")
	live_clipboard(&l)
	live_window(&l)
	live_preview(&l)
	live_toggle(&l)
	code := session_stop(&l.session)
	check(&l, code == 0, "papier quit: it ends, with 0 (%d)", code)
	log, _ := os.read_entire_file(fmt.tprintf("%s/papier.log", dir), context.temp_allocator)
	check(&l, !strings.contains(string(log), "error"), "papier wrote no error (%s/papier.log)", dir)
	fmt.printfln("live: %d checks, %d failed", l.checks, l.failures)
	if !keep && l.failures == 0 { _ = os.remove_all(dir) }
	return l.failures == 0 ? 0 : 1
}

// Copies of each kind and what papier makes of them.
@(private = "file")
live_clipboard :: proc(l: ^Live) {
	TEXT :: "hello from papier live"
	check(l, copy_and_wait(l, TEXT), "a text copied is in the history")
	list, _ := run_in(l, PROGRAM, "list", "100")
	if f, found := entry_of(list, TEXT); found { check(l, f[1] == "text", "its kind is text (%s)", f[1]) }

	rich := "rich bold live"
	check(l, copy_and_wait(l, "<p>rich <b>bold</b> live</p>", "text/html", seen = rich), "HTML copied is in the history, its tags out of the preview")
	list, _ = run_in(l, PROGRAM, "list", "100")
	if f, found := entry_of(list, rich); found { check(l, f[1] == "html", "its kind is html (%s)", f[1]) }

	image := "image/png 64 × 64"
	check(l, copy_and_wait(l, "", "image/png", "assets/logo_64.png", seen = image), "a PNG copied is in the history with its size")

	file := "/etc/hostname"
	check(l, copy_and_wait(l, "file:///etc/hostname\r\n", "text/uri-list", seen = file), "a file copied is in the history")
	list, _ = run_in(l, PROGRAM, "list", "100")
	if f, found := entry_of(list, file); found { check(l, f[1] == "files", "its kind is files (%s)", f[1]) }

	// a password manager's secret, then a marker: once the marker is there, the secret was seen and left out
	check(l, wl_copy(l, "hunter2-secret", "x-kde-passwordManagerHint"), "wl-copy a secret")
	marker := "after the secret"
	check(l, copy_and_wait(l, marker), "a marker after it is in the history")
	list, _ = run_in(l, PROGRAM, "list", "100")
	check(l, !strings.contains(list, "hunter2"), "the secret is not in the history")

	// the same text again: the entry moves to the top, nothing is added
	before := line_count(list)
	check(l, wl_copy(l, TEXT), "wl-copy the first text again")
	text := TEXT
	top_is :: proc(list: string, data: rawptr) -> bool { return strings.contains(strings.split_lines(list, context.temp_allocator)[0], (^string)(data)^) }
	ok: bool
	list, ok = wait_list(l, top_is, &text)
	check(l, ok, "it is first again")
	check(l, line_count(list) == before, "nothing was added (%d entries, %d before)", line_count(list), before)

	// an entry put back on the clipboard: every type it had
	if f, found := entry_of(list, image); found {
		_, code := run_in(l, PROGRAM, "copy", f[0])
		check(l, code == 0, "papier copy %s", f[0])
		deadline := time.tick_add(time.tick_now(), SESSION_WAIT)
		types := ""
		for time.tick_diff(time.tick_now(), deadline) > 0 {
			types, _ = run_in(l, "wl-paste", "-l")
			if strings.contains(types, "image/png") { break }
			time.sleep(SESSION_POLL)
		}
		check(l, strings.contains(types, "image/png"), "the clipboard offers image/png")
		png, _ := run_in(l, "wl-paste", "-t", "image/png")
		want, _ := os.read_entire_file("assets/logo_64.png", context.temp_allocator)
		check(l, png == string(want), "its bytes are the file's (%d bytes)", len(png))
	}

	// the clipboard emptied (its owner quit): papier puts the last entry back
	_, _ = run_in(l, "wl-copy", "--clear")
	deadline := time.tick_add(time.tick_now(), SESSION_WAIT)
	types := ""
	for time.tick_diff(time.tick_now(), deadline) > 0 {
		types, _ = run_in(l, "wl-paste", "-l")
		if strings.trim_space(types) != "" { break }
		time.sleep(SESSION_POLL)
	}
	check(l, strings.trim_space(types) != "", "an emptied clipboard gets the last entry back")
}

// The menu of an image offers to read its text when the system can (OCR: libtesseract and a language; papier asks on a
// worker, this process asks too). Starts and ends with "bold" in the search, as live_window has it.
@(private = "file")
live_image_menu :: proc(l: ^Live, c: ^cdp.Client) {
	check(l, cdp.key(c, "Escape"), "Escape clears the search")
	check(l, cdp.type_text(c, "image/png"), "search the image")
	check(l, cdp.wait_for(c, "rich bold live", SESSION_WAIT, gone = true), "the image alone is listed")
	if _, available := ocr.available(); available {
		check(l, cdp.key(c, "ContextMenu"), "the Menu key on the image")
		check(l, cdp.wait_for(c, "Copy the text of the image", SESSION_WAIT), "the image's menu offers to read its text")
		check(l, cdp.key(c, "Escape"), "Escape closes the menu")
		check(l, cdp.wait_for(c, "Copy the text of the image", SESSION_WAIT, gone = true), "and it closes")
		// (the same menu from a right click on the picture of the preview)
		_, clicked := cdp.call(c, "Toolkit.click", `{"name":"image","index":0,"count":1,"button":"right"}`)
		check(l, clicked, "a right click on the image's preview")
		check(l, cdp.wait_for(c, "Copy the text of the image", SESSION_WAIT), "opens the entry's menu, with its text to read")
		check(l, cdp.key(c, "Escape"), "Escape closes it")
		check(l, cdp.wait_for(c, "Copy the text of the image", SESSION_WAIT, gone = true), "and it closes")
	} else {
		fmt.println("  skip  the image's menu and OCR: this system has no OCR engine or language (tesseract)")
	}
	check(l, cdp.key(c, "Escape"), "Escape clears the search")
	check(l, cdp.type_text(c, "bold"), "type in the search again")
	check(l, cdp.wait_for(c, "hello from papier live", SESSION_WAIT, gone = true), "the search leaves the other entries out again")
	check(l, cdp.wait_for(c, "rich bold live", SESSION_WAIT), "and keeps the match")
}

// The window: shown, read, searched, hidden and shown again; each time a frame comes, and the DevTools server takes a
// new connection.
@(private = "file")
live_window :: proc(l: ^Live) {
	_, code := run_in(l, PROGRAM, "show")
	check(l, code == 0, "papier show")
	c, ok := window_connect(l)
	check(l, ok, "the window serves the DevTools protocol")
	if !ok { return }
	check(l, cdp.wait_for(&c, "hello from papier live", SESSION_WAIT), "the window lists the history")
	check(l, cdp.shot(&c, fmt.tprintf("%s/window.png", l.dir)), "a picture of the window")
	check(l, cdp.type_text(&c, "bold"), "type in the search")
	check(l, cdp.wait_for(&c, "hello from papier live", SESSION_WAIT, gone = true), "the search leaves the other entries out")
	check(l, cdp.wait_for(&c, "rich bold live", SESSION_WAIT), "and keeps the match")
	// the entry's menu, from the keyboard
	check(l, cdp.key(&c, "ContextMenu"), "the Menu key")
	check(l, cdp.wait_for(&c, "Open with", SESSION_WAIT), "the entry's menu opens")
	check(l, cdp.key(&c, "Escape"), "Escape")
	check(l, cdp.wait_for(&c, "Open with", SESSION_WAIT, gone = true), "and closes")
	live_image_menu(l, &c)
	// the edit view: the rich text edited as text, saved in place of its entry
	EDITED :: "rich bold live, edited"
	check(l, cdp.key(&c, "ctrl+e"), "Ctrl+E")
	check(l, cdp.wait_for(&c, "Editing", SESSION_WAIT), "the edit view opens")
	check(l, cdp.type_text(&c, ", edited"), "type in the editor")
	// (the palette is the window's: it opens while the editor has the keyboard)
	// (searched: with nothing typed the palette lists every command, and a long list builds only the rows in view)
	check(l, cdp.key(&c, "ctrl+k"), "Ctrl+K in the edit view")
	check(l, cdp.type_text(&c, "clear the history"), "search a command in the palette")
	check(l, cdp.wait_for(&c, "Clear the history (pinned entries stay)", SESSION_WAIT), "the palette opens over the edit view")
	check(l, cdp.key(&c, "Escape"), "Escape closes the palette")
	check(l, cdp.wait_for(&c, "Clear the history (pinned entries stay)", SESSION_WAIT, gone = true), "the palette is closed")
	check(l, cdp.key(&c, "ctrl+s"), "Ctrl+S")
	check(l, cdp.wait_for(&c, EDITED, SESSION_WAIT), "the entry is saved, edited")
	list, _ := run_in(l, PROGRAM, "list", "100")
	f, found := entry_of(list, EDITED)
	check(l, found && f[1] == "text", "the history has it, as text")

	// a theme chosen in the settings: saved, its folder made when it is not there, and still chosen after the reload
	cfg := fmt.tprintf("%s/config/papier", l.dir)
	_ = os.remove_all(cfg)
	check(l, cdp.key(&c, "ctrl+,"), "Ctrl+,")
	check(l, cdp.wait_for(&c, "Appearance", SESSION_WAIT), "the settings open")
	// (the palette from the settings, their search with the keyboard; it lists the settings, "Settings · <page>")
	check(l, cdp.key(&c, "ctrl+k"), "Ctrl+K in the settings")
	check(l, cdp.type_text(&c, "clear the history"), "search a command in the palette")
	check(l, cdp.wait_for(&c, "Clear the history (pinned entries stay)", SESSION_WAIT), "the palette opens over the settings")
	check(l, cdp.key(&c, "ctrl+a"), "select the search")
	check(l, cdp.type_text(&c, "theme"), "search the settings in the palette")
	check(l, cdp.wait_for(&c, "Settings · Appearance", SESSION_WAIT), "the palette lists the settings")
	check(l, cdp.key(&c, "Escape"), "Escape closes the palette")
	check(l, cdp.wait_for(&c, "Settings · Appearance", SESSION_WAIT, gone = true), "the palette is closed")
	check(l, cdp.click_text(&c, "Appearance"), "click the Appearance page")
	check(l, cdp.wait_for(&c, "Graphite", SESSION_WAIT), "the settings show the themes")
	check(l, cdp.click_text(&c, "Graphite"), "click Graphite's card")
	saved := false
	for _ in 0 ..< 50 {
		if data, err := os.read_entire_file(fmt.tprintf("%s/prefs", cfg), context.temp_allocator); err == nil && strings.contains(string(data), "appearance.theme\tGraphite") { saved = true; break }
		time.sleep(100 * time.Millisecond)
	}
	check(l, saved, "the theme is in %s/prefs", cfg)
	time.sleep(300 * time.Millisecond)   // (the running papier reads its preferences again)
	prefs, _ := run_in(l, PROGRAM, "prefs")
	check(l, strings.contains(prefs, "appearance.theme = Graphite"), "papier prefs: appearance.theme is Graphite after the reload")
	check(l, cdp.key(&c, "ctrl+,"), "Ctrl+, again")
	check(l, cdp.wait_for(&c, EDITED, SESSION_WAIT), "the history is back")

	// Enter on the entry (paste.on_select): it goes on the clipboard, the window hides, and papier presses the paste keys
	// for what has the keyboard (sway has a virtual keyboard; the toolkit's desktop tests see the keys arrive)
	check(l, cdp.key(&c, "Escape"), "Escape clears the search (\"bold\", typed above)")
	check(l, cdp.type_text(&c, "edited"), "search the edited entry")
	check(l, cdp.wait_for(&c, "hello from papier live", SESSION_WAIT, gone = true), "it alone is listed")
	check(l, cdp.wait_for(&c, EDITED, SESSION_WAIT), "it is listed")
	_ = cdp.key(&c, "Enter")   // (its release finds the window gone: what follows says whether Enter did its work)
	pasted := false
	got: string
	for _ in 0 ..< 50 {
		out, pcode := run_in(l, "wl-paste", "-n")
		got = out
		if pcode == 0 && out == EDITED { pasted = true; break }
		time.sleep(100 * time.Millisecond)
	}
	check(l, pasted, "it is on the clipboard (%q)", got[:min(len(got), 60)])
	time.sleep(300 * time.Millisecond)
	plog, _ := os.read_entire_file(fmt.tprintf("%s/papier.log", l.dir), context.temp_allocator)
	check(l, !strings.contains(string(plog), "press keys"), "papier pressed the paste keys (%s/papier.log)", l.dir)
	cdp.close(&c)

	for round in 1 ..= 3 {
		_, hcode := run_in(l, PROGRAM, "hide")
		check(l, hcode == 0, "round %d: papier hide", round)
		_, scode := run_in(l, PROGRAM, "show")
		check(l, scode == 0, "round %d: papier show", round)
		rc, rok := window_connect(l)
		check(l, rok, "round %d: the DevTools server takes a connection", round)
		if !rok { continue }
		// (a show starts from an empty search: the first entry is back)
		asked := time.tick_now()
		check(l, cdp.wait_for(&rc, "hello from papier live", SESSION_WAIT), "round %d: a frame of the window again (%.0f ms)", round, time.duration_milliseconds(time.tick_since(asked)))
		cdp.close(&rc)
	}
}

// A long Markdown entry selected: its preview is taller than the pane, and the wheel over it, then Shift+Page Down,
// move it (its heading goes up). Ends with the search empty.
@(private = "file")
live_preview :: proc(l: ^Live) {
	TOP :: "Long preview top"
	b := strings.builder_make(context.temp_allocator)
	// (a heading and a list: syntax.guess takes a text for Markdown on two of its signs, never one)
	strings.write_string(&b, "# " + TOP + "\n\n- an item of the list\n- another item\n\n")
	for i in 1 ..= 80 { fmt.sbprintf(&b, "Paragraph %d of the long preview, a line of text to make it tall.\n\n", i) }
	check(l, copy_and_wait(l, strings.to_string(b), seen = TOP), "a long Markdown text is in the history")
	_, code := run_in(l, PROGRAM, "show")
	check(l, code == 0, "papier show")
	c, ok := window_connect(l)
	check(l, ok, "the window serves the DevTools protocol")
	if !ok { return }
	defer cdp.close(&c)
	check(l, cdp.type_text(&c, "long preview"), "search the long entry")
	check(l, cdp.wait_for(&c, "hello from papier live", SESSION_WAIT, gone = true), "it alone is listed")
	width, _, _ := cdp.window_size(&c)
	// (the list takes LIST_SHARE, 0.48, of the width: the preview's text starts just past it, so half the window would
	// miss it; the list's own text starts near its left edge)
	left := width * 0.3
	at, shown := wait_preview(&c, TOP, left)
	check(l, shown, "its heading is in the preview, rendered")
	if !shown { return }
	_, wheeled := cdp.call(&c, "Input.dispatchMouseEvent", fmt.tprintf(`{{"type":"mouseWheel","x":%v,"y":%v,"deltaX":0,"deltaY":100}}`, at.x + at.w * 0.5, at.y + at.h + 120))
	check(l, wheeled, "a notch of the wheel over the preview")
	check(l, wait_preview_up(&c, TOP, left, at.y), "the preview scrolls: its heading goes up")
	now, _ := preview_of(&c, TOP, left)
	check(l, cdp.key(&c, "shift+PageDown"), "Shift+Page Down")
	check(l, wait_preview_up(&c, TOP, left, now.y), "the preview moves on by a page")
	check(l, cdp.key(&c, "Escape"), "Escape clears the search")
	check(l, cdp.wait_for(&c, "hello from papier live", SESSION_WAIT), "the history is listed again")
}

// The box of `text` in the preview: one that shows it and starts past `left` (the list may show it too).
@(private = "file")
preview_of :: proc(c: ^cdp.Client, text: string, left: f64) -> (at: cdp.Box, found: bool) {
	for b in cdp.find(c, text) { if b.x >= left { return b, true } }
	return
}

// Until the preview shows `text`, at most SESSION_WAIT.
@(private = "file")
wait_preview :: proc(c: ^cdp.Client, text: string, left: f64) -> (at: cdp.Box, ok: bool) {
	deadline := time.tick_add(time.tick_now(), SESSION_WAIT)
	for time.tick_diff(time.tick_now(), deadline) > 0 {
		if at, ok = preview_of(c, text, left); ok { return }
		time.sleep(SESSION_POLL)
	}
	return
}

// Until the preview's box of `text` is above `from`, or gone from the preview (scrolled out past its top), at most
// SESSION_WAIT.
@(private = "file")
wait_preview_up :: proc(c: ^cdp.Client, text: string, left, from: f64) -> bool {
	deadline := time.tick_add(time.tick_now(), SESSION_WAIT)
	for time.tick_diff(time.tick_now(), deadline) > 0 {
		at, found := preview_of(c, text, left)
		if !found || at.y < from - 0.5 {
			// (the scroll's glide ends first: the next move starts from where it stops)
			_, _ = cdp.wait_idle(c, SESSION_WAIT)
			return true
		}
		time.sleep(SESSION_POLL)
	}
	return false
}

// The shortcut while the window is shown but the person went to another place: the window comes to the front with the
// keyboard (it hid before); once in front, the shortcut hides it. `papier toggle` starts as a compositor's binding starts
// it (swaymsg exec), with a launch's activation token, which papier hands to the running one.
@(private = "file")
live_toggle :: proc(l: ^Live) {
	_, code := run_in(l, PROGRAM, "show")
	check(l, code == 0, "papier show")
	check(l, wait_papier_window(l, mapped = true, focused = true), "the window is shown, with the keyboard")
	_, wcode := run_in(l, "swaymsg", "workspace", "elsewhere")
	check(l, wcode == 0 && wait_papier_window(l, mapped = true, focused = false), "another workspace takes the keyboard, the window stays")
	check(l, sway_toggle(l), "the shortcut (papier toggle, started by sway)")
	check(l, wait_papier_window(l, mapped = true, focused = true), "the window comes to the front with the keyboard, not hidden")
	check(l, sway_toggle(l), "the shortcut again")
	check(l, wait_papier_window(l, mapped = false, focused = false), "the window had the keyboard: it hides")
}

// `papier toggle` started by sway, which gives it an activation token. Its homes are the session's, not the person's.
@(private = "file")
sway_toggle :: proc(l: ^Live) -> bool {
	cwd, _ := os.get_working_directory(context.temp_allocator)
	command := fmt.tprintf("exec env XDG_CONFIG_HOME=%s/config XDG_DATA_HOME=%s/data XDG_STATE_HOME=%s/state %s/%s toggle", l.dir, l.dir, l.dir, cwd, PROGRAM)
	_, code := run_in(l, "swaymsg", command)
	return code == 0
}

// Until sway's tree has papier's window (`mapped`) with the keyboard or not (`focused`), at most SESSION_WAIT.
@(private = "file")
wait_papier_window :: proc(l: ^Live, mapped, focused: bool) -> bool {
	deadline := time.tick_add(time.tick_now(), SESSION_WAIT)
	for time.tick_diff(time.tick_now(), deadline) > 0 {
		m, f := papier_window(l)
		if m == mapped && (!mapped || f == focused) { return true }
		time.sleep(SESSION_POLL)
	}
	return false
}

// Whether sway's tree has papier's window (on any workspace), and whether it has the keyboard.
@(private = "file")
papier_window :: proc(l: ^Live) -> (mapped, focused: bool) {
	out, code := run_in(l, "swaymsg", "-r", "-t", "get_tree")
	if code != 0 { return }
	tree, err := json.parse_string(out, allocator = context.temp_allocator)
	if err != nil { return }
	sway_walk(tree, &mapped, &focused)
	return
}

@(private = "file")
sway_walk :: proc(v: json.Value, mapped, focused: ^bool) {
	node, ok := v.(json.Object)
	if !ok { return }
	if id, is := node["app_id"].(json.String); is && id == "papier" {
		mapped^ = true
		if f, fb := node["focused"].(json.Boolean); fb && f { focused^ = true }
	}
	for key in ([]string{"nodes", "floating_nodes"}) {
		if kids, is := node[key].(json.Array); is { for kid in kids { sway_walk(kid, mapped, focused) } }
	}
}
