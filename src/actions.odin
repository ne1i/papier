package papier

// What the user can do in the window, named once: each action's label, group, keys and icon (gui_toolkit's commands). The
// same table gives the keys, the entry menu's shortcuts, the tooltips, the toolkit's command palette (Ctrl+K, its own
// command) and the sheet of the keys (F1). The moves of the selection (the arrows, Page Up/Down, Ctrl+Home/End, Alt+1…9) and Escape stay in view_keys:
// they are the list's, not commands.
//
// An action on entries acts on the rows selected (the toolkit's selection: Ctrl, Shift and Ctrl+Shift clicks, Shift and
// the moves, Ctrl+Space, Ctrl+Shift+A), or on the cursor's row when none is. What shows one entry (the preview, Edit,
// Open, Save as, the QR code) is the cursor's.

import "core:slice"
import prefs_page "gt:prefs_page"
import i18n "gt:i18n"
import "gt:ui"
import lucide "gt:lucide"
import "history"

Action :: enum u8 {
	Copy, Copy_Plain, Edit, Open, Save_As, Pin, Remove, Show_QR, Copy_Qr_Content, Copy_Image_Text, Toggle_Markdown_Source,
	Select_All, Select_One,
	Filter_All, Filter_Text, Filter_Images, Filter_Files, Filter_Pinned, Filter_Next, Filter_Previous,
	Clear_History, Settings, Check_Updates, Shortcuts, Hide, Restart, Quit,
}

