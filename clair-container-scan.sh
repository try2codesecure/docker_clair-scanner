#!/bin/bash

usage() {
    echo "Usage: $0 [-p]"
    echo
    echo "Options:"
    echo " -p : Pull images before running scan"
    echo " -v : verbose output"
    echo " -t : set threshold value ('Defcon1', 'Critical', 'High', 'Medium', 'Low', 'Negligible', 'Unknown')"
    exit 1
}

redirect_stderr() {
    if [ "$VERBOSE" = 1 ]; then
        "$@"
    else
        "$@" 2>/dev/null
    fi
}

redirect_all() {
    if [ "$VERBOSE" = 1 ]; then
        "$@"
    else
        "$@" 2>/dev/null >/dev/null
    fi
}

PULL=0
VERBOSE=0

while getopts ":phvt:" opt; do
    case $opt in
        p)
            PULL=1
            ;;
        v)
            VERBOSE=1
            ;;
        t)
            THRESHOLD=${OPTARG}
            ;;
        \?)
            echo "Invalid option: -$OPTARG" >&2
            usage
            ;;
        h)
            usage
            ;;
    esac
done
# set default threshold value if unset
if [[ "${THRESHOLD}" != @(Defcon1|Critical|High|Medium|Low|Negligible|Unknown) ]]; then
	THRESHOLD=High
	[[ "$VERBOSE" = 1 ]] && echo "threshold value invalid or unset, take default=$THRESHOLD"
fi


shift $(($OPTIND -1))
BASEDIR=$(cd $(dirname "$0") && pwd)
cd "$BASEDIR"

if [ ! -f "docker-compose.yaml" ]; then
    wget -q https://raw.githubusercontent.com/usr42/clair-container-scan/master/docker-compose.yaml
fi

[ "$PULL" = 1 ] && redirect_all docker-compose pull && docker pull "$@" && docker-compose build
redirect_stderr docker-compose run --rm -e "THRESHOLD=$THRESHOLD" scanner "$@"
ret=$?
redirect_all docker-compose down
exit $ret
