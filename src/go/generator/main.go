package main

import ( // nosemgrep go.lang.security.audit.xss.import-text-template.import-text-template
	"fmt"
	"text/template"
	"io"
	"io/ioutil"
	"log"
	"os"
	"sort"
	"encoding/json"
)


type bankConstants struct {
	Value []string
}


func GetConstants() (*bankConstants) {
	jsonString, _ := ioutil.ReadFile("src/banknames.json")
	var result bankConstants
	var data map[string]interface{}
	json.Unmarshal([]byte(jsonString), &data)

	keys := []string{}
	for k := range data {
		keys = append(keys, k)
	}

	sort.Strings(keys)

	for _,k := range keys {
		result.Value = append(result.Value, k)
	}
	return &result
}

func GenerateConstantsFile(outputFileWriter io.Writer, templateFilePath string, constantsArr *bankConstants) error {
	fileBytes, err := ioutil.ReadFile(templateFilePath)
	if err != nil {
		return err
	}

	t := template.Must(template.New(templateFilePath).Parse(string(fileBytes)))
	t.Execute(outputFileWriter, constantsArr)

	return nil
}

func main() {
	constantsArr := GetConstants()
	templateFilePath := os.Args[1]
	outputFilePath := os.Args[2]

	writer, err := os.Create(outputFilePath)
	if err != nil {
		log.Fatal(err)
	}

	if err := GenerateConstantsFile(writer, templateFilePath, constantsArr); err != nil {
		log.Printf("error generation constants file, err:%v", err)
	}
	fmt.Printf("Updated %v \n", outputFilePath)
}
