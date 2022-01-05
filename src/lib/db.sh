#!/usr/bin/env bash

#/ Retrieve the list of all databases, excluding system databases
#/
#/ @usage var="$(get_databases_list "localhost" "3306" "root" "root")"
#/
#/ @param $1 Host
#/ @param $2 Port
#/ @param $3 User
#/ @param $4 Password
#/ @return Prints the result
get_databases_list () {
    if [ "$#" -ne 4 ]; then
        echo "4 argument required, $# provided"
        exit 1
    fi

    mysql -h "$1" -P "$2" -u "$3" -p"$4" -e "SHOW DATABASES;" \
        | tr -d "| " \
        | grep -Ev "Database|sys|mysql|(information|performance)_schema" \
        | tr '\n' ' ' \
        | sed 's/[ \r\n]*$//'
}

#/ Dump a single database in /tmp/backup/
#/
#/ @usage dump "localhost" "3306" "root" "root" "database_name"
#/
#/ @param $1 Host
#/ @param $2 Port
#/ @param $3 User
#/ @param $4 Password
#/ @param $4 Database name
dump () {
    if [ "$#" -ne 5 ]; then
        echo "5 argument required, $# provided"
        exit 1
    fi

    mkdir -p "/tmp/backup"
    mysqldump --single-transaction -h "$1" -P "$2" -u "$3" -p"$4" "$5" 2>/dev/null > "/tmp/backup/$5.sql"
}
