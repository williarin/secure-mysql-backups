setup() {
    DIR="$( cd "$( dirname "$BATS_TEST_FILENAME" )" >/dev/null 2>&1 && pwd )"
    PATH="$DIR/../../src:$DIR/../../src/lib:$PATH"
    source file.sh
}

@test "fails if no argument given" {
    run get_archive_name_supersafe_mode
    [ "$status" -eq 1 ]
    [ "$output" = "At least 1 argument required, 0 provided" ]
}

@test "5th of the month creates a daily backup" {
    shopt -s expand_aliases
    alias date="FAKETIME='2022-07-05 06:35:46' date"

    run get_archive_name_supersafe_mode "main-backup"
    [ "$status" -eq 0 ]
    [ "$output" = "main-backup.day05.tgz" ]
}

@test "21st of the month creates a weekly backup all year" {
    shopt -s expand_aliases
    alias date="FAKETIME='2022-06-21 06:35:46' date"

    run get_archive_name_supersafe_mode "main-backup"
    [ "$status" -eq 0 ]
    [ "$output" = "main-backup.week25.tgz" ]
}

@test "last day of the year creates a yearly backup" {
    shopt -s expand_aliases
    alias date="FAKETIME='2021-12-31 06:35:46' date"

    run get_archive_name_supersafe_mode "main-backup"
    [ "$status" -eq 0 ]
    [ "$output" = "main-backup.year2021.tgz" ]
}
