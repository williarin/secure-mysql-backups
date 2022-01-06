setup() {
    DIR="$( cd "$( dirname "$BATS_TEST_FILENAME" )" >/dev/null 2>&1 && pwd )"
    PATH="$DIR/../../src:$DIR/../../src/lib:$PATH"
}

@test "fails if no argument given" {
    source file.sh

    run get_archive_name
    [ "$status" -eq 1 ]
    [ "$output" = "At least 1 argument required, 0 provided" ]
}

@test "Wednesday creates a daily backup" {
    source file.sh

    shopt -s expand_aliases
    alias date="FAKETIME='2022-01-05 06:35:46' date"

    run get_archive_name "main-backup"
    echo "$output"
    [ "$status" -eq 0 ]
    [ "$output" = "main-backup.day3-Wednesday.tgz" ]
}

@test "Saturday creates a weekly backup" {
    source file.sh

    shopt -s expand_aliases
    alias date="FAKETIME='2022-02-19 12:54:11' date"

    run get_archive_name "main-backup"
    echo "$output"
    [ "$status" -eq 0 ]
    [ "$output" = "main-backup.week3.tgz" ]
}

@test "last day of the month creates a monthly backup" {
    source file.sh

    shopt -s expand_aliases
    alias date="FAKETIME='2022-02-28 18:43:24' date"

    run get_archive_name "main-backup"
    [ "$status" -eq 0 ]
    [ "$output" = "main-backup.month02.tgz" ]
}
