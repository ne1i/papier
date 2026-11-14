package papier

// Several entries selected: Copy, Pin and Remove act on them in the list's order; what shows one entry (Edit, the
// preview) stays on the cursor's; a move alone takes the cursor's row alone.

import "core:testing"
import "gt:ui"
import "history"

@(test)
the_acts_take_every_entry_selected :: proc(t: ^testing.T) {
	app := new(App)
	defer free(app)
	defer delete(app.list.entries)
	defer delete(app.list.at)
	defer delete(app.shown)
	defer delete(app.ids)
	defer ui.vlist_destroy(&app.vl)
	app.vl.multi = true
	for i in 0 ..< 4 {
		id := u64(101 + i)
		append(&app.list.entries, history.Entry{id = id, kind = i == 3 ? history.Kind.Image : history.Kind.Text, preview = "x"})
		app.list.at[id] = i
		append(&app.shown, i)
		append(&app.ids, id)
	}
	ids_of :: proc(on: []^history.Entry) -> (out: [4]u64, n: int) {
		for e in on { if n < len(out) { out[n] = e.id; n += 1 } }
		return
	}

	// a Shift range over the first three, from the last to the first: the list's order all the same
	select_row(app, 2)
	ui.item_selection_move(&app.vl.selection, list_rows_now(app), 0, {.Shift})
	got, n := ids_of(acted_on(app))
	testing.expect(t, n == 3 && got[0] == 101 && got[1] == 102 && got[2] == 103, "the three, newest first")
	testing.expect(t, action_enabled(app, .Copy) && action_enabled(app, .Remove) && action_enabled(app, .Select_One), "Copy, Remove and Select_One act on several")

	// Ctrl: the cursor goes to the image alone; Edit follows the cursor (an image has no text to edit), Copy the selection
	ui.item_selection_move(&app.vl.selection, list_rows_now(app), 3, {.Ctrl})
	testing.expect_value(t, selected(app).id, u64(104))
	testing.expect_value(t, len(app.vl.selected), 3)
	testing.expect(t, !action_enabled(app, .Edit), "Edit: the cursor's image")
	_, n = ids_of(acted_on(app))
	testing.expect_value(t, n, 3)

	// Ctrl+Space adds it; Select_One keeps the cursor's alone
	ui.item_selection_toggle(&app.vl.selection, list_rows_now(app), app.vl.sel)
	testing.expect_value(t, len(app.vl.selected), 4)
	action_run(app, .Select_One)
	got, n = ids_of(acted_on(app))
	testing.expect(t, n == 1 && got[0] == 104, "the cursor's entry alone")
	testing.expect(t, !action_enabled(app, .Select_One), "nothing more to keep alone")

	// Ctrl+Shift+A: every entry shown
	action_run(app, .Select_All)
	testing.expect_value(t, len(app.vl.selected), 4)

	// nothing selected: the cursor's entry
	ui.item_selection_clear(&app.vl.selection)
	got, n = ids_of(acted_on(app))
	testing.expect(t, n == 1 && got[0] == 104, "the cursor's entry when none is selected")
}
