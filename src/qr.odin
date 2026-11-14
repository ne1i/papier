package papier

// An entry as a QR code (Ctrl+Shift+Q, the entry's menu, the palette): its text in a view (gui_toolkit's views: a
// dialog at home, which the user can float, dock or put in a window of its own), for a phone's camera. A text holds at
// most QR_MAX_BYTES (a QR code at its largest, with medium error correction, holds 2331 bytes; a phone reads a smaller
// one better).

import "core:fmt"
import "core:strings"
import i18n "gt:i18n"
import lucide "gt:lucide"
import "gt:ui"
import "history"

QR_MAX_BYTES :: 1200

// The id of the view.
QR_VIEW :: "qr"

Qr_View :: struct {
	app:  ^App,
	text: string,   // owned
}

// The text an entry's code would hold ("" when it has none, or too much): a text, an address, a file's path. `text` is
// the entry's whole text (the reader computes it with the entry's content).
qr_content :: proc(kind: history.Kind, text: string) -> string {
	t: string
	switch kind {
	case .Text, .Html, .Files: t = text
	case .Image, .Other:
	}
	t = strings.trim_space(t)
	return len(t) <= QR_MAX_BYTES ? t : ""
}

// The text of the code of `e`, once the reader loaded it ("" until then, or when it has none).
qr_text :: proc(app: ^App, e: ^history.Entry) -> string {
	return loaded_for(app, e) ? app.loaded.qr : ""
}

// Once, at start-up, on the program's Views.
qr_register :: proc(app: ^App) {
	app.qr.app = app
	ui.view_register(&app.views, QR_VIEW, qr_view, ui.View_Options{title = i18n.later("QR code"), icon = lucide.QR_CODE, width_em = QR_MIN_EM + QR_MARGIN_EM * 2})
}

qr_open :: proc(app: ^App, e: ^history.Entry) {
	text := qr_text(app, e)
	if text == "" { return }
	delete(app.qr.text)
	app.qr.text = strings.clone(text)
	ui.view_open(&app.views, QR_VIEW, &app.qr)
}

qr_destroy :: proc(app: ^App) {
	delete(app.qr.text)
	app.qr = {}
}

// The code's side, in ems, at the least and at the most; the margin at each side of it.
@(private = "file") QR_MIN_EM    :: 12
@(private = "file") QR_MAX_EM    :: 26
@(private = "file") QR_MARGIN_EM :: 1.5

// The view: the code, as large as its room allows, the text under it. A dialog grows to what is in it, so its own room
// would shrink the code at each build: it is sized by the owner window. Elsewhere the room's width sizes it (an internal
// window is as tall as what is in it until the user resizes it: its height would shrink the code too).
@(private = "file")
qr_view :: proc(v: ^ui.View, q: ^Qr_View) {
	em := ui.font_size()
	side: f32
	if v.presentation == .Dialog {
		size := q.app.main.win.size
		side = min(f32(size.x), f32(size.y)) * 0.6
	} else {
		side = ui.view_room(v).x - em * QR_MARGIN_EM * 2
	}
	side = clamp(side, em * QR_MIN_EM, em * QR_MAX_EM)
	ui.spacer(ui.px(em * 1.2))
	ui.next({width = ui.fill(), height = ui.children_sum()})
	if ui.row() {
		// (the margins in pixels: what the dialog measures; the fills centre the code in a wider room)
		ui.spacer(ui.px(em * QR_MARGIN_EM))
		ui.spacer(ui.fill())
		// (dark on white, its quiet zone included, whatever the theme: a camera reads that)
		ui.qr_code("###qr_code", q.text, side)
		ui.spacer(ui.fill())
		ui.spacer(ui.px(em * QR_MARGIN_EM))
	}
	ui.spacer(ui.px(em * 0.8))
	if ui.tags("weak") {
		ui.next({width = ui.fill(), font_size = em * 0.85, text_align = .Center})
		ui.paragraph(fmt.tprintf("%s###qr_words", ui.text_shown(one_line(q.text, 160))))
	}
	ui.spacer(ui.px(em * 1))
}
