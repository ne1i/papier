package papier

// A button that runs an action states its act name ("command:<id>"): the palette's Shift+Enter on that action comes to
// it (gui_toolkit's src/md/features/everything-palette.md, go to). A button that is not the action states none.

import "core:testing"
import "gt:font"
import "gt:ui"

@(test)
an_action_s_button_states_its_act_name :: proc(t: ^testing.T) {
	// (on the heap: the state keeps them past each call)
	Fixture :: struct { fonts: font.State, theme: ui.Theme, s: ui.State }
	f := new(Fixture)
	defer free(f)
	font.init(&f.fonts)
	defer font.destroy(&f.fonts)
	base, ok := font.load_embedded(&f.fonts, font.FALLBACK_UI_DATA)
	if !testing.expect(t, ok, "fonts") { return }
	ui.apply_palette(&f.theme, ui.palette_of("Midnight"))
	defer ui.theme_destroy(&f.theme)
	ui.init(&f.s, &f.fonts, &f.theme)
	defer ui.destroy(&f.s)
	app := new(App)
	defer free(app)

	for _ in 0 ..< 2 {
		ui.begin_build(&f.s, {
			window_size = {640, 400}, dt = 1.0 / 60, animations = false, dpi_scale = 1,
			base = ui.Style{pref = {.X = ui.text_size(), .Y = ui.px(30)}, font = base, font_size = 15, text_pad = 6},
		})
		if ui.row() {
			icon_action(app, "settings", "", "Settings", 15, .Settings)
			// (the pin button with several entries selected: it pins the entry shown, not the selection)
			icon_action(app, "pin", "", "Pin", 15, action_if(false, .Pin))
		}
		ui.end_build()
		free_all(context.temp_allocator)
	}
	testing.expect(t, ui.act_shown("command:settings"), "the settings button states the Settings action")
	testing.expect(t, !ui.act_shown("command:pin"), "a button that is not the action states none")
}
