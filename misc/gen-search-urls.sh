#!/usr/bin/env -S bash -x

declare -A languages

languages[bulgarian]=bg
languages[chinese]=zh
languages[czech]=cs
languages[danish]=da
languages[dutch]=nl
languages[english]=en
languages[estonian]=et
languages[finnish]=fi
languages[french]=fr
languages[german]=de
languages[greek]=el
languages[hungarian]=hu
languages[italian]=it
languages[japanese]=ja
languages[latvian]=lv
languages[lithuanian]=lt
languages[polish]=pl
languages[portugese]=pt
languages[romanian]=ro
languages[russian]=ru
languages[slovakian]=sk
languages[slovenian]=sl
languages[spanish]=es
languages[swedish]=sv

target_html="$PWD/deepl-ff-bookmark-html.html"
target_func="$PWD/gits/bashrc_stuff/env/translate"

#[[ -f $target_html ]] && echo > $target_html
#[[ -f $target_func ]] && echo > $target_func

added="$(($(date +%s) + $RANDOM))"
modified="$(($(date +%s) + $RANDOM))"
dir_html="<DT><H3 ADD_DATE=\"${added}\" LAST_MODIFIED=\"${modified}\">DeepL</H3>"

printf "$dir_html\n" #> $target_html

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
            search_html="<DT><A HREF=\"${baseurl}${transurl}\" ADD_DATE=\"${added}\" LAST_MODIFIED=\"${modified}\" SHORTCUTURL=\"${keyword}\" TAGS=\"${tags}\">${title}</A>"

            printf "$search_html\n" #>> $target_html

            template="${from_code}-${to_code}() {\n    # DeepL Translate | ${from_lang}->${to_lang}\n    input=\"\${@:-\$(</dev/stdin)}\"\n    baseurl=\"${baseurl}\"\n    query=\"#${from_code}/${to_code}/\${input}\"\n\n    if ps -e | grep -q GeckoMain; then\n        (\n            {\n                /usr/bin/firefox --new-tab \"\${baseurl}\${query}\"\n            } >/dev/null 2>&1 &\n        )\n    else\n        (\n            {\n                /usr/bin/firefox --new-instance \"\${baseurl}\${query}\"\n            } >/dev/null 2>&1 &\n        )\n    fi\n}"

            printf  "$template\n" #>> "$target_func"
        fi
    done 

    [[ $count -lt ${#lang_codes[@]} ]] && count=$(($count + 1))
done
