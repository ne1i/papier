package papier

import "core:testing"

// The shortcut hides only the window the person is in; a window shown behind another comes to the front.
@(test)
the_shortcut_hides_only_the_window_in_front :: proc(t: ^testing.T) {
	testing.expect_value(t, toggle_act(shown = false, focused = false), Toggle_Act.Show)
	testing.expect_value(t, toggle_act(shown = false, focused = true), Toggle_Act.Show)
	testing.expect_value(t, toggle_act(shown = true, focused = false), Toggle_Act.Raise)
	testing.expect_value(t, toggle_act(shown = true, focused = true), Toggle_Act.Hide)
}
