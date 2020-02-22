#!/usr/bin/env bash

if [ -z "$4" ]; then
    echo Syntax: confset \<section\> \<key\> \<value\> \<file\>
    exit 0
fi

section="$1"
key="$2"
value="$3"
file="$4"

# If the file is missing create it
if [[ ! -f "$file" ]]; then
    touch "$file"
fi

# If the file is missing the provided section it is created
# shellcheck disable=SC2143
if [[ -z "$(grep "\[$section\]" "$file")" ]]; then
    echo "[$section]" >> "$file"
fi

confget -f "$file" -s "$section" -c "$key"
res=$?

if [[ "$res" == "1" ]]; then
    # If file is missing the key it is added
    sed -i "s/\[$section]/\[$section]\n$key=$value/" "$file"
else
    # Otherwise change it
    sed -i "/^\[$section]/,/^\[/{s/^$key=.*/$key=$value/;}" "$file"
fi
