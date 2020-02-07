package main

import (
	"encoding/json"
	"fmt"
	"io/ioutil"
	"os"
	"strconv"
)

var ifsc map[string][]Data
var bankNames map[string]string
var sublet map[string]string
var customSublets map[string]string

type Data struct {
	Value string
}

func (d Data) MarshalJSON() ([]byte, error) {
	return json.Marshal(d.Value)
}

func (d *Data) UnmarshalJSON(input []byte) error {
	var value int
	if err := json.Unmarshal(input, &value); err != nil {
		var value string
		if err := json.Unmarshal(input, &value); err != nil {
			return err
		}
		d.Value = value
	}
	d.Value = strconv.Itoa(value)
	return nil
}

func main() {
	if err := loadFile("../IFSC.json", &ifsc); err != nil {
		fmt.Println("there is some error in IFSC.json file: ", err)
	}
	if err := loadFile("../sublet.json", &sublet); err != nil {
		fmt.Println("there is some error in sublet.json file: ", err)
	}
	if err := loadFile("../custom-sublets.json", &customSublets); err != nil {
		fmt.Println("there is some error in custom-sublets.json file: ", err)
	}
	if err := loadFile("../banknames.json", &bankNames); err != nil {
		fmt.Println("there is some error in banknames.json file: ", err)
	}
}

func loadFile(fileName string, result interface{}) error {
	basePath, err := os.Getwd()
	if err != nil {
		return err
	}
	completePath := fmt.Sprintf("%s/%s", basePath, fileName)
	bytes, err := ioutil.ReadFile(completePath)
	if err != nil {
		return err
	}
	if err := json.Unmarshal(bytes, &result); err != nil {
		return err
	}
	return nil
}
