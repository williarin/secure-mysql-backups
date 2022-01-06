setup() {
    DIR="$( cd "$( dirname "$BATS_TEST_FILENAME" )" >/dev/null 2>&1 && pwd )"
    PATH="$DIR/../../src:$DIR/../../src/lib:$PATH"
}

@test "fails if no argument given" {
    source file.sh

    run get_file_uid
    [ "$status" -eq 1 ]
    [ "$output" = "1 argument required, 0 provided" ]
}

@test "fails if file does not exist" {
    source file.sh

    file="/not_a_file"

    run get_file_uid "$file"
    [ "$status" -eq 1 ]
    [ "$output" = "File $file does not exist" ]
}

@test "outputs file's known user uid" {
    source file.sh

    file="/tmp/test_file"
    touch "$file"

    run get_file_uid "$file"
    [ "$status" -eq 0 ]
    [ "$output" = "0" ]

    run rm "$file"
}

@test "outputs file's unknown user uid" {
    source file.sh

    file="/tmp/test_file"
    touch "$file"
    chown "1054:2344" "$file"

    run get_file_uid "$file"
    [ "$status" -eq 0 ]
    [ "$output" = "1054" ]

    run rm "$file"
}

