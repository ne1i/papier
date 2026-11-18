package papier

// What the window remembers from one run to the next that the toolkit does not: the list's width and its fold. (Its
// place, its size and whether it is maximized are the toolkit's window.placement, app.odin.) Lines of text in the
// user's state folder (state_path), written by the reader when the window hides, when papier quits and when the fold or
// the width changes (state_write). It is read at start, before the window exists.

import "core:fmt"
import "core:strconv"
import "core:strings"
import "gt:fsx"
import "gt:ui"

Window_State :: struct {
	side: ui.Side_Panel,   // the list: its width open (logical pixels; 0: a share of the window) and its fold
}

// The state in `text` ("split w", "fold <words>"; unknown lines skipped: an older papier's "size" and "place" among
// them).
state_parse :: proc(text: string) -> (s: Window_State) {
	rest := text
	for line in strings.split_lines_iterator(&rest) {
		f := strings.fields(line, context.temp_allocator)
		if len(f) == 0 { continue }
		switch f[0] {
		case "split":
			if len(f) == 2 {
				if v, ok := strconv.parse_f32(f[1]); ok && v > 0 { s.side.width = v }
			}
		case "fold":
			if fold, ok := ui.side_fold_parse(strings.join(f[1:], " ", context.temp_allocator)); ok { s.side.fold = fold }
		}
	}
	return
}

state_format :: proc(s: Window_State, allocator := context.temp_allocator) -> string {
	b := strings.builder_make(allocator)
	if s.side.width > 0 { fmt.sbprintf(&b, "split %.0f\n", s.side.width) }
	// (the zero fold, wide and open, is no memory: no line)
	if fold := ui.side_fold_format(s.side.fold); fold != "" { fmt.sbprintf(&b, "fold %s\n", fold) }
	return strings.to_string(b)
}

state_load :: proc() -> Window_State {
	data, ok := fsx.read_all(state_path(), context.temp_allocator)
	return ok ? state_parse(string(data)) : {}
}

// The state, written by the reader's thread (its folder made when it is not there).
state_write :: proc(app: ^App) {
	reader_job(&app.reader, {kind = .Write, path = state_path(), data = transmute([]u8)state_format(app.remembered)})
}
