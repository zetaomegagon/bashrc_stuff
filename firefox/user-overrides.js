/*** overrides ***/

/*** custom prefs ***/
// https://www.inmotionhosting.com/support/security/dns-over-https-encrypted-sni-in-firefox/
user_pref("network.trr.mode", 3);
user_pref("network.security.esni.enabled", true); // enable ESNI
user_pref("network.trr.uri", "https://www.jabber-germany.de/dns-query"); // speciry TRR resolver

