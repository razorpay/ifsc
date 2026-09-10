#!/bin/sh

test_env=$2

if [[ "${test_env}" = "ci" ]]; then
    echo "Setting up code"
    go env -w GOPRIVATE=github.com/razorpay
    apk add --no-cache git gcc xmlsec-dev libxml2 libltdl pkgconfig libc-dev openssl-dev
    export CGO_CFLAGS_ALLOW=".*"
    git config --global url."https://${GIT_TOKEN}:x-oauth-basic@github.com".insteadOf "https://github.com"
    go get -u golang.org/x/tools/cmd/goimports
    go get -u golang.org/x/lint/golint
    cp config/default.toml config/dev-test.toml
fi
