package papier

import "core:slice"
import "core:testing"
import "gt:ui"

// The search field always has the keyboard: a key that types text would go to it and never run its action, while the
// entry's menu shows it. No action has one (gui_toolkit's src/md/features/commands.md).
@(test)
no_action_key_types_text :: proc(t: ^testing.T) {
	got := ui.command_typing_keys(slice.enumerated_array(&ACTIONS))
	testing.expectf(t, len(got) == 0, "keys that type text: %v", got)
}

// The palette, the keys, the settings, hide and quit are the window's: their keys work in the settings, the edit view and
// over a dialog (window_keys). The live run opens the palette from the settings and from the edit view.
@(test)
the_window_actions_are_marked :: proc(t: ^testing.T) {
	for a in ([]Action{.Settings, .Palette, .Shortcuts, .Hide, .Quit}) {
		testing.expectf(t, ACTIONS[a].scope == .Window, "%v is the window's", a)
	}
	testing.expect_value(t, ACTIONS[.Copy].scope, ui.Command_Scope.Page)
	testing.expect_value(t, len(ui.command_window_typing_keys(slice.enumerated_array(&ACTIONS))), 0)
}
