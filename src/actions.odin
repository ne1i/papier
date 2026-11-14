package papier

// What the user can do in the window, named once: each action's label, group, keys and icon (gui_toolkit's commands). The
// same table gives the keys, the entry menu's shortcuts, the tooltips, the command palette (Ctrl+K) and the sheet of the
// keys (F1). The moves of the selection (the arrows, Page Up/Down, Ctrl+Home/End, Alt+1…9) and Escape stay in view_keys:
// they are the list's, not commands.
//
// An action on entries acts on the marked rows (a Ctrl or Shift click, Ctrl+Shift+A), or on the selected one when none is
// marked.

import "base:runtime"
import "core:mem/virtual"
import "core:slice"
import "core:strings"
import prefs_page "gt:prefs_page"
import i18n "gt:i18n"
import "gt:ui"
import lucide "gt:lucide"
import "history"

Action :: enum u8 {
	Copy, Copy_Plain, Edit, Open, Save_As, Pin, Remove, Show_QR, Copy_Qr_Content, Copy_Image_Text, Toggle_Markdown_Source,
	Mark_All, Clear_Marks,
	Filter_All, Filter_Text, Filter_Images, Filter_Files, Filter_Pinned, Filter_Next, Filter_Previous,
	Clear_History, Settings, Check_Updates, Palette, Shortcuts, Hide, Restart, Quit,
}

ACTIONS := [Action]ui.Command{
	.Copy            = {label = i18n.later("Copy"), group = i18n.later("Entry"), keys = {{.Return, {}}}, icon = lucide.COPY, tags = {"paste", "clipboard"}},
	.Copy_Plain      = {label = i18n.later("Copy as plain text"), group = i18n.later("Entry"), icon = lucide.TYPE, tags = {"text", "unformatted"}},
	.Edit            = {label = i18n.later("Edit…"), group = i18n.later("Entry"), keys = {{.E, {.Ctrl}}}, icon = lucide.EDIT, tags = {"change", "modify"}},
	.Open            = {label = i18n.later("Open"), group = i18n.later("Entry"), keys = {{.O, {.Ctrl}}}, icon = lucide.EXTERNAL_LINK, tags = {"launch", "browser"}},
	.Save_As         = {label = i18n.later("Save as…"), group = i18n.later("Entry"), keys = {{.S, {.Ctrl}}}, icon = lucide.SAVE, tags = {"export", "file", "write"}},
	.Pin             = {label = i18n.later("Pin or unpin"), group = i18n.later("Entry"), keys = {{.P, {.Ctrl}}}, icon = lucide.PIN, tags = {"favourite", "keep", "star"}},
	.Remove          = {label = i18n.later("Remove"), group = i18n.later("Entry"), keys = {{.Delete, {.Shift}}}, icon = lucide.TRASH_2, tags = {"delete", "erase", "forget"}},
	.Show_QR         = {label = i18n.later("Show as a QR code"), group = i18n.later("Entry"), keys = {{.Q, {.Ctrl, .Shift}}}, icon = lucide.QR_CODE, tags = {"phone", "scan", "share"}},
	.Copy_Qr_Content = {label = i18n.later("Copy the QR code's content"), group = i18n.later("Entry"), icon = lucide.QR_CODE, tags = {"scan", "read", "link"}},
	.Toggle_Markdown_Source = {label = i18n.later("Show the Markdown source or rendered"), group = i18n.later("Entry"), keys = {{.M, {.Ctrl, .Shift}}}, icon = lucide.FILE_CODE, tags = {"markdown", "source", "raw", "render"}},
	.Copy_Image_Text = {label = i18n.later("Copy the text of the image"), group = i18n.later("Entry"), keys = {{.T, {.Ctrl, .Shift}}}, icon = lucide.FILE_TEXT, tags = {"ocr", "recognize", "read", "screenshot", "scan"}},
	.Mark_All        = {label = i18n.later("Mark every entry shown"), group = i18n.later("Selection"), keys = {{.A, {.Ctrl, .Shift}}}, icon = lucide.LIST_CHECKS, tags = {"select all", "selection"}},
	.Clear_Marks     = {label = i18n.later("Clear the marks"), group = i18n.later("Selection"), icon = lucide.X},
	.Filter_All      = {label = i18n.later("Show every entry"), group = i18n.later("Filter"), icon = lucide.LIST},
	.Filter_Text     = {label = i18n.later("Show text"), group = i18n.later("Filter"), icon = lucide.ALIGN_LEFT},
	.Filter_Images   = {label = i18n.later("Show images"), group = i18n.later("Filter"), icon = lucide.IMAGE},
	.Filter_Files    = {label = i18n.later("Show files"), group = i18n.later("Filter"), icon = lucide.FILES},
	.Filter_Pinned   = {label = i18n.later("Show pinned entries"), group = i18n.later("Filter"), icon = lucide.PIN},
	.Filter_Next     = {label = i18n.later("Next filter"), group = i18n.later("Filter"), keys = {{.Tab, {}}}, icon = lucide.FILTER},
	.Filter_Previous = {label = i18n.later("Previous filter"), group = i18n.later("Filter"), keys = {{.Tab, {.Shift}}}, icon = lucide.FILTER},
	.Clear_History   = {label = i18n.later("Clear the history (pinned entries stay)"), group = i18n.later("papier"), icon = lucide.TRASH_2, tags = {"wipe", "erase", "empty"}},
	.Settings        = {label = i18n.later("Settings"), group = i18n.later("papier"), keys = {{.Comma, {.Ctrl}}}, icon = lucide.SETTINGS, tags = {"preferences", "options", "configure"}},
	.Check_Updates   = {label = i18n.later("Check for updates"), group = i18n.later("papier"), icon = lucide.REFRESH_CW, tags = {"upgrade", "version", "new"}},
	.Palette         = {label = i18n.later("Command palette"), group = i18n.later("papier"), keys = {{.K, {.Ctrl}}, {.P, {.Ctrl, .Shift}}}, icon = lucide.COMMAND},
	.Shortcuts       = {label = i18n.later("Keyboard shortcuts"), group = i18n.later("papier"), keys = {{.F1, {}}}, icon = lucide.KEYBOARD, tags = {"help", "keys", "hotkeys"}},
	.Hide            = {label = i18n.later("Hide the window"), group = i18n.later("papier"), icon = lucide.X, tags = {"close", "dismiss"}},
	.Restart         = {label = i18n.later("Restart papier"), group = i18n.later("papier"), icon = lucide.ROTATE_CCW, tags = {"reload", "relaunch"}},
	.Quit            = {label = i18n.later("Quit papier"), group = i18n.later("papier"), keys = {{.Q, {.Ctrl}}}, icon = lucide.POWER, tags = {"exit", "close", "stop"}},
}

