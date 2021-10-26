#!/usr/bin/env -S bash -x

##################################################################################
# Generate FF bookmark html for all combinations of DeepL language translations, #
# that includes the following:                                                   #
# - a search keyword e.g. "en-es"                                                #
# - tags. Minimally "from-$lang" and "to-$lang"                                  #
# - a title: "DeepL Translate | ${from_lang}->${to_lang}"                        #
#                                                                                #
# Additionally generate translation function for each, which execute in FF       #
##################################################################################

# languages: languages=( "[bulgarian]=bg" "[chinese]=zh" ...)
declare -A languages

languages[bulgarian]=bg;  languages[chinese]=zh;  languages[czech]=cs
languages[danish]=da;     languages[dutch]=nl;    languages[english]=en
languages[estonian]=et;   languages[finnish]=fi;  languages[french]=fr
languages[german]=de;     languages[greek]=el;    languages[hungarian]=hu
languages[italian]=it;    languages[japanese]=ja; languages[latvian]=lv
languages[lithuanian]=lt; languages[polish]=pl;   languages[portugese]=pt
languages[romanian]=ro;   languages[russian]=ru;  languages[slovakian]=sk
languages[slovenian]=sl;  languages[spanish]=es;  languages[swedish]=sv

# targets to write out to
target_html="$HOME/projects/deepl-ff-bookmark-html.html"
target_func="$HOME/gits/bashrc_stuff/env/translate"

# create or empty target files
#[[ -f $target_html ]] && echo > $target_html
#[[ -f $target_func ]] && echo > $target_func

## main
added="$(($(date +%s) + $RANDOM))"
modified="$(($(date +%s) + $RANDOM))"
# Signifies a directory in FF bookmark html
dir_html="<DT><H3 ADD_DATE=\"${added}\" LAST_MODIFIED=\"${modified}\">DeepL</H3>"

printf "$dir_html\n" > $target_html

for language in ${!languages[@]}; do
    from_code="${languages[$language]}"
    from_lang="${language}"
    
    for language in ${!languages[@]}; do
        to_code="${languages[$language]}"
        to_lang="${language}"
        
        if [[ $to_code = $from_code ]]; then
            continue
        else
            baseurl="https://www.deepl.com/translator"
            transurl="#${from_code}/${to_code}/%s"            
            keyword=":${from_code}-${to_code}"
            tags="from-${from_lang},to-${to_lang},${keyword:1:${#keyword}},translate,deepl"
            title="DeepL Translate | ${from_lang}->${to_lang}"
            # FF bookmarks
            search_html="<DT><A HREF=\"${baseurl}${transurl}\" ADD_DATE=\"${added}\" LAST_MODIFIED=\"${modified}\" SHORTCUTURL=\"${keyword}\" TAGS=\"${tags}\">${title}</A>"

            # append bookmark to target
            printf "$search_html\n" #>> $target_html

            # Bash function template (need a better way...)
            template="${from_code}-${to_code}() {\n    # DeepL Translate | ${from_lang}->${to_lang}\n    input=\"\${@:-\$(</dev/stdin)}\"\n    baseurl=\"${baseurl}\"\n    query=\"#${from_code}/${to_code}/\${input}\"\n\n    if ps -e | grep -q GeckoMain; then\n        ( { /usr/bin/firefox --new-tab \"\${baseurl}\${query}\"; } >/dev/null 2>&1 & )\n    else\n        ( { /usr/bin/firefox --new-instance \"\${baseurl}\${query}\"; } >/dev/null 2>&1 & )\n    fi\n}"

            # append functions to target
            printf  "$template\n\n" >> "$target_func"
        fi
    done 
done
