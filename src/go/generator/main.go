package main

import (
	"errors"
	"fmt"
	"html/template"
	"io"
	"io/ioutil"
	"log"
	"os"
	"path"
	"regexp"
	"runtime"
)

type bankConstants struct {
	Value []string
}

func ExtractPhpConstant() (*bankConstants, error) {
	re := regexp.MustCompile(`(?P<bankCode>[A-Z]{4}) =`)
	_, fileN, _, ok := runtime.Caller(0)
	if !ok {
		return nil, errors.New("it was not possible to recover the information. Caller function error")
	}
	dir, _ := path.Split(fileN)
	phpFilePath := path.Join(dir, "..", "..", "php", "Bank.php")
	bytes, err := ioutil.ReadFile(phpFilePath)
	if err != nil {
		return nil, err
	}
	matches := re.FindAllStringSubmatch(string(bytes), -1)
	var result bankConstants
	for _, match := range matches {
		result.Value = append(result.Value, match[1])
	}
	return &result, nil
}

func GenerateConstantsFile(writer io.Writer) error {
	cwd, err := getCwd()
	if err != nil {
		log.Fatal(err)
	}
	templateFilePath := path.Join(cwd, "constants.template")
	fileBytes, err := ioutil.ReadFile(templateFilePath)
	if err != nil {
		return err
	}
	constantsArr, err := ExtractPhpConstant()
	if err != nil {
		return err
	}
	t := template.Must(template.New("constants.template").Parse(string(fileBytes)))
	t.Execute(writer, constantsArr)
	fmt.Printf("added %d constants ", len(constantsArr.Value))
	return nil
}
func getCwd() (string, error) {
	_, fileN, _, ok := runtime.Caller(0)
	if !ok {
		return "", errors.New("it was not possible to recover the information. Caller function error")
	}
	dir, _ := path.Split(fileN)
	return dir, nil
}
func main() {
	cwd, err := getCwd()
	if err != nil {
		log.Fatal(err)
	}
	constantsFilePath := path.Join(cwd, "..", "constants.go")
	os.Remove(constantsFilePath)
	file, err := os.Create(constantsFilePath)
	if err != nil {
		log.Fatal(err)
	}
	if err := GenerateConstantsFile(file); err != nil {
		log.Printf("error generation constants file, err:%v", err)
	}
	fmt.Printf("saved to %v \n", constantsFilePath)
}
