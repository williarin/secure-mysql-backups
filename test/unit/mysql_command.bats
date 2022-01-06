setup() {
    DIR="$( cd "$( dirname "$BATS_TEST_FILENAME" )" >/dev/null 2>&1 && pwd )"
    PATH="$DIR/../../src:$DIR/../../src/lib:$PATH"
    source db.sh

    wait_for_database "database" "3306" "root" "root" "60"
}

@test "fails if no argument given" {
    run mysql_command
    [ "$status" -eq 1 ]
    [ "$output" = "5 arguments required, 0 provided" ]
}

@test "outputs the command result" {
    run mysql_command "database" "3306" "root" "root" "SELECT 356"
    [ "$status" -eq 0 ]
    [ "$output" = "356" ]
}
