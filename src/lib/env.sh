#!/usr/bin/env bash

set -euo pipefail

#/ Helper function to lookup "env_FILE", "env", then fallback
#/
#/ @usage var="$(get_env "MYSQL_PASSWORD" "fallback_value")"
#/
#/ @param $1 Env var to get (without _FILE suffix)
#/ @param $2 Fallback value
#/ @return Prints the result
get_env () {
    if [ "$#" -lt 1 ]; then
        echo "1 argument required, $# provided"
        exit 1
    fi

    local var="$1_FILE"
    if [ -n "${!var+undefined}" ]; then
        cat "${!var}" | sed 's/[\r\n]*$//'
        return
    fi

    var="$1"
    if [ -n "${!var+undefined}" ]; then
        echo "${!var}"
        return
    fi

    echo "${2-}"
}
