/********************/
/** User Overrides **/
/********************/

/*** custom prefs ***/

// Set starup page to custom url
user_pref("browser.startup.page", 1);
user_pref("browser.startup.homepage", "https://apps.disroot.org/");

// Geolocation
user_pref("geo.provider.network.url", "file:///dev/null");
user_pref("browser.region.network.url", "file:///dev/null");

// Telemetry
user_pref("toolkit.telemetry.server", "file:///dev/null");
user_pref("toolkit.coverage.endpoint.base", "file:///dev/null");

// Studies
user_pref("app.normandy.api_url", "file:///dev/null");

// Crash reports
user_pref("breakpad.reportURL", "file:///dev/null");

// Captive portal detection
user_pref("captivedetect.canonicalURL", "file:///dev/null");

// Safebrowsing
user_pref("browser.safebrowsing.downloads.remote.url", "file:///dev/null");

// URL Bar
user_pref("keyword.enabled", true);
user_pref("browser.urlbar.suggest.engines", true);
//user_pref("browser.search.suggest.enabled", true);
//user_pref("browser.urlbar.suggest.searches", true);

// Visited links
user_pref("layout.css.visited_links_enabled", false);

// Disk writes
user_pref("browser.sessionstore.interval", 120000); // [DEFAULT: 15000]

// https://www.inmotionhosting.com/support/security/dns-over-https-encrypted-sni-in-firefox/
user_pref("network.trr.mode", 3);
user_pref("network.trr.bootstrapAddress", "194.36.144.87");
user_pref("network.trr.uri", "https://www.morbitzer.de/dns-query");

// https://blog.mozilla.org/security/2021/01/07/encrypted-client-hello-the-future-of-esni-in-firefox/
user_pref("network.dns.echconfig.enabled", true)
user_pref("network.dns.use_https_rr_as_altsvc", true)
//user_pref("network.security.esni.enabled", true);

/* UX FEATURES ***/
user_pref("browser.messaging-system.whatsNewPanel.enabled", false); // What's New toolbar icon [FF69+]
user_pref("extensions.pocket.enabled", false); // Pocket Account [FF46+]
user_pref("extensions.screenshots.disabled", true); // [FF55+]
user_pref("identity.fxaccounts.enabled", false); // Firefox Accounts & Sync [FF60+] [RESTART]
user_pref("reader.parse-on-load.enabled", false); // Reader View

// Optional Opsec
user_pref("signon.rememberSignons", false);
user_pref("browser.urlbar.suggest.history", true);
user_pref("browser.urlbar.suggest.bookmark", true);
user_pref("browser.urlbar.suggest.openpage", true);
user_pref("browser.urlbar.suggest.topsites", false); // [FF78+]
user_pref("browser.urlbar.autoFill", false);
user_pref("javascript.options.wasm", false);

/* OTHER ***/
user_pref("browser.bookmarks.max_backups", 30);

