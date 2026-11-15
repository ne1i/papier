package papier

import "core:testing"

// The window's state reads back what was written; unknown, malformed and partial lines are left out (the size and the
// place of an older papier among them: the toolkit's window.placement keeps those now).
@(test)
the_window_state_reads_back :: proc(t: ^testing.T) {
	s := Window_State{split = 412}
	testing.expect_value(t, state_parse(state_format(s)), s)
	testing.expect_value(t, state_parse("size 800 600\nplace -40 120\nsplit 300\n"), Window_State{split = 300})
	testing.expect_value(t, state_parse("split -3\nsplit\nnonsense here\n"), Window_State{})
	testing.expect_value(t, state_format(Window_State{}), "")
}
