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

## The order of show and hide

The window asks the watcher by one queue (copy, pin, delete, clear) and the watcher asks it by another (show, hide,
toggle, reload, quit). Both are in order: a hide then a show that come between two steps of the loop end shown.

## Updates

Once a new program is in place, papier ends as soon as its window is hidden, and the new one starts hidden
(`--hidden`): the person never sees the switch.
