#+build linux, windows
package papier

// (the systems with a clipboard watcher: its handler is what answers the instance's messages)

import "base:runtime"
import "core:testing"
import instance "gt:instance"
import "gt:platform"
import unwatched "gt:testkit/unwatched"

// An installer's --quit (the toolkit's MESSAGE_QUIT) ends papier as its Quit does: the instance's handler hands it to the
// window, whose loop then stops. The toolkit's ping changes nothing: its answer alone says that papier runs.
@(test)
the_instance_messages :: proc(t: ^testing.T) {
	unwatched.run(t, proc(t: ^testing.T) {
		context.allocator = runtime.heap_allocator()
		win: platform.Window   // (no system window: a wake of it does nothing)
		app: App
		app.watcher.window = &win
		defer delete(app.watcher.asked)

		watcher_message(&app.watcher, transmute([]u8)string(instance.MESSAGE_PING))
		testing.expect_value(t, len(app.watcher.asked), 0)
		testing.expect(t, !app.quit, "a ping does not end papier")

		watcher_message(&app.watcher, transmute([]u8)string(instance.MESSAGE_QUIT))
		app_requests(&app)
		testing.expect(t, app.quit, "a quit ends papier")
	})
}
