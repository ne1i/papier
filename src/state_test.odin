package papier

import "core:testing"
import "gt:ui"

// The window's state reads back what was written; unknown, malformed and partial lines are left out (the size and the
// place of an older papier among them: the toolkit's window.placement keeps those now).
@(test)
the_window_state_reads_back :: proc(t: ^testing.T) {
	s := Window_State{side = {width = 412}}
	testing.expect_value(t, state_parse(state_format(s)), s)
	testing.expect_value(t, state_parse("size 800 600\nplace -40 120\nsplit 300\n"), Window_State{side = {width = 300}})
	testing.expect_value(t, state_parse("split -3\nsplit\nnonsense here\nfold sideways\n"), Window_State{})
	testing.expect_value(t, state_format(Window_State{}), "")
}

// The list's fold survives a restart, each of its four states: a manual choice too (a fold while wide, an opening while
// narrow), which holds at a start on the same side of the threshold.
@(test)
the_lists_fold_reads_back :: proc(t: ^testing.T) {
	for fold in ([4]ui.Side_Fold{{}, {folded = true}, {narrow = true}, {folded = true, narrow = true}}) {
		s := Window_State{side = {width = 300, fold = fold}}
		testing.expect_value(t, state_parse(state_format(s)), s)
	}
	testing.expect_value(t, state_format(Window_State{side = {width = 300, fold = {folded = true, narrow = true}}}), "split 300\nfold folded narrow\n")
}
