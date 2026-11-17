package papiertool

// The site, made when it is deployed (.github/workflows/pages.yml) so that it cannot be behind a release. The steps are the
// toolkit's (gt:site, its `site` command: build <site> <out>, check, card); this file says what this site is: its address,
// names and colours. {{version}} in the home page is the last version: its download link names the file of that release.

import tk_site "gt:site"
import toolbox "gt:toolbox"

VERSION_MARK :: "{{version}}"

// The home page's download, for the reader's system (Windows first: what a phone or an unknown system is offered).
@(rodata)
SITE_DOWNLOADS := [?]tk_site.Download{
	{os = "windows", label = "Windows", href = "https://github.com/sachahjkl/papier/releases/download/v{{version}}/papier-{{version}}-windows-x64.zip", detail = "v{{version}} · Windows 10 / 11 · x64 · .zip"},
	{os = "linux", label = "Linux", href = "https://github.com/sachahjkl/papier/releases/download/v{{version}}/papier-{{version}}-linux-x64.tar.gz", detail = "v{{version}} · x64 · .tar.gz · Wayland"},
}

SITE_LD :: [?][2]string{
	{"applicationCategory", "UtilitiesApplication"},
	{"operatingSystem", "Windows, Linux"},
	{"license", "https://opensource.org/license/mit"},
}

site_meta :: proc() -> tk_site.Meta {
	// Where the site is published, what it is: the one place that says it (the vendor's fields are the toolkit's).
	m := tk_site.meta_default(name = "Papier", url = "https://papier.froment.software/", repository = REPOSITORY, tagline = "A fast clipboard history, searched as you type", theme = "#131315", accent = "#cbbca3")
	@(static) ld := SITE_LD
	m.ld_fields = ld[:]   // (static: the site command keeps the Meta as long as the tool runs)
	m.shop = SHOP
	return m
}

// The shop: papier's licence (src/licence), sold through Paddle by the toolkit's licence Worker. Its pages (pricing,
// thanks, terms, refunds, privacy, imprint) are the toolkit's templates, filled at each `site build` (Meta.shop). What is empty is
// the maintainer's to give once the shop is set up (docs/licence.md, "What the maintainer does at the end"): until the
// client token, the price id and the Worker are there, the button says "Coming soon".
SHOP :: tk_site.Shop{
	name           = "Papier",
	icon           = "../img/logo.png",
	product_title  = "Papier User License",
	price          = "15&nbsp;&euro;",
	price_note     = "",
	environment    = "production",
	client_token   = "live_cc454434f1340eaec97edd187d0",   // Paddle's client-side token (public: it is in the page)
	edition        = "supporter",
	price_id       = "pri_01m7fyah37tdgnpsxs8kh5ss03",
	worker         = "https://papier-licence.sacha-42a.workers.dev",
	thanks         = "https://papier.froment.software/thanks/",
	help           = REPOSITORY + "/issues/new",
	register       = "Open Papier's settings (Ctrl+,), the <b>General</b> page, <b>Licence</b>: paste the key, or choose the file.",
	extension      = ".papierlicence",
	repository     = REPOSITORY,
	seller         = tk_site.SELLER_FROMENT,
	code_licence   = "MIT License",
	platform       = "Windows 10 or 11, x64, and Linux, x64 (Wayland).",
	network        = tk_site.NETWORK_UPDATES_ONLY,
	stylesheet     = "../style.css",
	home           = "../",
	updated        = "2026-11-13",
}

// The site's command: the toolkit's, the shop's pages among the others (Meta.shop).
site_command :: proc() -> toolbox.Command {
	return tk_site.command({meta = site_meta(), pages = {version_mark = VERSION_MARK, downloads = SITE_DOWNLOADS[:]}, images = tk_site.images_default()})
}
