#+build !windows
package papier

// The list beside the preview is the toolkit's foldable side panel (src/md/features/window.md), in papier's real page,
// offscreen, on a reader of a temporary store: a narrow window folds the list to its rail, a wide one opens it; an
// opening by hand while narrow holds until the next crossing; the fold button stays at its pixel; Up and Down move the
// rail's selection; the state written says the fold.

import "core:fmt"
import "core:math"
import "core:os"
import "core:testing"
import "gt:fsx"
import "gt:testkit/session"
import "gt:ui"
import "history"

@(private = "file") RAIL_WIDE   :: [2]int{1000, 640}
@(private = "file") RAIL_NARROW :: [2]int{600, 640}

@(private = "file")
Rail_Test :: struct {
	app:   ^App,
	store: history.Store,
	dir:   string,
	em:    f32,
}

@(private = "file")
rail_build :: proc(s: ^session.Session) {
	r := (^Rail_Test)(s.user)
	app := r.app
	r.em = ui.font_size()
	app.icons = ui.lucide_icons()
	app.room = f32(s.win.size.x) / max(ui.scale(), 0.01)
	move_keys(app)
	ui.next({width = ui.fill(), height = ui.fill(), axis = .Y})
	if ui.column(id = "###page") { build_page(app, r.em) }
}

@(private = "file")
rail_start :: proc(t: ^testing.T, r: ^Rail_Test) -> ^session.Session {
	r.dir = fmt.aprintf("%s/papier_test_rail_%d", fsx.temp_dir(context.temp_allocator), os.get_pid())
	fsx.remove_tree(r.dir)
	ok, why := history.open(&r.store, r.dir)
	testing.expectf(t, ok, "the store opens: %s", why)
	r.app = new(App)
	app := r.app
	reader_start(&app.reader, nil, r.dir)
	texts := [?]string{"alpha: the first line", "beta", "gamma", "delta"}
	for text, i in texts {
		id := u64(101 + i)
		append(&app.list.entries, history.Entry{id = id, kind = i == 1 ? .Html : .Text, preview = text, pinned = i == 2})
		app.list.at[id] = i
		append(&app.shown, i)
		append(&app.ids, id)
	}
	app.ids_version = 1
	select_row(app, 0)
	s := session.start(t, {size = RAIL_WIDE, user = r, build = rail_build})
	session.frames(s, 3)
	return s
}

@(private = "file")
rail_end :: proc(r: ^Rail_Test) {
	app := r.app
	reader_stop(&app.reader)
	loaded_free(&app.loaded)
	view_clear(app)
	delete(app.list.entries)
	delete(app.list.at)
	delete(app.shown)
	delete(app.ids)
	delete(app.query)
	delete(app.thumbs.asks)
	delete(app.thumbs.file_asks)
	ui.vlist_destroy(&app.vl)
	ui.line_edit_destroy(&app.search)
	free(app)
	history.close(&r.store)
	fsx.remove_tree(r.dir)
	delete(r.dir)
}

// Whether the list shows as its rail: its box as wide as the rail.
@(private = "file")
railed :: proc(s: ^session.Session, r: ^Rail_Test) -> bool {
	list := session.get(s, "list")
	return abs((list.rect.max.x - list.rect.min.x) - math.round(r.em * RAIL_EM)) <= 1
}

@(private = "file")
fold_button_at :: proc(s: ^session.Session) -> [2]f32 { return session.get(s, "fold").rect.min }

@(test)
the_list_folds_to_its_rail_in_a_narrow_window :: proc(t: ^testing.T) {
	r: Rail_Test
	s := rail_start(t, &r)
	defer rail_end(&r)
	app := r.app
	testing.expect(t, !railed(s, &r), "wide: the list open")
	open_at := fold_button_at(s)
	session.save_png(s, "papier-open.png")

	app.state_due = false
	session.resize(s, RAIL_NARROW)
	session.frames(s, 2)
	testing.expect(t, railed(s, &r), "narrow: the rail")
	testing.expectf(t, app.remembered.side.fold == {folded = true, narrow = true}, "the automatic state: %v", app.remembered.side.fold)
	testing.expect(t, app.state_due, "a crossing asks a write")
	testing.expectf(t, fold_button_at(s) == open_at, "the fold button at its pixel: %v, open %v", fold_button_at(s), open_at)
	session.save_png(s, "papier-rail.png")

	session.resize(s, RAIL_WIDE)
	session.frames(s, 2)
	testing.expect(t, !railed(s, &r), "wide again: open")
	testing.expectf(t, app.remembered.side.fold == {}, "the automatic state: %v", app.remembered.side.fold)
}

@(test)
an_opening_while_narrow_holds_until_the_next_crossing :: proc(t: ^testing.T) {
	r: Rail_Test
	s := rail_start(t, &r)
	defer rail_end(&r)
	app := r.app
	session.resize(s, RAIL_NARROW)
	session.frames(s, 2)
	if !testing.expect(t, railed(s, &r), "narrow: the rail") { return }

	app.state_due = false
	session.click(s, "fold")
	session.frames(s, 2)
	testing.expect(t, !railed(s, &r), "opened by hand while narrow")
	testing.expect(t, app.state_due, "a manual fold asks a write")
	// (narrower still: the same side of the threshold, no crossing: the choice holds, and it is what a restart reads)
	session.resize(s, RAIL_NARROW - {40, 0})
	session.frames(s, 2)
	testing.expect(t, !railed(s, &r), "still open: no crossing")
	testing.expectf(t, state_parse(state_format(app.remembered)).side.fold == {narrow = true}, "the opening by hand is remembered: %v", app.remembered.side.fold)

	// a crossing, wide, then narrow again: the automatic state, the manual choice gone
	session.resize(s, RAIL_WIDE)
	session.frames(s, 2)
	session.resize(s, RAIL_NARROW)
	session.frames(s, 2)
	testing.expect(t, railed(s, &r), "narrow after a crossing: the rail again")
}

@(test)
the_rails_selection_moves_with_up_and_down :: proc(t: ^testing.T) {
	r: Rail_Test
	s := rail_start(t, &r)
	defer rail_end(&r)
	app := r.app
	session.resize(s, RAIL_NARROW)
	session.frames(s, 2)
	if !testing.expect(t, railed(s, &r), "narrow: the rail") { return }
	testing.expect_value(t, selected_id(app), u64(101))
	session.key(s, .Down)
	session.key(s, .Down)
	session.frames(s, 2)
	testing.expect_value(t, selected_id(app), u64(103))
	session.key(s, .Up)
	session.frames(s, 2)
	testing.expect_value(t, selected_id(app), u64(102))
	testing.expect(t, railed(s, &r), "still the rail")
}
