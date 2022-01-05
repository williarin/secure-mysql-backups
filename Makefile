all: test build

.PHONY: test
test:
	@for file in $$(find src -type f); do shellcheck --format=tty $$file; done;
	@sudo ./test/bats/bin/bats test/unit

.PHONY: build
build:
	docker build -t williarin/secure-mysql-backups:latest --target base .
