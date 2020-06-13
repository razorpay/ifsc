package ifsc

import (
	"encoding/json"
	"errors"
	"io/ioutil"
	"net/http"
)

const API_BASE = "https://ifsc.razorpay.com"

type IfscResponse struct {
	Bank     string `json:"BANK"`
	Branch   string `json:"BRANCH"`
	Address  string `json:"ADDRESS"`
	Contact  string `json:"CONTACT"`
	City     string `json:"CITY"`
	Ifsc     string `json:"IFSC"`
	District string `json:"DISTRICT"`
	State    string `json:"STATE"`
	BankCode string
}

// LookUP fetches the response from ifsc api for
func LookUP(ifsc string) (*IfscResponse, error) {
	var respStruct *IfscResponse

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
		//respStruct.SetBankCode()

	} else if status == http.StatusNotFound {
		return nil, errors.New("InvalidCode")
	} else {
		return nil, errors.New("IFSC API returned invalid response")
	}

	return respStruct, nil
}

//func ( ifsc * IfscResponse) SetBankCode(){
//
//}
//
//func (ifsc * IfscResponse) GetBankCode()string{
//
//}
//
//func (ifsc * IfscResponse) GetBankName()string{
//
//}
