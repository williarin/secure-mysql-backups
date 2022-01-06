setup() {
    DIR="$( cd "$( dirname "$BATS_TEST_FILENAME" )" >/dev/null 2>&1 && pwd )"
    PATH="$DIR/../../src:$DIR/../../src/lib:$PATH"
    source db.sh

    wait_for_database "database" "3306" "root" "root" "60"
}

teardown() {
    run bash -c "rm -f /tmp/backup/*"
}

@test "fails if no argument given" {
    run dump_database
    [ "$status" -eq 1 ]
    [ "$output" = "5 arguments required, 0 provided" ]
}

@test "dumps a database" {
    run dump_database "database" "3306" "root" "root" "my_db"
    [ "$status" -eq 0 ]
    [ -f "/tmp/backup/my_db.sql" ]
    [[ "$(head -n1 "/tmp/backup/my_db.sql")" = *"-- MariaDB dump"* ]]
}
