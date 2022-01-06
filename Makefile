all: test

.PHONY: test
test:
	@for file in $$(find ./src -type f); do shellcheck -e 1091,2012 --format=tty $$file; done;
	@./test/bats/bin/bats test/unit
