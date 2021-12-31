/********************/
/** User Overrides **/
/********************/

/*** custom prefs ***/

// Set starup page to custom url
user_pref("browser.startup.page", 1);
user_pref("browser.startup.homepage", "https://tree.taiga.io/project/zetaomegagon-todo/kanban");

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

/* OTHER ***/
user_pref("browser.bookmarks.max_backups", 30);

