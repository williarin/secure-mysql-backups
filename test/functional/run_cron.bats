@test "run-cron command runs without error" {
    export TEST_ENV=true

    run run-cron
    [ "$status" -eq 124 ]
    [ "${lines[0]}" = "Launching cron service..." ]
    [ "${#lines[@]}" -eq 1 ]
}

@test "run-cron command creates default cron entry" {
    export TEST_ENV=true

    run run-cron
    [ "$status" -eq 124 ]
    [ "$(cat /etc/crontabs/root)" = "0 0 * * * backup >> /var/log/backup.log" ]
}

@test "run-cron command creates cron with overriden minutes" {
    export TEST_ENV=true
    export CRON_MINUTE=12

    run run-cron
    [ "$status" -eq 124 ]
    [ "$(cat /etc/crontabs/root)" = "12 0 * * * backup >> /var/log/backup.log" ]
}

@test "run-cron command creates cron with overriden hours" {
    export TEST_ENV=true
    export CRON_HOUR=5

    run run-cron
    [ "$status" -eq 124 ]
    [ "$(cat /etc/crontabs/root)" = "0 5 * * * backup >> /var/log/backup.log" ]
}

@test "run-cron command creates cron fully overriden" {
    export TEST_ENV=true
    export CRON_TIME="*/10 9 * * sun"

    run run-cron
    [ "$status" -eq 124 ]
    [ "$(cat /etc/crontabs/root)" = "*/10 9 * * sun backup >> /var/log/backup.log" ]
}
