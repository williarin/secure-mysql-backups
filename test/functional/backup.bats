setup() {
    source "/usr/local/bin/lib/db.sh"

    wait_for_database "database" "3306" "root" "root" "60"
    mkdir -p /tmp/backup /backup
}

teardown() {
    run bash -c "rm -f /tmp/backup/* /backup/*"
    run mysql_command "database" "3306" "root" "root" "DROP DATABASE IF EXISTS alpha;"
    run mysql_command "database" "3306" "root" "root" "DROP DATABASE IF EXISTS beta;"
}

@test "creates a daily backup on a Thursday" {
    export MYSQL_HOST="database"
    export MYSQL_PASSWORD="root"
    export FAKETIME='2022-08-11 06:43:24'

    run backup
    [ "$status" -eq 0 ]
    [ -f "/backup/main-backup.day4-Thursday.tgz" ]
}

@test "creates a weekly backup on a Saturday" {
    export MYSQL_HOST="database"
    export MYSQL_PASSWORD="root"
    export FAKETIME='2022-08-13 06:43:24'

    run backup
    [ "$status" -eq 0 ]
    [ -f "/backup/main-backup.week2.tgz" ]
}

@test "creates a monthly backup at the end of the month" {
    export MYSQL_HOST="database"
    export MYSQL_PASSWORD="root"
    export FAKETIME='2022-08-31 06:43:24'

    run backup
    [ "$status" -eq 0 ]
    [ -f "/backup/main-backup.month08.tgz" ]
}

@test "creates a yearly backup at the end of the year" {
    export MYSQL_HOST="database"
    export MYSQL_PASSWORD="root"
    export FAKETIME='2022-12-31 06:43:24'

    run backup
    [ "$status" -eq 0 ]
    [ -f "/backup/main-backup.year2022.tgz" ]
}

@test "creates a daily backup on a Thursday - SuperSafe mode" {
    export MYSQL_HOST="database"
    export MYSQL_PASSWORD="root"
    export FAKETIME='2022-08-11 06:43:24'
    export SUPERSAFE_MODE=true

    run backup
    [ "$status" -eq 0 ]
    [ -f "/backup/main-backup.day11.tgz" ]
}

@test "creates a weekly backup on the 14th - SuperSafe mode" {
    export MYSQL_HOST="database"
    export MYSQL_PASSWORD="root"
    export FAKETIME='2022-08-14 06:43:24'
    export SUPERSAFE_MODE=true

    run backup
    [ "$status" -eq 0 ]
    [ -f "/backup/main-backup.week32.tgz" ]
}

@test "creates a yearly backup at the end of the year - SuperSafe mode" {
    export MYSQL_HOST="database"
    export MYSQL_PASSWORD="root"
    export FAKETIME='2022-12-31 06:43:24'
    export SUPERSAFE_MODE=true

    run backup
    [ "$status" -eq 0 ]
    [ -f "/backup/main-backup.year2022.tgz" ]
}

@test "creates a encrypted backup" {
    export MYSQL_HOST="database"
    export MYSQL_PASSWORD="root"
    export AES_PASSPHRASE="passphrase"
    export FAKETIME='2022-08-11 06:43:24'

    run backup
    [ "$status" -eq 0 ]
    [ -f "/backup/main-backup.day4-Thursday.tgz.aes" ]
}

@test "creates individual backups for each database" {
    export MYSQL_HOST="database"
    export MYSQL_PASSWORD="root"
    export INDIVIDUAL_BACKUPS=true
    export FAKETIME='2022-08-11 06:43:24'

    mysql_command "database" "3306" "root" "root" "CREATE DATABASE alpha;"
    mysql_command "database" "3306" "root" "root" "CREATE DATABASE beta;"

    run backup
    [ "$status" -eq 0 ]
    [ -f "/backup/main-backup.alpha.day4-Thursday.tgz" ]
    [ -f "/backup/main-backup.beta.day4-Thursday.tgz" ]
    [ -f "/backup/main-backup.my_db.day4-Thursday.tgz" ]
}

@test "creates individual encrypted backups for each database" {
    export MYSQL_HOST="database"
    export MYSQL_PASSWORD="root"
    export AES_PASSPHRASE="passphrase"
    export INDIVIDUAL_BACKUPS=true
    export FAKETIME='2022-08-11 06:43:24'

    mysql_command "database" "3306" "root" "root" "CREATE DATABASE alpha;"
    mysql_command "database" "3306" "root" "root" "CREATE DATABASE beta;"

    run backup
    [ "$status" -eq 0 ]
    [ -f "/backup/main-backup.alpha.day4-Thursday.tgz.aes" ]
    [ -f "/backup/main-backup.beta.day4-Thursday.tgz.aes" ]
    [ -f "/backup/main-backup.my_db.day4-Thursday.tgz.aes" ]
}