ACTIONS := [Action]ui.Command{
	.Copy            = {id = "copy", label = i18n.later("Copy"), group = i18n.later("Entry"), keys = {{.Return, {}}}, icon = lucide.COPY, tags = {"paste", "clipboard"}},
	.Copy_Plain      = {id = "copy_plain", label = i18n.later("Copy as plain text"), group = i18n.later("Entry"), icon = lucide.TYPE, tags = {"text", "unformatted"}},
	.Edit            = {id = "edit", label = i18n.later("Edit…"), group = i18n.later("Entry"), keys = {{.E, {.Ctrl}}}, icon = lucide.EDIT, tags = {"change", "modify"}},
	.Open            = {id = "open", label = i18n.later("Open"), group = i18n.later("Entry"), keys = {{.O, {.Ctrl}}}, icon = lucide.EXTERNAL_LINK, tags = {"launch", "browser"}},
	.Save_As         = {id = "save_as", label = i18n.later("Save as…"), group = i18n.later("Entry"), keys = {{.S, {.Ctrl}}}, icon = lucide.SAVE, tags = {"export", "file", "write"}},
	.Pin             = {id = "pin", label = i18n.later("Pin or unpin"), group = i18n.later("Entry"), keys = {{.P, {.Ctrl}}}, icon = lucide.PIN, tags = {"favourite", "keep", "star"}},
	.Remove          = {id = "remove", label = i18n.later("Remove"), group = i18n.later("Entry"), keys = {{.Delete, {.Shift}}}, icon = lucide.TRASH_2, tags = {"delete", "erase", "forget"}},
	.Show_QR         = {id = "show_qr", label = i18n.later("Show as a QR code"), group = i18n.later("Entry"), keys = {{.Q, {.Ctrl, .Shift}}}, icon = lucide.QR_CODE, tags = {"phone", "scan", "share"}},
	.Copy_Qr_Content = {id = "copy_qr_content", label = i18n.later("Copy the QR code's content"), group = i18n.later("Entry"), icon = lucide.QR_CODE, tags = {"scan", "read", "link"}},
	.Toggle_Markdown_Source = {id = "toggle_markdown_source", label = i18n.later("Show the Markdown source or rendered"), group = i18n.later("Entry"), keys = {{.M, {.Ctrl, .Shift}}}, icon = lucide.FILE_CODE, tags = {"markdown", "source", "raw", "render"}},
	.Copy_Image_Text = {id = "copy_image_text", label = i18n.later("Copy the text of the image"), group = i18n.later("Entry"), keys = {{.T, {.Ctrl, .Shift}}}, icon = lucide.FILE_TEXT, tags = {"ocr", "recognize", "read", "screenshot", "scan"}},
	.Select_All      = {id = "select_all", label = i18n.later("Select every entry shown"), group = i18n.later("Selection"), keys = {{.A, {.Ctrl, .Shift}}}, icon = lucide.LIST_CHECKS, tags = {"select all", "selection", "mark"}},
	.Select_One      = {id = "select_one", label = i18n.later("Keep the cursor's entry alone selected"), group = i18n.later("Selection"), icon = lucide.X, tags = {"clear", "selection", "unmark"}},
	.Filter_All      = {id = "filter_all", label = i18n.later("Show every entry"), group = i18n.later("Filter"), icon = lucide.LIST},
	.Filter_Text     = {id = "filter_text", label = i18n.later("Show text"), group = i18n.later("Filter"), icon = lucide.ALIGN_LEFT},
	.Filter_Images   = {id = "filter_images", label = i18n.later("Show images"), group = i18n.later("Filter"), icon = lucide.IMAGE},
	.Filter_Files    = {id = "filter_files", label = i18n.later("Show files"), group = i18n.later("Filter"), icon = lucide.FILES},
	.Filter_Pinned   = {id = "filter_pinned", label = i18n.later("Show pinned entries"), group = i18n.later("Filter"), icon = lucide.PIN},
	.Filter_Next     = {id = "filter_next", label = i18n.later("Next filter"), group = i18n.later("Filter"), keys = {{.Tab, {}}}, icon = lucide.FILTER},
	.Filter_Previous = {id = "filter_previous", label = i18n.later("Previous filter"), group = i18n.later("Filter"), keys = {{.Tab, {.Shift}}}, icon = lucide.FILTER},
	.Clear_History   = {id = "clear_history", label = i18n.later("Clear the history (pinned entries stay)"), group = i18n.later("Papier"), icon = lucide.TRASH_2, tags = {"wipe", "erase", "empty"}},
	.Settings        = {id = "settings", label = i18n.later("Settings"), group = i18n.later("Papier"), keys = {{.Comma, {.Ctrl}}}, icon = lucide.SETTINGS, tags = {"preferences", "options", "configure"}, scope = .Window},
	.Check_Updates   = {id = "check_updates", label = i18n.later("Check for updates"), group = i18n.later("Papier"), icon = lucide.REFRESH_CW, tags = {"upgrade", "version", "new"}},
	.Shortcuts       = {id = "shortcuts", label = i18n.later("Keyboard shortcuts"), group = i18n.later("Papier"), keys = {{.F1, {}}}, icon = lucide.KEYBOARD, tags = {"help", "keys", "hotkeys"}, scope = .Window},
	.Hide            = {id = "hide", label = i18n.later("Hide the window"), group = i18n.later("Papier"), icon = lucide.X, tags = {"close", "dismiss"}, scope = .Window},
	.Restart         = {id = "restart", label = i18n.later("Restart Papier"), group = i18n.later("Papier"), icon = lucide.ROTATE_CCW, tags = {"reload", "relaunch"}},
	.Quit            = {id = "quit", label = i18n.later("Quit Papier"), group = i18n.later("Papier"), keys = {{.Q, {.Ctrl}}}, icon = lucide.POWER, tags = {"exit", "close", "stop"}, scope = .Window},
}

// The entries an action acts on: those selected in the list's order, else the cursor's (temp memory). Run when an
// action runs, not at each build: it goes over the selection.
acted_on :: proc(app: ^App) -> []^history.Entry {
	out := make([dynamic]^history.Entry, context.temp_allocator)
	if len(app.vl.selected) > 0 {
		at := make([dynamic]int, context.temp_allocator)
		for id in app.vl.selected { if i, ok := app.list.at[id]; ok { append(&at, i) } }
		slice.sort(at[:])   // (the list's order is its entries' order)
		for i in at { append(&out, &app.list.entries[i]) }
	}
	if len(out) == 0 {
		if e := selected(app); e != nil { append(&out, e) }
	}
	return out[:]
}

