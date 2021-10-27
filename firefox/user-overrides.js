/********************/
/** User Overrides **/
/********************/

/*** custom prefs ***/

// https://www.inmotionhosting.com/support/security/dns-over-https-encrypted-sni-in-firefox/
user_pref("network.trr.mode", 3);
user_pref("network.trr.uri", "https://www.jabber-germany.de/dns-query");

// https://blog.mozilla.org/security/2021/01/07/encrypted-client-hello-the-future-of-esni-in-firefox/
user_pref("network.dns.echconfig.enabled", true)
user_pref("network.dns.use_https_rr_as_altsvc", true)
//user_pref("network.security.esni.enabled", true);

