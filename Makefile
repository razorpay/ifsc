SRC_DIR="./src/go"
.PHONY: test
test:
	cd $(SRC_DIR);go test -tags=unit -timeout 2m -coverprofile=coverage.cov -v ./...
