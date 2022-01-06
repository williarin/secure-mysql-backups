setup() {
    DIR="$( cd "$( dirname "$BATS_TEST_FILENAME" )" >/dev/null 2>&1 && pwd )"
    PATH="$DIR/../../src:$DIR/../../src/lib:$PATH"
    source db.sh

    wait_for_database "database" "3306" "root" "root" "60"
}

teardown() {
    run mysql_command "database" "3306" "root" "root" "DROP DATABASE IF EXISTS alpha;"
    run mysql_command "database" "3306" "root" "root" "DROP DATABASE IF EXISTS beta;"
}

@test "fails if no argument given" {
    run get_databases_list
    [ "$status" -eq 1 ]
    [ "$output" = "4 arguments required, 0 provided" ]
}

@test "outputs the default database" {
    run get_databases_list "database" "3306" "root" "root"
    [ "$status" -eq 0 ]
    [ "$output" = "my_db" ]
}

@test "outputs all databases" {
    run mysql_command "database" "3306" "root" "root" "CREATE DATABASE alpha;"
    run mysql_command "database" "3306" "root" "root" "CREATE DATABASE beta;"

    run get_databases_list "database" "3306" "root" "root"
    [ "$status" -eq 0 ]
    [ "$output" = "alpha beta my_db" ]
}
