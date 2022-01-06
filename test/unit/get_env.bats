setup() {
    DIR="$( cd "$( dirname "$BATS_TEST_FILENAME" )" >/dev/null 2>&1 && pwd )"
    PATH="$DIR/../../src:$DIR/../../src/lib:$PATH"
    source env.sh
}

@test "fails if no argument given" {
    run get_env
    [ "$status" -eq 1 ]
    [ "$output" = "1 argument required, 0 provided" ]
}

@test "outputs env_FILE value" {
    echo "super-secret-passphrase" > /tmp/bats-secret
    TEST_VAR_FILE="/tmp/bats-secret"

    run get_env "TEST_VAR"
    [ "$status" -eq 0 ]
    [ "$output" = "super-secret-passphrase" ]
}

@test "outputs env value" {
    TEST_VAR="secret-passphrase"

    run get_env "TEST_VAR"
    [ "$status" -eq 0 ]
    [ "$output" = "secret-passphrase" ]
}

@test "outputs env fallback" {
    run get_env "TEST_VAR" "fallback-passphrase"
    [ "$status" -eq 0 ]
    [ "$output" = "fallback-passphrase" ]
}
