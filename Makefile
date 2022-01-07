all: test

.PHONY: test
test:
	@printf "▶ Check scripts syntax\n"
	@for file in $$(find ./src -type f); do shellcheck -e 1091,2012 --format=tty $$file; done;
	@printf "\n▶ Run unit tests\n"
	@./test/bats/bin/bats test/unit
	@printf "\n▶ Run functional tests\n"
	@./test/bats/bin/bats test/functional
