#!/bin/bash

dir=/tmp/report/"$(date +%Y%m%d%H%M%S)"
mkdir -p "$dir"
clair_ip=$(/sbin/ifconfig eth0 | grep 'inet addr:' | cut -d: -f2| cut -d' ' -f1)

for image in "$@"
do
    [[ "$image" =~ "clair-" ]] && continue
    [[ "$image" =~ ":" ]] || image="$image":latest
    LOG="$dir/$(echo "$image"| tr ":/" "_" |cut -d' ' -f1)"
    if [ "$VERBOSE" == 1 ]; then
        echo "Image = $image"
        clair-scanner --clair=http://clair:6060 --threshold="$THRESHOLD" --reportAll=false --ip="$clair_ip" --report="$LOG".json "$image" | tee "$LOG".log
    else
        clair-scanner --clair=http://clair:6060 --threshold="$THRESHOLD" --reportAll=false --ip="$clair_ip" --report="$LOG".json "$image" 1>/dev/null 2>&1
    fi
done

if [ -n "$(find "$dir" -name "*.json")" ]; then
    if [ "$VERBOSE" == 1 ]; then
        if jq -sM '.' "$dir"/*.json | jq '[.[] | select (.unapproved != []) | {image: .image, unapproved: .unapproved}]'|grep -v '^\[\]$'; then
            exit 1
        else
            rm -Rf "$dir"
            exit 0
        fi 
    else
        if jq -sM '.' "$dir"/*.json | jq '[.[] | select (.unapproved != []) | {image: .image, unapproved: .unapproved}]'|grep -v '^\[\]$' 1>/dev/null 2>&1; then
            exit 1
        else
            rm -Rf "$dir"
            exit 0
        fi 
    fi
else
    [[ "$VERBOSE" == 1 ]] && echo "No image scanned."
    exit 1
fi
