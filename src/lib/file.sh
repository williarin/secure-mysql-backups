#!/usr/bin/env bash

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)
source "$SCRIPT_DIR/env.sh"

#/ Get an archive name corresponding to the current name
#/
#/ @usage var="$(get_archive_name "my-backup-name")"
#/
#/ @param $1 Backup name
#/ @return Prints the result
get_archive_name () {
    if [ "$#" -lt 1 ]; then
        echo "At least 1 argument required, $# provided"
        exit 1
    fi

    local day day_num month_num week_file backup_name archive_file
    backup_name="$1"

    # Find which week of the month 1-4 it is.
    day_num=$(date +%-d)
    if (( day_num <= 7 )); then
        week_file="$backup_name.week1.tgz"
    elif (( day_num > 7 && day_num <= 14 )); then
        week_file="$backup_name.week2.tgz"
    elif (( day_num > 14 && day_num <= 21 )); then
        week_file="$backup_name.week3.tgz"
    elif (( day_num > 21 && day_num < 32 )); then
        week_file="$backup_name.week4.tgz"
    fi

    # Create archive filename.
    day=$(date +%A)
    if [ "$(date +%-d)" -eq "$(date -d "$(date +%-m)/1 + 1 month - 1 day" "+%d")" ]; then
        month_num=$(date +%m)
        archive_file="$backup_name.month$month_num.tgz"
    elif [ "$day" != "Saturday" ]; then
        day_of_the_week=$(date +%-u)
        archive_file="$backup_name.day$day_of_the_week-$day.tgz"
    else
        archive_file=$week_file
    fi

    echo "$archive_file"
}

#/ Create an archive given an archive name and files list
#/
#/ @usage create_archive "my-backup-name.my_db.day1-Monday.tgz" "my_db.sql"
#/
#/ @param $1 Archive name
#/ @param $2 Files to archive
#/ @return Prints the result
create_archive () {
    if [ "$#" -ne 2 ]; then
        echo "2 arguments required, $# provided"
        exit 1
    fi

    local max_cpu chown_files passphrase archive_file owner group

    archive_file="$1"
    max_cpu="$(get_env "MAX_CPU" "$(grep -c ^processor /proc/cpuinfo)")"
    passphrase="$(get_env "AES_PASSPHRASE")"
    chown_files="$(get_env "CHOWN_FILES" "root:root")"
    owner="$(echo "$chown_files" | cut -d ":" -f1)"
    group="$(echo "$chown_files" | cut -d ":" -f2)"

    find /tmp/backup/ -type f -name "$2" -exec tar --owner="$owner" --group="$group" -P --transform="s@/tmp/backup/@@g" -cf - {} + \
        | pigz -9 -p "$max_cpu" \
        > "/tmp/backup/$archive_file"

    if [ -n "$passphrase" ]; then
        openssl enc -e -aes-256-cbc -md sha512 -pbkdf2 -iter 100000 -pass pass:"${passphrase}" -in "/tmp/backup/$archive_file" -out "/backup/$archive_file.aes"
    else
        mv "/tmp/backup/$archive_file" "/backup/$archive_file"
    fi

    bash -c "rm -f /tmp/backup/$2 /tmp/backup/$archive_file"
    chown -f "$chown_files" "/backup/$archive_file" "/backup/$archive_file.aes"
    exit 0
}


#/ Decrypt an archive file. The decrypted archive will be placed in the /backup directory as well.
#/
#/ @usage decrypt_archive "my-backup-name.my_db.day1-Monday.tgz"
#/
#/ @param $1 Archive name
decrypt_archive () {
    local passphrase chown_files
    passphrase="$(get_env "AES_PASSPHRASE")"
    chown_files="$(get_env "CHOWN_FILES" "root:root")"

    if [ "$#" -ne 1 ]; then
        echo "1 argument required, $# provided"
        exit 1
    fi

    if [ -z "$passphrase" ]; then
        echo "You must provide a passphrase to decrypt the file"
        exit 1
    fi

    openssl enc -d -aes-256-cbc -md sha512 -pbkdf2 -iter 100000 -pass pass:"${passphrase}" -in "/backup/$1" -out "/backup/${1%.aes}"
    chown -f "$chown_files" "/backup/${1%.aes}"
}
