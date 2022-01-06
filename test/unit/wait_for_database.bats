setup() {
    DIR="$( cd "$( dirname "$BATS_TEST_FILENAME" )" >/dev/null 2>&1 && pwd )"
    PATH="$DIR/../../src:$DIR/../../src/lib:$PATH"
    source db.sh
}

@test "fails if no argument given" {
    run wait_for_database
    [ "$status" -eq 1 ]
    [ "$output" = "5 arguments required, 0 provided" ]
}

@test "fails if not reaching host" {
    run wait_for_database "fakehost" "3306" "root" "root" "1"
    [ "$status" -eq 1 ]
    [[ "$output" == *"ERROR 2005 (HY000): Unknown server host 'fakehost'"* ]]
}

@test "succeeds if database is reachable" {
    run wait_for_database "database" "3306" "root" "root" "60"
    [ "$status" -eq 0 ]
}