// The entries an action acts on: the marked ones in the list's order, else the selected one (temp memory). Run when an
// action runs, not at each build: it goes over the marks.
acted_on :: proc(app: ^App) -> []^history.Entry {
	out := make([dynamic]^history.Entry, context.temp_allocator)
	if ui.list_mark_count(&app.vl) > 0 {
		at := make([dynamic]int, context.temp_allocator)
		for id in app.vl.marks { if i, ok := app.list.at[id]; ok { append(&at, i) } }
		slice.sort(at[:])   // (the list's order is its entries' order)
		for i in at { append(&out, &app.list.entries[i]) }
	} else if e := selected(app); e != nil {
		append(&out, e)
	}
	return out[:]
}

// How many entries an action acts on, and the one when it is one: what action_enabled needs, at each build, without a
// pass over the marks.
@(private = "file")
acted_count :: proc(app: ^App) -> (n: int, one: ^history.Entry) {
	switch ui.list_mark_count(&app.vl) {
	case 0:
		one = selected(app)
		return one != nil ? 1 : 0, one
	case 1:
		for id in app.vl.marks { one = list_entry(app, id) }
		return one != nil ? 1 : 0, one
	}
	return ui.list_mark_count(&app.vl), nil
}

// Whether `a` can act now.
action_enabled :: proc(app: ^App, a: Action) -> bool {
	n, one := acted_count(app)
	switch a {
	// (several: their texts joined by the reader; none of them a text says so then)
	case .Copy:          return n >= 1
	case .Copy_Plain:    return one != nil && one.kind == .Html && history.rep_find(one^, TEXT_MIME) >= 0
	case .Edit:          return one != nil && (one.kind == .Text || one.kind == .Html)
	case .Open:          return one != nil
	case .Save_As:       return one != nil && one.kind != .Files
	case .Pin:           return PINS && n > 0
	case .Remove:        return n > 0
	case .Show_QR:       return one != nil && qr_text(app, one) != ""
	case .Copy_Qr_Content: return one != nil && image_qr(app, one) != ""
	case .Toggle_Markdown_Source: return one != nil && loaded_for(app, one) && app.loaded.form == .Markdown
	// (one reading at a time: a second ask while one runs is not taken)
	case .Copy_Image_Text: return one != nil && one.kind == .Image && image_rep(one) >= 0 && ocr_offered(app) && app.ocr_reading == 0
	case .Mark_All:      return len(app.shown) > 0
	case .Clear_Marks:   return ui.list_mark_count(&app.vl) > 0
	case .Filter_Pinned: return PINS
	case .Clear_History: return len(app.list.entries) > 0
	case .Filter_All, .Filter_Text, .Filter_Images, .Filter_Files, .Filter_Next, .Filter_Previous,
	     .Settings, .Check_Updates, .Palette, .Shortcuts, .Hide, .Restart, .Quit:
		return true
	}
	return false
}

