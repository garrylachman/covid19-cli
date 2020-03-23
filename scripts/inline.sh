#!/usr/bin/env bash

old_IFS=$IFS # save the field separator
IFS=$'\n' # new field separator, the end of line
while read -r line; do
    if [[ "$line" =~ (\.|source)\s+.+ ]]; then
        file="$(echo $line | cut -d' ' -f2)"
        printf '%s\n' "$(cat $file)"
    else

      printf '%s\n' "$line"
    fi
done < "$1"
IFS=$old_IFS # restore default field separator
