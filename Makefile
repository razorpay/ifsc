go-test:
	go test -tags=unit -timeout 2m -coverprofile=coverage.cov -v ./...

generate-constants:
	go run ./src/go/generator/main.go ./src/go/generator/constants.template ./src/go/constants.go
	go run ./src/go/generator/main.go ./src/php/Bank.php.tpl ./src/php/Bank.php
	go run ./src/go/generator/main.go ./src/ruby/bank.rb.tpl ./src/ruby/bank.rb
	go run ./src/go/generator/main.go ./src/node/bank.js.tpl ./src/node/bank.js
