#!/bin/sh

mkdir -p /tmp/report/
clair_ip=$(/sbin/ifconfig eth0 | grep 'inet addr:' | cut -d: -f2| cut -d' ' -f1)

for image in "$@"
do
    clair-scanner -c=http://clair:6060 -t=$THRESHOLD --reportAll=false --ip=$clair_ip -r /tmp/report/$(echo $image|md5sum |cut -d' ' -f1).json $image > /tmp/report/$(echo $image|md5sum |cut -d' ' -f1).log 2>&1
done

if [ -n "$(ls -A /tmp/report)" ]
then
    #jq -sM . /tmp/report/*.json | jq '[.[] | select (.vulnerabilities != []) | {image: .image, vulnerabilities: .vulnerabilities}]'|grep -v '^\[\]$' && exit 1 || exit 0
    find /tmp/report/*.json -type f -mmin -20 -exec cat {} \; | jq -sM '.' | jq '[.[] | select (.unapproved != []) | {image: .image, unapproved: .unapproved}]'|grep -v '^\[\]$' && exit 1 || exit 0
else
    echo "No image scanned."
    exit 1
fi