action_run :: proc(app: ^App, a: Action) {
	if !action_enabled(app, a) { return }
	on := acted_on(app)
	switch a {
	case .Copy:
		if len(on) == 1 { entry_copy(app, on[0].id); break }
		if len(on) == 0 { break }
		// (several: their texts as one new entry, a line between two; the reader reads them, app_job_done copies them)
		ids := make([]u64, len(on), context.temp_allocator)
		for e, i in on { ids[i] = e.id }
		reader_job(&app.reader, {kind = .Join, ids = ids})
		ui.list_marks_clear(&app.vl)
	case .Copy_Plain: entry_copy(app, on[0].id, plain = true)
	case .Edit:       edit_begin(app, on[0])
	case .Open:       entry_open(app, on[0])
	case .Save_As:    entry_save_as(app, on[0])
	case .Pin:
		// (one pin for all: pinned if one of them is not)
		pin := false
		for e in on { if !e.pinned { pin = true } }
		for e in on { if e.pinned != pin { toggle_pin(app, e) } }
	case .Remove:
		ids := make([]u64, len(on), context.temp_allocator)
		for e, i in on { ids[i] = e.id }
		for id in ids { remove_entry(app, id) }
		ui.list_marks_clear(&app.vl)
		if len(ids) > 1 { announce(app, i18n.tr(len(ids), "Removed %d entry", "Removed %d entries"), len(ids)) }
	case .Show_QR:       qr_open(app, on[0])
	case .Toggle_Markdown_Source: app.markdown_source = !app.markdown_source
	case .Copy_Qr_Content: copy_new_text(app, image_qr(app, on[0]), i18n.tr("Copied the QR code's content"), chosen = false)
	case .Copy_Image_Text:
		e := on[0]
		at := image_rep(e)
		slow_ocr(&app.slow, e.id, app.list.dir, e.reps[at].hash, e.reps[at].mime)
		app.ocr_reading = e.id   // (app_ocr_follow ends it)
	case .Mark_All:      ui.list_mark_all(&app.vl)
	case .Clear_Marks:   ui.list_marks_clear(&app.vl)
	case .Filter_All:    set_filter(app, .All)
	case .Filter_Text:   set_filter(app, .Text)
	case .Filter_Images: set_filter(app, .Images)
	case .Filter_Files:  set_filter(app, .Files)
	case .Filter_Pinned: set_filter(app, .Pinned)
	case .Filter_Next:     set_filter(app, Filter((int(app.filter) + 1) % FILTER_COUNT))
	case .Filter_Previous: set_filter(app, Filter((int(app.filter) + FILTER_COUNT - 1) % FILTER_COUNT))
	case .Clear_History: watcher_send(&app.watcher, {verb = .Clear})
	case .Settings:      settings_toggle(app)
	case .Check_Updates: update_check_asked(app)
	case .Palette:       palette_show(app)
	case .Shortcuts:     ui.shortcuts_sheet_open(&app.sheet, slice.enumerated_array(&ACTIONS), i18n.tr("papier's keys"))
	case .Hide:          app_hide(app)
	case .Restart:       app_restart(app, hidden = false)
	case .Quit:          app.quit = true
	}
}

