package papier

import "core:strings"
import "core:testing"

// The program that opens an entry receives this folder: on Windows a "/" in it (the temporary folder joined with "/")
// is a path the person sees mixed; on Linux every separator is "/".
@(test)
the_open_folder_has_the_systems_separator :: proc(t: ^testing.T) {
	dir := open_dir()
	when ODIN_OS == .Windows {
		testing.expectf(t, !strings.contains_rune(dir, '/'), "a \"/\" in %q", dir)
		testing.expect(t, strings.has_suffix(dir, `\papier-open`))
	} else {
		testing.expect(t, strings.has_suffix(dir, "/papier/open") || strings.has_suffix(dir, "/papier-open"))
	}
}
