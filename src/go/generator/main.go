package main

import ( // nosemgrep go.lang.security.audit.xss.import-text-template.import-text-template

	"encoding/json"
	"fmt"
	"io"
	"io/ioutil"
	"log"
	"os"
	"sort"
	"text/template"
)

func GetConstants() map[string]string {

	var (
		data map[string]string
		keys []string
	)

	jsonString, _ := ioutil.ReadFile("src/banknames.json")

	json.Unmarshal(jsonString, &data)

	for k := range data {
		keys = append(keys, k)
	}

	sort.Strings(keys)

	sortedData := make(map[string]string, len(keys)+1)
	for _, k := range keys {
		sortedData[k] = data[k]
	}
	return sortedData
}

func GenerateConstantsFile(outputFileWriter io.Writer, templateFilePath string, constantsArr map[string]string) error {
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
