setup() {
    DIR="$( cd "$( dirname "$BATS_TEST_FILENAME" )" >/dev/null 2>&1 && pwd )"
    PATH="$DIR/../../src:$DIR/../../src/lib:$PATH"
    source file.sh

    mkdir -p /tmp/backup /backup
    chown "$USER:$GROUP" /tmp/backup /backup
}

@test "fails if no argument given" {
    run create_archive
    [ "$status" -eq 1 ]
    [ "$output" = "2 arguments required, 0 provided" ]
}

@test "fails if 1 argument given" {
    run create_archive "my-backup-name.my_db.day1-Monday.tgz"
    [ "$status" -eq 1 ]
    [ "$output" = "2 arguments required, 1 provided" ]
}

@test "creates a tgz archive with a single file" {
    echo "MYSQL_DUMP" > /tmp/backup/my_db.sql

    run create_archive "my-backup-name.my_db.day1-Monday.tgz" "my_db.sql"
    [ "$status" -eq 0 ]
    [ -f "/backup/my-backup-name.my_db.day1-Monday.tgz" ]
    [ ! -f "/tmp/backup/my_db.sql" ]

    run tar xzf "/backup/my-backup-name.my_db.day1-Monday.tgz" -C /backup/
    [ "$status" -eq 0 ]
    [ -f "/backup/my_db.sql" ]
    [ "$(cat /backup/my_db.sql)" == "MYSQL_DUMP" ]

    run rm -f /backup/my_db.sql /backup/my-backup-name.my_db.day1-Monday.tgz
}

@test "creates a tgz archive with multiple files" {
    echo "MYSQL_DUMP1" > /tmp/backup/my_db1.sql
    echo "MYSQL_DUMP2" > /tmp/backup/my_db2.sql
    echo "MYSQL_DUMP3" > /tmp/backup/my_db3.sql

    run create_archive "my-backup-name.my_db.day3-Wednesday.tgz" "*.sql"
    [ "$status" -eq 0 ]
    [ -f "/backup/my-backup-name.my_db.day3-Wednesday.tgz" ]
    [ ! -f "/tmp/backup/my_db1.sql" ]
    [ ! -f "/tmp/backup/my_db2.sql" ]
    [ ! -f "/tmp/backup/my_db3.sql" ]

    run tar xzf "/backup/my-backup-name.my_db.day3-Wednesday.tgz" -C /backup/
    [ "$status" -eq 0 ]
    [ -f "/backup/my_db1.sql" ]
    [ -f "/backup/my_db2.sql" ]
    [ -f "/backup/my_db3.sql" ]
    [ "$(cat /backup/my_db1.sql)" == "MYSQL_DUMP1" ]
    [ "$(cat /backup/my_db2.sql)" == "MYSQL_DUMP2" ]
    [ "$(cat /backup/my_db3.sql)" == "MYSQL_DUMP3" ]

    run rm -f /backup/my_db{1,2,3}.sql /backup/my-backup-name.my_db.day3-Wednesday.tgz
}

@test "creates a tgz archive with AES encryption" {
    echo "MYSQL_DUMP" > /tmp/backup/my_db.sql

    AES_PASSPHRASE="secret-passphrase"

    run create_archive "my-backup-name.my_db.day1-Monday.tgz" "my_db.sql"
    [ "$status" -eq 0 ]
    [ -f "/backup/my-backup-name.my_db.day1-Monday.tgz.aes" ]
    [ ! -f "/backup/my-backup-name.my_db.day1-Monday.tgz" ]
    [ ! -f "/tmp/backup/my_db.sql" ]

    run rm -f /backup/my-backup-name.my_db.day1-Monday.tgz.aes
}

@test "creates a tgz archive with another owner and group" {
    echo "MYSQL_DUMP" > /tmp/backup/my_db.sql

    CHOWN_FILES="1000:2500"

    run create_archive "my-backup-name.my_db.day1-Monday.tgz" "my_db.sql"
    [ "$status" -eq 0 ]
    [ -f "/backup/my-backup-name.my_db.day1-Monday.tgz" ]
    [ ! -f "/tmp/backup/my_db.sql" ]
    [ "$(get_file_uid "/backup/my-backup-name.my_db.day1-Monday.tgz")" -eq 1000 ]
    [ "$(get_file_gid "/backup/my-backup-name.my_db.day1-Monday.tgz")" -eq 2500 ]

    run tar xzf "/backup/my-backup-name.my_db.day1-Monday.tgz" -C /backup/
    [ "$status" -eq 0 ]
    [ -f "/backup/my_db.sql" ]
    [ "$(cat /backup/my_db.sql)" == "MYSQL_DUMP" ]
    [ "$(get_file_uid "/backup/my_db.sql")" -eq 1000 ]
    [ "$(get_file_gid "/backup/my_db.sql")" -eq 2500 ]

    run rm -f /backup/my_db.sql /backup/my-backup-name.my_db.day1-Monday.tgz
}

@test "creates a tgz archive using 1 CPU only" {
    echo "MYSQL_DUMP" > /tmp/backup/my_db.sql

    MAX_CPU=1

    run create_archive "my-backup-name.my_db.day1-Monday.tgz" "my_db.sql"
    [ "$status" -eq 0 ]
    [ -f "/backup/my-backup-name.my_db.day1-Monday.tgz" ]
    [ ! -f "/tmp/backup/my_db.sql" ]

    run rm -f /backup/my-backup-name.my_db.day1-Monday.tgz
}
