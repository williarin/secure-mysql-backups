setup() {
    DIR="$( cd "$( dirname "$BATS_TEST_FILENAME" )" >/dev/null 2>&1 && pwd )"
    PATH="$DIR/../../src:$DIR/../../src/lib:$PATH"
    source file.sh
}

@test "fails if no argument given" {
    run get_file_gid
    [ "$status" -eq 1 ]
    [ "$output" = "1 argument required, 0 provided" ]
}

@test "fails if file does not exist" {
    file="/not_a_file"

    run get_file_gid "$file"
    [ "$status" -eq 1 ]
    [ "$output" = "File $file does not exist" ]
}

@test "outputs file's known user gid" {
    file="/tmp/test_file"
    touch "$file"

    run get_file_gid "$file"
    [ "$status" -eq 0 ]
    [ "$output" = "0" ]

    run rm "$file"
}

@test "outputs file's unknown user gid" {
    file="/tmp/test_file"
    touch "$file"
    chown "1054:2344" "$file"

    run get_file_gid "$file"
    [ "$status" -eq 0 ]
    [ "$output" = "2344" ]

    run rm "$file"
}