// How many entries Copy, Pin and Remove act on: what action_enabled needs, at each build, without a pass over the
// selection.
@(private = "file")
acted_count :: proc(app: ^App) -> int {
	if n := len(app.vl.selected); n > 0 { return n }
	return selected(app) != nil ? 1 : 0
}

// Whether `a` can act now. Copy, Pin and Remove act on the entries selected; the others on the cursor's entry (`one`),
// the one the preview shows.
action_enabled :: proc(app: ^App, a: Action) -> bool {
	n, one := acted_count(app), selected(app)
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
	case .Select_All:    return len(app.shown) > 0
	case .Select_One:    return len(app.vl.selected) > 1
	case .Filter_Pinned: return PINS
	case .Clear_History: return len(app.list.entries) > 0
	case .Filter_All, .Filter_Text, .Filter_Images, .Filter_Files, .Filter_Next, .Filter_Previous,
	     .Settings, .Check_Updates, .Shortcuts, .Hide, .Restart, .Quit:
		return true
	}
	return false
}

action_run :: proc(app: ^App, a: Action) {
	if !action_enabled(app, a) { return }
	on := acted_on(app)
	cur := selected(app)   // (the cursor's: what the preview shows)
	switch a {
	case .Copy:
		if len(on) == 1 { entry_copy(app, on[0].id); break }
		if len(on) == 0 { break }
		// (several: their texts as one new entry, a line between two, in the list's order; the reader reads them,
		// app_job_done copies them; the cursor's row then alone selected, as after any copy)
		ids := make([]u64, len(on), context.temp_allocator)
		for e, i in on { ids[i] = e.id }
		reader_job(&app.reader, {kind = .Join, ids = ids})
		select_row(app, app.vl.sel)
	case .Copy_Plain: entry_copy(app, cur.id, plain = true)
	case .Edit:       edit_begin(app, cur)
	case .Open:       entry_open(app, cur)
	case .Save_As:    entry_save_as(app, cur)
	case .Pin:
		// (one pin for all: pinned if one of them is not)
		pin := false
		for e in on { if !e.pinned { pin = true } }
		for e in on { if e.pinned != pin { toggle_pin(app, e) } }
	case .Remove:
		ids := make([]u64, len(on), context.temp_allocator)
		for e, i in on { ids[i] = e.id }
		for id in ids { remove_entry(app, id) }
		// (the row that takes the cursor's place, alone selected)
		select_row(app, app.vl.sel)
		if len(ids) > 1 { announce(app, i18n.tr(len(ids), "Removed %d entry", "Removed %d entries"), len(ids)) }
	case .Show_QR:       qr_open(app, cur)
	case .Toggle_Markdown_Source: app.markdown_source = !app.markdown_source
	case .Copy_Qr_Content: copy_new_text(app, image_qr(app, cur), i18n.tr("Copied the QR code's content"), chosen = false)
	case .Copy_Image_Text:
		e := cur
		at := image_rep(e)
		slow_ocr(&app.slow, e.id, app.list.dir, e.reps[at].hash, e.reps[at].mime)
		app.ocr_reading = e.id   // (app_ocr_follow ends it)
	case .Select_All:    ui.item_selection_all(&app.vl.selection, list_rows_now(app))
	case .Select_One:    select_row(app, app.vl.sel)
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
	// (the sheet adds the toolkit's palette command itself)
	case .Shortcuts:     ui.shortcuts_sheet_open(&app.sheet, slice.enumerated_array(&ACTIONS), i18n.tr("Papier's keys"))
	case .Hide:          app_hide(app)
	case .Restart:       app_restart(app, hidden = false)
	case .Quit:          app.quit = true
	}
}

// The keys of the window's actions (scope .Window): in every page and mode, before anything else reads a key. The
// palette's first: its keys are the toolkit's, read by its own reader.
window_keys :: proc(app: ^App) {
	if palette_keys(app) { return }
	for a in Action {
		if ACTIONS[a].scope != .Window { continue }
		if ui.command_pressed(ACTIONS[a], !action_enabled(app, a)) { action_run(app, a); return }
	}
}

