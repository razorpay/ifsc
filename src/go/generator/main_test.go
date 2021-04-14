package main

import (
	"bytes"
	"io/ioutil"
	"path"
	"testing"
)

func Test_verifyConstantFile(t *testing.T) {
	var buff bytes.Buffer
	if err := GenerateConstantsFile(&buff); err != nil {
		t.Errorf("error generating constants file. error:%v", err)
	}
	dir, err := getCwd()
	if err != nil {
		t.Fatal(err)
	}
	constantsFilePath := path.Join(dir, "..", "constants.go")
	fileData, err := ioutil.ReadFile(constantsFilePath)
	if err != nil {
		t.Errorf("error reading constants file, err:%v", err)
	}
	if buff.String() != string(fileData) {
		t.Fatalf(`There is difference in constants file. Please regenerate the constants.go file and commit it.\n
		Use make generate-constants`)
	}

}
