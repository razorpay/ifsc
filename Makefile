go-test:
	go test -tags=unit -timeout 2m -coverprofile=coverage.cov -v ./...

generate-constants:
	go run ./src/go/generator/main.go
