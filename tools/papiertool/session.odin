#+build linux
package papiertool

// A session nobody sees, for `live` and `shots`: the toolkit's program session (toolbox.Program_Session: its own sway
// with no screen, no session bus, so no tray icon in the person's panel; the DevTools server on a port the system has
// free), and papier started in it, hidden, with its own history, preferences and state. wl-clipboard's commands and
// papier's own run in it (run_in, wl_copy); `papier quit` ends it.

import "core:os"
import "core:strings"
import "core:time"
import toolbox "gt:toolbox"

SESSION_WAIT   :: 8 * time.Second
SESSION_POLL   :: 50 * time.Millisecond
// (papier floats at a size of its own, as a popup over the desktop would: the pictures have its real proportions)
// (a window asked to the front with a launch's token gets the keyboard: sway's default only marks it urgent)
SWAY_CONFIG    :: "for_window [app_id=\"papier\"] floating enable, resize set 1100 680\nfocus_on_window_activation focus\n"
// The preferences file under the session's folder: config's user layer.
PREFS_FILE     :: "config/FromentSoftware/Papier/prefs"

// Starts sway and papier in `dir` (made anew), then waits until papier answers (--status: it runs hidden, with no
// window to connect to). `prefs`: lines of papier's preferences file. `why` says what failed; program_session_stop
// still cleans up.
session_start :: proc(s: ^toolbox.Program_Session, dir: string, prefs: []string = nil) -> (why: string) {
	files: [1]toolbox.Program_File
	n := 0
	if len(prefs) > 0 {
		// (its first line, then name<TAB>value)
		b := strings.builder_make(context.temp_allocator)
		strings.write_string(&b, "wbprefs 1\n")
		for p in prefs { strings.write_string(&b, p); strings.write_byte(&b, '\n') }
		files[0] = {path = PREFS_FILE, text = strings.to_string(b)}
		n = 1
	}
	// (the log is the default, <dir>/papier.log)
	o := toolbox.Program_Options{command = {PROGRAM, "--hidden"}, desktop = {config = SWAY_CONFIG, homes = true}, files = files[:n], quit = {PROGRAM, "quit"}}
	if why = toolbox.program_session_start(s, dir, o); why != "" { return }
	deadline := time.tick_add(time.tick_now(), SESSION_WAIT)
	for time.tick_diff(time.tick_now(), deadline) > 0 {
		if out, _ := run_in(s, PROGRAM, "--status"); strings.contains(out, "running: true") { return "" }
		time.sleep(SESSION_POLL)
	}
	return "papier does not answer"
}

// A command of the session, its standard output kept.
run_in :: proc(s: ^toolbox.Program_Session, command: ..string) -> (out: string, code: int) {
	return toolbox.capture(command, {env = s.env})
}

// wl-copy of `text` (or of the file `file`) as `mime` ("": text). wl-copy leaves a process of its own that serves the
// selection: this one waits only for the one it starts, whose output goes nowhere.
wl_copy :: proc(s: ^toolbox.Program_Session, text: string, mime := "", file := "") -> bool {
	cmd := make([dynamic]string, context.temp_allocator)
	append(&cmd, "wl-copy")
	if mime != "" { append(&cmd, "-t", mime) }
	stdin: ^os.File
	if file != "" {
		f, err := os.open(file)
		if err != nil { return false }
		stdin = f
	} else {
		append(&cmd, text)
	}
	defer if stdin != nil { os.close(stdin) }
	p, err := os.process_start({command = cmd[:], env = s.env, stdin = stdin})
	if err != nil { return false }
	state, werr := os.process_wait(p, SESSION_WAIT)
	return werr == nil && state.exited && state.exit_code == 0
}

// `papier list` until `done` says yes, at most SESSION_WAIT.
wait_list :: proc(s: ^toolbox.Program_Session, done: proc(list: string, data: rawptr) -> bool, data: rawptr) -> (list: string, ok: bool) {
	deadline := time.tick_add(time.tick_now(), SESSION_WAIT)
	for time.tick_diff(time.tick_now(), deadline) > 0 {
		out, code := run_in(s, PROGRAM, "list", "100")
		if code == 0 && done(out, data) { return out, true }
		time.sleep(SESSION_POLL)
	}
	out, _ := run_in(s, PROGRAM, "list", "100")
	return out, false
}

lists :: proc(list: string, data: rawptr) -> bool { return strings.contains(list, (^string)(data)^) }

// Copies `text` and waits until the history has it.
copy_and_wait :: proc(s: ^toolbox.Program_Session, text: string, mime := "", file := "", seen := "") -> bool {
	if !wl_copy(s, text, mime, file) { return false }
	want := seen != "" ? seen : text
	_, ok := wait_list(s, lists, &want)
	return ok
}
