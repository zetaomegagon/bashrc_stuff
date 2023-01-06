# [ bashrc_stuff ]
##### A mix of bash environment config, other misc config, backups, and random (personal) scripts. Needs heavy cleanup.

##### Notable scripts:
- [get-baby-names](https://github.com/zetaomegagon/bashrc_stuff/blob/master/baby_names/get-baby-names.sh): Pulls the top 8077 baby names in 2017, for boys, from [NameCensus](https://namecensus.com/), and writes them to a text file. The site's routes were restructured, so this script no longer functions.

- [git-sync](https://github.com/zetaomegagon/bashrc_stuff/blob/master/bin/git-sync): pushes local changes to a remote git repository. It assumes that I work from multiple computers and forget about the changes I push, so makes sure to pull remote changes; stash them; and then push the current local changes. It needs refactoring, particularly building guards using the `trap` builtin. To be used with a `cron` job or a `systemd timer`.

- [init-dimm-sensors](https://github.com/zetaomegagon/bashrc_stuff/blob/master/bin/init-dimm-sensors): instantiates an i2c dimm device so that the `sensor-temps` script, listed below, is able to parse temprature data about my laptop's ram. To be used with a `systemd service`.

- [sensor-temps](https://github.com/zetaomegagon/bashrc_stuff/blob/master/bin/sensor-temps): uses `lm_sensors`, `jq`, and `hddtemps` to provide hardware temprature data and fan speeds for pretty printing in the Gnome top bar. Depends on [Top Bar Script Executor](https://extensions.gnome.org/extension/1154/top-bar-script-executor/).

- [touchpad-button-config](https://github.com/zetaomegagon/bashrc_stuff/blob/master/bin/touchpad-button-config): Removes middle click functionality from the Dell XPS 13 Developer Edition laptop, since middle click had closed tabs in Firefox (wrote this up for my SO). I believe this only works on that machine with X11 running.

- [gen-translate-urls](https://github.com/zetaomegagon/bashrc_stuff/blob/master/misc/gen-translate-urls.sh): Generates a bookmarks file for Firefox, and functions for command line execution, allowing omnibar bookmark and command line based translate *from* any DeepL supported language *to* any DeepL suported language.

- [translate](https://github.com/zetaomegagon/bashrc_stuff/blob/master/env/translate): this is the resultant `rc` file generated by `gen-search-urls`, which provides command line DeepL translate functions when sourced.

- [fedora-28-jss-autosnapshot](https://github.com/zetaomegagon/bashrc_stuff/blob/master/misc/fedora-28-jss-autosnapshot.sh): creates VirtualBox backups of a Fedora 28 based Jamf Pro instance.

