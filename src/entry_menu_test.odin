package papier

import "core:strings"
import "core:testing"

// The program that opens an entry receives this folder, papier's runtime folder's "open": on Windows a "/" in it (the
// temporary folder joined with "/") is a path the person sees mixed; on Linux every separator is "/".
@(test)
the_open_folder_has_the_systems_separator :: proc(t: ^testing.T) {
	dir := open_dir()
	when ODIN_OS == .Windows {
		testing.expectf(t, !strings.contains_rune(dir, '/'), "a \"/\" in %q", dir)
		testing.expectf(t, strings.has_suffix(dir, `\papier\open`), "%q", dir)
	} else {
		testing.expectf(t, strings.has_suffix(dir, "/papier/open"), "%q", dir)
	}
}

// The history kept off the disk is in papier's runtime folder: the session's ($XDG_RUNTIME_DIR/papier) when it has one.
@(test)
the_history_off_the_disk_is_in_the_runtime_folder :: proc(t: ^testing.T) {
	when ODIN_OS != .Windows {
		testing.expectf(t, strings.has_suffix(history_dir(false), "/papier"), "%q", history_dir(false))
		testing.expect(t, history_dir(false) != history_dir(true), "off the disk is not the data folder")
	}
}
