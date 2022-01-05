setup() {
    DIR="$( cd "$( dirname "$BATS_TEST_FILENAME" )" >/dev/null 2>&1 && pwd )"
    PATH="$DIR/../../src:$DIR/../../src/lib:$PATH"
}

@test "fails if no argument given" {
    source env.sh

    run get_env
    [ "$status" -eq 1 ]
    [ "$output" = "1 argument required, 0 provided" ]
}

@test "outputs env_FILE value" {
    source env.sh

    echo "super-secret-passphrase" > /tmp/bats-secret
    TEST_VAR_FILE="/tmp/bats-secret"

    run get_env "TEST_VAR"
    [ "$status" -eq 0 ]
    [ "$output" = "super-secret-passphrase" ]
}

@test "outputs env value" {
    source env.sh

    TEST_VAR="secret-passphrase"

    run get_env "TEST_VAR"
    [ "$status" -eq 0 ]
    [ "$output" = "secret-passphrase" ]
}

@test "outputs env fallback" {
    source env.sh

    run get_env "TEST_VAR" "fallback-passphrase"
    [ "$status" -eq 0 ]
    [ "$output" = "fallback-passphrase" ]
}