// The keys of the actions, when nothing else has the keyboard.
actions_keys :: proc(app: ^App) {
	for a in Action {
		if ui.command_pressed(ACTIONS[a], !action_enabled(app, a)) { action_run(app, a); return }
	}
}

// The palette's table: the actions, then every setting (one chosen opens the settings on it alone), then the moves of
// each open view (float it, dock it, put it in a window of its own, re-attach it, close it). Made when the preferences,
// the language or the views change, not at each frame: the titles are translated when it is made.
Palette_Table :: struct {
	arena:    virtual.Arena,
	commands: []ui.Command,
	names:    []string,             // the setting each command after the actions names
	acts:     []ui.View_Command,    // what each command after the settings does (its strings in the arena)
	prefs:    u64,                  // the preferences' version it was made for (0: not made)
	language: u32,                  // i18n.version() it was made in: a change of language makes it again
	views:    u64,                  // ui.views_version it was made for
	version:  u64,                  // bumped at each making (Palette_Options.version)
}

palette_table_destroy :: proc(t: ^Palette_Table) {
	virtual.arena_destroy(&t.arena)
	t^ = {}
}

// Made again when what it lists changed; true when it was.
@(private = "file")
palette_table_keep :: proc(app: ^App) -> bool {
	t := &app.palette_table
	views := ui.views_version(&app.views)
	if t.prefs == app.prefs.version + 1 && t.language == i18n.version() && t.views == views { return false }
	virtual.arena_free_all(&t.arena)
	a := virtual.arena_allocator(&t.arena)
	settings, names := prefs_page.palette_commands(&app.prefs, settings_options(app), a)
	moves, acts := palette_view_moves(app, a)
	t.commands = slice.concatenate([][]ui.Command{slice.enumerated_array(&ACTIONS), settings, moves}, a)
	t.names, t.acts = names, acts
	t.prefs, t.language, t.views = app.prefs.version + 1, i18n.version(), views
	t.version += 1
	return true
}

// The views' commands, but the palette's own (it is open while they are listed: moving it from itself is no help).
// Their ids are copied: a view's strings go when it closes.
@(private = "file")
palette_view_moves :: proc(app: ^App, a: runtime.Allocator) -> (commands: []ui.Command, acts: []ui.View_Command) {
	all, all_acts := ui.views_commands(&app.views, a)
	out := make([dynamic]ui.Command, 0, len(all), a)
	out_acts := make([dynamic]ui.View_Command, 0, len(all), a)
	for c, i in all {
		act := all_acts[i]
		if act.id == ui.PALETTE_VIEW { continue }
		act.id, act.instance = strings.clone(act.id, a), strings.clone(act.instance, a)
		append(&out, c)
		append(&out_acts, act)
	}
	return out[:], out_acts[:]
}

// What the palette lists, given to it; which actions can act now is read here (nothing else changes them while the
// palette has the keyboard).
@(private = "file")
palette_give :: proc(app: ^App) {
	t := &app.palette_table
	disabled := make([]bool, len(t.commands), context.temp_allocator)
	for a in Action { disabled[int(a)] = !action_enabled(app, a) }
	ui.palette_set(&app.palette, t.commands, disabled, {version = t.version})
}

// Ctrl+K: the palette, on what can act now.
@(private = "file")
palette_show :: proc(app: ^App) {
	palette_table_keep(app)
	palette_give(app)
	ui.palette_open(&app.palette)
}

// The palette's choice, and its table kept while it is open (in the window's build).
actions_build :: proc(app: ^App) {
	t := &app.palette_table
	// (the choice is an index in the table it was made from: taken before the table is made again)
	if i, _, ok := ui.palette_chosen(&app.palette); ok && i < len(t.commands) {
		settings_end := len(Action) + len(t.names)
		switch {
		case i < len(Action):   action_run(app, Action(i))
		case i < settings_end:  settings_show(app, t.names[i - len(Action)])
		case:                   ui.views_command_run(&app.views, t.acts[i - settings_end])
		}
	}
	if ui.palette_is_open(&app.palette) && palette_table_keep(app) { palette_give(app) }
}

// A tooltip: the action's label and its key.
action_tip :: proc(a: Action) -> string { return ui.command_tip(ACTIONS[a]) }

