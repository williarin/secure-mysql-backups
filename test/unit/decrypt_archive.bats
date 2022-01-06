setup() {
    DIR="$( cd "$( dirname "$BATS_TEST_FILENAME" )" >/dev/null 2>&1 && pwd )"
    PATH="$DIR/../../src:$DIR/../../src/lib:$PATH"
    source file.sh

    mkdir -p /tmp/backup /backup
    chown "$USER:$GROUP" /tmp/backup /backup
}

@test "fails if no argument given" {
    run decrypt_archive
    [ "$status" -eq 1 ]
    [ "$output" = "1 argument required, 0 provided" ]
}

@test "fails if no passphrase given" {
    run decrypt_archive "my-backup-name.my_db.day1-Monday.tgz"
    [ "$status" -eq 1 ]
    [ "$output" = "You must provide a passphrase to decrypt the file" ]
}

@test "decrypts an archive" {
    echo "MYSQL_DUMP" > /tmp/backup/my_db.sql

    AES_PASSPHRASE="secret-passphrase"

    run create_archive "my-backup-name.my_db.day1-Monday.tgz" "my_db.sql"

    run decrypt_archive "my-backup-name.my_db.day1-Monday.tgz.aes"
    [ "$status" -eq 0 ]
    [ -f "/backup/my-backup-name.my_db.day1-Monday.tgz" ]

    run tar xzf "/backup/my-backup-name.my_db.day1-Monday.tgz" -C /backup/
    [ "$status" -eq 0 ]
    [ -f "/backup/my_db.sql" ]
    [ "$(cat /backup/my_db.sql)" == "MYSQL_DUMP" ]

    run rm -f /backup/my-backup-name.my_db.day1-Monday.tgz /backup/my-backup-name.my_db.day1-Monday.tgz.aes
}

@test "decrypts an archive and set permissions to another user and group" {
    echo "MYSQL_DUMP" > /tmp/backup/my_db.sql

    CHOWN_FILES="1000:1000"
    AES_PASSPHRASE="secret-passphrase"

    run create_archive "my-backup-name.my_db.day1-Monday.tgz" "my_db.sql"

    run decrypt_archive "my-backup-name.my_db.day1-Monday.tgz.aes"
    [ "$status" -eq 0 ]
    [ -f "/backup/my-backup-name.my_db.day1-Monday.tgz" ]
    [ "$(get_file_uid "/backup/my-backup-name.my_db.day1-Monday.tgz")" -eq 1000 ]
    [ "$(get_file_gid "/backup/my-backup-name.my_db.day1-Monday.tgz")" -eq 1000 ]

    run tar xzf "/backup/my-backup-name.my_db.day1-Monday.tgz" -C /backup/
    [ "$status" -eq 0 ]
    [ -f "/backup/my_db.sql" ]
    [ "$(cat /backup/my_db.sql)" == "MYSQL_DUMP" ]

    run rm -f /backup/my-backup-name.my_db.day1-Monday.tgz /backup/my-backup-name.my_db.day1-Monday.tgz.aes
}
