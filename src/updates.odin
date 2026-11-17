package papier

// Updates: gui_toolkit's updates (prefs_page.updates_*: gt:update's Updater) check papier's latest release a while after
// the start and then every day, download the program it names, check it against its signed manifest (src/update:
// papier's product and key) and put it in place of this one. Only the installed copy does it by itself (update.auto): a
// build, or a copy run where it was unzipped, is updated when the settings' Check now asks. Once a new papier is in place,
// this one gives way to it as soon as its window is hidden: the new one starts hidden, in the notification area. A copy
// from the Nix store is left to Nix.

import "core:fmt"
import "gt:host"
import process "gt:process"
import prefs_page "gt:prefs_page"
import update "gt:update"

// At each turn of the loop: what changed is said, and an update in place takes over once the window is hidden.
app_updates_follow :: proc(app: ^App) {
	changed, st := prefs_page.updates_follow(&app.updates)
	if changed {
		host.host_settle(&app.main)   // (the badge and the settings show the state)
		// (the status bar's badge shows the phase: the status line says only what it cannot, once)
		if words, _ := update.notice(st); words != "" && app.visible { say(app, "%s", words) }
	}
	if st.phase == .Installed && !app.visible && !app.quit { app_restart(app) }
}

// The program starts again once this one has ended (it holds the single instance until then): an update put in place,
// or Restart asked. `hidden`: in the notification area (an update, while the window was hidden).
app_restart :: proc(app: ^App, hidden := true) {
	delete(app.launch_after)
	app.launch_after = fmt.aprintf("%s", process.executable_path())
	app.launch_hidden = hidden
	app.quit = true
}

// "Check for updates" (the palette): asked, its answer said in the status bar whatever it is.
update_check_asked :: proc(app: ^App) { update.check_now(app.updates.updater) }
