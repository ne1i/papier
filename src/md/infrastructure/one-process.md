# One resident process

## Why one process

A clipboard manager on Wayland must hold a data-control connection for the whole session, and its window must come fast.
So papier is one process that starts with the session (`papier --hidden`) and never closes its window: it hides it.

- A hidden window keeps the GPU device, the fonts and the history in memory: `papier toggle` shows it in a few
  milliseconds (a new surface and its first configure, then a frame).
- gui_toolkit's `host_hide` / `host_show` do this. On Wayland the surface and its role go at the hide and new ones come
  at the show, so no state of the last frames waits in the compositor.

## The second start

A second `papier` takes the instance name (`gt:instance`: a lock file and a Unix socket in `$XDG_RUNTIME_DIR`), finds it
taken, sends its command (`show`, `toggle`, `copy 42`…) and ends. The compositor binds `papier toggle`; papier binds no
global key of its own.

- A start or a command waits the toolkit's `instance.WAIT_MS_DEFAULT` (2 s) for a papier that is starting or closing;
  a silent one ends the wait at once. papier keeps no wait of its own: no command needs a shorter one.
- An installer's `--status` and `--quit` are the toolkit's `instance.running` and `instance.quit`: the running papier
  takes the toolkit's quit message as its own Quit.

## What the shortcut does

`toggle` hides the window only when it is shown and has the keyboard (the platform window's `active`: its focus or
activation events). A window shown behind another, because the person clicked elsewhere, comes to the front with the
keyboard; a hidden one is shown. A toggle that looked at visibility alone hid the window the person was calling back.

- Bringing a shown window to the front needs the compositor's consent on Wayland: the second start hands the launch's
  activation token (`XDG_ACTIVATION_TOKEN`, else `DESKTOP_STARTUP_ID`) with its verb, and the running papier activates
  its surface with it (`platform.raise_window_token`). A show of a hidden window uses the same token. On Windows the
  second start allows the running one the foreground (`instance`: `AllowSetForegroundWindow`); papier's own hotkey is
  its own input, so it may take the foreground.
- A raise keeps what the window shows (the search, the selection): it is the same look, brought back. Only a show of a
  hidden window starts a new look.
- The tray's click toggles by visibility alone: the click takes the keyboard from the window first (the taskbar's), so
  the focus rule would never hide it.

## The order of show and hide

The window asks the watcher by one queue (copy, pin, delete, clear) and the watcher asks it by another (show, hide,
toggle, reload, quit). Both are in order: a hide then a show that come between two steps of the loop end shown.

## Updates

Once a new program is in place, papier ends as soon as its window is hidden, and the new one starts hidden
(`--hidden`): the person never sees the switch.
