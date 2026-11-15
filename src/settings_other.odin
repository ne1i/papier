#+build !windows
#+build !linux
package papier

// The preferences of a system papier does not watch yet (macOS): nothing is recorded, so no setting of the capture
// applies; only the history's place is needed, for the store (history/store_unix.odin).

import config "gt:config"
import "gt:platform"

PREF_DEFS_SYSTEM := [?]config.Def{}

prefs_read_system :: proc(p: ^config.Prefs, s: ^Settings, allocator := context.allocator) {}

// The user's data folder: without history.persist here, a history in a temporary folder would go unasked.
history_dir :: proc(persist: bool, allocator := context.temp_allocator) -> string {
	return platform.user_dir(.Data, APP_FOLDER, allocator)
}
