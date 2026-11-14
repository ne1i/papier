package papier

import "core:slice"
import "core:testing"
import config "gt:config"
import prefs_page "gt:prefs_page"
import "gt:ui"

// The search field always has the keyboard: a key that types text would go to it and never run its action, while the
// entry's menu shows it. No action has one (gui_toolkit's src/md/features/commands.md).
@(test)
no_action_key_types_text :: proc(t: ^testing.T) {
	got := ui.command_typing_keys(slice.enumerated_array(&ACTIONS))
	testing.expectf(t, len(got) == 0, "keys that type text: %v", got)
}

// The keys, the settings, hide and quit are the window's: their keys work in the settings, the edit view and over a
// dialog (window_keys). The live run opens the palette from the settings and from the edit view.
@(test)
the_window_actions_are_marked :: proc(t: ^testing.T) {
	for a in ([]Action{.Settings, .Shortcuts, .Hide, .Quit}) {
		testing.expectf(t, ACTIONS[a].scope == .Window, "%v is the window's", a)
	}
	testing.expect_value(t, ACTIONS[.Copy].scope, ui.Command_Scope.Page)
	testing.expect_value(t, len(ui.command_window_typing_keys(slice.enumerated_array(&ACTIONS))), 0)
}

// The palette's keys are the toolkit's command (Ctrl+K, Ctrl+Shift+P), read by its own reader: no action of papier's
// takes them, or the key would run twice.
@(test)
no_action_takes_the_palette_keys :: proc(t: ^testing.T) {
	for chord in ui.palette_command().keys {
		for a in Action {
			for k in ACTIONS[a].keys { testing.expectf(t, k != chord, "%v takes the palette's key %v", a, chord) }
		}
	}
}

// The prefixes papier fills: the toolkit's commands (and the views' moves) and its settings, nothing else. Its history
// is the window itself.
@(test)
the_palette_prefixes :: proc(t: ^testing.T) {
	p: ui.Command_Palette
	defer ui.palette_destroy(&p)
	prefs := config.prefs_make()
	defer config.prefs_destroy(&prefs)
	page: prefs_page.Page
	settings: prefs_page.Palette_Settings
	ui.palette_commands(&p, slice.enumerated_array(&ACTIONS), nil)
	options :: proc(user: rawptr) -> prefs_page.Page_Options { return {} }
	prefs_page.palette_settings_add(&p, &settings, &prefs, &page, options, nil)
	testing.expect(t, slice.equal(ui.palette_prefixes(&p), []string{"> Commands", ": Settings"}), "the prefixes")
}
