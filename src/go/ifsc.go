package ifsc

import (
	"encoding/json"
	"errors"
	"fmt"
	"io/ioutil"
	"log"
	"path"
	"runtime"
	"strconv"
	"strings"
)

var ifscMap map[string][]Data
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

func init() {
	LoadBankData()
	if ifscMap == nil {
		if err := LoadFile("IFSC.json", &ifscMap, ""); err != nil {
			log.Panic(fmt.Sprintf("there is some error in IFSC.json file: %v", err))
		}
	}
	if sublet == nil {
		if err := LoadFile("sublet.json", &sublet, ""); err != nil {
			log.Panic(fmt.Sprintf("there is some error in sublet.json file: %v", err))
		}
	}
	if customSublets == nil {
		if err := LoadFile("custom-sublets.json", &customSublets, ""); err != nil {
			log.Panic(fmt.Sprintf("there is some error in  custom-sublets.json file: %v", err))
		}
	}
	if bankNames == nil {
		if err := LoadFile("banknames.json", &bankNames, ""); err != nil {
			log.Panic(fmt.Sprintf("there is some error in banknames.json file: %v", err))
		}
	}
}

func LoadFile(fileName string, result interface{}, fullDirPath string) error {
	_, fileN, _, ok := runtime.Caller(0)
	if !ok {
		return errors.New("it was not possible to recover the information. Caller function error")
	}
	dir, _ := path.Split(fileN)
	jsonDir := path.Join(dir, "..")
	var completePath string
	if fullDirPath != "" {
		completePath = path.Join(fullDirPath, fileName)
	} else {
		completePath = path.Join(jsonDir, fileName)

	}
	bytes, err := ioutil.ReadFile(completePath)
	if err != nil {
		return err
	}
	if err := json.Unmarshal(bytes, &result); err != nil {
		return err
	}
	return nil
}

func Validate(code string) bool {
	if len(code) != 11 || string(code[4]) != "0" {
		return false
	}
	bankCode := strings.ToUpper(code[0:4])
	branchCode := strings.ToUpper(code[5:])
	list, ok := ifscMap[bankCode]
	if !ok {
		return false
	}
	branchData, err := getData(branchCode)
	if err != nil {
		return false
	}
	for _, data := range list {
		if data == *branchData {
			return true
		}
	}
	return false
}

func getData(input string) (*Data, error) {
	var inputBytes []byte
	var err error
	intValue, err := strconv.ParseInt(input, 10, 32)
	if err == nil {
		input = strconv.Itoa(int(intValue))
	}
	if inputBytes, err = json.Marshal(input); err != nil {
		return nil, err
	}
	var output Data
	if err := json.Unmarshal(inputBytes, &output); err != nil {
		return nil, err
	}
	return &output, nil
}

func GetBankName(code string) (string, error) {
	bankName, ok := bankNames[code]
	if !ok {
		if Validate(code) {
			bankCode, ok := sublet[code]
			if !ok {
				bankName, err := getCustomSubletName(code)
				if err != nil {
					bankName, _ := bankNames[code[0:4]]
					return bankName, nil
				} else {
					return bankName, nil
				}
			}
			return bankNames[bankCode], nil

		} else {
			return "", errors.New("invalid bank code")
		}
	}
	return bankName, nil
}
func getCustomSubletName(code string) (string, error) {
	for key, value := range customSublets {
		if len(code) >= len(key) && code[0:len(key)] == key {
			bankName, ok := bankNames[value]
			if !ok {
				return value, nil
			}
			return bankName, nil
		}
	}
	return "", errors.New("custom sublet name not found")
}

func ValidateBankCode(bankCodeInput string) bool {
	_, ok := bankCodes[bankCodeInput]
	return ok
}
