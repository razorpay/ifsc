go-test:
	go test -tags=unit -timeout 2m -coverprofile=coverage.cov -v ./...

generate-constants:
	go run ./src/go/generator/main.go ./src/go/generator/constants.template ./src/go/constants.go
	go run ./src/go/generator/main.go ./src/php/Bank.php.tpl ./src/php/Bank.php
	go run ./src/go/generator/main.go ./src/ruby/bank.rb.tpl ./src/ruby/bank.rb
	go run ./src/go/generator/main.go ./src/node/bank.js.tpl ./src/node/bank.js

# CI guard: regenerate the SDK constant files from banknames.json and fail if
# they differ from what is committed. Catches the case where someone edits
# banknames.json without re-running `make generate-constants`, or edits one of
# the generated files by hand.
check-constants:
	@$(MAKE) generate-constants
	@if ! git diff --quiet -- src/ruby/bank.rb src/php/Bank.php src/node/bank.js src/go/constants.go; then \
		echo "ERROR: SDK constant files are out of sync with src/banknames.json."; \
		echo "Run 'make generate-constants' and commit the changes."; \
		git --no-pager diff -- src/ruby/bank.rb src/php/Bank.php src/node/bank.js src/go/constants.go; \
		exit 1; \
	fi
	@echo "OK: bank.rb, Bank.php, bank.js, constants.go are in sync with banknames.json"
