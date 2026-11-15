#+build !windows
#+build !linux
package papier

// The watcher on a system papier does not watch yet (macOS): no clipboard client exists here, so it does not start and
// papier says so (app.odin) instead of showing a history that never changes.

import config "gt:config"
import instance "gt:instance"
import "gt:platform"

Watcher_System :: struct {}

watcher_start :: proc(wt: ^Watcher, owner: instance.Owner, window: ^platform.Window, prefs: ^config.Prefs) -> bool {
	return false
}

watcher_stop :: proc(wt: ^Watcher) { watcher_free(wt) }

// (no thread to wake)
watcher_poke :: proc(wt: ^Watcher) {}
