#!/bin/bash

# Re-generate the constant files and ensure they don't need to be updated

make generate-constants >/dev/null
for file in "src/go/constants.go" "src/php/Bank.php" "src/ruby/bank.rb" "src/node/bank.js"; do
	git diff -s --exit-code $file || (echo "[ERR] $file needs to be updated. Please run make generate-constants and commit $file" && exit 1)
done
