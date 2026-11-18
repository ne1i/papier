package papiertool

// build, test, check: the toolkit's (toolbox.build_commands), the same steps on a laptop and in the CI, with papier's
// SQLite built first.

import changelog "gt:changelog"
import toolbox "gt:toolbox"

// The packages that have tests (this tool has none of its own: its steps are gui_toolkit's, tested there; check still
// type-checks it). src's tests run one at a time: some take the toolkit's one test session (list_rail_test.odin).
@(rodata) TESTS := [?]toolbox.Test_Package{{path = "src", one_thread = true}, {path = "src/history"}}

// SQLite, from its amalgamation in ext/sqlite (3.54.1), compiled into build/sqlite/libsqlite3.a: the history's database
// (src/sqlite links it). Built again when its sources or the flags below change (toolbox.build_c_lib's stamp).
SQLITE_SOURCES :: [?]string{"ext/sqlite/sqlite3.c"}
SQLITE_OUT     :: "build/sqlite"
// FTS5 for the search; no extensions loaded at run time, no deprecated or shared-cache code; double quotes only for names.
SQLITE_FLAGS :: [?]string{
	"-O2", "-fPIC", "-w",
	"-DSQLITE_ENABLE_FTS5", "-DSQLITE_THREADSAFE=1", "-DSQLITE_DQS=0", "-DSQLITE_DEFAULT_MEMSTATUS=0",
	"-DSQLITE_OMIT_LOAD_EXTENSION", "-DSQLITE_OMIT_DEPRECATED", "-DSQLITE_OMIT_SHARED_CACHE", "-DSQLITE_LIKE_DOESNT_MATCH_BLOBS",
}

// Linux: SQLite as a static library (Windows reads the system's own history: no database).
build_sqlite :: proc(_: toolbox.Project) -> bool {
	when ODIN_OS == .Linux {
		sources, flags := SQLITE_SOURCES, SQLITE_FLAGS
		return toolbox.build_c_lib("sqlite3", sources[:], SQLITE_OUT, flags[:])
	} else {
		return true
	}
}

build_options :: proc() -> toolbox.Build_Options {
	p := project()
	return {project = p, changelog_command = changelog.command(p), tests = TESTS[:], catalogues = I18N, prepare = build_sqlite}
}
