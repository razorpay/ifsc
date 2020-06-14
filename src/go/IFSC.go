package ifsc

import (
	"encoding/json"
	"errors"
	"fmt"
	"io/ioutil"
	"path"
	"runtime"
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
		return nil
	}
	d.Value = strconv.Itoa(value)
	return nil
}

func Init() {
	LoadBankData()
	if ifsc == nil {
		if err := LoadFile("IFSC.json", &ifsc); err != nil {
			fmt.Println("there is some error in IFSC.json file: ", err)
		}
	}
	if sublet == nil {
		if err := LoadFile("sublet.json", &sublet); err != nil {
			fmt.Println("there is some error in sublet.json file: ", err)
		}
	}
	if customSublets == nil {
		if err := LoadFile("custom-sublets.json", &customSublets); err != nil {
			fmt.Println("there is some error in custom-sublets.json file: ", err)
		}
	}
	if bankNames == nil {
		if err := LoadFile("banknames.json", &bankNames); err != nil {
			fmt.Println("there is some error in banknames.json file: ", err)
		}
	}
}

func LoadFile(fileName string, result interface{}) error {
	_, fileN, _, ok := runtime.Caller(0)
	if !ok{
		return errors.New("it was not possible to recover the information. Caller function error")
	}
	dir, _:= path.Split(fileN)
	jsonDir := path.Join(dir, "..")
	completePath := path.Join( jsonDir, fileName)
	bytes, err := ioutil.ReadFile(completePath)
	if err != nil {
		return err
	}
	if err := json.Unmarshal(bytes, &result); err != nil {
		return err
	}
	return nil
}
func validateBankCode(code string) bool {
	return true
}
func GetBankName(code string) string {
	return "true"
}
