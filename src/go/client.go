package ifsc

import (
	"encoding/json"
	"errors"
	"io/ioutil"
	"net/http"
)

const API_BASE = "https://ifsc.razorpay.com"

type IFSCResponse struct {
	Bank     string `json:"BANK"`
	Branch   string `json:"BRANCH"`
	Address  string `json:"ADDRESS"`
	Contact  string `json:"CONTACT"`
	City     string `json:"CITY"`
	District string `json:"DISTRICT"`
	State    string `json:"STATE"`
	BankCode string
}

// LookUP fetches the response from ifsc api for
func LookUP(ifsc string) (*IFSCResponse, error) {
	var respStruct *IFSCResponse
	resp, err := http.Get(API_BASE + "/" + ifsc)
	if err != nil {
		return nil, err
	}
	status := resp.StatusCode
	if status == http.StatusOK {
		respBytes, err := ioutil.ReadAll(resp.Body)
		if err != nil {
			return nil, err
		}
		err = json.Unmarshal(respBytes, &respStruct)
		if err != nil {
			return nil, err
		}
		respStruct.setBankCode()

	} else if status == http.StatusNotFound {
		return nil, errors.New("InvalidCode")
	} else {
		return nil, errors.New("IFSC API returned invalid response")
	}

	return respStruct, nil
}

func (ifsc *IFSCResponse) setBankCode() {
	if ifsc.BankCode == "" {
		ifsc.BankCode = ifsc.GetBankCode()
	}
}

func (ifsc *IFSCResponse) GetBankCode() string {
	return ifsc.BankCode[0:4]
}

func (ifsc *IFSCResponse) GetBankName() string {
	bankName, err := GetBankName(ifsc.GetBankCode())
	if err != nil {
		return ""
	}
	return bankName
}
