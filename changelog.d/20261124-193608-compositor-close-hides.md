type: Fixed

**The window manager's close key hides the window**: a close from the compositor (Hyprland's or sway's close key, `swaymsg kill`) froze the window and made Papier's memory grow by tens of megabytes a second; it now hides the window, as Escape does.