// The keys of the history's actions, when nothing else has the keyboard (window_keys read the window's).
actions_keys :: proc(app: ^App) {
	for a in Action {
		if ACTIONS[a].scope == .Window { continue }
		if ui.command_pressed(ACTIONS[a], !action_enabled(app, a)) { action_run(app, a); return }
	}
}

// The palette is the toolkit's (gui_toolkit's src/md/features/palette.md): its commands source lists the actions, and
// beside them the views' moves; prefs_page's settings source lists the settings (`:`). Papier fills no other prefix:
// its history is the window itself, searched in its title bar. The toolkit runs the choices of its own sources.
Palette_State :: struct {
	disabled: [Action]bool,   // the actions that cannot act, as the commands source last took them
	version:  u64,            // moves with `made_for`: the source compares it, never the table
	made_for: Can_Act_Key,    // what `disabled` was read for ({}: never)
	settings: prefs_page.Palette_Settings,
}

// What action_enabled reads, by versions and ids: the selection and its active row (the toolkit's version), the rows
// shown (ids_version: papier's own moves of the cursor go with it), the cursor's answer of the reader and picture, a
// reading of OCR, the history's size. A change of one reads `disabled` again; else nothing is read.
Can_Act_Key :: struct {
	made:          bool,
	selection:     u64,
	rows:          u64,
	loaded:        [2]u64,
	view:          [2]u64,
	view_qr:       bool,
	ocr_reading:   u64,
	ocr_offered:   bool,
	entries:       int,
}

@(private = "file")
can_act_key :: proc(app: ^App) -> Can_Act_Key {
	return {
		made = true, selection = app.vl.selection.version, rows = app.ids_version,
		loaded = {app.loaded.id, app.loaded.key}, view = {app.view.id, app.view.key}, view_qr = app.view.has_tex && app.view.qr != "",
		ocr_reading = app.ocr_reading, ocr_offered = app.ocr_offered, entries = len(app.list.entries),
	}
}

// The usage memory and the settings source, once the window, the updater and the install are made. The source asks
// for the page's options when it reads or acts: the themes read again or a new registry need nothing here.
palette_init :: proc(app: ^App) {
	ui.palette_memory_open(&app.palette, &app.main.state, palette_choices_path())
	open :: proc(user: rawptr) { (^App)(user).settings_open = true }
	options :: proc(user: rawptr) -> prefs_page.Page_Options { return settings_options((^App)(user)) }
	prefs_page.palette_settings_add(&app.palette, &app.palette_state.settings, &app.prefs, &app.settings_page, options, open, app)
}

// The actions and what can act now, given to the commands source. `disabled` is read again only when what it depends
// on moved (Can_Act_Key); its version moves with it.
@(private = "file")
palette_give :: proc(app: ^App) {
	ps := &app.palette_state
	if key := can_act_key(app); key != ps.made_for {
		for a in Action { ps.disabled[a] = !action_enabled(app, a) }
		ps.made_for = key
		ps.version += 1
	}
	ui.palette_commands(&app.palette, slice.enumerated_array(&ACTIONS), slice.enumerated_array(&ps.disabled), {version = ps.version})
}

// Ctrl+K and Ctrl+Shift+P (the toolkit's command, read by its one reader): the palette opens, on what can act now, or
// closes. True when they were pressed.
palette_keys :: proc(app: ^App) -> bool {
	if !ui.palette_keys(&app.palette) { return false }
	palette_give(app)
	return true
}

// The palette's choice (the toolkit's sources act in it), and what can act kept while it is open: at each build.
actions_build :: proc(app: ^App) {
	if c, ok := ui.palette_chosen(&app.palette); ok {
		if i, is := ui.palette_chosen_command(&app.palette, c); is && i >= 0 && i < len(Action) { action_run(app, Action(i)) }
	}
	if ui.palette_is_open(&app.palette) { palette_give(app) }
}


// A tooltip: the action's label and its key.
action_tip :: proc(a: Action) -> string { return ui.command_tip(ACTIONS[a]) }

